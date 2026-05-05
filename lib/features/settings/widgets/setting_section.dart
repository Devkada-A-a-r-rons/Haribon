import 'package:flutter/material.dart';
import 'segmented_toggle.dart';
import 'package:haribon/theme/app_colors.dart';


class SettingSection extends StatelessWidget {
  final IconData icon;
  final String sectionTitle;
  final String question;
  final List<String> options;
  final int initialIndex;
  final ValueChanged<int> onChanged;

  const SettingSection({
    super.key,
    required this.icon,
    required this.sectionTitle,
    required this.question,
    required this.options,
    required this.initialIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: AppColors.blueGreyDark),
            const SizedBox(width: 8),
            Text(
              sectionTitle.toUpperCase(),
              style: textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: AppColors.blueGreySecondary,
                fontSize: 10,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          question,
          style: textTheme.bodyMedium?.copyWith(
            color: AppColors.navyDarker,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        SegmentedToggle(
          options: options,
          initialIndex: initialIndex,
          onChanged: onChanged,
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
