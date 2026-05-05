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
      // 1. Fetch Latest Vehicle & Route Config
      final configResponse = await Supabase.instance.client
          .from('vehicle_configurations')
          .select()
          .order('created_at', ascending: false)
          .limit(1);

      // 2. Fetch Latest Smart Trip
      final tripResponse = await Supabase.instance.client
          .from('smart_trips')
          .select()
          .order('created_at', ascending: false)
          .limit(1);

      // 3. Get Onboarding Data as a final fallback
      final onboarding = await DatabaseService().getOnboardingData();

      Map<String, dynamic>? config;
      if (configResponse != null && (configResponse as List).isNotEmpty) {
        config = configResponse.first;
      } else if (onboarding != null) {
        // Create a virtual config from onboarding
        config = {
          'brand': onboarding['vehicle_brand'] ?? 'Toyota',
          'model': onboarding['vehicle_model'] ?? 'Rush',
          'origin_name': 'Pampanga',
          'destination_name': 'Baguio City',
          'route_distance_km': 248.0,
          'budget': 2500.0,
          'created_at': DateTime.now().toIso8601String(),
        };
      }

      if (config != null) {
        final trip = (tripResponse != null && (tripResponse as List).isNotEmpty) 
            ? tripResponse.first 
            : null;

        final distance = (config['route_distance_km'] ?? 0.0).toDouble();
        final budget = (config['budget'] ?? 2500.0).toDouble();
        final fuelCost = trip != null ? (trip['est_fuel_cost'] ?? 0.0).toDouble() : (distance * 0.08 * 65.0);
        final tollFee = trip != null ? (trip['toll_fee'] ?? 0.0).toDouble() : 0.0;
        
        final totalEst = fuelCost + tollFee;
        final costRatio = budget > 0 ? (totalEst / budget) : 1.0;
        final score = ((1.0 - costRatio.clamp(0, 1)) * 100).toInt().clamp(60, 98);
        
        final liters = fuelCost > 0 ? (fuelCost / 68.0) : 0.0;
        final co2 = liters * 2.31; 

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
            liters: double.tryParse(s['subtitle']?.split(' ')[1] ?? '0') ?? 0.0,
            pricePerLiter: 65.0,
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
          title: config['origin_name'] ?? 'Pampanga',
          description: 'Trip started with ${_summary?.stats.fuelLiters ?? 15}L fuel.',
        ));

        // Refueling Stops
        for (var i = 0; i < fuelStops.length; i++) {
          final stop = fuelStops[i];
          final eta = startTime.add(Duration(minutes: (distance / (fuelStops.length + 1) * (i + 1) / 65 * 60).toInt()));
          timeline.add(TimelineStop(
            type: TimelineStopType.refuel,
            time: DateFormat('hh:mm a').format(eta),
            title: stop.stationName,
            description: 'Recommended: Fill ${stop.liters}L ${config['fuel_grade'] ?? 'Gasoline'}.',
            buttonText: 'LOG FUEL',
          ));
        }

        // Arrival
        final arrivalTime = startTime.add(Duration(minutes: (distance / 65 * 60).toInt()));
        timeline.add(TimelineStop(
          type: TimelineStopType.arrival,
          time: DateFormat('hh:mm a').format(arrivalTime),
          title: config['destination_name'] ?? 'Baguio City',
          description: 'Expected Arrival at $distance km mark.',
        ));

        setState(() {
          _timelineStops = timeline;
          _summary = TripSummary(
            origin: config!['origin_name'] ?? 'Pampanga',
            destination: config!['destination_name'] ?? 'Baguio City',
            date: DateFormat('MMM d, yyyy').format(DateTime.parse(config!['created_at'])),
            duration: Duration(minutes: (distance / 60 * 60).toInt()),
            distanceKm: distance,
            efficiencyScore: score,
            efficiencyRating: score > 85 ? 'Excellent' : 'Good',
            efficiencyPercentile: 'Top ${100 - score}% of users',
            stats: TripStats(
              fuelLiters: double.parse(liters.toStringAsFixed(1)),
              fuelCostPhp: fuelCost,
              avgSpeedKmh: 65,
              co2SavedKg: double.parse((co2 * 0.1).toStringAsFixed(1)),
              costVsEstimatePhp: fuelCost - budget,
            ),
            fuelStops: fuelStops,
            aiInsight: mainInsight,
            routeSegments: [
              RouteSegment(label: 'Expressways', duration: const Duration(hours: 2), fraction: 0.6, color: SummaryColors.primary),
              RouteSegment(label: 'City Roads', duration: const Duration(hours: 1), fraction: 0.4, color: SummaryColors.amber),
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
        appBar: const CommonAppBar(title: 'Trip Summary'),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.route_outlined, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('No trip plan found yet.', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: widget.onPlanNext ?? () => Navigator.pop(context),
                child: const Text('Plan a Trip'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: CommonAppBar(
        title: _currentIndex == 0 ? 'Trip Summary' : 'Timeline',
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
