import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_colors.dart';
import '../models/monthly_report_model.dart';

class EfficiencyTrendChart extends StatelessWidget {
  final List<TrendData> trends;

  const EfficiencyTrendChart({super.key, required this.trends});

  @override
  Widget build(BuildContext context) {
    if (trends.isEmpty) {
      return _EmptyState();
    }

    // Find min and max for scaling
    final scores = trends.map((t) => t.efficiencyScore).toList();
    final maxScore = scores.reduce((a, b) => a > b ? a : b).toDouble();
    final minScore = scores.reduce((a, b) => a < b ? a : b).toDouble();
    final scoreRange = maxScore - minScore > 0 ? maxScore - minScore : 1.0;

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
            'EFFICIENCY TREND',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textTertiary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: trends.map((trend) {
                // Normalize score to 0-1 range for bar height
                final normalizedScore =
                    (trend.efficiencyScore - minScore) / scoreRange;
                final barHeight = 80 * (normalizedScore.clamp(0.0, 1.0));
                final isHigh = trend.efficiencyScore > 80;

                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '${trend.efficiencyScore}%',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 100,
                        height: barHeight.clamp(10, 80),
                        decoration: BoxDecoration(
                          color: isHigh
                              ? const Color(0xFF22C55E)
                              : AppColors.warning,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        trend.dayLabel,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textTertiary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppColors.containerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.textTertiary.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.trending_up_rounded,
              size: 48,
              color: AppColors.textTertiary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 12),
            Text(
              'No trend data available',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
