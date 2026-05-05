import 'package:flutter/material.dart';
import 'package:haribon/theme/app_colors.dart';


class InsightCard extends StatelessWidget {
  final List<String> insights;
  const InsightCard({super.key, required this.insights});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_outline, color: AppColors.blueGreyDark, size: 18),
              const SizedBox(width: 8),
              Text(
                'AI Budget Insights',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.blueGreyDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...insights.asMap().entries.map((entry) {
            final index = entry.key;
            final text = entry.value;
            Color dotColor = AppColors.blueGreyDark;
            if (index == 0) dotColor = AppColors.tealDark;
            if (text.toLowerCase().contains('budget') && text.toLowerCase().contains('over')) dotColor = AppColors.redDark;
            
            return Padding(
              padding: EdgeInsets.only(bottom: index == insights.length - 1 ? 0 : 12.0),
              child: _buildInsightRow(theme, dotColor, text),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildInsightRow(ThemeData theme, Color dotColor, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.navyDarker,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
