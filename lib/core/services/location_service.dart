import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

/// Centralized geocoding for Philippine locations used in Haribon.
class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  /// Returns coordinates for a given location name.
  /// First checks local cache, then can be extended to fetch from Supabase.
  LatLng getCoords(String location) {
    final lower = location.toLowerCase();
    
    // NCR / Metro Manila
    if (lower.contains('mall of asia') || lower.contains('moa')) return const LatLng(14.5352, 120.9822);
    if (lower.contains('makati')) return const LatLng(14.5547, 121.0244);
    if (lower.contains('bgc') || lower.contains('bonifacio')) return const LatLng(14.5500, 121.0494);
    if (lower.contains('quezon city') || lower.contains('qc')) return const LatLng(14.6760, 121.0437);
    if (lower.contains('pasig')) return const LatLng(14.5764, 121.0851);
    if (lower.contains('marikina')) return const LatLng(14.6507, 121.1029);
    if (lower.contains('paranaque') || lower.contains('parañaque')) return const LatLng(14.4793, 121.0198);
    if (lower.contains('las pinas') || lower.contains('las piñas')) return const LatLng(14.4453, 120.9832);
    if (lower.contains('muntinlupa')) return const LatLng(14.4081, 121.0415);
    if (lower.contains('taguig')) return const LatLng(14.5176, 121.0509);
    if (lower.contains('manila')) return const LatLng(14.5995, 120.9842);

    // North Luzon
    if (lower.contains('san fernando') && lower.contains('pampanga')) return const LatLng(15.0333, 120.6833);
    if (lower.contains('san fernando') && lower.contains('union')) return const LatLng(16.6159, 120.3209);
    if (lower.contains('angeles') || lower.contains('holy angel')) return const LatLng(15.1450, 120.5887);
    if (lower.contains('clark')) return const LatLng(15.1789, 120.5323);
    if (lower.contains('mabalacat')) return const LatLng(15.2214, 120.5746);
    if (lower.contains('baguio')) return const LatLng(16.4124, 120.5999);
    if (lower.contains('tarlac')) return const LatLng(15.4755, 120.5960);
    if (lower.contains('bulacan') || lower.contains('malolos')) return const LatLng(14.8527, 120.8144);
    if (lower.contains('pampanga')) return const LatLng(15.0622, 120.6446);
    if (lower.contains('laoag')) return const LatLng(18.1960, 120.5927);
    if (lower.contains('vigan')) return const LatLng(17.5705, 120.3872);

    // South Luzon
    if (lower.contains('cavite') || lower.contains('bacoor')) return const LatLng(14.4625, 120.9642);
    if (lower.contains('tagaytay')) return const LatLng(14.1153, 120.9621);
    if (lower.contains('batangas')) return const LatLng(13.7565, 121.0583);
    if (lower.contains('laguna') || lower.contains('santa rosa')) return const LatLng(14.3122, 121.1114);
    if (lower.contains('naga')) return const LatLng(13.6218, 123.1944);
    if (lower.contains('legazpi')) return const LatLng(13.1391, 123.7438);

    // Visayas / Mindanao
    if (lower.contains('cebu')) return const LatLng(10.3157, 123.8854);
    if (lower.contains('iloilo')) return const LatLng(10.7202, 122.5621);
    if (lower.contains('bacolod')) return const LatLng(10.6840, 122.9563);
    if (lower.contains('davao')) return const LatLng(7.1907, 125.4553);
    if (lower.contains('cagayan de oro') || lower.contains('cdo')) return const LatLng(8.4542, 124.6319);
    if (lower.contains('zamboanga')) return const LatLng(6.9214, 122.0739);
    if (lower.contains('gensan') || lower.contains('general santos')) return const LatLng(6.1134, 125.1747);
    if (lower.contains('subic')) return const LatLng(14.8292, 120.2828);
    if (lower.contains('olongapo')) return const LatLng(14.8348, 120.2842);
    if (lower.contains('malolos')) return const LatLng(14.8527, 120.8144);
    if (lower.contains('pampanga')) return const LatLng(15.0622, 120.6446);
    if (lower.contains('tarlac')) return const LatLng(15.4755, 120.5960);
    if (lower.contains('dagupan')) return const LatLng(16.0433, 120.3337);

    // Default to Manila if no match
    return const LatLng(14.5995, 120.9842);
  }

  /// Optional: Dynamic geocoding from Supabase (Async version)
  Future<LatLng> getCoordsAsync(String location) async {
    final local = getCoords(location);
    // If it's not the default Manila, return it
    if (local.latitude != 14.5995 || local.longitude != 120.9842 || location.toLowerCase().contains('manila')) {
      return local;
    }

    try {
      final res = await Supabase.instance.client
          .from('geocoding_data')
          .select()
          .ilike('name', '%$location%')
          .maybeSingle();
      
      if (res != null) {
        return LatLng(res['latitude'], res['longitude']);
      }
    } catch (e) {
      debugPrint('Supabase geocoding error: $e');
    }
    
    return local;
  }
}
