import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_colors.dart';
import '../models/home_data_model.dart';

class EfficiencyTrendChart extends StatelessWidget {
  final List<double> data;
  final String trendLabel;
  final List<HomeStat> stats;

  const EfficiencyTrendChart({
    super.key,
    required this.data,
    this.trendLabel = '+5% this month',
    this.stats = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryMain,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '(km/L based on recent trips)',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    trendLabel,
                    style: GoogleFonts.poppins(
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
          const SizedBox(height: 12),
          SizedBox(
            height: 130,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: data.asMap().entries.map((entry) {
                final index = entry.key;
                final value = entry.value;
                final isLast = index == data.length - 1;
                final now = DateTime.now();
                final dayDate = now.subtract(Duration(days: data.length - 1 - index));
                final dayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
                final label = dayLabels[dayDate.weekday % 7];

                final maxVal = data.isEmpty
                    ? 15.0
                    : data.reduce((a, b) => a > b ? a : b).clamp(15.0, double.infinity);
                
                final normalizedHeight = (value / maxVal) * 100;
                final isZero = value <= 0;
                final displayHeight = isZero ? 6.0 : normalizedHeight.clamp(6.0, 100.0);
                final ratio = maxVal > 0 ? value / maxVal : 0.0;
                
                final barColor = isZero
                    ? AppColors.surfaceDim.withOpacity(0.3)
                    : ratio >= 0.66
                        ? const Color(0xFF4CAF50)
                        : ratio >= 0.33
                            ? const Color(0xFFFFC107)
                            : const Color(0xFFF44336);

                return _ChartBar(
                  height: displayHeight,
                  label: label,
                  isActive: isLast,
                  isZero: isZero,
                  value: value,
                  color: barColor,
                );
              }).toList(),
            ),
          ),
          if (stats.isNotEmpty) ...[
            const SizedBox(height: 16),
            Row(
              children: stats.asMap().entries.map((e) {
                final stat = e.value;
                final isLast = e.key == stats.length - 1;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: isLast ? 0 : 8),
                    child: Row(
                      children: [
                        Icon(stat.icon, color: Colors.black, size: 14),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                stat.value,
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                stat.label,
                                style: GoogleFonts.poppins(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Peak Efficiency',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                data.isEmpty ? '0.0 km/L' : '${data.reduce((a, b) => a > b ? a : b).toStringAsFixed(1)} km/L',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Calculated from your actual driving history in the last 7 days.',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textTertiary,
                  height: 1.4,
                ),
              ),
            ],
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
    return SizedBox(
      width: 40,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (isActive) ...[
            Text(
              isZero ? '-' : value.toStringAsFixed(1),
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryMain,
              ),
            ),
            const SizedBox(height: 4),
          ],
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 16,
            height: height,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
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
