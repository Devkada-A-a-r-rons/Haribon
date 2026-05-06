import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_colors.dart';
import '../models/monthly_report_model.dart';

/// MODULE: VEHICLE USAGE CALENDAR
/// Displays a calendar view of vehicle usage throughout the month.
class VehicleUsageCalendar extends StatelessWidget {
  final List<VehicleUsageDay> usageDays;
  final int daysInMonth;

  const VehicleUsageCalendar({
    super.key,
    required this.usageDays,
    required this.daysInMonth,
  });

  @override
  Widget build(BuildContext context) {
    // Create a map for quick lookup
    final usageMap = {for (var u in usageDays) u.dayOfMonth: u};

    // Get the day of week for the first day (0=Monday)
    // Assuming we start on a Monday for simplicity
    final firstDayOfWeek = 0; // Placeholder, will start from day 1
    final daysPaddingStart = (firstDayOfWeek % 7);

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
            'VEHICLE USAGE CALENDAR',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textTertiary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendItem(label: 'No Use', color: AppColors.surfaceDim),
              const SizedBox(width: 16),
              _LegendItem(label: '1 Trip', color: const Color(0xFFA8DADC)),
              const SizedBox(width: 16),
              _LegendItem(label: '2+ Trips', color: AppColors.primaryDark),
            ],
          ),
          const SizedBox(height: 20),
          // Calendar grid
          GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.0,
            ),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: daysInMonth + daysPaddingStart,
            itemBuilder: (context, index) {
              if (index < daysPaddingStart) {
                return const SizedBox.shrink();
              }

              final day = index - daysPaddingStart + 1;
              final usage = usageMap[day];
              final isUsed = usage?.used ?? false;
              final tripCount = usage?.tripsCount ?? 0;

              Color backgroundColor;
              if (!isUsed) {
                backgroundColor = AppColors.surfaceDim.withValues(alpha: 0.3);
              } else if (tripCount > 1) {
                backgroundColor = AppColors.primaryDark;
              } else {
                backgroundColor = const Color(0xFFA8DADC);
              }

              return Container(
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        day.toString(),
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isUsed
                              ? Colors.white
                              : AppColors.textTertiary,
                        ),
                      ),
                      if (isUsed && tripCount > 0)
                        Text(
                          '$tripCount',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: isUsed
                                ? Colors.white.withValues(alpha: 0.8)
                                : AppColors.textTertiary,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final String label;
  final Color color;

  const _LegendItem({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
