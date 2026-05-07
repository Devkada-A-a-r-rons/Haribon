import 'package:flutter/material.dart';
import 'package:haribon/theme/app_colors.dart';


class TotalFuelCard extends StatelessWidget {
  final double liters;
  final double baseLiters;
  final double extraLiters;

  const TotalFuelCard({
    super.key,
    required this.liters,
    this.baseLiters = 0,
    this.extraLiters = 0,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    // Use provided values or fallback to proportional split
    final base = baseLiters > 0 ? baseLiters : liters * 0.85;
    final extra = extraLiters > 0 ? extraLiters : liters * 0.15;

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
            'TOTAL FUEL USED',
            style: textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: AppColors.textPrimary,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${liters.toStringAsFixed(1)}L',
            style: textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: AppColors.primaryMain,
              fontSize: 40,
            ),
          ),
          const SizedBox(height: 12),
          RichText(
            text: TextSpan(
              style: textTheme.bodySmall?.copyWith(color: AppColors.textTertiary),
              children: [
                const TextSpan(text: 'Base Fuel '),
                TextSpan(text: '${base.toStringAsFixed(1)}L', style: textTheme.bodySmall?.copyWith(color: AppColors.primaryMain, fontWeight: FontWeight.bold)),
                const TextSpan(text: ' | Extra Fuel '),
                TextSpan(text: '+${extra.toStringAsFixed(1)}L', style: textTheme.bodySmall?.copyWith(color: AppColors.redDark, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
