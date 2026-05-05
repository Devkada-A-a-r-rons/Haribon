import 'package:flutter/material.dart';
import 'package:haribon/theme/app_colors.dart';


class FuelReadinessCard extends StatelessWidget {
  const FuelReadinessCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.local_gas_station_outlined, color: AppColors.blueGreyDark),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.redSoftBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Refill Needed',
                  style: textTheme.labelSmall?.copyWith(color: AppColors.redDark, fontWeight: FontWeight.bold, fontSize: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('Fuel Readiness', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text('Current Tank: 8L (96km)', style: textTheme.bodySmall?.copyWith(color: AppColors.blueGreySecondary)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.greyLightest,
              borderRadius: BorderRadius.circular(8),
              border: const Border(left: BorderSide(color: AppColors.redDark, width: 3)),
            ),
            child: Text(
              'Warning: 10.3L more needed for the 220km trip to Baguio.',
              style: textTheme.bodySmall?.copyWith(color: AppColors.navyDarker, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
