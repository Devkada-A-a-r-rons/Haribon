import 'package:flutter/material.dart';
import 'package:haribon/theme/app_colors.dart';


class OptimizationTipsCard extends StatelessWidget {
  final List<String> tips;
  const OptimizationTipsCard({super.key, required this.tips});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.containerLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_outline, color: AppColors.primaryMain, size: 22),
              const SizedBox(width: 12),
              Text(
                'Optimization Tips',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryMain,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...tips.asMap().entries.map((entry) {
            final idx = entry.key;
            final text = entry.value;
            return Padding(
              padding: EdgeInsets.only(bottom: idx == tips.length - 1 ? 0 : 16),
              child: _buildBulletPoint(textTheme, text),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(TextTheme textTheme, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 6.0),
          child: Icon(Icons.circle, size: 6, color: AppColors.primaryMain),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
