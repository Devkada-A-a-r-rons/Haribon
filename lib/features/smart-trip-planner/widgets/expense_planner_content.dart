import 'package:flutter/material.dart';
import 'package:haribon/theme/app_colors.dart';


class ExpensePlannerContent extends StatefulWidget {
  const ExpensePlannerContent({super.key});

  @override
  State<ExpensePlannerContent> createState() => _ExpensePlannerContentState();
}

class _ExpensePlannerContentState extends State<ExpensePlannerContent> {
  bool _accommodationEnabled = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Food & Dining
        Row(
          children: [
            const Icon(Icons.restaurant, size: 16, color: AppColors.primaryMain),
            const SizedBox(width: 8),
            Text('Food & Dining', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildInputBox(theme, 'Travelers', '4')),
            const SizedBox(width: 12),
            Expanded(child: _buildInputBox(theme, 'Meals', '3')),
          ],
        ),
        const SizedBox(height: 12),
        Text('Style', style: theme.textTheme.labelSmall?.copyWith(color: AppColors.textTertiary)),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildChoiceChip(theme, 'Mixed', true),
            const SizedBox(width: 8),
            _buildChoiceChip(theme, 'Budget', false),
            const SizedBox(width: 8),
            _buildChoiceChip(theme, 'Fine', false),
          ],
        ),
        const SizedBox(height: 24),
        
        // Accommodation
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.bed, size: 16, color: AppColors.primaryMain),
                const SizedBox(width: 8),
                Text('Accommodation', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
              ],
            ),
            SizedBox(
              height: 24,
              child: Switch(
                value: _accommodationEnabled, 
                onChanged: (v) {
                  setState(() {
                    _accommodationEnabled = v;
                  });
                }, 
                activeColor: AppColors.primaryMain
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildInputBox(theme, 'Nights', '1')),
            const SizedBox(width: 12),
            Expanded(child: _buildInputBox(theme, 'Rooms', '1')),
          ],
        ),
        const SizedBox(height: 12),
        Text('Type', style: theme.textTheme.labelSmall?.copyWith(color: AppColors.textTertiary)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: AppColors.containerLow, borderRadius: BorderRadius.circular(8)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Airbnb', style: theme.textTheme.bodySmall),
              const Icon(Icons.keyboard_arrow_down, size: 16),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Tolls
        _buildExpenseSummaryItem(theme, Icons.toll, 'Tolls (NLEX/TPLEX)', 'class 1 vehicle', '₱780'),
        const SizedBox(height: 12),
        // Parking
        _buildExpenseSummaryItem(theme, Icons.local_parking, 'Parking Fees', 'Est. 2 Full Days', '₱300'),
      ],
    );
  }

  Widget _buildInputBox(ThemeData theme, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelSmall?.copyWith(color: AppColors.textTertiary)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.containerLow,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(value, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildChoiceChip(ThemeData theme, String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryMain : AppColors.containerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: isSelected ? Colors.white : AppColors.textTertiary,
        ),
      ),
    );
  }

  Widget _buildExpenseSummaryItem(ThemeData theme, IconData icon, String title, String subtitle, String amount) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.greyLight),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: AppColors.greySoftBg, shape: BoxShape.circle),
            child: Icon(icon, size: 16, color: AppColors.primaryMain),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                Text(subtitle, style: theme.textTheme.labelSmall?.copyWith(color: AppColors.textTertiary)),
              ],
            ),
          ),
          Text(amount, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
