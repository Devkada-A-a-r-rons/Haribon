import 'package:flutter/material.dart';
import 'package:haribon/theme/app_colors.dart';


class VisualBreakdownCard extends StatelessWidget {
  const VisualBreakdownCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            width: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 120,
                  width: 120,
                  child: CircularProgressIndicator(
                    value: 0.35,
                    backgroundColor: AppColors.greySoftBg,
                    color: AppColors.blueGreyDark,
                    strokeWidth: 16,
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Largest', style: theme.textTheme.labelSmall?.copyWith(color: AppColors.greyLightAccent, fontSize: 8)),
                    Text('Fuel', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.navyDarker)),
                    Text('35%', style: theme.textTheme.labelSmall?.copyWith(color: AppColors.greyLightAccent, fontSize: 10)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Visual Breakdown',
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColors.navyDarker,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildLegendRow(theme, AppColors.blueGreyDark, 'Fuel', '₱940 (35%)'),
          const SizedBox(height: 12),
          _buildLegendRow(theme, AppColors.tealDark, 'Food', '₱660 (25%)'),
          const SizedBox(height: 12),
          _buildLegendRow(theme, AppColors.bluePale, 'Tolls', '₱780 (29%)'),
          const SizedBox(height: 12),
          _buildLegendRow(theme, AppColors.greenLightBg, 'Parking', '₱300 (11%)'),
        ],
      ),
    );
  }

  Widget _buildLegendRow(ThemeData theme, Color dotColor, String label, String amount) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: theme.textTheme.bodySmall?.copyWith(color: AppColors.blueGreySecondary)),
        ),
        Text(amount, style: theme.textTheme.bodySmall?.copyWith(color: AppColors.navyDarker, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
