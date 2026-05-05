import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_colors.dart';
import '../full_route_map_screen.dart';

class RouteMapCard extends StatelessWidget {
  final LatLng? origin;
  final LatLng? destination;
  final String originName;
  final String destinationName;

  static const Map<String, LatLng> _locationCoordinates = {
    'Manila': LatLng(14.5995, 120.9842),
    'Baguio': LatLng(16.4023, 120.5960),
    'Baguio City': LatLng(16.4023, 120.5960),
    'Pampanga': LatLng(15.0271, 120.6901),
    'Angeles': LatLng(15.1441, 120.5887),
    'Tarlac': LatLng(15.4802, 120.5979),
    'Pangasinan': LatLng(15.9761, 120.3210),
    'Manaoag': LatLng(16.0433, 120.4855),
    'SM Mall of Asia': LatLng(14.5351, 120.9818),
    'SM City Clark': LatLng(15.1691, 120.5831),
    'Clark': LatLng(15.1691, 120.5831),
    'MOA': LatLng(14.5351, 120.9818),
  };

  LatLng _getCoords(String name, LatLng fallback) {
    // Try to match exact landmark first, then city name
    if (_locationCoordinates.containsKey(name)) return _locationCoordinates[name]!;
    
    final cleanName = name.split(',').first.trim();
    return _locationCoordinates[cleanName] ?? fallback;
  }

  const RouteMapCard({
    super.key,
    this.origin,
    this.destination,
    this.originName = 'Manila',
    this.destinationName = 'Baguio City',
  });

  @override
  Widget build(BuildContext context) {
    final start = origin ?? _getCoords(originName, const LatLng(14.5995, 120.9842));
    final end = destination ?? _getCoords(destinationName, const LatLng(16.4023, 120.5960));
    
    final centerLat = (start.latitude + end.latitude) / 2;
    final centerLng = (start.longitude + end.longitude) / 2;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FullRouteMapScreen(
              origin: start,
              destination: end,
              originName: originName,
              destinationName: destinationName,
            ),
          ),
        );
      },
      child: Stack(
        children: [
          Container(
            height: 220,
            width: double.infinity,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppColors.surfaceMain,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.5), width: 1),
            ),
            child: IgnorePointer(
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(centerLat, centerLng),
                  initialZoom: 7.5,
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
                          start,
                          // Approximate NLEX/EDSA path if between Clark/Manila
                          if (start.latitude > 15.0 && end.latitude < 14.6) ...[
                            LatLng(15.02, 120.69), // San Fernando
                            LatLng(14.85, 120.81), // Bulacan
                            LatLng(14.65, 120.98), // QC / Balintawak
                          ],
                          if (start.latitude < 14.6 && end.latitude > 15.0) ...[
                            LatLng(14.65, 120.98),
                            LatLng(14.85, 120.81),
                            LatLng(15.02, 120.69),
                          ],
                          end,
                        ],
                        color: AppColors.primaryMain,
                        strokeWidth: 5.0,
                      ),
                    ],
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: start,
                        width: 100,
                        height: 35,
                        child: _buildMarkerLabel(originName, iconRight: false),
                      ),
                      Marker(
                        point: end,
                        width: 110,
                        height: 35,
                        child: _buildMarkerLabel(destinationName, iconRight: true),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 12,
            top: 12,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4),
                ],
              ),
              child: const Icon(Icons.fullscreen_rounded, size: 20, color: AppColors.primaryMain),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarkerLabel(String text, {required bool iconRight}) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 140),
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
          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (iconRight)
            const SizedBox(width: 4),
          if (iconRight)
            const Icon(Icons.location_on, size: 14, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}
