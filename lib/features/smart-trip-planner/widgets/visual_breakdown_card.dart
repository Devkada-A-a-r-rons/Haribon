import 'package:flutter/material.dart';
import 'package:haribon/theme/app_colors.dart';


class VisualBreakdownCard extends StatefulWidget {
  final double fuelCost;
  final double tollCost;
  final double otherCost;
  final double? distanceKm;
  final double? kmPerLiter;
  final double? fuelPrice;

  const VisualBreakdownCard({
    super.key,
    required this.fuelCost,
    required this.tollCost,
    required this.otherCost,
    this.distanceKm,
    this.kmPerLiter,
    this.fuelPrice,
  });

  @override
  State<VisualBreakdownCard> createState() => _VisualBreakdownCardState();
}

class _VisualBreakdownCardState extends State<VisualBreakdownCard> {
  bool _showDetails = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = widget.fuelCost + widget.tollCost + widget.otherCost;
    
    if (total == 0) return const SizedBox.shrink();

    final fuelPct = widget.fuelCost / total;
    final tollPct = widget.tollCost / total;
    final otherPct = widget.otherCost / total;

    String largestCategory = 'Fuel';
    double largestPct = fuelPct;
    if (tollPct > largestPct) { largestCategory = 'Tolls'; largestPct = tollPct; }
    if (otherPct > largestPct) { largestCategory = 'Food/Misc'; largestPct = otherPct; }

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
                    value: largestPct,
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
                    Text(largestCategory, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.navyDarker, fontSize: 14)),
                    Text('${(largestPct * 100).toStringAsFixed(0)}%', style: theme.textTheme.labelSmall?.copyWith(color: AppColors.greyLightAccent, fontSize: 10)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Visual Breakdown',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.navyDarker,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: () => setState(() => _showDetails = !_showDetails),
                icon: Icon(_showDetails ? Icons.visibility_off_outlined : Icons.calculate_outlined, size: 14),
                label: Text(_showDetails ? 'Hide Detail' : 'Show Math', style: const TextStyle(fontSize: 10)),
                style: TextButton.styleFrom(foregroundColor: AppColors.tealPrimary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildLegendRow(theme, AppColors.blueGreyDark, 'Fuel', '₱${widget.fuelCost.toStringAsFixed(0)} (${(fuelPct * 100).toStringAsFixed(0)}%)'),
          const SizedBox(height: 12),
          _buildLegendRow(theme, AppColors.bluePale, 'Tolls', '₱${widget.tollCost.toStringAsFixed(0)} (${(tollPct * 100).toStringAsFixed(0)}%)'),
          const SizedBox(height: 12),
          _buildLegendRow(theme, AppColors.tealDark, 'Food/Misc', '₱${widget.otherCost.toStringAsFixed(0)} (${(otherPct * 100).toStringAsFixed(0)}%)'),
          
          if (_showDetails) ...[
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Computation Breakdown', style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.navyDarker)),
            ),
            const SizedBox(height: 8),
            _buildMathRow(theme, 'Fuel', '(${widget.distanceKm?.toStringAsFixed(0)}km ÷ ${widget.kmPerLiter?.toStringAsFixed(1)}km/L) × ₱${widget.fuelPrice?.toStringAsFixed(1)}'),
            _buildMathRow(theme, 'Tolls', 'NLEX/TPLEX standard rates for Class 1 vehicle'),
            _buildMathRow(theme, 'Misc', 'Base food/emergency allocation'),
          ],
        ],
      ),
    );
  }

  Widget _buildMathRow(ThemeData theme, String label, String formula) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.blueGreySecondary)),
          Text(formula, style: const TextStyle(fontSize: 10, color: AppColors.navyDarker, fontStyle: FontStyle.italic)),
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
