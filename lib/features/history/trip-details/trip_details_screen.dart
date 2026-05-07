import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_colors.dart';
import '../../common/widgets/app_bar.dart';
import 'widgets/metrics_grid.dart';
import 'widgets/consumption_breakdown.dart';
import 'widgets/carbon_impact.dart';
import 'widgets/logistics_timeline.dart';
import 'widgets/route_insights.dart';

class TripDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> tripData;
  const TripDetailsScreen({super.key, required this.tripData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceMain,
      appBar: CommonAppBar(showSettings: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'HISTORICAL ROUTE',
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.textTertiary,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${tripData['origin_name']} → ${tripData['destination_name']}',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${DateFormat('MMM d, yyyy').format(DateTime.parse(tripData['created_at']))} \u2022 ${(tripData['distance_km'] ?? tripData['route_distance_km'] ?? 0).toStringAsFixed(0)} km',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            
            // Metrics Grid
            MetricsGrid(tripData: tripData),
            const SizedBox(height: 24),
            
            // Consumption Breakdown
            Text(
              'Consumption Breakdown',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            const ConsumptionBreakdown(),
            const SizedBox(height: 16),
            
            // Carbon Impact
            const CarbonImpact(),
            const SizedBox(height: 32),
            
            // Logistics Timeline
            LogisticsTimeline(tripData: tripData),
            const SizedBox(height: 32),
            
            // Route Insights
            const RouteInsights(),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}

