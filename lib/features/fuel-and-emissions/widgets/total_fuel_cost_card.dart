import 'package:flutter/material.dart';
import 'package:haribon/theme/app_colors.dart';


class TotalFuelCostCard extends StatelessWidget {
  final double cost;
  const TotalFuelCostCard({super.key, required this.cost});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final extraCost = cost * 0.15;

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
            'TOTAL FUEL COST',
            style: textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: AppColors.textPrimary,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '₱${cost.toStringAsFixed(0)}',
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.primaryMain,
              fontSize: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '+₱${extraCost.toStringAsFixed(0)} from road conditions.',
            style: textTheme.bodySmall?.copyWith(color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }
}
