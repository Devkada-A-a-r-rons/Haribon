import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/monthly_report_model.dart';
import '../widgets/monthly_report_header.dart';
import '../widgets/monthly_stats_card.dart';
import '../widgets/efficiency_trend_chart.dart';
import '../widgets/vehicle_usage_calendar.dart';
import '../widgets/top_insight_card.dart';
import '../widgets/daily_trips_list.dart';
import '../../common/widgets/app_bar.dart';
import '../../common/widgets/nav_bar.dart';
import '../../../theme/app_colors.dart';

/// MAIN MONTHLY REPORT SCREEN
/// Displays comprehensive monthly statistics and trip analytics.
class MonthlyReportScreen extends StatefulWidget {
  final String? month;
  final String? year;
  final int? selectedNavIndex;
  final ValueChanged<int>? onNavIndexChanged;

  const MonthlyReportScreen({
    super.key,
    this.month,
    this.year,
    this.selectedNavIndex,
    this.onNavIndexChanged,
  });

  @override
  State<MonthlyReportScreen> createState() => _MonthlyReportScreenState();
}

class _MonthlyReportScreenState extends State<MonthlyReportScreen> {
  late MonthlyReport _report;
  bool _isLoading = true;
  String? _errorMessage;
  int _currentNavIndex = 5; // Analysis tab

  @override
  void initState() {
    super.initState();
    _currentNavIndex = widget.selectedNavIndex ?? 5;
    _fetchMonthlyReport();
  }

