import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_colors.dart';
import './gas_station_card.dart';

class GasStationListWidget extends StatelessWidget {
  final List<GasStationData>? stations;
  const GasStationListWidget({super.key, this.stations});

  static List<GasStationData> mapFromSupabase(List<dynamic> data) {
    return data.asMap().entries.map((entry) {
      final i = entry.key;
      final p = entry.value;
      final brand = (p['brand'] ?? 'Unknown').toString().toUpperCase();
      final gasoline = (p['gasoline'] ?? 0.0).toDouble();
      
      Color brandColor = Colors.grey;
      String brandText = brand;
      if (brand.contains('PETRON')) brandColor = const Color(0xFFE30613);
      if (brand.contains('SHELL')) brandColor = const Color(0xFFE8A800);
      if (brand.contains('CALTEX')) brandColor = const Color(0xFF0066B2);
      if (brand.contains('PHOENIX')) brandColor = const Color(0xFFFF6600);
      if (brand.contains('SEAOIL')) brandColor = const Color(0xFF0D5FA6);

      // Logo text formatting (2-3 chars per line)
      if (brandText.length > 4) {
        brandText = '${brandText.substring(0, 3)}\n${brandText.substring(3)}';
      }

      return GasStationData(
        rank: i + 1,
        label: '$brand — ${p['branch'] ?? 'Main'}',
        branch: p['branch'] ?? 'Main',
        price: '₱${gasoline.toStringAsFixed(2)}',
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
        fuelTypes: const ['Gasoline', 'Diesel'],
        hours: 'Open 24hrs',
        isBestDeal: i == 0,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
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
          ],
        ),
        const SizedBox(height: 14),
        ...(stations ?? []).map((s) => GasStationCard(station: s)),
        const SizedBox(height: 4),
      ],
    );
  }
}