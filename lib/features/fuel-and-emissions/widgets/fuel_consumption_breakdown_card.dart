import 'package:flutter/material.dart';
import 'package:haribon/theme/app_colors.dart';


class FuelConsumptionBreakdownCard extends StatelessWidget {
  final double totalLiters;
  final double trafficLiters;

  const FuelConsumptionBreakdownCard({
    super.key,
    required this.totalLiters,
    required this.trafficLiters,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    
    // Proportional breakdown logic
    final base = totalLiters * 0.75;
    final traffic = trafficLiters;
    final terrain = totalLiters * 0.08;
    final idle = totalLiters * 0.02;

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
            'FUEL CONSUMPTION BREAKDOWN',
            style: textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: AppColors.textPrimary,
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
                children: totalLiters > 0 ? [
                  Expanded(flex: (base * 100 / totalLiters).toInt().clamp(1, 100), child: Container(color: AppColors.primaryMain)),
                  Expanded(flex: (traffic * 100 / totalLiters).toInt().clamp(1, 100), child: Container(color: AppColors.orangePrimary)),
                  Expanded(flex: (terrain * 100 / totalLiters).toInt().clamp(1, 100), child: Container(color: AppColors.redDark)),
                  Expanded(flex: (idle * 100 / totalLiters).toInt().clamp(1, 100), child: Container(color: AppColors.surfaceDim)),
                ] : [
                  Expanded(child: Container(color: AppColors.surfaceDim)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Grid
          Row(
  children: [
    Expanded(child: _buildLegendItem(textTheme, Icons.local_gas_station, AppColors.primaryMain, 'Base', '${base.toStringAsFixed(1)}L')),
    Expanded(child: _buildLegendItem(textTheme, Icons.directions_car, AppColors.orangePrimary, 'Traffic', '+${traffic.toStringAsFixed(1)}L')),
    Expanded(child: _buildLegendItem(textTheme, Icons.terrain, AppColors.redDark, 'Terrain', '+${terrain.toStringAsFixed(1)}L')),
    Expanded(child: _buildLegendItem(textTheme, Icons.timer, AppColors.surfaceDim, 'Idle', '+${idle.toStringAsFixed(1)}L')),
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
            Text(label, style: textTheme.labelSmall?.copyWith(color: AppColors.textTertiary, fontSize: 10)),
            const SizedBox(height: 2),
            Text(value, style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          ],
        ),
      ],
    );
  }
}
