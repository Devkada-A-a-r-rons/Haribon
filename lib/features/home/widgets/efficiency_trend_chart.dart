import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_colors.dart';

class EfficiencyTrendChart extends StatelessWidget {
  final List<double> data;
  final String trendLabel;

  const EfficiencyTrendChart({
    super.key, 
    required this.data,
    this.trendLabel = '+5% this month',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.containerLowest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Travel Efficiency',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '(km/L based on recent trips)',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    trendLabel,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
              const Icon(Icons.trending_up, color: AppColors.textTertiary, size: 20),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 160, // increased height to prevent overflow
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: data.asMap().entries.map((entry) {
                final index = entry.key;
                final value = entry.value;
                final isLast = index == data.length - 1;
                final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                
                // Find max value to scale the bars dynamically (minimum scale of 15 km/L)
                final maxVal = data.isEmpty ? 15.0 : data.reduce((a, b) => a > b ? a : b).clamp(15.0, double.infinity);
                
                // Normalize height relative to max value (max height = 100px)
                final normalizedHeight = (value / maxVal) * 100;
                
                // Handle zero values for days with no driving
                final isZero = value <= 0;
                final displayHeight = isZero ? 6.0 : normalizedHeight.clamp(6.0, 100.0);
                
                return _ChartBar(
                  height: displayHeight,
                  label: days[index],
                  isActive: isLast,
                  isZero: isZero,
                  value: value,
                  color: isZero 
                    ? AppColors.surfaceDim.withValues(alpha: 0.3)
                    : isLast 
                      ? AppColors.primaryMain 
                      : value >= 10.0 ? AppColors.blueAccent.withValues(alpha: 0.6) : AppColors.blueLighterBg,
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.auto_awesome, color: AppColors.success, size: 18),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Your travel efficiency peaked at 12.4 km/L! Avoiding heavy traffic in Manila helped save approximately 2L of fuel.',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.success,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartBar extends StatelessWidget {
  final double height;
  final String label;
  final double value;
  final bool isActive;
  final bool isZero;
  final Color color;

  const _ChartBar({
    required this.height, 
    required this.label, 
    required this.value,
    required this.isActive,
    required this.isZero,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (isActive) ...[
            Text(
              isZero ? '-' : value.toStringAsFixed(1),
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryMain,
              ),
            ),
            const SizedBox(height: 4),
          ],
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: double.infinity,
            height: height,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
              color: isActive ? AppColors.textPrimary : AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
