import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'summary_header.dart';
import 'summary_shared.dart';
import '../models/trip_summary_model.dart';

/// MODULE: KEY STATS GRID
/// 2×2 grid of stat cards: fuel used, avg speed, CO₂ saved, cost vs estimate.
class KeyStatsGrid extends StatelessWidget {
  final TripStats stats;

  const KeyStatsGrid({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final underBudget = stats.costVsEstimatePhp <= 0;
    final budgetAbs = stats.costVsEstimatePhp.abs();

    final cards = [
      _StatData(
        emoji: '🔥',
        label: 'Fuel Used',
        value: '${stats.fuelLiters.toStringAsFixed(1)} L',
        subValue: '₱${stats.fuelCostPhp.toStringAsFixed(0)}',
        valueColor: null,
      ),
      _StatData(
        emoji: '⚡',
        label: 'Avg Speed',
        value: '${stats.avgSpeedKmh.toStringAsFixed(0)} km/h',
        subValue: 'highway average',
        valueColor: null,
      ),
      _StatData(
        emoji: '🌿',
        label: 'CO₂ Saved',
        value: '${stats.co2SavedKg.toStringAsFixed(1)} kg',
        subValue: 'vs. baseline route',
        valueColor: SummaryColors.eco,
      ),
      _StatData(
        emoji: '💰',
        label: 'vs. Estimate',
        value: underBudget
            ? '₱${budgetAbs.toStringAsFixed(0)} under'
            : '₱${budgetAbs.toStringAsFixed(0)} over',
        subValue: underBudget ? 'under budget 🎉' : 'over budget',
        valueColor: underBudget ? SummaryColors.eco : Colors.red,
      ),
    ];

    return Column(
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
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.55,
          ),
          itemBuilder: (_, i) => _StatCard(data: cards[i]),
        ),
      ],
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDBE5FF)),
        boxShadow: [
          BoxShadow(
            color: SummaryColors.primary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(data.emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  data.label,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF737687),
                    letterSpacing: 0.3,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            data.value,
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: data.valueColor ?? SummaryColors.primary,
              letterSpacing: -0.3,
            ),
          ),
          Text(
            data.subValue,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: const Color(0xFF9EA3B5),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
