import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/monthly_report_model.dart';
import 'widgets/monthly_report_header.dart';
import 'widgets/monthly_stats_card.dart';
import 'widgets/efficiency_trend_chart.dart';
import 'widgets/vehicle_usage_calendar.dart';
import 'widgets/top_insight_card.dart';
import 'widgets/daily_trips_list.dart';
import '../common/widgets/app_bar.dart';
import '../common/widgets/nav_bar.dart';
import '../../theme/app_colors.dart';

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
  int _currentNavIndex = 4; // Analysis tab

  @override
  void initState() {
    super.initState();
    _currentNavIndex = widget.selectedNavIndex ?? 4;
    _fetchMonthlyReport();
  }

  Future<void> _fetchMonthlyReport() async {
    try {
      setState(() => _isLoading = true);

      final now = DateTime.now();
      final month = widget.month ?? DateFormat('MMMM').format(now);
      final year = widget.year ?? now.year.toString();

      // Fetch trips for this month
      final startOfMonth = DateTime(int.parse(year), _monthToNumber(month), 1);
      final endOfMonth = DateTime(int.parse(year), _monthToNumber(month) + 1, 0, 23, 59, 59);

      final response = await Supabase.instance.client
          .from('smart_trips')
          .select()
          .gte('created_at', startOfMonth.toIso8601String())
          .lte('created_at', endOfMonth.toIso8601String())
          .order('created_at', ascending: true);

      final List<dynamic> tripsData = response as List<dynamic>;

      // Process data
      _report = _processReportData(tripsData, month, year);

      setState(() => _isLoading = false);
    } catch (e) {
      debugPrint('Error fetching monthly report: $e');
      setState(() {
        _errorMessage = 'Failed to load monthly report: $e';
        _isLoading = false;
      });
    }
  }

  int _monthToNumber(String month) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months.indexOf(month) + 1;
  }

  MonthlyReport _processReportData(List<dynamic> trips, String month, String year) {
    double totalDistance = 0;
    double totalCost = 0;
    double totalLiters = 0;
    double totalScore = 0;
    
    final List<DailyTripSummary> dailySummaries = [];
    final List<TrendData> trends = [];
    final List<VehicleUsageDay> usage = [];
    
    // Group by day
    final Map<int, List<dynamic>> grouped = {};
    for (var trip in trips) {
      final date = DateTime.tryParse(trip['created_at'] ?? '') ?? DateTime.now();
      grouped.putIfAbsent(date.day, () => []).add(trip);
    }

    // Process each day
    final lastDay = DateTime(int.parse(year), _monthToNumber(month) + 1, 0).day;
    for (int day = 1; day <= lastDay; day++) {
      final dayTrips = grouped[day] ?? [];
      final hasTrips = dayTrips.isNotEmpty;
      
      double dayDist = 0;
      double dayCost = 0;
      double dayScoreSum = 0;
      
      final List<TripEntry> entries = [];
      for (var t in dayTrips) {
        final dist = (t['distance_km'] ?? 0.0).toDouble();
        final cost = (t['est_fuel_cost'] ?? 0.0).toDouble();
        final liters = (t['est_fuel_liters'] ?? 0.0).toDouble();
        final score = (t['efficiency_score'] ?? 85).toDouble();
        
        dayDist += dist;
        dayCost += cost;
        dayScoreSum += score;
        totalLiters += liters;
        
        entries.add(TripEntry(
          origin: t['origin_name'] ?? 'Unknown',
          destination: t['destination_name'] ?? 'Unknown',
          time: DateFormat('hh:mm a').format(DateTime.tryParse(t['created_at'] ?? '') ?? DateTime.now()),
          distanceKm: dist,
          costPhp: cost,
          efficiencyScore: score.toInt(),
        ));
      }

      if (hasTrips) {
        totalDistance += dayDist;
        totalCost += dayCost;
        final dayAvgScore = dayScoreSum / dayTrips.length;
        totalScore += dayAvgScore;

        dailySummaries.add(DailyTripSummary(
          date: day.toString(),
          dayOfMonth: day,
          dayName: DateFormat('E').format(DateTime(int.parse(year), _monthToNumber(month), day)),
          trips: entries,
          dailyTotalDistance: dayDist,
          dailyTotalCost: dayCost,
          dayEfficiencyScore: dayAvgScore.toInt(),
        ));

        trends.add(TrendData(
          dayOfMonth: day,
          efficiencyScore: dayAvgScore.toInt(),
          dayLabel: day.toString(),
        ));
      }

      usage.add(VehicleUsageDay(
        dayOfMonth: day,
        used: hasTrips,
        tripsCount: dayTrips.length,
      ));
    }

    final activeTripsCount = dailySummaries.length;
    final avgScore = activeTripsCount > 0 ? (totalScore / activeTripsCount).toInt() : 0;

    return MonthlyReport(
      month: month,
      year: year,
      totalTrips: trips.length,
      totalDistanceKm: totalDistance,
      totalFuelCostPhp: totalCost,
      totalEmissionsCo2Kg: totalDistance * 0.115,
      averageEfficiencyScore: avgScore,
      dailyTrips: dailySummaries,
      stats: MonthlyStats(
        avgFuelCostPerTrip: trips.isNotEmpty ? totalCost / trips.length : 0,
        avgDistancePerTrip: trips.isNotEmpty ? totalDistance / trips.length : 0,
        avgEmissionsPerTrip: trips.isNotEmpty ? (totalDistance * 0.115) / trips.length : 0,
        bestEfficiencyScore: trends.isNotEmpty ? trends.map((t) => t.efficiencyScore).reduce((a, b) => a > b ? a : b) : 0,
        worstEfficiencyScore: trends.isNotEmpty ? trends.map((t) => t.efficiencyScore).reduce((a, b) => a < b ? a : b) : 0,
        avgSpeedKmh: 65,
        daysWithTrips: activeTripsCount,
      ),
      efficiencyTrend: trends,
      vehicleUsage: usage,
      topInsight: totalDistance > 500 
          ? "You've covered significant ground this month. Great job maintaining an average efficiency score of $avgScore%!"
          : 'Keep tracking your trips to unlock more detailed performance insights.',
    );
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
