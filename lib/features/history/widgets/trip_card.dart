import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../theme/app_colors.dart'; // Ensure this import is still correct

// New implementation of TripCard with a different UI style.
// Preserves all given information but replaces the layout and look.
// Background image is fixed, no map feature.

class TripCard extends StatelessWidget {
  final String route;
  final String badgeText;
  final String date;
  final String distance;
  final String fuelUsed;
  final String cost;
  final VoidCallback onTap;

  const TripCard({
    super.key,
    required this.route,
    required this.badgeText,
    required this.date,
    required this.distance,
    required this.fuelUsed,
    required this.cost,
    required this.onTap,
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
            // Fixed background image - Copy style
            Image.asset(
              'assets/scenic_road_trip.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: AppColors.primaryLight,
                child: const Icon(Icons.image, size: 50, color: AppColors.primaryMain),
              ),
            ),

            // Gradient overlay for text readability
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

            // Top left badge
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
                  badgeText, // Use the badgeText property
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            // Map feature - REMOVED, as per user's request.

            // Bottom info overlay containing all the data
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
                    // Route information
                    Text(
                      route,
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
                    // Date or current journey information
                    Text(
                      date,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.white70,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Statistics Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _buildStatItem('DISTANCE', distance),
                        const SizedBox(width: 24),
                        _buildStatItem('FUEL USED', fuelUsed),
                        const SizedBox(width: 24),
                        _buildStatItem('COST', cost),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // "VIEW DETAILS" button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: onTap,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white60, width: 1.5),
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          backgroundColor: Colors.transparent,
                        ),
                        child: Text(
                          'VIEW DETAILS', // Use original button text
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

  // Helper function to build a statistic column with specific styling.
  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 9, // Small font size
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
            color: Colors.white, // No specific color, just white
            shadows: [
              // Use text shadows for readability on complex background
              Shadow(color: Colors.black45, blurRadius: 6, offset: Offset(0, 1)),
            ],
          ),
        ),
      ],
    );
  }
}