import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../common/widgets/app_bar.dart';
import 'widgets/insight_card.dart';
import 'widgets/expandable_card.dart';
import 'widgets/refueling_planner_content.dart';
import 'widgets/expense_planner_content.dart';
import 'widgets/visual_breakdown_card.dart';
import 'widgets/bottom_action_card.dart';
import 'widgets/fuel_readiness_card.dart';
import 'package:haribon/theme/app_colors.dart';
import '../../core/database/database_service.dart';
import '../../core/services/toll_service.dart';
import '../../rag_pipeline/llm/gemini_llm_service.dart';
import 'models/smart_trip_planner_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


class SmartTripPlanner extends StatefulWidget {
  const SmartTripPlanner({super.key});

  @override
  State<SmartTripPlanner> createState() => _SmartTripPlannerState();
}

class _SmartTripPlannerState extends State<SmartTripPlanner> {
  int _selectedIndex = 1; // PLANNER
  
  // Dynamic Data
  double _budget = 2500.0;
  Map<String, dynamic>? _vehicleConfig;
  double _estFuelCost = 0.0;
  double _tollFee = 0.0;
  double _otherExpenses = 600.0; // Default for food/others
  double _fuelPricePerLiter = 65.0; // Added for computation breakdown
  bool _isLoading = true;
  
  List<String> _aiInsights = [
    'Analyzing your trip data...',
    'Fetching live fuel prices...',
    'Calculating toll fees...'
  ];
  
  String _destination = 'Baguio City';
  String _origin = 'Pampanga';
  double _distanceKm = 0.0;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // 1. Fetch the latest vehicle and route configuration from Supabase
      // Using 'vehicle_configurations' (plural) to match VehicleIntelligenceScreen
      final remoteResponse = await Supabase.instance.client
          .from('vehicle_configurations')
          .select()
          .order('created_at', ascending: false) // Using created_at for reliable sorting
          .limit(1);

      Map<String, dynamic>? latestConfig;

      if (remoteResponse != null && (remoteResponse as List).isNotEmpty) {
        final data = remoteResponse.first;
        latestConfig = {
          'brand': data['brand'],
          'model': data['model'],
          'origin_name': data['origin_name'], 
          'destination_name': data['destination_name'],
          'route_distance_km': (data['route_distance_km'] ?? 0.0).toDouble(),
          'tank_size_liters': (data['tank_size_liters'] ?? 42.0).toDouble(),
          'km_per_liter': (data['km_per_liter'] ?? 12.0).toDouble(),
          'fuel_grade': data['fuel_type'] ?? 'Gasoline',
          'budget': (data['budget'] ?? 2500.0).toDouble(),
        };
      }

      if (latestConfig != null) {
        setState(() {
          _vehicleConfig = latestConfig;
          _distanceKm = latestConfig!['route_distance_km'];
          // Use a more descriptive default if null, though it should be set
          _origin = latestConfig!['origin_name'] ?? 'Pampanga';
          _destination = latestConfig!['destination_name'] ?? 'Baguio City';
          _budget = latestConfig!['budget'];
          
          // Re-calculate liters per km from km_per_liter
          double kml = (latestConfig!['km_per_liter'] as num).toDouble();
          if (kml > 0) {
            _vehicleConfig!['liters_per_km'] = 1.0 / kml;
          }
        });
      }

      // 2. Fetch Toll Fees (Dynamic based on route)
      String highway = 'NLEX';
      String entry = 'Balintawak';
      String exit = 'Sta. Ines';
      
      final dest = _destination.toLowerCase();
      if (dest.contains('baguio') || dest.contains('tarlac') || dest.contains('pampanga')) {
        highway = 'NLEX/TPLEX';
        entry = 'Balintawak';
        exit = dest.contains('baguio') ? 'Rosario' : 'Sta. Ines';
      } else if (dest.contains('batangas') || dest.contains('tagaytay') || dest.contains('laguna')) {
        highway = 'SLEX';
        entry = 'Magallanes';
        exit = dest.contains('batangas') ? 'Sto. Tomas' : 'Sta. Rosa';
      }