  Future<void> _fetchMonthlyReport() async {
    try {
      setState(() => _isLoading = true);

      // Get current month if not provided
      final now = DateTime.now();
      final month = widget.month ?? DateFormat('MMMM').format(now);
      final year = widget.year ?? now.year.toString();

      // Mock data generation - in production, fetch from Supabase
      // For now, we'll create realistic sample data
      _report = _generateMockReport(month, year);

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load monthly report: $e';
        _isLoading = false;
      });
    }
  }

  MonthlyReport _generateMockReport(String month, String year) {
    // Generate sample data for the month
    final daysInMonth = DateFormat('d')
        .parse('${DateTime.now().day}')
        .add(Duration(days: 1))
        .subtract(Duration(days: 1))
        .day;

    final dailyTrips = _generateDailyTrips(daysInMonth);
    final trends = _generateTrends(daysInMonth);
    final vehicleUsage = _generateVehicleUsage(daysInMonth);

    final totalTrips = dailyTrips.fold<int>(0, (sum, d) => sum + d.trips.length);
    final totalDistance =
        dailyTrips.fold<double>(0, (sum, d) => sum + d.dailyTotalDistance);
    final totalCost =
        dailyTrips.fold<double>(0, (sum, d) => sum + d.dailyTotalCost);
    final avgScore =
        dailyTrips.fold<int>(0, (sum, d) => sum + d.dayEfficiencyScore) ~/
            (dailyTrips.isEmpty ? 1 : dailyTrips.length);

    // Calculate stats
    final stats = MonthlyStats(
      avgFuelCostPerTrip: totalTrips > 0 ? totalCost / totalTrips : 0,
      avgDistancePerTrip: totalTrips > 0 ? totalDistance / totalTrips : 0,
      avgEmissionsPerTrip: totalTrips > 0
          ? (totalDistance * 0.115 / totalTrips)
          : 0, // kg CO2
      bestEfficiencyScore:
          dailyTrips.fold<int>(0, (max, d) => d.dayEfficiencyScore > max ? d.dayEfficiencyScore : max),
      worstEfficiencyScore:
          dailyTrips.fold<int>(100, (min, d) => d.dayEfficiencyScore < min ? d.dayEfficiencyScore : min),
      avgSpeedKmh: 65,
      daysWithTrips: dailyTrips.where((d) => d.hasTrips).length,
    );

    return MonthlyReport(
      month: month,
      year: year,
      totalTrips: totalTrips,
      totalDistanceKm: totalDistance,
      totalFuelCostPhp: totalCost,
      totalEmissionsCo2Kg: totalDistance * 0.115,
      averageEfficiencyScore: avgScore,
      dailyTrips: dailyTrips,
      stats: stats,
      efficiencyTrend: trends,
      vehicleUsage: vehicleUsage,
      topInsight:
          'Your driving on expressways improved by 8% this month. Keep maintaining steady speeds between 75-85 km/h for optimal fuel efficiency.',
    );
  }

  List<DailyTripSummary> _generateDailyTrips(int daysInMonth) {
    final List<DailyTripSummary> trips = [];
    final random = DateTime.now().millisecond % 7;

    for (int i = 1; i <= daysInMonth; i++) {
      final hasTrips = random % 3 != 0; // Roughly 66% of days have trips
      final dayOfWeek = DateTime(DateTime.now().year, DateTime.now().month, i)
          .toLocal()
          .weekday;
      final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

      if (hasTrips) {
        final tripCount = (random % 2) + 1;
        final tripList = <TripEntry>[];

        for (int j = 0; j < tripCount; j++) {
          final distance = 25 + (random * 15).toDouble();
          tripList.add(
            TripEntry(
              origin: j == 0 ? 'Home' : 'Office',
              destination: j == 0 ? 'Office' : 'Home',
              time: j == 0 ? '08:00 AM' : '05:30 PM',
              distanceKm: distance,
              costPhp: distance * 8,
              efficiencyScore: 75 + (random % 20),
            ),
          );
        }

        trips.add(
          DailyTripSummary(
            date: '$i',
            dayOfMonth: i,
            dayName: dayNames[(dayOfWeek - 1) % 7],
            trips: tripList,
            dailyTotalDistance:
                tripList.fold(0, (sum, t) => sum + t.distanceKm),
            dailyTotalCost: tripList.fold(0, (sum, t) => sum + t.costPhp),
            dayEfficiencyScore:
                tripList.fold(0, (sum, t) => sum + t.efficiencyScore) ~/
                    tripList.length,
          ),
        );
      }
    }

    return trips;
  }

  List<TrendData> _generateTrends(int daysInMonth) {
    final List<TrendData> trends = [];
    final random = DateTime.now().millisecond % 7;

    for (int i = 1; i <= daysInMonth; i += 3) {
      trends.add(
        TrendData(
          dayOfMonth: i,
          efficiencyScore: 70 + (random * 25).toInt(),
          dayLabel: '$i',
        ),
      );
    }

    return trends;
  }

  List<VehicleUsageDay> _generateVehicleUsage(int daysInMonth) {
    final List<VehicleUsageDay> usage = [];
    final random = DateTime.now().millisecond % 7;

    for (int i = 1; i <= daysInMonth; i++) {
      final isUsed = random % 3 != 0;
      usage.add(
        VehicleUsageDay(
          dayOfMonth: i,
          used: isUsed,
          tripsCount: isUsed ? (random % 3) + 1 : 0,
        ),
      );
    }

    return usage;
  }

  void _handleNavChange(int index) {
    setState(() => _currentNavIndex = index);
    widget.onNavIndexChanged?.call(index);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: const CommonAppBar(title: 'Monthly Report'),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primaryMain),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: const CommonAppBar(title: 'Monthly Report'),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(_errorMessage!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchMonthlyReport,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: const CommonAppBar(title: 'Monthly Report'),
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Header with overview metrics
                  MonthlyReportHeader(report: _report),
                  const SizedBox(height: 24),

                  // Top insight
                  TopInsightCard(insight: _report.topInsight),
                  const SizedBox(height: 24),

                  // Performance insights stats
                  MonthlyStatsCard(stats: _report.stats),
                  const SizedBox(height: 24),

                  // Efficiency trend chart
                  EfficiencyTrendChart(trends: _report.efficiencyTrend),
                  const SizedBox(height: 24),

                  // Vehicle usage calendar
                  VehicleUsageCalendar(
                    usageDays: _report.vehicleUsage,
                    daysInMonth:
                        _report.vehicleUsage.isEmpty
                            ? 30
                            : _report.vehicleUsage
                                .map((u) => u.dayOfMonth)
                                .reduce((a, b) => a > b ? a : b),
                  ),
                  const SizedBox(height: 24),

                  // Daily trips list
                  DailyTripsList(dailyTrips: _report.dailyTrips),
                  const SizedBox(height: 40),
                ]),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CommonNavBar(
        activeIndex: _currentNavIndex,
        onTabSelected: _handleNavChange,
      ),
    );
  }
}
