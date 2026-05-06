import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'summary_header.dart';
import 'summary_shared.dart';
import '../models/trip_summary_model.dart';
import 'package:haribon/theme/app_colors.dart';


/// MODULE: KEY STATS GRID
class KeyStatsGrid extends StatelessWidget {
  final TripStats stats;

  const KeyStatsGrid({super.key, required this.stats});

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
            itemBuilder: (_, i) => _StatCard(data: cards[i]),
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

  const _StatCard({required this.data});

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

