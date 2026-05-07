import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import '../../theme/app_colors.dart';
import '../common/widgets/app_bar.dart';
import '../common/widgets/trip_card.dart';
import 'widgets/history_images.dart';
import 'trip-details/trip_details_screen.dart';
import '../summary/full_route_map_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> _trips = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    try {
      final tripResponse = await Supabase.instance.client
          .from('smart_trips')
          .select()
          .order('created_at', ascending: false);

      final insightsResponse = await Supabase.instance.client
          .from('trip_insights')
          .select()
          .order('created_at', ascending: false);

      final configResponse = await Supabase.instance.client
          .from('vehicle_configurations')
          .select()
          .order('created_at', ascending: false)
          .limit(5);

      final List<Map<String, dynamic>> combinedTrips = [];

      if (tripResponse != null) {
        combinedTrips.addAll(List<Map<String, dynamic>>.from(tripResponse));
      }

      if (configResponse != null) {
        for (var config in configResponse) {
          final exists = combinedTrips.any((t) =>
              t['origin_name'] == config['origin_name'] &&
              t['destination_name'] == config['destination_name']);

          if (!exists) {
            final vehicleModel = '${config['brand']} ${config['model']}';
            final matchingInsight = (insightsResponse as List?)
                ?.where(
                  (i) =>
                      i['origin'] == config['origin_name'] &&
                      i['destination'] == config['destination_name'] &&
                      i['vehicle_model'] == vehicleModel,
                )
                .firstOrNull;

            combinedTrips.add({
              ...config,
              'is_active_plan': true,
              'budget': (matchingInsight != null
                      ? matchingInsight['budget']
                      : config['budget']) ??
                  0.0,
              'ai_insights': (matchingInsight != null &&
                      matchingInsight['insights'] != null)
                  ? jsonDecode(matchingInsight['insights'])
                  : [],
            });
          }
        }
      }

      setState(() {
        _trips = combinedTrips;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching history: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceMain,
      appBar: const CommonAppBar(),
      body: RefreshIndicator(
        onRefresh: _fetchHistory,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Trip History',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Review your past journeys and\nefficiency insights at a glance.',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_trips.isEmpty)
                Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      Icon(Icons.history_outlined,
                          size: 64,
                          color: AppColors.textTertiary.withValues(alpha: 0.3)),
                      const SizedBox(height: 16),
                      Text('No trips found yet.',
                          style: GoogleFonts.poppins(
                              color: AppColors.textSecondary)),
                    ],
                  ),
                )
              else
                ..._trips.map((trip) {
                  final fuelCost =
                      (trip['est_fuel_cost'] ?? trip['budget'] ?? 0.0)
                          .toDouble();
                  final budget =
                      (trip['total_budget'] ?? trip['budget'] ?? 1.0)
                          .toDouble();
                  final toll = (trip['toll_fee'] ?? 0.0).toDouble();
                  final isActive = trip['is_active_plan'] == true;
                  final score =
                      ((1.0 - ((fuelCost + toll) / budget).clamp(0, 1)) * 100)
                          .toInt()
                          .clamp(60, 98);
                  final fuelLiters =
                      (trip['est_fuel_liters'] as num?)?.toDouble() ??
                          (fuelCost / 65.0);
                  final originName = trip['origin_name'] ?? 'Origin';
                  final destName = trip['destination_name'] ?? 'Destination';
                  final distanceKm =
                      (trip['distance_km'] ?? trip['route_distance_km'] ?? 0)
                          .toStringAsFixed(0);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    // ── Unified TripCard (history variant) ──────────────
                    child: TripCard(
                      route: '$originName → $destName',
                      badgeTextOverride: isActive
                          ? 'ACTIVE PLAN'
                          : '$score ${score > 85 ? 'EXCELLENT' : 'GOOD'}',
                      date: DateFormat("MMM d, yyyy \u2022 hh:mm a").format(
                          DateTime.parse(trip['created_at'])),
                      distance: '$distanceKm km',
                      efficiency: '$score/100',
                      efficiencyColor: score > 85
                          ? AppColors.success
                          : AppColors.orangeDark,
                      cost: '₱${fuelCost.toStringAsFixed(0)}',
                      buttonText: 'View Trip Details',
                      imageWidget: _getRandomImage(
                          trip['id']?.hashCode ?? trip['created_at'].hashCode),
                      onActionButton: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  TripDetailsScreen(tripData: trip)),
                        );
                      },
                      onViewMap: () {
                        final origin = _getCoords(originName);
                        final dest = _getCoords(destName);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FullRouteMapScreen(
                              origin: origin,
                              destination: dest,
                              originName: originName,
                              destinationName: destName,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getRandomImage(int seed) {
    final images = [
      const HaribonImageWidget(),
      const BirdGradientImageWidget(),
      const AerovistaImageWidget(),
    ];
    return images[seed % images.length];
  }

  LatLng _getCoords(String location) {
    final lower = location.toLowerCase();
    if (lower.contains('mall of asia') || lower.contains('moa')) return const LatLng(14.5352, 120.9822);
    if (lower.contains('makati')) return const LatLng(14.5547, 121.0244);
    if (lower.contains('bgc') || lower.contains('bonifacio')) return const LatLng(14.5500, 121.0494);
    if (lower.contains('quezon') || lower.contains('qc')) return const LatLng(14.6760, 121.0437);
    if (lower.contains('manila')) return const LatLng(14.5995, 120.9842);
    if (lower.contains('clark') || lower.contains('angeles')) return const LatLng(15.1789, 120.5323);
    if (lower.contains('pampanga')) return const LatLng(15.1450, 120.5887);
    if (lower.contains('baguio')) return const LatLng(16.4124, 120.5999);
    if (lower.contains('tarlac')) return const LatLng(15.4755, 120.5960);
    if (lower.contains('bulacan') || lower.contains('malolos')) return const LatLng(14.8527, 120.8144);
    if (lower.contains('cavite') || lower.contains('bacoor')) return const LatLng(14.4625, 120.9642);
    if (lower.contains('tagaytay')) return const LatLng(14.1153, 120.9621);
    if (lower.contains('batangas')) return const LatLng(13.7565, 121.0583);
    if (lower.contains('laguna') || lower.contains('santa rosa')) return const LatLng(14.3122, 121.1114);
    if (lower.contains('cebu')) return const LatLng(10.3157, 123.8854);
    if (lower.contains('davao')) return const LatLng(7.1907, 125.4553);
    return const LatLng(14.5995, 120.9842);
  }
}