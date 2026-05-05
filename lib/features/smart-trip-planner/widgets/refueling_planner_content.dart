import 'package:flutter/material.dart';
import 'package:haribon/theme/app_colors.dart';


class RefuelingPlannerContent extends StatelessWidget {
  const RefuelingPlannerContent({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        _buildTimelineItem(theme, 'Pampanga', 'DEPARTURE POINT', Icons.adjust, AppColors.bluePale, isFirst: true),
        _buildTimelineItem(theme, 'Shell Angeles', 'Recommended 12L @ P63/L', Icons.close, AppColors.blueGreyDark, highlight: 'Optimal\nPrice'),
        _buildTimelineItem(theme, 'Petron Tarlac', 'Optional Backup', Icons.circle, AppColors.greyLight),
        _buildTimelineItem(theme, 'Shell Baguio Road', 'Skip: High Peak Price', Icons.circle, AppColors.greyLight, isRed: true),
        _buildTimelineItem(theme, 'Baguio City', '220KM JOURNEY END', Icons.location_on, AppColors.greenLightBg, isLast: true),
      ],
    );
  }

  Widget _buildTimelineItem(ThemeData theme, String title, String subtitle, IconData icon, Color iconColor, {bool isFirst = false, bool isLast = false, String? highlight, bool isRed = false}) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Expanded(child: Container(color: isFirst ? Colors.transparent : AppColors.greyLight, width: 2)),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: iconColor, width: 2),
                  ),
                  child: Icon(icon, size: 12, color: iconColor),
                ),
                Expanded(child: Container(color: isLast ? Colors.transparent : AppColors.greyLight, width: 2)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(title, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.navyDarker)),
                        Text(subtitle, style: theme.textTheme.labelSmall?.copyWith(color: isRed ? AppColors.redDark : AppColors.blueGreySecondary)),
                      ],
                    ),
                  ),
                  if (highlight != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.blueGreyDark,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        highlight,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.labelSmall?.copyWith(color: Colors.white, fontSize: 9),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
