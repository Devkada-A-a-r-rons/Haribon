import 'package:flutter/material.dart';
import 'package:haribon/theme/app_colors.dart';


class FuelReadinessCard extends StatelessWidget {
  final double distanceKm;
  final double litersPerKm;
  final double currentLiters;
  final String destination;

  const FuelReadinessCard({
    super.key,
    required this.distanceKm,
    required this.litersPerKm,
    required this.currentLiters,
    required this.destination,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    final fuelNeeded = distanceKm * litersPerKm;
    final isReady = currentLiters >= fuelNeeded;
    final deficit = fuelNeeded - currentLiters;
    final currentRange = currentLiters / litersPerKm;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.containerLowest,
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
              const Icon(Icons.local_gas_station_outlined, color: AppColors.primaryMain),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isReady ? AppColors.greenSoftBg : AppColors.redSoftBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isReady ? 'Ready' : 'Refill Needed',
                  style: textTheme.labelSmall?.copyWith(
                    color: isReady ? Colors.green.shade700 : AppColors.redDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('Fuel Readiness', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(
            'Current Tank: ${currentLiters.toStringAsFixed(1)}L (${currentRange.toStringAsFixed(0)}km range)',
            style: textTheme.bodySmall?.copyWith(color: AppColors.textTertiary),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.containerLow,
              borderRadius: BorderRadius.circular(8),
              border: Border(
                left: BorderSide(
                  color: isReady ? AppColors.primaryMain : AppColors.redDark,
                  width: 3,
                ),
              ),
            ),
            child: Text(
              isReady
                  ? 'You have enough fuel for the ${distanceKm.toStringAsFixed(0)}km trip to $destination.'
                  : 'Warning: ${deficit.toStringAsFixed(1)}L more needed for the ${distanceKm.toStringAsFixed(0)}km trip to $destination.',
              style: textTheme.bodySmall?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
