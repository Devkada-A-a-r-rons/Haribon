import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_colors.dart';
import '../../summary/models/trip_summary_model.dart';

class TripCard extends StatelessWidget {
  final TripSummary? summary;

  final String? route;
  final String? badgeTextOverride;
  final String? date;
  final String? distance;
  final String? efficiency;
  final Color? efficiencyColor;

  final String cost;
  final String buttonText;
  final VoidCallback? onActionButton;
  final VoidCallback? onViewMap;
  final Widget? imageWidget;

  const TripCard({
    super.key,
    this.summary,
    this.route,
    this.badgeTextOverride,
    this.date,
    this.distance,
    this.efficiency,
    this.efficiencyColor,
    required this.cost,
    required this.buttonText,
    this.onActionButton,
    this.onViewMap,
    this.imageWidget,
  }) : assert(
          summary != null || route != null,
          'Either summary or route must be provided.',
        );


  String get _badgeText {
    if (badgeTextOverride != null) return badgeTextOverride!;
    if (summary != null) {
      return summary!.efficiencyRating == 'Active Plan' ? 'Active Plan' : 'Latest Trip';
    }
    return 'Trip';
  }

  String get _route =>
      route ?? (summary != null ? '${summary!.origin} to ${summary!.destination}' : '');

  String get _date => date ?? summary?.date ?? '';

  String get _distance =>
      distance ?? (summary != null ? '${summary!.distanceKm.toInt()} km' : '');

  String? get _efficiency =>
      efficiency ?? (summary != null ? '${summary!.efficiencyScore}/100' : null);

  Color get _efficiencyColor => efficiencyColor ?? AppColors.success;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onActionButton,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: SizedBox(
          height: 280,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background image
              imageWidget != null
                  ? Opacity(opacity: 0.85, child: SizedBox.expand(child: imageWidget!))
                  : Image.asset(
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

              // Top-left badge
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
                    _badgeText,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              // Top-right map button
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
                        _route,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.2,
                          shadows: const [
                            Shadow(color: Colors.black54, blurRadius: 8, offset: Offset(0, 2)),
                            Shadow(color: Colors.black38, blurRadius: 16, offset: Offset(0, 4)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _date,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.white70,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _TripStat(label: 'DISTANCE', value: _distance),
                          const SizedBox(width: 20),
                          if (_efficiency != null) ...[
                            _TripStat(
                              label: 'EFFICIENCY',
                              value: _efficiency!,
                              valueColor: _efficiencyColor,
                            ),
                            const SizedBox(width: 20),
                          ],
                          _TripStat(label: 'COST', value: cost),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: onActionButton,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white60, width: 1.5),
                            shape: const StadiumBorder(),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            backgroundColor: Colors.transparent,
                          ),
                          child: Text(
                            buttonText,
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