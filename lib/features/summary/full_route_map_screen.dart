import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_colors.dart';

class FullRouteMapScreen extends StatelessWidget {
  final LatLng origin;
  final LatLng destination;
  final String originName;
  final String destinationName;

  const FullRouteMapScreen({
    super.key,
    required this.origin,
    required this.destination,
    required this.originName,
    required this.destinationName,
  });

  @override
  Widget build(BuildContext context) {
    final centerLat = (origin.latitude + destination.latitude) / 2;
    final centerLng = (origin.longitude + destination.longitude) / 2;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Route Details',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(centerLat, centerLng),
          initialZoom: 8.5,
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.all,
          ),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.haribon',
          ),
          PolylineLayer(
            polylines: <Polyline>[
              Polyline(
                points: [
                  origin,
                  // Approximate NLEX/EDSA path if between Clark/Manila
                  if (origin.latitude > 15.0 && destination.latitude < 14.6) ...[
                    LatLng(15.02, 120.69), // San Fernando
                    LatLng(14.85, 120.81), // Bulacan
                    LatLng(14.65, 120.98), // QC / Balintawak
                  ],
                  if (origin.latitude < 14.6 && destination.latitude > 15.0) ...[
                    LatLng(14.65, 120.98),
                    LatLng(14.85, 120.81),
                    LatLng(15.02, 120.69),
                  ],
                  destination,
                ],
                color: AppColors.primaryMain,
                strokeWidth: 6.0,
              ),
            ],
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: origin,
                width: 140,
                height: 45,
                child: _buildMarkerLabel(originName, isDestination: false),
              ),
              Marker(
                point: destination,
                width: 140,
                height: 45,
                child: _buildMarkerLabel(destinationName, isDestination: true),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMarkerLabel(String text, {required bool isDestination}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDestination ? AppColors.redPrimary : AppColors.primaryMain,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isDestination ? Icons.flag_rounded : Icons.location_on_rounded,
            size: 16,
            color: isDestination ? AppColors.redPrimary : AppColors.primaryMain,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
