import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_colors.dart';
import '../models/monthly_report_model.dart';

/// MODULE: MONTHLY REPORT HEADER
/// Displays the report period and key overview metrics.
class MonthlyReportHeader extends StatelessWidget {
  final MonthlyReport report;

  const MonthlyReportHeader({
    super.key,
    required this.report,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Period label
        Text(
          report.displayPeriod,
          style: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),

        // Subtitle with trip count
        Text(
          '${report.totalTrips} ${report.totalTrips == 1 ? 'trip' : 'trips'} this month',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.textTertiary,
          ),
        ),
        const SizedBox(height: 20),

        // Overview metrics grid
        _OverviewMetricsGrid(report: report),
      ],
    );
  }
}

class _OverviewMetricsGrid extends StatelessWidget {
  final MonthlyReport report;

  const _OverviewMetricsGrid({required this.report});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.1,
      children: [
        _MetricCard(
          icon: Icons.local_gas_station_rounded,
          label: 'Total Fuel Cost',
          value: report.formattedTotalCost,
          backgroundColor: AppColors.primaryLight,
          iconColor: AppColors.primaryDark,
        ),
        _MetricCard(
          icon: Icons.route_rounded,
          label: 'Total Distance',
          value: report.formattedDistance,
          backgroundColor: const Color(0xFFF0F9FF),
          iconColor: const Color(0xFF1E40AF),
        ),
        _MetricCard(
          icon: Icons.eco_rounded,
          label: 'CO2 Emissions',
          value: report.formattedEmissions,
          backgroundColor: const Color(0xFFF0FDF4),
          iconColor: const Color(0xFF15803D),
        ),
        _MetricCard(
          icon: Icons.analytics_rounded,
          label: 'Avg Efficiency',
          value: '${report.averageEfficiencyScore}%',
          backgroundColor: const Color(0xFFFEF3C7),
          iconColor: const Color(0xFFB45309),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color backgroundColor;
  final Color iconColor;

  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.backgroundColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.textTertiary.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: iconColor, size: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
