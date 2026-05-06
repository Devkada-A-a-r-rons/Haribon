import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_colors.dart';
import '../../summary/models/trip_summary_model.dart';

class HomeLatestTripCard extends StatelessWidget {
  final TripSummary summary;
  final VoidCallback? onViewSummary;
  final VoidCallback? onViewMap;

  const HomeLatestTripCard({
    super.key,
    required this.summary,
    this.onViewSummary,
    this.onViewMap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        height: 260,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            Image.asset(
              'assets/scenic_road_trip.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: AppColors.primaryLight,
                child: const Icon(Icons.image, size: 50, color: AppColors.primaryMain),
              ),
            ),

            // Gradient overlay
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.35, 1.0],
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black87,
                  ],
                ),
              ),
            ),

            // Top badge
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24),
                ),
                child: Text(
                  summary.efficiencyRating == 'Active Plan' ? 'Active Plan' : 'Latest Trip',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            // Map view button
            Positioned(
              top: 16,
              right: 16,
              child: GestureDetector(
                onTap: onViewMap,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Icon(Icons.map_rounded, color: Colors.white, size: 20),
                ),
              ),
            ),

            // Bottom info overlay
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${summary.origin} to ${summary.destination}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.2,
                        shadows: [
                          Shadow(color: Colors.black54, blurRadius: 8, offset: Offset(0, 2)),
                          Shadow(color: Colors.black38, blurRadius: 16, offset: Offset(0, 4)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      summary.date,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.white70,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _TripStat(label: 'DISTANCE', value: '${summary.distanceKm.toInt()} km'),
                        const SizedBox(width: 24),
                        _TripStat(
                          label: 'EFFICIENCY',
                          value: '${summary.efficiencyScore}/100',
                          valueColor: AppColors.success,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: onViewSummary,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white60, width: 1.5),
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          backgroundColor: Colors.transparent,
                        ),
                        child: Text(
                          'View Full Summary',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TripStat extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _TripStat({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: Colors.white60,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: valueColor ?? Colors.white,
          ),
        ),
      ],
    );
  }
}
