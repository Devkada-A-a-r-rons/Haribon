import 'package:flutter/material.dart';
import 'package:haribon/theme/app_colors.dart';


class OptimizationTipsCard extends StatelessWidget {
  const OptimizationTipsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.tealSoftBg, // light teal/blue tint
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_outline, color: AppColors.blueGreyDark, size: 22),
              const SizedBox(width: 12),
              Text(
                'Optimization Tips',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.blueGreyDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildBulletPoint(textTheme, 'Avoid peak traffic to save ₱300 on this route next time.'),
          const SizedBox(height: 16),
          _buildBulletPoint(textTheme, 'Maintain steady speed for efficiency; avoid sudden braking in hilly areas.'),
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
          child: Icon(Icons.circle, size: 6, color: AppColors.blueGreyDark),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.navyDarker,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
