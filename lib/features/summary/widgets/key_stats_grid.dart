import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'summary_header.dart';
import 'summary_shared.dart';
import '../models/trip_summary_model.dart';
import 'package:haribon/theme/app_colors.dart';


/// MODULE: KEY STATS GRID
class KeyStatsGrid extends StatelessWidget {
  final TripStats stats;
  final Function(double)? onEditBudget;

  const KeyStatsGrid({super.key, required this.stats, this.onEditBudget});

  @override
  Widget build(BuildContext context) {
    final underBudget = stats.costVsEstimatePhp <= 0;
    final budgetAbs = stats.costVsEstimatePhp.abs();

    final cards = [
      _StatData(
        emoji: '',
        label: 'Fuel Used',
        value: '${stats.fuelLiters.toStringAsFixed(1)} L',
        subValue: '\u20B1${stats.fuelCostPhp.toStringAsFixed(0)}',
        valueColor: null,
      ),
      _StatData(
        emoji: '',
        label: 'Avg Speed',
        value: '${stats.avgSpeedKmh.toStringAsFixed(0)} km/h',
        subValue: 'highway average',
        valueColor: null,
      ),
      _StatData(
        emoji: '',
        label: 'CO\u2082 Saved',
        value: '${stats.co2SavedKg.toStringAsFixed(1)} kg',
        subValue: 'vs. baseline route',
        valueColor: SummaryColors.eco,
      ),
      _StatData(
        emoji: '',
        label: 'vs. Estimate',
        value: underBudget
            ? '\u20B1${budgetAbs.toStringAsFixed(0)} under'
            : '\u20B1${budgetAbs.toStringAsFixed(0)} over',
        subValue: underBudget ? 'under budget' : 'over budget',
        valueColor: underBudget ? SummaryColors.eco : Colors.red,
      ),
    ];

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel(label: 'TRIP STATISTICS'),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cards.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.45,
            ),
            itemBuilder: (_, i) {
              final isBudgetCard = cards[i].label == 'vs. Estimate';
              return GestureDetector(
                onTap: isBudgetCard && onEditBudget != null ? () => _showEditBudgetDialog(context) : null,
                child: _StatCard(
                  data: cards[i],
                  isActionable: isBudgetCard && onEditBudget != null,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showEditBudgetDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceMain,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Edit Trip Budget', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Adjust your planned budget for this journey.', 
              style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 20),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Enter new budget',
                prefixText: '₱ ',
                filled: true,
                fillColor: AppColors.containerLow,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins(color: AppColors.textTertiary)),
          ),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(controller.text);
              if (val != null && val > 0) {
                onEditBudget!(val);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryMain,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Save', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _StatData {
  final String emoji;
  final String label;
  final String value;
  final String subValue;
  final Color? valueColor;

  const _StatData({
    required this.emoji,
    required this.label,
    required this.value,
    required this.subValue,
    this.valueColor,
  });
}

class _StatCard extends StatelessWidget {
  final _StatData data;
  final bool isActionable;

  const _StatCard({required this.data, this.isActionable = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.greySoftBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                data.label,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textTertiary,
                  letterSpacing: 0.3,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              if (isActionable)
                const Icon(Icons.edit_outlined, size: 12, color: AppColors.textTertiary),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            data.value,
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: data.valueColor ?? AppColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          Text(
            data.subValue,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: AppColors.textTertiary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

