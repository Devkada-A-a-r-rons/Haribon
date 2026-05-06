import 'package:flutter/material.dart';
import 'package:haribon/theme/app_colors.dart';


class TotalCo2Card extends StatelessWidget {
  final double co2;
  const TotalCo2Card({super.key, required this.co2});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final trees = (co2 / 20.0).ceil(); // Rough estimate: 20kg CO2 per tree per year

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
            'TOTAL CO2',
            style: textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: AppColors.textPrimary,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${co2.toStringAsFixed(1)} kg',
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.success,
              fontSize: 28,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.park, size: 16, color: AppColors.success),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Equivalent to $trees tree${trees == 1 ? '' : 's'} needed to offset',
                  style: textTheme.bodySmall?.copyWith(color: AppColors.success),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
