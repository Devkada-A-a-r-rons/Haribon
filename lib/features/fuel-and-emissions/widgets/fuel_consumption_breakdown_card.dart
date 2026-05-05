import 'package:flutter/material.dart';
import 'package:haribon/theme/app_colors.dart';


class FuelConsumptionBreakdownCard extends StatelessWidget {
  const FuelConsumptionBreakdownCard({super.key});

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
            'FUEL CONSUMPTION BREAKDOWN',
            style: textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: AppColors.navyDarker,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 16),
          // Stacked Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 16,
              child: Row(
                children: [
                  Expanded(flex: 70, child: Container(color: AppColors.blueGreyDark)), // Base
                  Expanded(flex: 10, child: Container(color: AppColors.orangePrimary)), // Traffic
                  Expanded(flex: 15, child: Container(color: AppColors.redDark)), // Terrain
                  Expanded(flex: 5, child: Container(color: AppColors.blueGreyLight)),  // Idle
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Grid
          Row(
            children: [
              Expanded(child: _buildLegendItem(textTheme, Icons.local_gas_station, AppColors.blueGreyDark, 'Base', '18.3L')),
              Expanded(child: _buildLegendItem(textTheme, Icons.directions_car, AppColors.orangePrimary, 'Traffic', '+1.5L')),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildLegendItem(textTheme, Icons.terrain, AppColors.redDark, 'Terrain', '+2.9L')),
              Expanded(child: _buildLegendItem(textTheme, Icons.timer, AppColors.blueGreyLight, 'Idle', '+0.5L')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(TextTheme textTheme, IconData icon, Color iconColor, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: iconColor),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: textTheme.labelSmall?.copyWith(color: AppColors.blueGreySecondary, fontSize: 10)),
            const SizedBox(height: 2),
            Text(value, style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700, color: AppColors.navyDarker)),
          ],
        ),
      ],
    );
  }
}
