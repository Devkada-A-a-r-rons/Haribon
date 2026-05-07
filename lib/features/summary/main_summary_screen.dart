import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../common/widgets/app_bar.dart';
import '../timeline/timeline_screen.dart';
import 'trip_summary_screen.dart';
import 'models/trip_summary_model.dart';
import 'widgets/summary_header.dart';
import '../../core/database/database_service.dart';
import 'package:haribon/theme/app_colors.dart';
import 'package:intl/intl.dart';
import '../timeline/models/timeline_stop.dart';
import '../../rag_pipeline/llm/gemini_llm_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

class MainSummaryScreen extends StatefulWidget {
  final VoidCallback? onPlanNext;
  final VoidCallback? onViewAnalysis;
  const MainSummaryScreen({super.key, this.onPlanNext, this.onViewAnalysis});

  @override
  State<MainSummaryScreen> createState() => _MainSummaryScreenState();
}

class _MainSummaryScreenState extends State<MainSummaryScreen> {
  TripSummary? _summary;
  List<TimelineStop> _timelineStops = [];
  String? _timelineAiInsight;
  int _currentIndex = 0;
  bool _isLoading = true;
  final ScrollController _summaryScrollController = ScrollController();
  final ScrollController _timelineScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchLatestTripSummary();
  }

  Future<void> _fetchLatestTripSummary() async {
    setState(() => _isLoading = true);
    try {
      // 1. Fetch Active Vehicle & Route Config
      final activeResponse = await Supabase.instance.client
          .from('vehicle_configurations')
          .select()
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      // 2. Fetch Latest Smart Trip
      final tripResponse = await Supabase.instance.client
          .from('smart_trips')
          .select()
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      // 3. Fetch latest fuel prices for accurate average
      double avgFuelPrice = 65.0;
      try {
        final fuelPrices = await Supabase.instance.client
            .from('fuel_prices')
            .select()
            .order('updated_at', ascending: false)
            .limit(10);
        if ((fuelPrices as List).isNotEmpty) {
          final fuelGrade = (activeResponse?['fuel_type'] ?? 'gasoline').toString().toLowerCase();
          final fuelKey = fuelGrade.contains('diesel') ? 'diesel' : 'gasoline';
          
          double total = 0;
          int count = 0;
          for (var p in fuelPrices) {
            final price = (p[fuelKey] as num?)?.toDouble();
            if (price != null && price > 0) {
              total += price;
              count++;
            }
          }
          if (count > 0) avgFuelPrice = total / count;
        }
      } catch (_) {}

      final config = activeResponse;
      if (config != null) {
        final trip = tripResponse;

        final distance = (config['route_distance_km'] ?? 0.0).toDouble();
        final budget = (config['budget'] ?? 2500.0).toDouble();
        final kmPerLiter = (config['km_per_liter'] as num?)?.toDouble() ?? 12.0;
        final co2Factor = (config['fuel_type']?.toString().toLowerCase().contains('diesel') ?? false) ? 2.68 : 2.31;

        // ACCURATE COMPUTATION
        final totalLiters = distance / kmPerLiter;
        final fuelCost = totalLiters * avgFuelPrice;
        final tollFee = (trip != null ? (trip['toll_fee'] ?? 0.0) : (config['toll_fee'] ?? 0.0)).toDouble();
        
        final totalEst = fuelCost + tollFee;
        
        // Efficiency Score based on Budget
        double score;
        if (budget > 0) {
          final deviation = (totalEst - budget) / budget;
          // If totalEst is exactly budget, score is 90. 
          // If 50% under budget, score is 100.
          // If 50% over budget, score drops.
          score = (90 - (deviation * 40)).toDouble().clamp(40.0, 99.0);
        } else {
          score = 85.0;
        }
        
        final co2 = totalLiters * co2Factor; 

        final insights = trip != null ? trip['ai_insights'] as List? : [];
        final mainInsight = insights != null && insights.isNotEmpty 
            ? insights.first.toString() 
            : 'Optimizing your ${config['brand']} ${config['model']} for $distance km.';

        final stopsData = trip != null ? trip['refueling_plan'] as List? : [];
        final fuelStops = stopsData?.map((s) {
          final isStation = s['icon'] == Icons.local_gas_station.codePoint;
          return FuelStop(
            stationName: s['title'] ?? 'Station',
            brand: isStation ? 'Gas Station' : 'Point',
            liters: double.tryParse(s['subtitle']?.split(' ')[1] ?? '0') ?? (totalLiters / 2),
            pricePerLiter: avgFuelPrice,
            brandColor: s['color'] != null ? Color(s['color']) : AppColors.tealPrimary,
          );
        }).where((s) => s.brand == 'Gas Station').toList() ?? [];

        // 4. Generate Timeline Stops with ETAs
        final startTime = DateTime.parse(config['created_at']);
        final List<TimelineStop> timeline = [];
        
        // Departure
        timeline.add(TimelineStop(
          type: TimelineStopType.departure,
          time: DateFormat('hh:mm a').format(startTime),
          title: config['origin_name'] ?? 'Origin',
          description: 'Trip started with estimated ${totalLiters.toStringAsFixed(1)}L fuel requirement.',
        ));

        // Refueling Stops
        for (var i = 0; i < fuelStops.length; i++) {
          final stop = fuelStops[i];
          final eta = startTime.add(Duration(minutes: (distance / (fuelStops.length + 1) * (i + 1) / 60 * 60).toInt()));
          timeline.add(TimelineStop(
            type: TimelineStopType.refuel,
            time: DateFormat('hh:mm a').format(eta),
            title: stop.stationName,
            description: 'Recommended: Fill ${stop.liters.toStringAsFixed(1)}L ${config['fuel_type'] ?? 'Gasoline'}.',
            buttonText: 'LOG FUEL',
          ));
        }

        // Arrival
        final arrivalTime = startTime.add(Duration(minutes: (distance / 60 * 60).toInt()));
        timeline.add(TimelineStop(
          type: TimelineStopType.arrival,
          time: DateFormat('hh:mm a').format(arrivalTime),
          title: config['destination_name'] ?? 'Destination',
          description: 'Arrival at ${distance.toStringAsFixed(0)} km mark.',
        ));

        setState(() {
          _timelineStops = timeline;
          _summary = TripSummary(
            origin: config['origin_name'] ?? 'Origin',
            destination: config['destination_name'] ?? 'Destination',
            date: DateFormat('MMM d, yyyy').format(DateTime.parse(config['created_at'])),
            duration: Duration(minutes: (distance / 60 * 60).toInt()),
            distanceKm: distance,
            efficiencyScore: score.toInt(),
            efficiencyRating: score > 85 ? 'Excellent' : 'Good',
            efficiencyPercentile: 'Top ${100 - score.toInt()}% of users',
            stats: TripStats(
              fuelLiters: totalLiters,
              fuelCostPhp: fuelCost,
              avgSpeedKmh: 65,
              co2SavedKg: co2,
              costVsEstimatePhp: totalEst - budget,
            ),
            fuelStops: fuelStops,
            aiInsight: mainInsight,
            routeSegments: [
              RouteSegment(label: 'Expressways', duration: const Duration(hours: 2), fraction: 0.7, color: SummaryColors.primary),
              RouteSegment(label: 'Local Roads', duration: const Duration(hours: 1), fraction: 0.3, color: SummaryColors.amber),
            ],
            treesEquivalent: (co2 / 20).ceil(),
          );
          _isLoading = false;
        });

        // 5. Generate Timeline AI Insight in background
        _generateTimelineAiInsight(config, distance);
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error fetching summary: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _generateTimelineAiInsight(Map<String, dynamic> config, double distance) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null) return;

    try {
      final gemini = GeminiLLMService(apiKey: apiKey);
      final prompt = """
      Generate a single, premium travel insight for a trip timeline.
      Route: ${config['origin_name']} to ${config['destination_name']} ($distance km).
      Vehicle: ${config['brand']} ${config['model']}.
      Focus on driving tips, traffic, or fuel management for this specific route.
      Keep it under 35 words.
      """;
      
      final insight = await gemini.generateResponse(prompt, systemContext: "You are a professional travel dispatcher for Haribon app.");
      if (mounted) {
        setState(() => _timelineAiInsight = insight.trim());
      }
    } catch (e) {
      debugPrint('Timeline AI Error: $e');
    }
  }

  Future<void> _handleBudgetUpdate(double newBudget) async {
    try {
      final configResponse = await Supabase.instance.client
          .from('vehicle_configurations')
          .select()
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (configResponse != null) {
        await Supabase.instance.client
            .from('vehicle_configurations')
            .update({'budget': newBudget})
            .eq('id', configResponse['id']);
        
        // Refresh summary to show new "vs. Estimate" and Score
        _fetchLatestTripSummary();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Budget updated to \u20B1${newBudget.toStringAsFixed(0)}'),
              backgroundColor: AppColors.tealPrimary,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error updating budget: $e');
    }
  }

  void _switchToTimeline() => setState(() => _currentIndex = 1);
  void _switchToSummary() => setState(() => _currentIndex = 0);

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.tealPrimary)),
      );
    }

    if (_summary == null) {
      return Scaffold(
        appBar: const CommonAppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.route_outlined, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('No trip plan found yet.', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: widget.onPlanNext ??
                    () => Navigator.pushReplacementNamed(
                          context,
                          '/home',
                          arguments: 1,
                        ),
                child: const Text('Plan a Trip'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: CommonAppBar(
        leading: _currentIndex == 1
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: _switchToSummary,
              )
            : null,
        actions: [
          if (_currentIndex == 0)
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () => _fetchLatestTripSummary(),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchLatestTripSummary,
        color: AppColors.tealPrimary,
        child: IndexedStack(
          index: _currentIndex,
          children: [
            TripSummaryScreen(
              summary: _summary!,
              onSeeTimeline: _switchToTimeline,
              onPlanNext: widget.onPlanNext,
              onViewAnalysis: widget.onViewAnalysis,
              scrollController: _summaryScrollController,
              onUpdateBudget: _handleBudgetUpdate,
            ),
            TimelineScreen(
              onBack: _switchToSummary,
              scrollController: _timelineScrollController,
              stops: _timelineStops,
              aiInsight: _timelineAiInsight,
            ),
          ],
        ),
      ),
    );
  }
}
