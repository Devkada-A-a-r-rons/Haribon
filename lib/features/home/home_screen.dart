import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../common/widgets/app_bar.dart';
import '../summary/models/trip_summary_model.dart';
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

  @override
  void initState() {
    super.initState();
    _dashboardData = HomeDashboardData.mock();
    _latestTrip = _buildMockLatestTrip();
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
          child: Column(
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
                  // Handle navigation to full summary
                },
              ),
              const SizedBox(height: 24),
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
}
