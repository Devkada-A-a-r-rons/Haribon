import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class TollService {
  static const String baseUrl = 'https://www.expressway.ph/api/toll-calculator';

  /// Calculates toll fee based on highway and vehicle class
  /// vehicleClass: 1 (Cars, SUVs), 2 (Buses, small trucks), 3 (Large trucks)
  Future<double> calculateToll({
    required String highway,
    required String entryPoint,
    required String exitPoint,
    int vehicleClass = 1,
  }) async {
    final query = '?highway=$highway&entry=$entryPoint&exit=$exitPoint&class=$vehicleClass';
    final targetUrl = '$baseUrl$query';

    try {
      if (kIsWeb) {
        // Try multiple proxies for web
        final proxies = [
          'https://corsproxy.io/?',
          'https://api.allorigins.win/get?url=',
        ];

        for (var proxy in proxies) {
          try {
            final proxyUrl = Uri.parse('$proxy${Uri.encodeComponent(targetUrl)}');
            final response = await http.get(proxyUrl).timeout(const Duration(seconds: 4));
            
            if (response.statusCode == 200) {
              var body = response.body;
              if (proxy.contains('allorigins')) {
                final allOriginsData = jsonDecode(body);
                body = allOriginsData['contents'] ?? '';
              }
              
              if (body.isNotEmpty) {
                final data = jsonDecode(body);
                final fee = data['fee'];
                if (fee != null) {
                  return (fee as num).toDouble();
                }
              }
            }
          } catch (e) {
            debugPrint('Proxy $proxy failed: $e');
            continue;
          }
        }
      } else {
        // Native (no CORS issue)
        final url = Uri.parse(targetUrl);
        final response = await http.get(url).timeout(const Duration(seconds: 5));
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final fee = data['fee'];
          if (fee != null) {
            return (fee as num).toDouble();
          }
        }
      }
      return _getFallbackToll(highway);
    } catch (e) {
      debugPrint('Toll Calculation failed: $e');
      return _getFallbackToll(highway);
    }
  }

  double _getFallbackToll(String highway) {
    final hw = highway.toUpperCase();
    if (hw.contains('NLEX')) return 350.0;
    if (hw.contains('SLEX')) return 280.0;
    if (hw.contains('TPLEX')) return 400.0;
    if (hw.contains('MCX')) return 30.0;
    if (hw.contains('CAVITEX')) return 100.0;
    if (hw.contains('SKYWAY')) return 250.0;
    return 150.0; // General average
  }
}
