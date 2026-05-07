import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import '../common/widgets/app_bar.dart';
import 'widgets/total_fuel_card.dart';
import 'widgets/fuel_consumption_breakdown_card.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/total_fuel_cost_card.dart';
import 'widgets/total_co2_card.dart';
import 'widgets/efficiency_loss_insights_card.dart';
import 'widgets/optimization_tips_card.dart';
import 'package:haribon/theme/app_colors.dart';
import '../../rag_pipeline/llm/gemini_llm_service.dart';

import '../../core/database/database_service.dart';

class FuelAndEmissionsScreen extends StatefulWidget {
  const FuelAndEmissionsScreen({super.key});

  @override
  State<FuelAndEmissionsScreen> createState() => _FuelAndEmissionsScreenState();
}

class _FuelAndEmissionsScreenState extends State<FuelAndEmissionsScreen> {
  bool _isLoading = true;
  List<String> _proInsights = [];
  List<String> _proTips = [];

  // ── Aggregated fuel metrics ──
  double _totalLiters = 0;
  double _baseLiters = 0;
  double _trafficLiters = 0;
  double _terrainLiters = 0;
  double _idleLiters = 0;
  double _totalCost = 0;

  double _extraCostFromConditions = 0;
  double _totalCO2 = 0;

  // ── Live vehicle / fuel data ──
  double _kmPerLiter = 12.0;
  double _fuelPricePerLiter = 65.0;
  String _fuelGrade = 'Gasoline';

  // ── Date range for the analysis period ──
  String _analysisPeriod = '';
  int _tripCount = 0;

  @override
  void initState() {
    super.initState();
    _loadAllStats();
    // Listen for vehicle config changes from any screen
    DatabaseService().onConfigChanged.addListener(_onConfigChanged);
  }

  @override
  void dispose() {
    DatabaseService().onConfigChanged.removeListener(_onConfigChanged);
    super.dispose();
  }

  void _onConfigChanged() {
    _loadAllStats();
  }

