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
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: AppColors.containerLow,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.blueGreySecondary.withOpacity(0.2)),
    ),
    child: Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            style: textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.navyDarker,
              fontSize: 16,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
              hintText: 'Your name',
            ),
          ),
        ),
        const SizedBox(width: 8),
        const Icon(Icons.edit_outlined, size: 18, color: AppColors.blueGreySecondary),
      ],
    ),
  );
  }
}
