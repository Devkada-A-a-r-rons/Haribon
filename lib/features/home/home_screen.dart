import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import '../chatbot/chatbot_screen.dart';
import '../../core/database/database_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../theme/app_colors.dart';
import '../common/widgets/app_bar.dart';
import '../summary/models/trip_summary_model.dart';
import '../summary/trip_summary_screen.dart';
import '../summary/full_route_map_screen.dart';
import './models/home_data_model.dart';
import './widgets/home_greeting.dart';
import '../common/widgets/trip_card.dart';
import './widgets/home_stat_grid.dart';
import '../monthly-report/monthly_report_screen.dart';
import '../timeline/timeline_screen.dart';
import './widgets/gas_station_list_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late HomeDashboardData _dashboardData;
  late TripSummary _latestTrip;
  bool _isLoading = true;
  Map<String, dynamic>? _activePlan;
  Map<String, dynamic>? _vehicleConfig;
  double _fuelPricePerLiter = 65.0;

  @override
  void initState() {
    super.initState();
    _latestTrip = _buildMockLatestTrip();
    _loadData();
  }

  Future<void> _loadData() async {
    final onboardingData = await DatabaseService().getOnboardingData();

    String userName = 'Driver';
    List<HomeStat> stats = [];
    double avgFuelPrice = 65.0;
    List<double> trend = List.filled(7, 12.0);

    try {
      // 1. Fetch ALL trips for aggregation
      final allTrips = await Supabase.instance.client.from('smart_trips').select();

      // 2. Fetch Active Plan
      final activeResponse = await Supabase.instance.client
          .from('vehicle_configurations')
          .select()
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      // 2b. Fetch live fuel prices
      try {
        final fuelPrices = await Supabase.instance.client
            .from('fuel_prices')
            .select()
            .order('updated_at', ascending: false)
            .limit(10);
        if (fuelPrices != null && (fuelPrices as List).isNotEmpty) {
          double total = 0;
          for (var p in fuelPrices) {
            total += (p['gasoline'] as num).toDouble();
          }
          avgFuelPrice = total / (fuelPrices as List).length;
        }
      } catch (_) {}

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
        _vehicleConfig = Map<String, dynamic>.from(activeResponse);
        final activeDist = (activeResponse['route_distance_km'] ?? 99.0).toDouble();
        final activeCost = (activeResponse['budget'] ?? 0.0).toDouble();

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

      // 4. Calculate Efficiency Trend (last 7 days)
      final now = DateTime.now();

      if (allTrips != null && (allTrips as List).isNotEmpty) {
        for (int i = 0; i < 7; i++) {
          final targetDate = now.subtract(Duration(days: 6 - i));
          double dailyDist = 0;
          double dailyLiters = 0;

          for (var trip in allTrips) {
            final tripDate = DateTime.tryParse(trip['created_at'] ?? '') ?? now;
            if (tripDate.year == targetDate.year &&
                tripDate.month == targetDate.month &&
                tripDate.day == targetDate.day) {
              final dist = (trip['distance_km'] ?? 0.0).toDouble();
              final liters = (trip['est_fuel_liters'] ?? 0.0).toDouble();
              if (dist > 0 && liters > 0) {
                dailyDist += dist;
                dailyLiters += liters;
              }
            }
          }

          trend[i] = dailyLiters > 0 ? dailyDist / dailyLiters : 12.0;
        }
      }

      // 5. Update Stats
      stats = [
        HomeStat(
          label: 'Est. Drive Time',
          value: '1.3 hrs',
          icon: Icons.access_time_rounded,
          color: AppColors.blueLighterBg,
          iconColor: AppColors.blueLight,
        ),
        HomeStat(
          label: 'Fuel Required',
          value: '18.9 Liters',
          icon: Icons.local_gas_station_rounded,
          color: AppColors.orangeSoftBg,
          iconColor: AppColors.orangeDark,
        ),
        HomeStat(
          label: 'Market Average',
          value: '₱${avgFuelPrice.toStringAsFixed(2)}/L',
          icon: Icons.show_chart_rounded,
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
        _fuelPricePerLiter = avgFuelPrice;
        _dashboardData = HomeDashboardData(
          userName: userName,
          weeklyCo2Saved: mockData.weeklyCo2Saved,
          stats: stats,
          efficiencyTrend: trend,
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
                    const SizedBox(height: 16),

                    // ── Unified TripCard (home variant) ──────────────────
                    TripCard(
                      summary: _latestTrip,
                      cost: '₱${_latestTrip.stats.fuelCostPhp.toStringAsFixed(0)}',
                      buttonText: 'View Full Summary',
                      onActionButton: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                TripSummaryScreen(summary: _latestTrip),
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
                              vehicleConfig: _vehicleConfig,
                              fuelPricePerLiter: _fuelPricePerLiter,
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),
                     Text(
              'Your Recent Trips',
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1A1A),
              ),
            ),
               const SizedBox(height: 16),
                    HomeStatGrid(stats: _dashboardData.stats),
                    const SizedBox(height: 16),
                    const GasStationListWidget(),
                    const SizedBox(height: 10),
                  ],
                ),
        ),
      ),
    );
  }

  LatLng _getCoords(String location) {
    final lower = location.toLowerCase();
    if (lower.contains('mall of asia') || lower.contains('moa')) return const LatLng(14.5352, 120.9822);
    if (lower.contains('makati')) return const LatLng(14.5547, 121.0244);
    if (lower.contains('bgc') || lower.contains('bonifacio')) return const LatLng(14.5500, 121.0494);
    if (lower.contains('quezon') || lower.contains('qc')) return const LatLng(14.6760, 121.0437);
    if (lower.contains('pasig')) return const LatLng(14.5764, 121.0851);
    if (lower.contains('marikina')) return const LatLng(14.6507, 121.1029);
    if (lower.contains('manila')) return const LatLng(14.5995, 120.9842);
    if (lower.contains('paranaque') || lower.contains('parañaque')) return const LatLng(14.4793, 121.0198);
    if (lower.contains('las pinas') || lower.contains('las piñas')) return const LatLng(14.4453, 120.9832);
    if (lower.contains('muntinlupa')) return const LatLng(14.4081, 121.0415);
    if (lower.contains('caloocan')) return const LatLng(14.6574, 120.9673);
    if (lower.contains('malabon')) return const LatLng(14.6617, 120.9568);
    if (lower.contains('valenzuela')) return const LatLng(14.7011, 120.9830);
    if (lower.contains('clark')) return const LatLng(15.1789, 120.5323);
    if (lower.contains('angeles') || lower.contains('pampanga')) return const LatLng(15.1450, 120.5887);
    if (lower.contains('baguio')) return const LatLng(16.4124, 120.5999);
    if (lower.contains('dagupan')) return const LatLng(16.0433, 120.3337);
    if (lower.contains('olongapo') || lower.contains('subic')) return const LatLng(14.8292, 120.2828);
    if (lower.contains('bataan')) return const LatLng(14.6416, 120.4818);
    if (lower.contains('tarlac')) return const LatLng(15.4755, 120.5960);
    if (lower.contains('cabanatuan')) return const LatLng(15.4886, 120.9741);
    if (lower.contains('bulacan') || lower.contains('malolos')) return const LatLng(14.8527, 120.8144);
    if (lower.contains('cavite') || lower.contains('bacoor')) return const LatLng(14.4625, 120.9642);
    if (lower.contains('tagaytay')) return const LatLng(14.1153, 120.9621);
    if (lower.contains('batangas')) return const LatLng(13.7565, 121.0583);
    if (lower.contains('laguna') || lower.contains('santa rosa')) return const LatLng(14.3122, 121.1114);
    if (lower.contains('antipolo')) return const LatLng(14.5863, 121.1760);
    if (lower.contains('rizal')) return const LatLng(14.6037, 121.3084);
    if (lower.contains('cebu')) return const LatLng(10.3157, 123.8854);
    if (lower.contains('iloilo')) return const LatLng(10.7202, 122.5621);
    if (lower.contains('bacolod')) return const LatLng(10.6407, 122.9457);
    if (lower.contains('tacloban')) return const LatLng(11.2543, 125.0000);
    if (lower.contains('davao')) return const LatLng(7.1907, 125.4553);
    if (lower.contains('cagayan de oro') || lower.contains('cdo')) return const LatLng(8.4542, 124.6319);
    if (lower.contains('zamboanga')) return const LatLng(6.9214, 122.0790);
    if (lower.contains('general santos') || lower.contains('gensan')) return const LatLng(6.1164, 125.1716);
    return const LatLng(14.5995, 120.9842);
  }
}