import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_colors.dart';
import './gas_station_card.dart';

class GasStationListWidget extends StatelessWidget {
  final List<GasStationData>? stations;
  const GasStationListWidget({super.key, this.stations});

  /// Maps Supabase fuel_prices rows to GasStationData objects,
  /// sorted by gasoline price ascending (cheapest first = Best Deal).
  static List<GasStationData> mapFromSupabase(List<dynamic> data) {
    // 1. Keep only the latest entry for each brand
    final Map<String, dynamic> uniqueBrands = {};
    for (var p in data) {
      final brand = (p['brand'] ?? 'Unknown').toString().toUpperCase().trim();
      if (!uniqueBrands.containsKey(brand)) {
        uniqueBrands[brand] = p;
      }
    }

    // 2. Convert back to list and sort by gasoline price ascending (cheapest first)
    final sorted = uniqueBrands.values.toList();
    sorted.sort((a, b) {
      final priceA = (a['gasoline'] ?? 999.0).toDouble();
      final priceB = (b['gasoline'] ?? 999.0).toDouble();
      return priceA.compareTo(priceB);
    });

    // 3. Take Top 10
    final top10 = sorted.take(10).toList();

    return top10.asMap().entries.map((entry) {
      final i = entry.key;
      final p = entry.value;
      final brand = (p['brand'] ?? 'Unknown').toString().toUpperCase();
      final gasoline = (p['gasoline'] ?? 0.0).toDouble();
      final diesel = (p['diesel'] as num?)?.toDouble();

      Color brandColor = Colors.grey;
      if (brand.contains('PETRON')) brandColor = const Color(0xFFE30613);
      if (brand.contains('SHELL')) brandColor = const Color(0xFFE8A800);
      if (brand.contains('CALTEX')) brandColor = const Color(0xFF0066B2);
      if (brand.contains('PHOENIX')) brandColor = const Color(0xFFFF6600);
      if (brand.contains('SEAOIL')) brandColor = const Color(0xFF0D5FA6);
      if (brand.contains('TOTAL')) brandColor = const Color(0xFF003B8E);
      if (brand.contains('UNIOIL')) brandColor = const Color(0xFF009639);
      if (brand.contains('FLYING')) brandColor = const Color(0xFF8B0000);
      if (brand.contains('PTT')) brandColor = const Color(0xFF00529B);
      if (brand.contains('JETTI')) brandColor = const Color(0xFFF7941D);
      if (brand.contains('CLEANFUEL')) brandColor = const Color(0xFF00A651);

      // Logo text formatting (2-3 chars per line)
      String brandText = brand;
      if (brandText.length > 4) {
        brandText = '${brandText.substring(0, 3)}\n${brandText.substring(3)}';
      }

      // Build fuel types list dynamically
      final fuelTypes = <String>['Gasoline'];
      if (diesel != null && diesel > 0) fuelTypes.add('Diesel');

      return GasStationData(
        rank: i + 1,
        label: brand,
        branch: p['branch'] ?? 'Main',
        price: '₱${gasoline.toStringAsFixed(2)}',
        dieselPrice: diesel != null && diesel > 0
            ? '₱${diesel.toStringAsFixed(2)}'
            : null,
        brandLogo: Text(
          brandText,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: brandColor,
            height: 1.1,
          ),
        ),
        fuelTypes: fuelTypes,
        hours: 'Open 24hrs',
        isBestDeal: i == 0, // Cheapest = Best Deal
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final stationList = stations ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Common Gas Station Prices',
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1A1A),
              ),
            ),
            if (stationList.isNotEmpty)
              Text(
                '${stationList.length} brands',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppColors.textTertiary,
                ),
              ),
          ],
        ),
        const SizedBox(height: 14),
        if (stationList.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Text(
                'Loading fuel prices...',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.textTertiary,
                ),
              ),
            ),
          )
        else
          ...stationList.map((s) => GasStationCard(station: s)),
        const SizedBox(height: 4),
      ],
    );
  }
}