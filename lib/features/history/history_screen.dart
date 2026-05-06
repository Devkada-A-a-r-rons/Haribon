import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../common/widgets/app_bar.dart';
import 'widgets/trip_card.dart';
import 'widgets/history_images.dart';
import 'trip-details/trip_details_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> _trips = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    try {
      // 1. Fetch official saved trips
      final tripResponse = await Supabase.instance.client
          .from('smart_trips')
          .select()
          .order('created_at', ascending: false);

      // 2. Fetch trip insights (often contains the most specific budget)
      final insightsResponse = await Supabase.instance.client
          .from('trip_insights')
          .select()
          .order('created_at', ascending: false);

      // 3. Fetch active vehicle configuration as fallback
      final configResponse = await Supabase.instance.client
          .from('vehicle_configurations')
          .select()
          .order('created_at', ascending: false)
          .limit(5);

      final List<Map<String, dynamic>> combinedTrips = [];
      
      // Add saved trips first
      if (tripResponse != null) {
        combinedTrips.addAll(List<Map<String, dynamic>>.from(tripResponse));
      }

      // Merge insights into active configurations or add them as new history items
      if (configResponse != null) {
        for (var config in configResponse) {
          final exists = combinedTrips.any((t) => 
            t['origin_name'] == config['origin_name'] && 
            t['destination_name'] == config['destination_name']
          );
          
          if (!exists) {
            // Find matching insight for this config to get the budget
            final vehicleModel = '${config['brand']} ${config['model']}';
            final matchingInsight = (insightsResponse as List?)?.where(
              (i) => i['origin'] == config['origin_name'] && 
                     i['destination'] == config['destination_name'] &&
                     i['vehicle_model'] == vehicleModel,
            ).firstOrNull;

            combinedTrips.add({
              ...config,
              'is_active_plan': true,
              'budget': (matchingInsight != null ? matchingInsight['budget'] : config['budget']) ?? 0.0,
              'ai_insights': (matchingInsight != null && matchingInsight['insights'] != null) 
                  ? jsonDecode(matchingInsight['insights']) 
                  : [],
            });
          }
        }
      }

      setState(() {
        _trips = combinedTrips;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching history: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceMain,
      appBar: const CommonAppBar(title: 'History'),
      body: RefreshIndicator(
        onRefresh: _fetchHistory,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Trip History',
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Review your past journeys and\nefficiency insights at a glance.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_trips.isEmpty)
                Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      Icon(Icons.history_outlined, size: 64, color: AppColors.textTertiary.withValues(alpha: 0.3)),
                      const SizedBox(height: 16),
                      Text('No trips found yet.', style: GoogleFonts.inter(color: AppColors.textSecondary)),
                    ],
                  ),
                )
              else
                ..._trips.map((trip) {
                  final fuelCost = (trip['est_fuel_cost'] ?? trip['budget'] ?? 0.0).toDouble();
                  final budget = (trip['total_budget'] ?? trip['budget'] ?? 1.0).toDouble();
                  final toll = (trip['toll_fee'] ?? 0.0).toDouble();
                  final isActive = trip['is_active_plan'] == true;
                  final score = ((1.0 - ((fuelCost + toll) / budget).clamp(0, 1)) * 100).toInt().clamp(60, 98);
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: TripCard(
                      route: '${trip['origin_name'] ?? 'Pampanga'} → ${trip['destination_name'] ?? 'Baguio'}',
                      badgeText: isActive ? 'ACTIVE PLAN' : '$score ${score > 85 ? 'EXCELLENT' : 'GOOD'}',
                      badgeColor: isActive ? AppColors.historyBlue.withValues(alpha: 0.1) : (score > 85 ? AppColors.badgeExcellentBg : AppColors.badgeGoodBg),
                      badgeTextColor: isActive ? AppColors.historyBlue : (score > 85 ? AppColors.badgeExcellentText : AppColors.insightOlive),
                      badgeIcon: isActive ? Icons.rocket_launch_outlined : (score > 85 ? Icons.auto_awesome : Icons.eco_outlined),
                      date: DateFormat('MMM d, yyyy • hh:mm a').format(DateTime.parse(trip['created_at'])),
                      distance: '${(trip['distance_km'] ?? trip['route_distance_km'] ?? 0).toStringAsFixed(0)} km',
                      fuelUsed: '${((fuelCost / 68.0)).toStringAsFixed(1)} L',
                      cost: '₱${fuelCost.toStringAsFixed(0)}',
                      imageWidget: _getRandomImage(trip['id']?.hashCode ?? trip['created_at'].hashCode),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => TripDetailsScreen(tripData: trip)),
                        );
                      },
                    ),
                  );
                }),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getRandomImage(int seed) {
    final images = [
      const HaribonImageWidget(),
      const BirdGradientImageWidget(),
      const AerovistaImageWidget(),
    ];
    return images[seed % images.length];
  }
}
