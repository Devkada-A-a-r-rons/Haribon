import 'package:flutter/material.dart';
import 'package:haribon/theme/app_colors.dart';
import '../../common/widgets/typing_text.dart';


class EfficiencyLossInsightsCard extends StatelessWidget {
  final List<String> insights;
  const EfficiencyLossInsightsCard({super.key, required this.insights});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    
    // Icon mapping logic for better visual context
    IconData getIcon(int index) {
      if (index == 0) return Icons.terrain;
      if (index == 1) return Icons.directions_car;
      return Icons.access_time;
    }

    Color getIconColor(int index) {
      if (index == 0) return AppColors.redDark;
      if (index == 1) return AppColors.orangePrimary;
      return AppColors.textTertiary;
    }

    Color getBgColor(int index) {
      if (index == 0) return AppColors.redSoftBg;
      if (index == 1) return AppColors.orangeSoftBg;
      return AppColors.blueGreySoftBg;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.containerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'EFFICIENCY LOSS INSIGHTS',
            style: textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: AppColors.textPrimary,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 20),
          if (insights.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: ThinkingIndicator()),
            )
          else
            ...insights.asMap().entries.map((entry) {
              final idx = entry.key;
              final text = entry.value;
              return Padding(
                padding: EdgeInsets.only(bottom: idx == insights.length - 1 ? 0 : 16),
                child: _buildInsightItem(
                  textTheme: textTheme,
                  icon: getIcon(idx),
                  iconColor: getIconColor(idx),
                  bgColor: getBgColor(idx),
                  text: text,
                  hideDivider: idx == insights.length - 1,
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildInsightItem({
    required TextTheme textTheme,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String text,
    bool hideDivider = false,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TypingText(
                text: text,
                style: textTheme.bodySmall?.copyWith(color: AppColors.textPrimary, height: 1.4),
              ),
            ),
          ],
        ),
        if (!hideDivider) ...[
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.greySoftBg),
        ],
      ],
    );
  }
}
