import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_colors.dart';
import '../models/monthly_report_model.dart';

/// MODULE: MONTHLY STATS CARD
/// Displays aggregated statistics for the month.
class MonthlyStatsCard extends StatelessWidget {
  final MonthlyStats stats;

  const MonthlyStatsCard({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.containerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.textTertiary.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PERFORMANCE INSIGHTS',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textTertiary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          _StatRow(
            label: 'Avg. Cost Per Trip',
            value: '₱${stats.avgFuelCostPerTrip.toStringAsFixed(0)}',
            icon: Icons.attach_money_rounded,
          ),
          const SizedBox(height: 12),
          _StatRow(
            label: 'Avg. Distance Per Trip',
            value: '${stats.avgDistancePerTrip.toStringAsFixed(1)} km',
            icon: Icons.straighten_rounded,
          ),
          const SizedBox(height: 12),
          _StatRow(
            label: 'Avg. Speed',
            value: '${stats.avgSpeedKmh.toStringAsFixed(0)} km/h',
            icon: Icons.speed_rounded,
          ),
          const SizedBox(height: 12),
          _StatRow(
            label: 'Active Days',
            value: '${stats.daysWithTrips} days',
            icon: Icons.calendar_month_rounded,
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.surfaceDim, height: 16),
          const SizedBox(height: 8),
          _StatRow(
            label: 'Best Efficiency Score',
            value: '${stats.bestEfficiencyScore}%',
            icon: Icons.trending_up_rounded,
            highlightColor: const Color(0xFF15803D),
          ),
          const SizedBox(height: 8),
          _StatRow(
            label: 'Lowest Efficiency Score',
            value: '${stats.worstEfficiencyScore}%',
            icon: Icons.trending_down_rounded,
            highlightColor: AppColors.warning,
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? highlightColor;

  const _StatRow({
    required this.label,
    required this.value,
    required this.icon,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = highlightColor ?? AppColors.textSecondary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 12),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
