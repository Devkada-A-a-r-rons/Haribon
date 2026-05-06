import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'summary_header.dart';
import 'package:haribon/theme/app_colors.dart';


/// MODULE: HERO TRIP CARD
/// Blue â†’ Green gradient card showing route, duration, and distance.
class HeroTripCard extends StatelessWidget {
  final String origin;
  final String destination;
  final String duration;
  final double distanceKm;

  const HeroTripCard({
    super.key,
    required this.origin,
    required this.destination,
    required this.duration,
    required this.distanceKm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.containerLowest,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Route label
          _RouteLabel(origin: origin, destination: destination),
          const SizedBox(height: 20),

          // Stats row
          Row(
            children: [
              Expanded(
                child: _HeroStat(
                  icon: Icons.schedule_rounded,
                  label: 'Duration',
                  value: duration,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _HeroStat(
                  icon: Icons.route_rounded,
                  label: 'Distance',
                  value: '${distanceKm.toStringAsFixed(0)} km',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RouteLabel extends StatelessWidget {
  final String origin;
  final String destination;

  const _RouteLabel({required this.origin, required this.destination});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'COMPLETED TRIP',
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryMain,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              origin,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: -0.4,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.textTertiary,
                size: 20,
              ),
            ),
            Text(
              destination,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: -0.4,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _HeroStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _HeroStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.textTertiary, size: 14),
            const SizedBox(width: 5),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: AppColors.textTertiary,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
        ),
      ],
    );
  }
}

