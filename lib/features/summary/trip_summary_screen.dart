import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:haribon/features/summary/widgets/summary_header.dart';
import '../../theme/app_colors.dart';
import 'models/trip_summary_model.dart';
import 'widgets/hero_trip_card.dart';
import 'widgets/efficiency_score_gauge.dart';
import 'widgets/key_stats_grid.dart';
import 'widgets/fuel_stop_log.dart';
import 'widgets/ai_insight_card.dart';
import 'widgets/route_breakdown_chart.dart';
import 'widgets/route_map_card.dart';
import '../monthly-report/monthly_report_screen.dart';


TripSummary _buildMockSummary() => TripSummary(
  origin: 'Manila',
  destination: 'Baguio City',
  date: 'May 3, 2026',
  duration: const Duration(hours: 6, minutes: 42),
  distanceKm: 248,
  efficiencyScore: 87,
  efficiencyRating: 'Excellent',
  efficiencyPercentile: 'Top 12% of Haribon users this week',
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
      brandColor: AppColors.redPrimary,
    ),
    FuelStop(
      stationName: 'Shell Kennon Road',
      brand: 'Shell',
      liters: 8.2,
      pricePerLiter: 82.00,
      brandColor: AppColors.amberAccent,
    ),
  ],
  aiInsight:
      'Maintaining a steady 80 km/h on TPLEX improved your fuel efficiency '
      'by 12% vs. your last trip. Avoiding the Baguio traffic window at 4 PM '
      'saved you approximately â‚±45 in fuel.',
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

class TripSummaryScreen extends StatelessWidget {
  final TripSummary summary;
  final VoidCallback? onSeeTimeline;
  final VoidCallback? onPlanNext;
  final VoidCallback? onViewAnalysis;
  final ScrollController? scrollController;

  const TripSummaryScreen({
    super.key, 
    required this.summary,
    this.onSeeTimeline,
    this.onPlanNext,
    this.onViewAnalysis,
    this.scrollController,
  });

  factory TripSummaryScreen.mock({Key? key}) =>
      TripSummaryScreen(key: key, summary: TripSummaryScreen.mock().summary);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Container(
      color: AppColors.surfaceMain,
      child: SafeArea(
        bottom: false,
        child: CustomScrollView(
          controller: scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                       Text(
                  'Trip Summary',
                  style: textTheme.headlineMedium?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Here\'s what happened during your trip.',
                  style: textTheme.bodyMedium?.copyWith(
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 8),
                  HeroTripCard(
                    origin: summary.origin,
                    destination: summary.destination,
                    duration: summary.durationLabel,
                    distanceKm: summary.distanceKm,
                  ),
                  const SizedBox(height: 16),
                  RouteMapCard(
                    originName: summary.origin,
                    destinationName: summary.destination,
                  ),
               
                  const SizedBox(height: 16),
                  EfficiencyScoreGauge(
                    score: summary.efficiencyScore,
                    rating: summary.efficiencyRating,
                    percentileLabel: summary.efficiencyPercentile,
                  ),
                  const SizedBox(height: 16),
                  KeyStatsGrid(stats: summary.stats),
                  const SizedBox(height: 16),
                  FuelStopLog(stops: summary.fuelStops),
                  const SizedBox(height: 16),
                  
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: onSeeTimeline,
                      icon: const Icon(Icons.timeline_rounded, size: 18),
                      label: Text(
                        'SEE TRIP TIMELINE',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryMain,
                        side: const BorderSide(color: AppColors.primaryMain, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  AiInsightCard(insight: summary.aiInsight),
                  const SizedBox(height: 16),
                  RouteBreakdownChart(segments: summary.routeSegments),
                  const SizedBox(height: 16),
                  _CtaFooter(
                    onPlanNext: onPlanNext,
                    onViewAnalysis: onViewAnalysis,
                  ),
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
  final VoidCallback? onPlanNext;
  final VoidCallback? onViewAnalysis;
  const _CtaFooter({this.onPlanNext, this.onViewAnalysis});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: onPlanNext,
            icon: const Icon(Icons.map_rounded, size: 18),
            label: Text(
              'Plan Next Trip',
              style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700),
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
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              // Navigate to Monthly Report screen
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const MonthlyReportScreen(),
                ),
              );
            },
            icon: const Icon(Icons.bar_chart_rounded, size: 18),
            label: Text(
              'View Monthly Report',
              style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
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
        const SizedBox(height: 10),
      ],
    );
  }
}

