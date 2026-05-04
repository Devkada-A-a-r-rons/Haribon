import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import 'models/trip_summary_model.dart';
import 'widgets/summary_header.dart';
import 'widgets/hero_trip_card.dart';
import 'widgets/efficiency_score_gauge.dart';
import 'widgets/key_stats_grid.dart';
import 'widgets/fuel_stop_log.dart';
import 'widgets/ai_insight_card.dart';
import 'widgets/route_breakdown_chart.dart';
import 'widgets/summary_bottom_nav.dart';
import 'widgets/route_map_card.dart';

TripSummary _buildMockSummary() => TripSummary(
  origin: 'Manila',
  destination: 'Baguio City',
  date: 'May 3, 2026',
  duration: const Duration(hours: 6, minutes: 42),
  distanceKm: 248,
  efficiencyScore: 87,
  efficiencyRating: 'Excellent',
  efficiencyPercentile: 'Top 12% of Agila users this week',
  stats: const TripStats(
    fuelLiters: 18.4,
    fuelCostPhp: 1380,
    avgSpeedKmh: 62,
    co2SavedKg: 2.1,
    costVsEstimatePhp: -80,
  ),
  fuelStops: [
    FuelStop(
      stationName: 'Petron TPLEX Urdaneta',
      brand: 'Petron',
      liters: 10.2,
      pricePerLiter: 69.70,
      brandColor: const Color(0xFFE53935),
    ),
    FuelStop(
      stationName: 'Shell Kennon Road',
      brand: 'Shell',
      liters: 8.2,
      pricePerLiter: 82.00,
      brandColor: const Color(0xFFFFB300),
    ),
  ],
  aiInsight:
      'Maintaining a steady 80 km/h on TPLEX improved your fuel efficiency '
      'by 12% vs. your last trip. Avoiding the Baguio traffic window at 4 PM '
      'saved you approximately ₱45 in fuel.',
  routeSegments: [
    RouteSegment(
      label: 'SLEX / C5',
      duration: const Duration(hours: 1, minutes: 20),
      fraction: 0.20,
      color: SummaryColors.primary,
    ),
    RouteSegment(
      label: 'TPLEX',
      duration: const Duration(hours: 2, minutes: 45),
      fraction: 0.41,
      color: SummaryColors.primary,
    ),
    RouteSegment(
      label: 'Kennon Road',
      duration: const Duration(hours: 1, minutes: 30),
      fraction: 0.22,
      color: SummaryColors.amber,
    ),
    RouteSegment(
      label: 'Baguio City',
      duration: const Duration(hours: 1, minutes: 7),
      fraction: 0.17,
      color: SummaryColors.eco,
    ),
  ],
  treesEquivalent: 4,
);

/// The Trip Summary screen — assembles all modular summary widgets.
class TripSummaryScreen extends StatelessWidget {
  final TripSummary summary;

  const TripSummaryScreen({super.key, required this.summary});

  /// Convenience factory using built-in mock data (for quick preview).
  factory TripSummaryScreen.mock({Key? key}) =>
      TripSummaryScreen(key: key, summary: _buildMockSummary());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SummaryColors.surface,
      bottomNavigationBar: const SummaryBottomNavBar(activeIndex: 1),
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Sticky header ──────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: SummaryHeader(
                  destination: summary.destination,
                  date: summary.date,
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // 1. Hero trip card
                  HeroTripCard(
                    origin: summary.origin,
                    destination: summary.destination,
                    duration: summary.durationLabel,
                    distanceKm: summary.distanceKm,
                  ),
                  const SizedBox(height: 16),

                  // Map showing the route
                  const RouteMapCard(),
                  const SizedBox(height: 16),

                  // 2. Efficiency score gauge
                  EfficiencyScoreGauge(
                    score: summary.efficiencyScore,
                    rating: summary.efficiencyRating,
                    percentileLabel: summary.efficiencyPercentile,
                  ),
                  const SizedBox(height: 16),

                  // 3. Key stats 2×2 grid
                  KeyStatsGrid(stats: summary.stats),
                  const SizedBox(height: 16),

                  // 4. Fuel stop log
                  FuelStopLog(stops: summary.fuelStops),
                  const SizedBox(height: 16),

                  // 5. AI Pro insight
                  AiInsightCard(insight: summary.aiInsight),
                  const SizedBox(height: 16),

                  // 6. Route breakdown chart
                  RouteBreakdownChart(segments: summary.routeSegments),
                  const SizedBox(height: 16),

                  // 7. CTA footer
                  _CtaFooter(summary: summary),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CtaFooter extends StatelessWidget {
  final TripSummary summary;

  const _CtaFooter({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Primary CTA
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.map_rounded, size: 18),
            label: Text(
              'Plan Next Trip',
              style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: SummaryColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Secondary CTA
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.bar_chart_rounded, size: 18),
            label: Text(
              'View Monthly Report',
              style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: SummaryColors.primary,
              side: const BorderSide(color: SummaryColors.primary, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
