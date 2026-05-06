import 'package:flutter/material.dart';
import 'package:haribon/theme/app_colors.dart';

class ProfileHeader extends StatelessWidget {
  final TextEditingController controller;

  const ProfileHeader({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.navyDarker,
                  fontSize: 24,
                  fontFeatures: [],
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.tealDark),
                  ),
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.edit_outlined, size: 20, color: AppColors.blueGreySecondary),
          ],
        ),
        const SizedBox(height: 8),
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
