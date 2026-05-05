import 'package:flutter/material.dart';
import 'package:haribon/theme/app_colors.dart';


class TotalFuelCard extends StatelessWidget {
  const TotalFuelCard({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TOTAL FUEL NEEDED',
            style: textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: AppColors.navyDarker,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '23.2L',
            style: textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: AppColors.blueGreyDark,
              fontSize: 40,
            ),
          ),
          const SizedBox(height: 12),
          RichText(
            text: TextSpan(
              style: textTheme.bodySmall?.copyWith(color: AppColors.blueGreySecondary),
              children: [
                const TextSpan(text: 'Base Fuel '),
                TextSpan(text: '18.3L', style: textTheme.bodySmall?.copyWith(color: AppColors.blueGreyDark, fontWeight: FontWeight.bold)),
                const TextSpan(text: ' | Extra Fuel '),
                TextSpan(text: '+4.9L', style: textTheme.bodySmall?.copyWith(color: AppColors.redDark, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
