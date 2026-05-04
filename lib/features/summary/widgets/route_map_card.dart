import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_colors.dart';

class RouteMapCard extends StatelessWidget {
  const RouteMapCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Rough coordinates for Manila and Baguio
    final manila = const LatLng(14.5995, 120.9842);
    final baguio = const LatLng(16.4023, 120.5960);

    return Container(
      height: 200,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surfaceMain,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryLight, width: 1),
      ),
      child: FlutterMap(
        options: MapOptions(
          initialCenter: const LatLng(15.45, 120.7), // Center between Manila & Baguio
          initialZoom: 7.5,
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.none, // Static map for summary
          ),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.haribon',
          ),
          PolylineLayer(
            polylines: [
              Polyline(
                points: [
                  manila,
                  const LatLng(15.04, 120.68), // NLEX approximation
                  const LatLng(15.50, 120.60), // TPLEX approximation
                  const LatLng(16.10, 120.55), // Kennon Road start
                  baguio,
                ],
                color: AppColors.primaryMain,
                strokeWidth: 4.0,
              ),
            ],
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: manila,
                width: 100,
                height: 30,
                alignment: Alignment.centerRight,
                child: _buildMarkerLabel('Manila', iconRight: false),
              ),
              Marker(
                point: baguio,
                width: 110,
                height: 30,
                alignment: Alignment.centerLeft,
                child: _buildMarkerLabel('Baguio City', iconRight: true),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMarkerLabel(String text, {required bool iconRight}) {
    return Align(
      alignment: iconRight ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!iconRight)
              const Icon(Icons.location_on, size: 14, color: AppColors.textSecondary),
            if (!iconRight)
              const SizedBox(width: 4),
            Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            if (iconRight)
              const SizedBox(width: 4),
            if (iconRight)
              const Icon(Icons.location_on, size: 14, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
