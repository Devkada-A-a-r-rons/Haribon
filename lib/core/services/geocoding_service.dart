import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class GeocodingResult {
  final String name;
  final LatLng location;

  GeocodingResult({required this.name, required this.location});
}

class GeocodingService {
  static const _proxies = [
    'https://api.allorigins.win/get?url=',
    'https://corsproxy.io/?url=',
    'https://api.codetabs.com/v1/proxy?url=',
  ];

  Future<List<GeocodingResult>> search(String query) async {
    if (query.isEmpty) return [];

    final targetUrl = 'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&limit=5&addressdetails=1';
    
    try {
      if (kIsWeb) {
        for (final proxy in _proxies) {
          final res = await _tryProxy(proxy, targetUrl);
          if (res != null) {
            return _parseResponse(res);
          }
        }
      } else {
        final res = await http.get(
          Uri.parse(targetUrl),
          headers: {'User-Agent': 'HaribonApp/1.0'},
        ).timeout(const Duration(seconds: 8));
        
        if (res.statusCode == 200) {
          return _parseResponse(res.body);
        }
      }
    } catch (e) {
      debugPrint('[GeocodingService] Search failed: $e');
    }
    
    return [];
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
    } catch (_) {}
    return null;
  }

  List<GeocodingResult> _parseResponse(String body) {
    try {
      final List<dynamic> data = jsonDecode(body);
      return data.map((item) {
        return GeocodingResult(
          name: item['display_name'] ?? 'Unknown',
          location: LatLng(
            double.parse(item['lat']),
            double.parse(item['lon']),
          ),
        );
      }).toList();
    } catch (e) {
      debugPrint('[GeocodingService] Parse error: $e');
      return [];
    }
  }
}
