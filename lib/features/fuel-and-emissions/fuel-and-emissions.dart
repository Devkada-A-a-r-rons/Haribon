import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import '../common/widgets/app_bar.dart';
import 'widgets/total_fuel_card.dart';
import 'widgets/fuel_consumption_breakdown_card.dart';
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
  double _totalLiters = 0;
  double _totalCost = 0;
  double _totalCO2 = 0;
  double _trafficLiters = 0;

  @override
  void initState() {
    super.initState();
    _loadAllStats();
  }

  Future<void> _loadAllStats() async {
    try {
      // 1. Fetch official saved trips
      final savedTrips = await Supabase.instance.client
          .from('smart_trips')
          .select();

      // 2. Fetch active configurations (the "Active Plans")
      final activeConfigs = await Supabase.instance.client
          .from('vehicle_configurations')
          .select();

      final List<dynamic> allTrips = [];
      if (savedTrips != null) allTrips.addAll(savedTrips);
      
      // Add unique active configs that aren't saved yet
      if (activeConfigs != null) {
        for (var config in activeConfigs) {
          final isAlreadySaved = allTrips.any((t) => 
            t['origin_name'] == config['origin_name'] && 
            t['destination_name'] == config['destination_name']
          );
          if (!isAlreadySaved) {
            allTrips.add(config);
          }
        }
      }

      if (allTrips.isNotEmpty) {
        double liters = 0;
        double cost = 0;
        double co2 = 0;
        double traffic = 0;

        for (var trip in allTrips) {
          final tripCost = (trip['est_fuel_cost'] ?? trip['budget'] ?? 0.0).toDouble();
          final tripLiters = tripCost > 0 ? (tripCost / 68.0) : 0.0;
          liters += tripLiters;
          cost += tripCost;
          co2 += tripLiters * 2.3;
          traffic += tripLiters * 0.15;
        }

        setState(() {
          _totalLiters = liters;
          _totalCost = cost;
          _totalCO2 = co2;
          _trafficLiters = traffic;
        });

        // 3. Load Pro Insights for the latest journey
        await _loadProInsights(allTrips.last);
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
          _proInsights = List<String>.from(data['insights']);
          _proTips = List<String>.from(data['tips']);
          _isLoading = false;
        });
        return;
      }

      // Generate with Gemini if not found
      final apiKey = dotenv.env['GEMINI_API_KEY'];
      if (apiKey == null) return;

      final brand = (vehicle != null && vehicle is Map) ? (vehicle['brand'] ?? 'Vehicle') : 'Vehicle';
      final model = (vehicle != null && vehicle is Map) ? (vehicle['model'] ?? '') : '';

      final gemini = GeminiLLMService(apiKey: apiKey);
      final prompt = """
      Act as a Professional Eco-Driving Analyst for Haribon app.
      Analyze this history summary: Total ${_totalLiters.toStringAsFixed(1)}L used over multiple trips.
      Latest journey: $origin to $destination in a $brand $model.
      
      Generate 3 'Efficiency Loss Insights' (focus on traffic loss of ${_trafficLiters.toStringAsFixed(1)}L) 
      and 2 'Optimization Tips' for this user.
      
      Return as a JSON object:
      {
        "insights": ["insight 1", "insight 2", "insight 3"],
        "tips": ["tip 1", "tip 2"]
      }
      """;

      final response = await gemini.generateResponse(prompt, systemContext: "Return ONLY pure JSON.");
      final cleanedResponse = response.replaceAll('```json', '').replaceAll('```', '').trim();
      final decoded = jsonDecode(cleanedResponse);

      final insights = List<String>.from(decoded['insights']);
      final tips = List<String>.from(decoded['tips']);

      setState(() {
        _proInsights = insights;
        _proTips = tips;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading AI Pro Insights: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyLightest,
      appBar: CommonAppBar(
        title: 'Fuel & Emissions',
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, color: AppColors.navyDarker),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                children: [
                  TotalFuelCard(liters: _totalLiters),
                  const SizedBox(height: 16),
                  FuelConsumptionBreakdownCard(
                    totalLiters: _totalLiters,
                    trafficLiters: _trafficLiters,
                  ),
                  const SizedBox(height: 16),
                  TotalFuelCostCard(cost: _totalCost),
                  const SizedBox(height: 16),
                  TotalCo2Card(co2: _totalCO2),
                  const SizedBox(height: 16),
                  if (_proInsights.isNotEmpty)
                    EfficiencyLossInsightsCard(insights: _proInsights),
                  const SizedBox(height: 16),
                  if (_proTips.isNotEmpty)
                    OptimizationTipsCard(tips: _proTips),
                  const SizedBox(height: 40), 
                ],
              ),
            ),
          ),
    );
  }
}
