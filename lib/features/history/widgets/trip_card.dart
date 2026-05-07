import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../theme/app_colors.dart';
import 'package:intl/intl.dart';

class TripCard extends StatelessWidget {
  final String route;
  final String badgeText;
  final String date;
  final String distance;
  final String fuelUsed;
  final String cost;
  final VoidCallback onTap;
  final VoidCallback? onViewMap;
  final Widget? imageWidget;

  const TripCard({
    super.key,
    required this.route,
    required this.badgeText,
    required this.date,
    required this.distance,
    required this.fuelUsed,
    required this.cost,
    required this.onTap,
    this.onViewMap,
    this.imageWidget,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          // No fixed height here! It will scale with content.
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              // 1. Background Image - Positioned.fill makes it match the content size
              Positioned.fill(
                child: Opacity(
                  opacity: 0.6,
                  child: imageWidget ??
                      Image.asset(
                        'assets/scenic_road_trip.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: AppColors.primaryLight.withOpacity(0.2),
                          child: const Icon(Icons.image, size: 50, color: Colors.white24),
                        ),
                      ),
                ),
              ),

              // 2. Gradient Overlay - Also matches content size
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.0, 0.5, 1.0],
                      colors: [
                        Colors.black.withOpacity(0.4),
                        Colors.black.withOpacity(0.2),
                        Colors.black.withOpacity(0.9),
                      ],
                    ),
                  ),
                ),
              ),

              // 3. MAIN CONTENT - This "pushes" the height of the card
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Extra spacing at the top so text doesn't hit the Badge
                    const SizedBox(height: 45),
                    
                    Text(
                      route,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.2,
                        shadows: [
                          const Shadow(blurRadius: 10, color: Colors.black45),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      date,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Stats Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStat('DIST', distance),
                        _buildStat('FUEL', fuelUsed),
                        _buildStat('COST', cost),
                        if (onViewMap != null)
                          ElevatedButton.icon(
                            onPressed: onViewMap,
                            icon: const Icon(Icons.map_outlined, size: 14),
                            label: const Text("MAP"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.2),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // 4. Floating Badge - Keeps its position relative to the top
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryMain.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Text(
                    badgeText,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 9, color: Colors.white60, fontWeight: FontWeight.w600)),
        Text(value, style: GoogleFonts.poppins(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w700)),
      ],
    );
  }
}
