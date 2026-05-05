import 'package:flutter/material.dart';
import 'package:haribon/theme/app_colors.dart';


class TotalFuelCard extends StatelessWidget {
  final double liters;
  const TotalFuelCard({super.key, required this.liters});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final baseLiters = liters * 0.85;
    final extraLiters = liters * 0.15;

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
            'TOTAL FUEL USED',
            style: textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: AppColors.navyDarker,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${liters.toStringAsFixed(1)}L',
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
                TextSpan(text: '${baseLiters.toStringAsFixed(1)}L', style: textTheme.bodySmall?.copyWith(color: AppColors.blueGreyDark, fontWeight: FontWeight.bold)),
                const TextSpan(text: ' | Extra Fuel '),
                TextSpan(text: '+${extraLiters.toStringAsFixed(1)}L', style: textTheme.bodySmall?.copyWith(color: AppColors.redDark, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
