import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'summary_header.dart';
import 'package:haribon/theme/app_colors.dart';


/// MODULE: HERO TRIP CARD
/// Blue → Green gradient card showing route, duration, and distance.
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.bluePrimary, AppColors.greenDark],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.bluePrimary.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
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
              _HeroStat(
                icon: Icons.schedule_rounded,
                label: 'Duration',
                value: duration,
              ),
              const SizedBox(width: 24),
              _HeroStat(
                icon: Icons.route_rounded,
                label: 'Distance',
                value: '${distanceKm.toStringAsFixed(0)} km',
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
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.65),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                origin,
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.4,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white.withValues(alpha: 0.8),
                size: 20,
              ),
            ),
            Flexible(
              child: Text(
                destination,
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.4,
                ),
                overflow: TextOverflow.ellipsis,
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
            Icon(icon, color: Colors.white.withValues(alpha: 0.7), size: 14),
            const SizedBox(width: 5),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
}
