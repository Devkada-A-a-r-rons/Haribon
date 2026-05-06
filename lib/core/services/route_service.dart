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
    'https://corsproxy.io/?',
    'https://api.codetabs.com/v1/proxy?url=',
  ];

  /// Decode Google-encoded polyline into LatLng list.
  static List<LatLng> _decodePolyline(String encoded) {
    final List<LatLng> points = [];
    int index = 0;
    final int len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1e5, lng / 1e5));
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
    // OSRM with full geometry (encoded polyline)
    final targetUrl = 'https://router.project-osrm.org/route/v1/driving/'
        '${origin.longitude},${origin.latitude};'
        '${destination.longitude},${destination.latitude}'
        '?overview=full&geometries=polyline'
        '${useHighway ? '' : '&exclude=motorway'}';

    String? bodyString;

    try {
      if (kIsWeb) {
        // Try proxies in order
        for (final proxy in _proxies) {
          try {
            final proxyUri = proxy.contains('corsproxy.io')
                ? Uri.parse('$proxy${Uri.encodeComponent(targetUrl)}')
                : Uri.parse('$proxy${Uri.encodeComponent(targetUrl)}');

            final res = await http
                .get(proxyUri)
                .timeout(const Duration(seconds: 8));

            if (res.statusCode == 200) {
              if (proxy.contains('allorigins')) {
                final wrapper = jsonDecode(res.body);
                bodyString = wrapper['contents'];
              } else {
                bodyString = res.body;
              }
              if (bodyString != null && bodyString.trim().startsWith('{')) {
                debugPrint('[RouteService] Success via $proxy');
                break;
              }
            }
          } catch (e) {
            debugPrint('[RouteService] Proxy $proxy failed: $e');
          }
        }
      } else {
        final res = await http
            .get(Uri.parse(targetUrl))
            .timeout(const Duration(seconds: 10));
        if (res.statusCode == 200) bodyString = res.body;
      }

      if (bodyString == null || !bodyString.trim().startsWith('{')) {
        debugPrint('[RouteService] No valid response from OSRM');
        return _fallbackRoute(origin, destination, useHighway);
      }

      final data = jsonDecode(bodyString);
      if (data['routes'] == null || (data['routes'] as List).isEmpty) {
        return _fallbackRoute(origin, destination, useHighway);
      }

      final route = data['routes'][0];
      final encodedGeometry = route['geometry'] as String;
      final polyline = _decodePolyline(encodedGeometry);
      final distanceKm = (route['distance'] as num).toDouble() / 1000.0;
      final durationHrs = (route['duration'] as num).toDouble() / 3600.0;

      return RouteResult(
        polyline: polyline,
        distanceKm: distanceKm,
        durationHrs: durationHrs,
        isHighway: useHighway,
      );
    } catch (e) {
      debugPrint('[RouteService] Error: $e');
      return _fallbackRoute(origin, destination, useHighway);
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
