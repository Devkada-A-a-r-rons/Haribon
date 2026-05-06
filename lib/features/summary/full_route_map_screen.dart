import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_colors.dart';
import '../../../core/services/route_service.dart';
import '../../../core/services/journey_service.dart';

class FullRouteMapScreen extends StatefulWidget {
  final LatLng origin;
  final LatLng destination;
  final String originName;
  final String destinationName;
  final Map<String, dynamic>? vehicleConfig;
  final double fuelPricePerLiter;

  const FullRouteMapScreen({
    super.key,
    required this.origin,
    required this.destination,
    required this.originName,
    required this.destinationName,
    this.vehicleConfig,
    this.fuelPricePerLiter = 65.0,
  });

  @override
  State<FullRouteMapScreen> createState() => _FullRouteMapScreenState();
}

class _FullRouteMapScreenState extends State<FullRouteMapScreen>
    with TickerProviderStateMixin {
  final RouteService _routeService = RouteService();
  final JourneyService _journeyService = JourneyService();
  final MapController _mapController = MapController();

  RouteResult? _route;
  bool _isLoadingRoute = true;
  bool _useHighway = true;
  bool _journeyStarted = false;
  StreamSubscription<JourneyState>? _journeySubscription;
  JourneyState? _journeyState;

  // Drag-up sheet controller
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  @override
  void initState() {
    super.initState();
    _fetchRoute();
  }

  @override
  void dispose() {
    _journeySubscription?.cancel();
    super.dispose();
  }

  Future<void> _fetchRoute() async {
    setState(() => _isLoadingRoute = true);
    final result = await _routeService.getRoute(
      origin: widget.origin,
      destination: widget.destination,
      useHighway: _useHighway,
    );
    if (mounted) {
      setState(() {
        _route = result;
        _isLoadingRoute = false;
      });
      // Fit map to route bounds
      if (result != null && result.polyline.isNotEmpty) {
        _fitMapToBounds(result.polyline);
      }
    }
  }

  void _fitMapToBounds(List<LatLng> points) {
    if (points.isEmpty) return;
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;
    for (final p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }
    final center = LatLng((minLat + maxLat) / 2, (minLng + maxLng) / 2);
    // Calculate appropriate zoom
    final latDiff = maxLat - minLat;
    final lngDiff = maxLng - minLng;
    final maxDiff = latDiff > lngDiff ? latDiff : lngDiff;
    double zoom = 10.0;
    if (maxDiff < 0.1) zoom = 13.0;
    else if (maxDiff < 0.5) zoom = 11.0;
    else if (maxDiff < 2.0) zoom = 9.0;
    else if (maxDiff < 5.0) zoom = 7.5;
    else zoom = 6.5;

    _mapController.move(center, zoom);
  }

  void _toggleRouteType(bool useHighway) {
    if (_useHighway == useHighway) return;
    setState(() => _useHighway = useHighway);
    _fetchRoute();
  }

  Future<void> _startJourney() async {
    final config = widget.vehicleConfig ?? {
      'current_fuel_liters': 15.0,
      'liters_per_km': 0.08,
      'origin_name': widget.originName,
      'destination_name': widget.destinationName,
    };

    await _journeyService.startJourney(
      vehicleConfig: config,
      fuelPricePerLiter: widget.fuelPricePerLiter,
      startPosition: widget.origin,
    );

    _journeySubscription = _journeyService.stateStream.listen((state) {
      if (mounted) setState(() => _journeyState = state);
    });

    setState(() => _journeyStarted = true);

    // Collapse sheet so map is visible
    _sheetController.animateTo(
      0.15,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  Future<void> _stopJourney() async {
    await _journeyService.stopJourney();
    _journeySubscription?.cancel();
    setState(() {
      _journeyStarted = false;
      _journeyState = null;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Journey ended! Trip data saved.'),
          backgroundColor: AppColors.tealDark,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          // ── Map ──────────────────────────────────────────────────
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(
                (widget.origin.latitude + widget.destination.latitude) / 2,
                (widget.origin.longitude + widget.destination.longitude) / 2,
              ),
              initialZoom: 9.0,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.haribon.app',
              ),
              if (_route != null && _route!.polyline.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    // Route shadow
                    Polyline(
                      points: _route!.polyline,
                      color: Colors.black.withOpacity(0.15),
                      strokeWidth: 9.0,
                    ),
                    // Main route line
                    Polyline(
                      points: _route!.polyline,
                      color: _useHighway
                          ? AppColors.primaryMain
                          : const Color(0xFF2ECC71),
                      strokeWidth: 5.5,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  // Origin marker
                  Marker(
                    point: widget.origin,
                    width: 160,
                    height: 52,
                    child: _buildMarker(
                      widget.originName,
                      isDestination: false,
                      icon: Icons.my_location_rounded,
                      color: AppColors.primaryMain,
                    ),
                  ),
                  // Destination marker
                  Marker(
                    point: widget.destination,
                    width: 160,
                    height: 52,
                    child: _buildMarker(
                      widget.destinationName,
                      isDestination: true,
                      icon: Icons.flag_rounded,
                      color: const Color(0xFFE74C3C),
                    ),
                  ),
                  // Current position during journey
                  if (_journeyState?.currentPosition != null)
                    Marker(
                      point: _journeyState!.currentPosition!,
                      width: 36,
                      height: 36,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primaryMain,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryMain.withOpacity(0.4),
                              blurRadius: 12,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.navigation_rounded,
                            color: Colors.white, size: 18),
                      ),
                    ),
                ],
              ),
            ],
          ),

          // ── Loading indicator ─────────────────────────────────────
          if (_isLoadingRoute)
            Positioned(
              top: 120,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primaryMain,
                        ),
                      ),
                      SizedBox(width: 10),
                      Text('Calculating route...',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ),

          // ── Active Journey Live HUD ───────────────────────────────
          if (_journeyStarted && _journeyState != null)
            Positioned(
              top: 100,
              right: 16,
              child: _buildLiveHUD(),
            ),

          // ── Drag-Up Bottom Sheet ──────────────────────────────────
          DraggableScrollableSheet(
            controller: _sheetController,
            initialChildSize: 0.32,
            minChildSize: 0.12,
            maxChildSize: 0.65,
            builder: (context, scrollController) =>
                _buildBottomSheet(scrollController),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white.withOpacity(0.95),
      elevation: 0,
      centerTitle: true,
      title: Text(
        '${widget.originName} → ${widget.destinationName}',
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w700,
          fontSize: 14,
          color: AppColors.textPrimary,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      actions: [
        // Highway / Service Road Toggle
        Container(
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: AppColors.greySoftBg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _routeToggleChip(
                label: 'Highway',
                icon: Icons.speed_rounded,
                isSelected: _useHighway,
                color: AppColors.primaryMain,
                onTap: () => _toggleRouteType(true),
              ),
              _routeToggleChip(
                label: 'Service Rd',
                icon: Icons.park_outlined,
                isSelected: !_useHighway,
                color: const Color(0xFF2ECC71),
                onTap: () => _toggleRouteType(false),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _routeToggleChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 12, color: isSelected ? Colors.white : AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveHUD() {
    final state = _journeyState!;
    final fuelPct = (state.currentFuelLiters /
            ((widget.vehicleConfig?['tank_size_liters'] as num?)?.toDouble() ??
                42.0))
        .clamp(0.0, 1.0);
    final fuelColor = fuelPct > 0.3
        ? AppColors.primaryMain
        : fuelPct > 0.15
            ? Colors.orange
            : Colors.red;

    return Container(
      width: 130,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                    color: Colors.green, shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.5), blurRadius: 4, spreadRadius: 1)]),
              ),
              const SizedBox(width: 6),
              const Text('LIVE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.green, letterSpacing: 1.2)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${state.currentFuelLiters.toStringAsFixed(1)}L',
            style: GoogleFonts.poppins(
                fontSize: 20, fontWeight: FontWeight.w900, color: fuelColor),
          ),
          const Text('fuel left', style: TextStyle(fontSize: 9, color: Colors.black45)),
          const SizedBox(height: 6),
          // Fuel bar
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: fuelPct,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(fuelColor),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${state.distanceTraveledKm.toStringAsFixed(1)} km',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
          ),
          Text(
            '₱${state.fuelCostPhp.toStringAsFixed(0)} used',
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _stopJourney,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Text(
                'END TRIP',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: Colors.red.shade700,
                    letterSpacing: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSheet(ScrollController scrollController) {
    final routeKm = _route?.distanceKm ?? 0.0;
    final routeHrs = _route?.durationHrs ?? 0.0;
    final litersPerKm = (widget.vehicleConfig?['liters_per_km'] as num?)?.toDouble() ?? 0.08;
    final estimatedFuelLiters = routeKm * litersPerKm;
    final estimatedFuelCost = estimatedFuelLiters * widget.fuelPricePerLiter;
    final tollEstimate = _useHighway ? routeKm * 1.2 : 0.0; // ~₱1.20/km on expressways

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
              color: Colors.black12, blurRadius: 20, offset: Offset(0, -4)),
        ],
      ),
      child: SingleChildScrollView(
        controller: scrollController,
        child: Column(
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Route Type Badge
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _useHighway
                              ? AppColors.primaryMain.withOpacity(0.1)
                              : const Color(0xFF2ECC71).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _useHighway
                                  ? Icons.speed_rounded
                                  : Icons.park_outlined,
                              size: 12,
                              color: _useHighway
                                  ? AppColors.primaryMain
                                  : const Color(0xFF2ECC71),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _useHighway
                                  ? 'Highway Route'
                                  : 'Service Road (Toll-Free)',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: _useHighway
                                    ? AppColors.primaryMain
                                    : const Color(0xFF2ECC71),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      if (_isLoadingRoute)
                        const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Route stats grid
                  Row(
                    children: [
                      Expanded(
                          child: _statChip(
                              '${routeKm.toStringAsFixed(1)} km',
                              'Distance',
                              Icons.route_rounded,
                              AppColors.blueLighterBg,
                              AppColors.blueLight)),
                      const SizedBox(width: 8),
                      Expanded(
                          child: _statChip(
                              routeHrs < 1
                                  ? '${(routeHrs * 60).toInt()} min'
                                  : '${routeHrs.toStringAsFixed(1)} hrs',
                              'ETA',
                              Icons.schedule_rounded,
                              AppColors.orangeSoftBg,
                              AppColors.orangeDark)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                          child: _statChip(
                              '₱${estimatedFuelCost.toStringAsFixed(0)}',
                              'Est. Fuel Cost',
                              Icons.local_gas_station_rounded,
                              AppColors.greenSoftBg,
                              AppColors.greenAccent)),
                      const SizedBox(width: 8),
                      Expanded(
                          child: _statChip(
                              _useHighway
                                  ? '₱${tollEstimate.toStringAsFixed(0)}'
                                  : '₱0 (Toll-Free)',
                              'Toll Estimate',
                              Icons.toll_rounded,
                              AppColors.orangeSoftBg,
                              AppColors.orangeDark)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Fuel deduction info
                  if (widget.vehicleConfig != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMain,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.greySoftBg),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.directions_car_rounded,
                              size: 18, color: AppColors.primaryMain),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${widget.vehicleConfig!['brand'] ?? ''} ${widget.vehicleConfig!['model'] ?? ''}',
                                  style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700),
                                ),
                                Text(
                                  'Uses ${estimatedFuelLiters.toStringAsFixed(1)}L · ${(1.0 / litersPerKm).toStringAsFixed(1)} km/L efficiency',
                                  style: const TextStyle(
                                      fontSize: 10, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          // Current fuel level
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _journeyStarted && _journeyState != null
                                    ? '${_journeyState!.currentFuelLiters.toStringAsFixed(1)}L'
                                    : '${(widget.vehicleConfig!['current_fuel_liters'] as num?)?.toStringAsFixed(1) ?? '?'}L',
                                style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primaryMain),
                              ),
                              const Text('remaining',
                                  style: TextStyle(
                                      fontSize: 9, color: Colors.grey)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Start / Stop Journey Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: _journeyStarted
                        ? OutlinedButton.icon(
                            onPressed: _stopJourney,
                            icon: const Icon(Icons.stop_circle_rounded,
                                color: Colors.red),
                            label: const Text('End Journey',
                                style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15)),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.red),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                            ),
                          )
                        : ElevatedButton.icon(
                            onPressed: _startJourney,
                            icon: const Icon(Icons.navigation_rounded,
                                size: 20),
                            label: Text(
                              'Start Journey',
                              style: GoogleFonts.poppins(
                                  fontSize: 15, fontWeight: FontWeight.w800),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryMain,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                            ),
                          ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statChip(String value, String label, IconData icon, Color bg, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary)),
                Text(label,
                    style: TextStyle(
                        fontSize: 9,
                        color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarker(String text,
      {required bool isDestination,
      required IconData icon,
      required Color color}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 8,
                  offset: const Offset(0, 4)),
            ],
            border: Border.all(color: color, width: 2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  text,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
        ),
        // Pin point
        Container(
          width: 2,
          height: 8,
          color: color,
        ),
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      ],
    );
  }
}
