import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

/// Represents a computed route from OSRM.
class RouteResult {
  final List<LatLng> polyline;
  final double distanceKm;
  final double durationHrs;
  final bool isHighway;

  const RouteResult({
    required this.polyline,
    required this.distanceKm,
    required this.durationHrs,
    required this.isHighway,
  });
}

/// Fetches real on-road routes from the OSRM public API.
/// Supports highway (fastest) and service road (avoid expressways) profiles.
class RouteService {
  static const _proxies = [
    'https://api.allorigins.win/get?url=',
    'https://thingproxy.freeboard.io/fetch/',
    'https://api.codetabs.com/v1/proxy?url=',
    'https://corsproxy.io/?url=',
  ];

  /// Decode Google-encoded polyline into LatLng list.
  static List<LatLng> _decodePolyline(String encoded) {
    final List<LatLng> points = [];
    int index = 0;
    final int len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int b;
      int shift = 0;
      int result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      final double finalLat = lat / 1e5;
      final double finalLng = lng / 1e5;

      if (finalLat >= -90 && finalLat <= 90 && finalLng >= -180 && finalLng <= 180) {
        points.add(LatLng(finalLat, finalLng));
      }
    }
    return points;
  }

  /// Fetches a route between two coordinates.
  /// [useHighway]: true = fastest (expressways), false = avoid tolls (service roads).
  Future<RouteResult?> getRoute({
    required LatLng origin,
    required LatLng destination,
    bool useHighway = true,
  }) async {
    // Try different mirrors and geometries
    final mirrors = [
      'https://router.project-osrm.org/route/v1/driving/',
      'https://routing.openstreetmap.de/routed-car/route/v1/driving/',
    ];

    for (final mirror in mirrors) {
      final geometries = kIsWeb ? 'geojson' : 'polyline';
      final targetUrl = '$mirror'
          '${origin.longitude},${origin.latitude};'
          '${destination.longitude},${destination.latitude}'
          '?overview=full&geometries=$geometries'
          '${useHighway ? '' : '&exclude=motorway,toll'}';

      try {
        if (kIsWeb) {
          for (final proxy in _proxies) {
            final res = await _tryProxy(proxy, targetUrl);
            if (res != null) {
              final result = _parseResponse(res, origin, destination, useHighway);
              if (result != null && result.polyline.length > 5) return result;
            }
          }
        } else {
          final res = await http.get(Uri.parse(targetUrl)).timeout(const Duration(seconds: 10));
          if (res.statusCode == 200) {
            final result = _parseResponse(res.body, origin, destination, useHighway);
            if (result != null) return result;
          }
        }
      } catch (e) {
        debugPrint('[RouteService] Mirror $mirror failed: $e');
      }
    }

    return _fallbackRoute(origin, destination, useHighway);
  }

  Future<String?> _tryProxy(String proxy, String targetUrl) async {
    try {
      final proxyUri = Uri.parse('$proxy${Uri.encodeComponent(targetUrl)}');
      final res = await http.get(proxyUri).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        if (proxy.contains('allorigins')) {
          final wrapper = jsonDecode(res.body);
          return wrapper['contents']?.toString();
        }
        return res.body;
      }
    } catch (e) {
      debugPrint('[RouteService] Proxy $proxy failed: $e');
    }
    return null;
  }

  RouteResult? _parseResponse(String bodyString, LatLng origin, LatLng destination, bool useHighway) {
    try {
      if (!bodyString.trim().startsWith('{')) return null;
      final data = jsonDecode(bodyString);
      if (data['routes'] == null || (data['routes'] as List).isEmpty) return null;

      final route = data['routes'][0];
      final dynamic geometryData = route['geometry'];
      List<LatLng> polyline = [];

      if (geometryData is String) {
        polyline = _decodePolyline(geometryData);
      } else if (geometryData is Map && geometryData['coordinates'] != null) {
        final coords = geometryData['coordinates'] as List;
        polyline = coords.map((c) {
          final point = c as List;
          return LatLng((point[1] as num).toDouble(), (point[0] as num).toDouble());
        }).toList();
      }
      
      final distanceKm = ((route['distance'] as num?)?.toDouble() ?? 0.0) / 1000.0;
      final durationHrs = ((route['duration'] as num?)?.toDouble() ?? 0.0) / 3600.0;

      return RouteResult(
        polyline: polyline,
        distanceKm: distanceKm > 0 ? distanceKm : 1.0,
        durationHrs: durationHrs > 0 ? durationHrs : 0.1,
        isHighway: useHighway,
      );
    } catch (e) {
      return null;
    }
  }

  /// Fallback straight-line route if OSRM fails.
  RouteResult _fallbackRoute(LatLng origin, LatLng destination, bool useHighway) {
    final Distance calc = const Distance();
    final distanceM = calc.as(LengthUnit.Meter, origin, destination);
    final distanceKm = distanceM / 1000.0;
    return RouteResult(
      polyline: [origin, destination],
      distanceKm: distanceKm * (useHighway ? 1.0 : 1.15),
      durationHrs: distanceKm / 80.0,
      isHighway: useHighway,
    );
  }
}
