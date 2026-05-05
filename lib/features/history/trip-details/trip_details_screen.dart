import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_colors.dart';
import '../../common/widgets/app_bar.dart';
import 'widgets/metrics_grid.dart';
import 'widgets/consumption_breakdown.dart';
import 'widgets/carbon_impact.dart';
import 'widgets/logistics_timeline.dart';
import 'widgets/route_insights.dart';

class TripDetailsScreen extends StatelessWidget {
  const TripDetailsScreen({super.key});

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
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.textTertiary,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Pampanga → Baguio',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Oct 24, 2023 • 3h 45m',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            
            // Metrics Grid
            const MetricsGrid(),
            const SizedBox(height: 24),
            
            // Consumption Breakdown
            Text(
              'Consumption Breakdown',
              style: GoogleFonts.inter(
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
            const LogisticsTimeline(),
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
