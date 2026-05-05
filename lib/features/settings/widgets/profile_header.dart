import 'package:flutter/material.dart';
import 'package:haribon/theme/app_colors.dart';


class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Alex Rivera',
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.navyDarker,
            fontSize: 24,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Pro Driver',
          style: textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            color: AppColors.blueGreyDark,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