      _tollFee = await TollService().calculateToll(
        highway: highway,
        entryPoint: entry,
        exitPoint: exit,
      );

      // 3. Calculate Fuel Cost
      await _calculateFuelCost();

      // 4. Generate AI Insights
      await _generateAIInsights();

    } catch (e) {
      debugPrint('Error loading vehicle configurations: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<dynamic> _currentRefuelingPlan = [];

  Future<void> _calculateFuelCost() async {
    if (_vehicleConfig == null) return;
    
    try {
      final response = await Supabase.instance.client
          .from('fuel_prices')
          .select()
          .order('updated_at', ascending: false)
          .limit(10);

      if (response != null && (response as List).isNotEmpty) {
        final fuelGrade = _vehicleConfig!['fuel_grade']?.toString().toLowerCase() ?? 'unleaded';
        final fuelKey = (fuelGrade == 'diesel') ? 'diesel' : 'gasoline';
        
        double avgPrice = 0;
        for (var p in response as List) {
          avgPrice += (p[fuelKey] as num).toDouble();
        }
        avgPrice /= (response as List).length;

        final efficiency = (_vehicleConfig!['liters_per_km'] as num?)?.toDouble() ?? 0.08;
        final litersNeeded = _distanceKm * efficiency;
        
        setState(() {
          _fuelPricePerLiter = avgPrice;
          _estFuelCost = litersNeeded * avgPrice;
        });
      }
    } catch (e) {
      debugPrint('Fuel calculation error: $e');
      setState(() {
        _fuelPricePerLiter = 65.0;
        _estFuelCost = _distanceKm * 0.08 * 65.0; // Fallback
      });
    }
  }

  Future<void> _generateAIInsights() async {
    final vehicleModel = '${_vehicleConfig?['brand']} ${_vehicleConfig?['model']}';
    
    // 1. Try to fetch from local cache first
    final localInsight = await DatabaseService().getTripInsights(_origin, _destination, vehicleModel);
    if (localInsight != null && localInsight['budget'] == _budget) {
      if (mounted) {
        setState(() => _aiInsights = List<String>.from(localInsight['insights']));
      }
      return;
    }

    // 2. Try to fetch from Supabase
    try {
      final remoteResponse = await Supabase.instance.client
          .from('trip_insights')
          .select()
          .eq('origin', _origin)
          .eq('destination', _destination)
          .eq('vehicle_model', vehicleModel)
          .eq('budget', _budget)
          .order('created_at', ascending: false)
          .limit(1);
      
      if (remoteResponse != null && (remoteResponse as List).isNotEmpty) {
        final data = remoteResponse.first;
        final insights = List<String>.from(jsonDecode(data['insights']));
        if (mounted) {
          setState(() => _aiInsights = insights);
        }
        // Sync to local
        await DatabaseService().saveTripInsights({
          'origin': _origin,
          'destination': _destination,
          'vehicle_model': vehicleModel,
          'budget': _budget,
          'insights': insights,
        });
        return;
      }
    } catch (e) {
      debugPrint('Supabase insight fetch error: $e');
    }

    // 3. Generate with Gemini if not found
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null) return;

    final gemini = GeminiLLMService(apiKey: apiKey);
    final totalEst = _estFuelCost + _tollFee + _otherExpenses;
    final balance = _budget - totalEst;
    
    final prompt = """
    Analyze this trip data and provide 3 concise, highly actionable budget insights (one sentence each) as bullet points.
    Trip: $_origin to $_destination ($_distanceKm km)
    Vehicle: $vehicleModel
    Budget: ₱${_budget.toStringAsFixed(0)}
    Estimated Costs: Fuel: ₱${_estFuelCost.toStringAsFixed(0)}, Tolls: ₱${_tollFee.toStringAsFixed(0)}, Food/Other: ₱${_otherExpenses.toStringAsFixed(0)}
    Total: ₱${totalEst.toStringAsFixed(0)}
    Balance: ₱${balance.toStringAsFixed(0)}
    Return ONLY 3 bullet points starting with '•'.
    """;

    final response = await gemini.generateResponse(prompt, systemContext: "You are an AI Travel Budget Expert for Haribon app.");
    
    final parsedInsights = response.split('\n')
        .where((s) => s.contains('•'))
        .map((s) => s.replaceAll('•', '').trim())
        .toList();
    
    final finalInsights = parsedInsights.length >= 3 ? parsedInsights.take(3).toList() : [
      'Refuel at outskirts to save on fuel costs.',
      'Expect high toll fees on expressways.',
      balance < 0 ? 'You are over budget. Consider reducing other expenses.' : 'You have a healthy budget buffer.'
    ];

    if (mounted) {
      setState(() => _aiInsights = finalInsights);
    }

    // 4. Save to both local and Supabase
    final insightData = {
      'origin': _origin,
      'destination': _destination,
      'vehicle_model': vehicleModel,
      'budget': _budget,
      'insights': finalInsights,
    };

    await DatabaseService().saveTripInsights(insightData);
    
    try {
      await Supabase.instance.client.from('trip_insights').insert({
        'origin': _origin,
        'destination': _destination,
        'vehicle_model': vehicleModel,
        'budget': _budget,
        'insights': jsonEncode(finalInsights),
      });
    } catch (e) {
      debugPrint('Supabase insight save error: $e');
    }
  }

  Future<void> _saveSmartTrip() async {
    try {
      final vehicleModel = '${_vehicleConfig?['brand']} ${_vehicleConfig?['model']}';
      
      await Supabase.instance.client.from('smart_trips').upsert({
        'origin_name': _origin,
        'destination_name': _destination,
        'distance_km': _distanceKm,
        'total_budget': _budget,
        'est_fuel_cost': _estFuelCost,
        'toll_fee': _tollFee,
        'other_expenses': _otherExpenses,
        'vehicle_details': {
          'brand': _vehicleConfig?['brand'],
          'model': _vehicleConfig?['model'],
          'fuel_grade': _vehicleConfig?['fuel_grade'],
          'efficiency': _vehicleConfig?['liters_per_km'],
        },
        'ai_insights': _aiInsights,
        'refueling_plan': _currentRefuelingPlan,
      }, onConflict: 'origin_name, destination_name, vehicle_details');
    } catch (e) {
      debugPrint('Error saving full smart trip: $e');
    }
  }

  void _showBudgetDialog() {
    final controller = TextEditingController(text: _budget.toStringAsFixed(0));
    final theme = Theme.of(context);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.containerLowest,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          top: 12,
          left: 24,
          right: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.greySoftBg,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryMain.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.account_balance_wallet_outlined, color: AppColors.primaryMain, size: 20),
                ),
                const SizedBox(width: 16),
                Text(
                  'Edit Trip Budget',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Set your maximum spending limit for this trip. We\'ll use this to calibrate your AI budget insights.',
              style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textTertiary, height: 1.4),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: AppColors.containerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.greySoftBg),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                autofocus: true,
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  prefixText: '₱ ',
                  prefixStyle: theme.textTheme.headlineSmall?.copyWith(color: AppColors.primaryMain, fontWeight: FontWeight.bold),
                  hintText: '0',
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppColors.greySoftBg),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Cancel', style: TextStyle(color: AppColors.textTertiary, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final newBudget = double.tryParse(controller.text) ?? _budget;
                      setState(() => _budget = newBudget);
                      
                      // Sync budget back to vehicle_configurations
                      try {
                        await Supabase.instance.client
                            .from('vehicle_configurations')
                            .update({'budget': newBudget})
                            .eq('brand', _vehicleConfig?['brand'] ?? '')
                            .eq('model', _vehicleConfig?['model'] ?? '');
                      } catch (e) {
                        debugPrint('Error syncing budget to config: $e');
                      }

                      Navigator.pop(context);
                      await _generateAIInsights();
                      await _saveSmartTrip();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryMain,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Update Budget', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  double get _totalEst => _estFuelCost + _tollFee + _otherExpenses;
  double get _balance => _budget - _totalEst;
  double get _progress => (_totalEst / _budget).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.primaryMain)));
    }

    return Scaffold(
      backgroundColor: AppColors.surfaceMain,
      appBar: CommonAppBar(
        title: 'Smart Trip Planner',
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // BUDGET STATUS SECTION
                Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'CURRENT BUDGET STATUS',
                        style: textTheme.labelSmall?.copyWith(
                          color: AppColors.primaryMain,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          fontSize: 10,
                        ),
                      ),
                      GestureDetector(
                        onTap: _showBudgetDialog,
                        child: const Icon(Icons.edit_outlined, size: 14, color: AppColors.primaryMain),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '₱${_budget.toStringAsFixed(0)}',
                      style: textTheme.headlineMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w900,
                        fontSize: 36,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Total Budget',
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.textTertiary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Gradient progress bar
                Stack(
                  children: [
                    Container(
                      height: 8,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: AppColors.greySoftBg,
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: _progress,
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          gradient: LinearGradient(
                            colors: _balance < 0 
                              ? [AppColors.redDark, Colors.redAccent]
                              : [AppColors.bluePale, AppColors.primaryMain],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Est. Cost: ₱${_totalEst.toStringAsFixed(0)}',
                      style: textTheme.bodySmall?.copyWith(
                        color: _balance < 0 ? AppColors.redDark : AppColors.primaryMain,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Balance: ${_balance < 0 ? '-' : ''}₱${_balance.abs().toStringAsFixed(0)}',
                      style: textTheme.bodySmall?.copyWith(
                        color: _balance < 0 ? AppColors.redDark : AppColors.textTertiary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // VISUAL BREAKDOWN
                VisualBreakdownCard(
                  fuelCost: _estFuelCost,
                  tollCost: _tollFee,
                  otherCost: _otherExpenses,
                  distanceKm: _distanceKm,
                  kmPerLiter: (_vehicleConfig?['km_per_liter'] as num?)?.toDouble() ?? 12.0,
                  fuelPrice: _fuelPricePerLiter,
                ),
                const SizedBox(height: 16),

                // FUEL READINESS
                FuelReadinessCard(
                  distanceKm: _distanceKm,
                  litersPerKm: (_vehicleConfig?['liters_per_km'] as num?)?.toDouble() ?? 0.08,
                  currentLiters: (_vehicleConfig?['current_fuel_liters'] as num?)?.toDouble() ?? 10.0,
                  destination: _destination,
                ),
                const SizedBox(height: 16),

                // REFUELING PLANNER
                ExpandableCard(
                  icon: Icons.map_outlined,
                  title: 'Smart Refueling\nPlanner',
                  subtitle: 'Optimized pitstops',
                  subtitleColor: AppColors.textTertiary,
                  content: RefuelingPlannerContent(
                    origin: _origin,
                    destination: _destination,
                    distanceKm: _distanceKm,
                    fuelGrade: _vehicleConfig?['fuel_grade'] ?? 'Unleaded',
                    onPlanGenerated: (stops) {
                      _currentRefuelingPlan = stops;
                    },
                  ),
                  initiallyExpanded: true,
                ),
                const SizedBox(height: 16),

                // AI BUDGET INSIGHTS
                InsightCard(insights: _aiInsights),
                const SizedBox(height: 16),

                // BOTTOM IMAGE CARD
                const BottomActionCard(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}