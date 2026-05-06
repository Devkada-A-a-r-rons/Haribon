import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import '../../core/database/database_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../theme/app_colors.dart';
import '../common/widgets/app_bar.dart';
import '../summary/models/trip_summary_model.dart';
import '../summary/trip_summary_screen.dart';
import '../summary/full_route_map_screen.dart';
import './models/home_data_model.dart';
import './widgets/home_greeting.dart';
import './widgets/home_latest_trip_card.dart';
import './widgets/home_stat_grid.dart';
import './widgets/efficiency_trend_chart.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late HomeDashboardData _dashboardData;
  late TripSummary _latestTrip;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _latestTrip = _buildMockLatestTrip();
    _loadData();
  }

  Map<String, dynamic>? _activePlan;

  Future<void> _loadData() async {
    final onboardingData = await DatabaseService().getOnboardingData();
    
    String userName = 'Driver';
    List<HomeStat> stats = [];

    try {
      // 1. Fetch ALL trips for aggregation
      final allTrips = await Supabase.instance.client
          .from('smart_trips')
          .select();
      
      // 2. Fetch Active Plan
      final activeResponse = await Supabase.instance.client
          .from('vehicle_configurations')
          .select()
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      double totalDistance = 0;
      double totalCost = 0;
      double totalCO2 = 0;

      // Aggregate from History
      if (allTrips != null && (allTrips as List).isNotEmpty) {
        for (var trip in allTrips) {
          totalDistance += (trip['distance_km'] ?? trip['route_distance_km'] ?? 0.0).toDouble();
          totalCost += (trip['est_fuel_cost'] ?? 0.0).toDouble();
          totalCO2 += (trip['est_co2_kg'] ?? ((trip['est_fuel_cost'] ?? 0.0) / 68.0 * 2.3)).toDouble();
        }
      }

      // 3. Prioritize Active Plan for Main Card
      if (activeResponse != null) {
        final activeDist = (activeResponse['route_distance_km'] ?? 99.0).toDouble();
        final activeCost = (activeResponse['budget'] ?? 0.0).toDouble();
        
        // Add Active Plan to totals for immediate feedback
        totalDistance += activeDist;
        totalCost += activeCost;
        totalCO2 += (activeCost / 68.0 * 2.3);

        setState(() {
          _latestTrip = TripSummary(
            origin: activeResponse['origin_name'] ?? 'Current Location',
            destination: activeResponse['destination_name'] ?? 'Baguio',
            date: 'Active Journey',
            duration: const Duration(hours: 4, minutes: 30),
            distanceKm: activeDist,
            efficiencyScore: 92,
            efficiencyRating: 'Active Plan',
            efficiencyPercentile: 'Top 5%',
            stats: TripStats(
              fuelLiters: (activeCost / 68.0),
              fuelCostPhp: activeCost,
              avgSpeedKmh: 65,
              co2SavedKg: (activeCost / 68.0 * 2.3),
              costVsEstimatePhp: 0,
            ),
            fuelStops: [],
            aiInsight: '',
            routeSegments: [],
            treesEquivalent: (activeCost / 68.0 * 2.3 / 20.0).ceil(),
          );
        });
      } else if (allTrips != null && (allTrips as List).isNotEmpty) {
        final latest = (allTrips as List).last;
        setState(() {
          _latestTrip = TripSummary(
            origin: latest['origin_name'] ?? 'Unknown',
            destination: latest['destination_name'] ?? 'Unknown',
            date: 'Last Trip',
            duration: Duration(minutes: (latest['est_travel_time_min'] ?? 0)),
            distanceKm: (latest['distance_km'] ?? 0.0).toDouble(),
            efficiencyScore: (latest['efficiency_score'] ?? 85).toInt(),
            efficiencyRating: 'Good',
            efficiencyPercentile: 'Top 15%',
            stats: TripStats(
              fuelLiters: (latest['est_fuel_liters'] ?? 0.0).toDouble(),
              fuelCostPhp: (latest['est_fuel_cost'] ?? 0.0).toDouble(),
              avgSpeedKmh: 65,
              co2SavedKg: (latest['est_co2_kg'] ?? 0.0).toDouble(),
              costVsEstimatePhp: 0,
            ),
            fuelStops: [],
            aiInsight: '',
            routeSegments: [],
            treesEquivalent: ((latest['est_co2_kg'] ?? 0.0) / 20.0).ceil(),
          );
        });
      }

      // 4. Update Stats with Real Lifetime Totals
      stats = [
        HomeStat(
          label: 'Total Distance',
          value: '${totalDistance.toStringAsFixed(0)} km',
          icon: Icons.route_rounded,
          color: AppColors.blueLighterBg,
          iconColor: AppColors.blueLight,
        ),
        HomeStat(
          label: 'Total Spent',
          value: '₱${totalCost.toStringAsFixed(0)}',
          icon: Icons.payments_rounded,
          color: AppColors.orangeSoftBg,
          iconColor: AppColors.orangeDark,
        ),
        HomeStat(
          label: 'CO2 Saved',
          value: '${totalCO2.toStringAsFixed(1)} kg',
          icon: Icons.park_rounded,
          color: AppColors.greenSoftBg,
          iconColor: AppColors.greenAccent,
        ),
      ];

      if (onboardingData != null) {
        userName = onboardingData['user_name'] ?? 'Driver';
      }
    } catch (e) {
      debugPrint('Error loading home data: $e');
    }

    final mockData = HomeDashboardData.mock();

    if (mounted) {
      setState(() {
        _dashboardData = HomeDashboardData(
          userName: userName,
          weeklyCo2Saved: mockData.weeklyCo2Saved,
          stats: stats,
          efficiencyTrend: mockData.efficiencyTrend,
          activities: mockData.activities,
        );
        _isLoading = false;
      });
    }
  }

  TripSummary _buildMockLatestTrip() {
    return TripSummary(
      origin: 'Manila',
      destination: 'Baguio',
      date: 'Yesterday, 4:20 PM',
      duration: const Duration(hours: 4, minutes: 30),
      distanceKm: 248,
      efficiencyScore: 87,
      efficiencyRating: 'Excellent',
      efficiencyPercentile: 'Top 12%',
      stats: const TripStats(
        fuelLiters: 18.4,
        fuelCostPhp: 1380,
        avgSpeedKmh: 62,
        co2SavedKg: 2.1,
        costVsEstimatePhp: -80,
      ),
      fuelStops: [],
      aiInsight: '',
      routeSegments: [],
      treesEquivalent: 4,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceMain,
      appBar: const CommonAppBar(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _isLoading 
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              const SizedBox(height: 24),
              HomeGreeting(
                userName: _dashboardData.userName,
                weeklyCo2Saved: _dashboardData.weeklyCo2Saved,
              ),
              const SizedBox(height: 24),
              HomeLatestTripCard(
                summary: _latestTrip,
                onViewSummary: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TripSummaryScreen(summary: _latestTrip),
                    ),
                  );
                },
                onViewMap: () {
                  final originCoords = _getCoords(_latestTrip.origin);
                  final destCoords = _getCoords(_latestTrip.destination);
                  
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FullRouteMapScreen(
                        origin: originCoords,
                        destination: destCoords,
                        originName: _latestTrip.origin,
                        destinationName: _latestTrip.destination,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Text(
                'SHORTCUTS',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: AppColors.navyDarker,
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildShortcutButton(
                      context,
                      icon: Icons.map_outlined,
                      label: 'Plan Trip',
                      color: AppColors.primaryMain,
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildShortcutButton(
                      context,
                      icon: Icons.insert_chart_outlined,
                      label: 'Monthly',
                      color: AppColors.tealDark,
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildShortcutButton(
                      context,
                      icon: Icons.timeline_rounded,
                      label: 'Timeline',
                      color: AppColors.orangeDark,
                      onTap: () {},
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'OVERALL STATS',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: AppColors.navyDarker,
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 16),
              HomeStatGrid(stats: _dashboardData.stats),
              const SizedBox(height: 24),
              EfficiencyTrendChart(data: _dashboardData.efficiencyTrend),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShortcutButton(BuildContext context, {required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.containerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.surfaceDim.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  LatLng _getCoords(String location) {
    final lower = location.toLowerCase();
    if (lower.contains('clark')) return const LatLng(15.1789, 120.5323);
    if (lower.contains('mall of asia')) return const LatLng(14.5352, 120.9822);
    if (lower.contains('baguio')) return const LatLng(16.4124, 120.5999);
    if (lower.contains('manila')) return const LatLng(14.5995, 120.9842);
    return const LatLng(14.5995, 120.9842); // Default Manila
  }
}
