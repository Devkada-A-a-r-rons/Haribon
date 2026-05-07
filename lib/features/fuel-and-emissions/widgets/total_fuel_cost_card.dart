import 'package:flutter/material.dart';
import 'package:haribon/theme/app_colors.dart';


class TotalFuelCostCard extends StatelessWidget {
  final double cost;
  final double extraCost;
  final double fuelPricePerLiter;

  const TotalFuelCostCard({
    super.key,
    required this.cost,
    this.extraCost = 0,
    this.fuelPricePerLiter = 65.0,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    // Use the real extra cost from road conditions, or fallback to 15%
    final extra = extraCost > 0 ? extraCost : cost * 0.15;

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
            '+₱${extra.toStringAsFixed(0)} from road\nconditions.',
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.textTertiary,
              fontSize: 11,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