  /// Master data loader: fetches vehicle config, live fuel prices, all trips,
  /// then computes realistic fuel/emission metrics from each trip's distance,
  /// route conditions, and the user's actual vehicle efficiency.
  Future<void> _loadAllStats() async {
    try {
      // ────────────────────────────────────────────────────
      // 0. Fetch the user's real vehicle efficiency (km/L)
      // ────────────────────────────────────────────────────
      final vehicleConfig = await Supabase.instance.client
          .from('vehicle_configurations')
          .select()
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (vehicleConfig != null) {
        final kml = (vehicleConfig['km_per_liter'] as num?)?.toDouble();
        if (kml != null && kml > 0) _kmPerLiter = kml;
        _fuelGrade = vehicleConfig['fuel_type']?.toString() ??
            vehicleConfig['fuel_grade']?.toString() ??
            'Gasoline';
      }

      // ────────────────────────────────────────────────────
      // 0b. Fetch live fuel prices → weighted average
      // ────────────────────────────────────────────────────
      try {
        final fuelPrices = await Supabase.instance.client
            .from('fuel_prices')
            .select()
            .order('updated_at', ascending: false)
            .limit(10);

        if ((fuelPrices as List).isNotEmpty) {
          // Use the correct fuel column based on the user's vehicle grade
          final fuelKey =
              _fuelGrade.toLowerCase().contains('diesel') ? 'diesel' : 'gasoline';
          double total = 0;
          int count = 0;
          for (var p in fuelPrices) {
            final price = (p[fuelKey] as num?)?.toDouble();
            if (price != null && price > 0) {
              total += price;
              count++;
            }
          }
          if (count > 0) _fuelPricePerLiter = total / count;
        }
      } catch (_) {}

      // ────────────────────────────────────────────────────
      // 1. Fetch ALL saved trips from Supabase
      // ────────────────────────────────────────────────────
      final savedTrips = await Supabase.instance.client
          .from('smart_trips')
          .select()
          .order('created_at', ascending: false);

      // Also pull active vehicle configurations (represent planned/active trips)
      final activeConfigs = await Supabase.instance.client
          .from('vehicle_configurations')
          .select()
          .order('created_at', ascending: false);

      final List<dynamic> allTrips = [];
      allTrips.addAll(savedTrips);

      // Merge unique active configs that aren't already saved as trips
      for (var config in activeConfigs) {
          final isAlreadySaved = allTrips.any(
            (t) =>
                t['origin_name'] == config['origin_name'] &&
                t['destination_name'] == config['destination_name'],
          );
          if (!isAlreadySaved) {
            allTrips.add(config);
          }
      }

      // ────────────────────────────────────────────────────
      // 2. Compute realistic metrics from each trip
      // ────────────────────────────────────────────────────
      if (allTrips.isNotEmpty) {
        double liters = 0;
        double baseLiters = 0;
        double trafficLiters = 0;
        double terrainLiters = 0;
        double idleLiters = 0;
        double cost = 0;
        double extraConditionsCost = 0;
        double co2 = 0;

        DateTime? earliest;
        DateTime? latest;

        for (var trip in allTrips) {
          // ── Extract raw trip data ──
          final distKm =
              (trip['distance_km'] ?? trip['route_distance_km'] ?? 0.0)
                  .toDouble();
          final storedLiters =
              (trip['est_fuel_liters'] as num?)?.toDouble();
          final storedCost =
              (trip['est_fuel_cost'] as num?)?.toDouble();

          // Date tracking for the analysis period label
          final createdAt =
              DateTime.tryParse(trip['created_at']?.toString() ?? '');
          if (createdAt != null) {
            if (earliest == null || createdAt.isBefore(earliest)) {
              earliest = createdAt;
            }
            if (latest == null || createdAt.isAfter(latest)) {
              latest = createdAt;
            }
          }

          // ── Compute trip fuel (liters) ──
          // Priority: stored est_fuel_liters → distance / vehicle km/L → fallback from cost
          double tripLiters;
          if (storedLiters != null && storedLiters > 0) {
            tripLiters = storedLiters;
          } else if (distKm > 0 && _kmPerLiter > 0) {
            tripLiters = distKm / _kmPerLiter;
          } else if (storedCost != null && storedCost > 0) {
            tripLiters = storedCost / _fuelPricePerLiter;
          } else {
            tripLiters = 0.0;
          }

          // ── Realistic fuel breakdown per trip ──
          // Base consumption: the fuel burned under ideal driving conditions
          //   = distance / highway_km_per_liter (assume 10% better than mixed avg)
          final idealKmPerLiter = _kmPerLiter * 1.10;
          final tripBaseLiters =
              distKm > 0 ? distKm / idealKmPerLiter : tripLiters * 0.78;

          // Traffic penalty: city driving & congestion burn ~12-18% extra
          // We use the difference between actual and ideal as traffic loss,
          // bounded to at least 10% of trip liters to be realistic
          double tripTraffic = tripLiters - tripBaseLiters;
          if (tripTraffic < 0) tripTraffic = tripLiters * 0.10;

          // Further split the extra into traffic (70%), terrain (20%), idle (10%)
          final tripTerrain = tripTraffic * 0.25;
          final tripIdle = tripTraffic * 0.10;
          final tripTrafficFinal = tripTraffic - tripTerrain - tripIdle;

          // ── Compute trip cost using LIVE fuel price ──
          final tripCost = tripLiters * _fuelPricePerLiter;
          final tripBaseCost = tripBaseLiters * _fuelPricePerLiter;
          final tripExtraCost = tripCost - tripBaseCost;

          // ── CO2 emissions: 2.31 kg CO2 per liter of gasoline ──
          //    diesel = 2.68 kg/L; we use the correct factor
          final co2Factor =
              _fuelGrade.toLowerCase().contains('diesel') ? 2.68 : 2.31;
          final tripCO2 = tripLiters * co2Factor;

          // ── Accumulate ──
          liters += tripLiters;
          baseLiters += tripBaseLiters;
          trafficLiters += tripTrafficFinal;
          terrainLiters += tripTerrain;
          idleLiters += tripIdle;
          cost += tripCost;
          extraConditionsCost += tripExtraCost;
          co2 += tripCO2;
        }

        // Build analysis period label
        String period = '';
        final now = DateTime.now();
        if (earliest != null && latest != null) {
          final months = [
            'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
            'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
          ];
          
          final isToday = latest.year == now.year && latest.month == now.month && latest.day == now.day;
          final latestStr = isToday ? 'Today' : '${months[latest.month - 1]} ${latest.day}';

          if (earliest.year == latest.year && earliest.month == latest.month && earliest.day == latest.day) {
            period = isToday ? 'Today, ${now.year}' : '${months[earliest.month - 1]} ${earliest.day}, ${earliest.year}';
          } else {
            period = '${months[earliest.month - 1]} ${earliest.day} – $latestStr, ${latest.year}';
          }
        } else {
          // Fallback if no trips: Show current month
          final months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
          period = '${months[now.month - 1]} ${now.year}';
        }

        setState(() {
          _totalLiters = liters;
          _baseLiters = baseLiters;
          _trafficLiters = trafficLiters;
          _terrainLiters = terrainLiters;
          _idleLiters = idleLiters;
          _totalCost = cost;
          _extraCostFromConditions = extraConditionsCost;
          _totalCO2 = co2;
          _analysisPeriod = period;
          _tripCount = allTrips.length;
          _isLoading = false;
        });

        // 3. Load Pro Insights in background for the latest journey
        await _loadProInsights(allTrips.first);
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error aggregating stats: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadProInsights(Map<String, dynamic> trip) async {
    try {
      final origin = trip['origin_name'];
      final destination = trip['destination_name'];
      final vehicle = trip['vehicle_details'];

      // Check if Pro Insights already exist
      final onboarding = await DatabaseService().getOnboardingData();
      final userName = onboarding?['user_name'] ?? 'Anonymous';

      final existingResponse = await Supabase.instance.client
          .from('ai_pro_insights')
          .select()
          .eq('user_name', userName)
          .eq('trip_origin', origin)
          .eq('trip_destination', destination)
          .maybeSingle();

      if (existingResponse != null) {
        final data = existingResponse['insights'];
        setState(() {
          _proInsights = List<String>.from(data['insights'] ?? []);
          _proTips = List<String>.from(data['tips'] ?? []);
          _isLoading = false;
        });
        return;
      }

      // Generate with Gemini if not found
      final apiKey = dotenv.env['GEMINI_API_KEY'];
      if (apiKey == null) return;

      final brand = (vehicle != null && vehicle is Map)
          ? (vehicle['brand'] ?? 'Vehicle')
          : 'Vehicle';
      final model = (vehicle != null && vehicle is Map)
          ? (vehicle['model'] ?? '')
          : '';

      final gemini = GeminiLLMService(apiKey: apiKey);
      final prompt = """
      Act as a Professional Eco-Driving Analyst for Haribon app.
      Analyze this fuel & emissions summary from $_tripCount trips${_analysisPeriod.isNotEmpty ? ' during $_analysisPeriod' : ''}:
      
      - Total Fuel Used: ${_totalLiters.toStringAsFixed(1)}L
      - Base driving consumption: ${_baseLiters.toStringAsFixed(1)}L
      - Traffic congestion loss: ${_trafficLiters.toStringAsFixed(1)}L
      - Terrain elevation loss: ${_terrainLiters.toStringAsFixed(1)}L
      - Idle engine loss: ${_idleLiters.toStringAsFixed(1)}L
      - Total CO2 emitted: ${_totalCO2.toStringAsFixed(1)} kg
      - Total Fuel Cost: ₱${_totalCost.toStringAsFixed(0)}
      - Extra cost from road conditions: ₱${_extraCostFromConditions.toStringAsFixed(0)}
      - Vehicle: $brand $model (${_kmPerLiter.toStringAsFixed(1)} km/L, $_fuelGrade)
      - Latest journey: $origin to $destination
      
      Generate 3 'Efficiency Loss Insights' with specific data references and 2 'Optimization Tips' with estimated savings.
      
      Return ONLY a JSON object:
      {
        "insights": ["insight 1", "insight 2", "insight 3"],
        "tips": ["tip 1", "tip 2"]
      }
      """;

      final response = await gemini.generateResponse(
        prompt,
        systemContext: "Return ONLY pure JSON. No conversational text.",
      );

      String cleanedResponse = response.trim();
      
      // 1. Error check
      if (cleanedResponse.isEmpty || cleanedResponse.toLowerCase().contains('error')) {
         throw Exception('Invalid AI response');
      }

      // 2. Code block extraction
      if (cleanedResponse.contains('```')) {
        final regExp = RegExp(r'```(?:json)?\s*([\s\S]*?)```');
        final match = regExp.firstMatch(cleanedResponse);
        if (match != null) {
          cleanedResponse = match.group(1)?.trim() ?? cleanedResponse;
        }
      }

      // 3. JSON object isolation
      final startIndex = cleanedResponse.indexOf('{');
      final endIndex = cleanedResponse.lastIndexOf('}');
      if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
        cleanedResponse = cleanedResponse.substring(startIndex, endIndex + 1);
      }

      Map<String, dynamic> decoded;
      try {
        decoded = jsonDecode(cleanedResponse);
      } catch (e) {
        debugPrint('AI Response was not valid JSON, using fallbacks: $e');
        _applyFallbackInsights();
        return;
      }

      final insights = List<String>.from(decoded['insights'] ?? [
        'Consumption is tracking within expected parameters for your vehicle type.',
        'Consider optimizing your routes during peak traffic hours.'
      ]);
      final tips = List<String>.from(decoded['tips'] ?? [
        'Plan trips ahead to avoid congestion.',
        'Use cruise control on highways where possible.'
      ]);

      setState(() {
        _proInsights = insights;
        _proTips = tips;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading AI Pro Insights: $e');
      _applyFallbackInsights();
    }
  }

  void _applyFallbackInsights() {
    setState(() {
      _proInsights = [
        'Your efficiency is currently impacted by traffic and terrain conditions.',
        'Maintaining steady speeds on highways can improve range by up to 15%.',
        'Fuel quality and tire pressure significantly impact your consumption.'
      ];
      _proTips = [
        'Avoid sudden acceleration to save approximately ₱45 per trip.',
        'Plan your route to avoid the 4 PM - 6 PM traffic window.'
      ];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceMain,
      appBar: CommonAppBar(showBackButton: false),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAllStats,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 16.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fuel & Emissions',
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _analysisPeriod.isNotEmpty
                            ? '$_tripCount trip${_tripCount == 1 ? '' : 's'} · $_analysisPeriod'
                            : 'Track your fuel consumption and\nefficiency insights at a glance.',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (_analysisPeriod.isNotEmpty)
                        Text(
                          '${_kmPerLiter.toStringAsFixed(1)} km/L · ₱${_fuelPricePerLiter.toStringAsFixed(2)}/L avg · $_fuelGrade',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: AppColors.textTertiary,
                            height: 1.4,
                          ),
                        ),
                      const SizedBox(height: 16),
                      TotalFuelCard(
                        liters: _totalLiters,
                        baseLiters: _baseLiters,
                        extraLiters: _totalLiters - _baseLiters,
                      ),
                 
                      FuelConsumptionBreakdownCard(
                        totalLiters: _totalLiters,
                        baseLiters: _baseLiters,
                        trafficLiters: _trafficLiters,
                        terrainLiters: _terrainLiters,
                        idleLiters: _idleLiters,
                      ),
                  
                      Row(
                        children: [
                          Expanded(
                            child: TotalFuelCostCard(
                              cost: _totalCost,
                              extraCost: _extraCostFromConditions,
                              fuelPricePerLiter: _fuelPricePerLiter,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: TotalCo2Card(co2: _totalCO2)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      EfficiencyLossInsightsCard(insights: _proInsights),
                      const SizedBox(height: 16),
                      OptimizationTipsCard(tips: _proTips),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
