import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import '../../core/database/database_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../theme/app_colors.dart';
import '../common/widgets/app_bar.dart';
import '../summary/models/trip_summary_model.dart';
import '../summary/main_summary_screen.dart';
import '../summary/full_route_map_screen.dart';
import './models/home_data_model.dart';
import './widgets/home_greeting.dart';
import '../common/widgets/trip_card.dart';
import './widgets/home_stat_grid.dart';
import './widgets/gas_station_list_widget.dart';
import './widgets/gas_station_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late HomeDashboardData _dashboardData;
  late TripSummary _latestTrip;
  bool _isLoading = true;
  Map<String, dynamic>? _vehicleConfig;
  double _fuelPricePerLiter = 65.0;
  List<GasStationData> _gasStations = [];

  @override
  void initState() {
    super.initState();
    _latestTrip = _buildMockLatestTrip();
    _loadData();
    // Listen for changes from vehicle intelligence / onboarding
    DatabaseService().onConfigChanged.addListener(_loadData);
  }

  Future<void> _loadData() async {
    final onboardingData = await DatabaseService().getOnboardingData();

    String userName = 'Driver';
    List<HomeStat> stats = [];
    double avgFuelPrice = 65.0;
    List<double> trend = List.filled(7, 12.0);
    double totalCO2Accumulated = 0;
    double totalDistance = 0;
    double totalLiters = 0;
    double avgSpeedAccumulator = 0;
    int speedCount = 0;
    String fuelGrade = 'gasoline';

    try {
      // ── 1. Fetch ALL trips for aggregation ──
      final allTrips = await Supabase.instance.client
          .from('smart_trips')
          .select()
          .order('created_at', ascending: false);

      // ── 2. Fetch Active Vehicle Config ──
      final activeResponse = await Supabase.instance.client
          .from('vehicle_configurations')
          .select()
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (activeResponse != null) {
        fuelGrade = (activeResponse['fuel_type'] ?? 'gasoline').toString().toLowerCase();
      }

      // ── 3. Fetch live fuel prices (sorted cheapest first for gas stations) ──
      try {
        final fuelPrices = await Supabase.instance.client
            .from('fuel_prices')
            .select()
            .order('updated_at', ascending: false)
            .limit(100);
        if ((fuelPrices as List).isNotEmpty) {
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
          
          // Map to gas station cards (sorted cheap→expensive inside)
          _gasStations = GasStationListWidget.mapFromSupabase(fuelPrices);
        }
      } catch (_) {}

      // ── 4. Vehicle efficiency from config ──
      double kmPerLiter = 12.0;
      if (activeResponse != null) {
        final kml = (activeResponse['km_per_liter'] as num?)?.toDouble();
        if (kml != null && kml > 0) kmPerLiter = kml;
      }

      final co2Factor = fuelGrade.contains('diesel') ? 2.68 : 2.31;

      // ── 5. Aggregate real data from trips ──
      if ((allTrips as List).isNotEmpty) {
        for (var trip in allTrips) {
          final distKm = (trip['distance_km'] ?? trip['route_distance_km'] ?? 0.0).toDouble();
          final storedLiters = (trip['est_fuel_liters'] as num?)?.toDouble();
          final storedCost = (trip['est_fuel_cost'] as num?)?.toDouble();
          final travelTimeMin = (trip['est_travel_time_min'] as num?)?.toDouble() ?? 0;

          if (distKm > 0) {
            totalDistance += distKm;
            if (travelTimeMin > 0) {
              avgSpeedAccumulator += (distKm / (travelTimeMin / 60.0));
              speedCount++;
            }
          }

          // Compute liters
          double tripLiters;
          if (storedLiters != null && storedLiters > 0) {
            tripLiters = storedLiters;
          } else if (distKm > 0 && kmPerLiter > 0) {
            tripLiters = distKm / kmPerLiter;
          } else if (storedCost != null && storedCost > 0) {
            tripLiters = storedCost / avgFuelPrice;
          } else {
            tripLiters = 0.0;
          }

          totalLiters += tripLiters;
          totalCO2Accumulated += tripLiters * co2Factor;
        }
      }

      double globalAvgSpeed = speedCount > 0 ? avgSpeedAccumulator / speedCount : 65.0;

      // ── 6. Prioritize Active Plan for Main Trip Card ──
      if (activeResponse != null) {
        _vehicleConfig = Map<String, dynamic>.from(activeResponse);
        final activeDist = (activeResponse['route_distance_km'] ?? 0.0).toDouble();
        final litersPerKm = kmPerLiter > 0 ? 1.0 / kmPerLiter : 0.08;
        final activeLiters = activeDist * litersPerKm;
        final activeCost = activeLiters * avgFuelPrice;
        final activeCO2 = activeLiters * co2Factor;

        setState(() {
          _latestTrip = TripSummary(
            origin: activeResponse['origin_name'] ?? 'Current Location',
            destination: activeResponse['destination_name'] ?? 'Destination',
            date: 'Active Journey',
            duration: Duration(minutes: (activeDist / 60.0 * 60).toInt()),
            distanceKm: activeDist,
            efficiencyScore: 92,
            efficiencyRating: 'Active Plan',
            efficiencyPercentile: 'Top 5%',
            stats: TripStats(
              fuelLiters: activeLiters,
              fuelCostPhp: activeCost,
              avgSpeedKmh: globalAvgSpeed,
              co2SavedKg: activeCO2,
              costVsEstimatePhp: 0,
            ),
            fuelStops: [],
            aiInsight: '',
            routeSegments: [],
            treesEquivalent: (activeCO2 / 20.0).ceil(),
          );
        });
      } else if ((allTrips as List).isNotEmpty) {
        final latest = (allTrips as List).first;
        final latestDist = (latest['distance_km'] ?? 0.0).toDouble();
        final latestLiters = (latest['est_fuel_liters'] as num?)?.toDouble() ?? (latestDist / kmPerLiter);
        final latestCost = latestLiters * avgFuelPrice;
        final latestCO2 = latestLiters * co2Factor;
        final latestTime = (latest['est_travel_time_min'] as num?)?.toDouble() ?? 0;
        final latestSpeed = latestTime > 0 ? (latestDist / (latestTime / 60.0)) : globalAvgSpeed;
        
        setState(() {
          _latestTrip = TripSummary(
            origin: latest['origin_name'] ?? 'Unknown',
            destination: latest['destination_name'] ?? 'Unknown',
            date: 'Last Trip',
            duration: Duration(minutes: latestTime.toInt()),
            distanceKm: latestDist,
            efficiencyScore: (latest['efficiency_score'] ?? 85).toInt(),
            efficiencyRating: 'Good',
            efficiencyPercentile: 'Top 15%',
            stats: TripStats(
              fuelLiters: latestLiters,
              fuelCostPhp: latestCost,
              avgSpeedKmh: latestSpeed,
              co2SavedKg: latestCO2,
              costVsEstimatePhp: 0,
            ),
            fuelStops: [],
            aiInsight: '',
            routeSegments: [],
            treesEquivalent: (latestCO2 / 20.0).ceil(),
          );
        });
      }

      // ── 7. Calculate Efficiency Trend (last 7 days) ──
      final now = DateTime.now();

      if ((allTrips as List).isNotEmpty) {
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

          trend[i] = dailyLiters > 0 ? dailyDist / dailyLiters : kmPerLiter;
        }
      }

      // ── 8. Build Dynamic Stats ──
      String driveTime = '-- hrs';
      String fuelReq = '-- L';
      
      if (activeResponse != null) {
        final dist = (activeResponse['route_distance_km'] ?? 0.0).toDouble();
        final litersPerKm = kmPerLiter > 0 ? 1.0 / kmPerLiter : 0.08;
        final hrs = dist / 60.0;
        driveTime = hrs < 1 ? '${(hrs * 60).toInt()} min' : '${hrs.toStringAsFixed(1)} hrs';
        fuelReq = '${(dist * litersPerKm).toStringAsFixed(1)} L';
      }

      stats = [
        HomeStat(
          label: 'Est. Drive Time',
          value: driveTime,
          icon: Icons.access_time_rounded,
          color: AppColors.blueLighterBg,
          iconColor: AppColors.blueLight,
        ),
        HomeStat(
          label: 'Fuel Required',
          value: fuelReq,
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
          weeklyCo2Saved: totalCO2Accumulated,
          stats: stats,
          efficiencyTrend: trend,
          activities: mockData.activities,
        );
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    DatabaseService().onConfigChanged.removeListener(_loadData);
    super.dispose();
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
                      buttonText: 'View Trip Details',
                      onActionButton: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MainSummaryScreen(
                              onPlanNext: () => Navigator.pop(context),
                            ),
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
                              isHistory: _latestTrip.date != 'Active Journey',
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),
                     Text(
              'Trip Stats',
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1A1A),
              ),
            ),
               const SizedBox(height: 16),
                    HomeStatGrid(stats: _dashboardData.stats),
                    const SizedBox(height: 16),
                    GasStationListWidget(stations: _gasStations),
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