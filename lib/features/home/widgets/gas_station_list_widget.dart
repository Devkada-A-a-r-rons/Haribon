import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_colors.dart';
import './gas_station_card.dart';

class GasStationListWidget extends StatelessWidget {
  const GasStationListWidget({super.key});

  List<GasStationData> get _stations => [
        GasStationData(
          rank: 1,
          label: 'Petron — EDSA Magallanes',
          branch: 'EDSA Magallanes',
          price: '₱63.50',
          brandLogo: Text(
            'PET\nRON',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: const Color(0xFFE30613),
              height: 1.1,
            ),
          ),
          fuelTypes: const ['Gasoline', 'Diesel', 'Premium'],
          hours: 'Open 24hrs',
          isBestDeal: true,
        ),
        GasStationData(
          rank: 2,
          label: 'Shell — Buendia Ave',
          branch: 'Buendia Ave',
          price: '₱64.10',
          brandLogo: Text(
            'SH\nELL',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: const Color(0xFFE8A800),
              height: 1.1,
            ),
          ),
          fuelTypes: const ['Gasoline', 'V-Power', 'Diesel'],
          hours: 'Open 24hrs',
        ),
        GasStationData(
          rank: 3,
          label: 'Caltex — Osmeña Highway',
          branch: 'Osmeña Highway',
          price: '₱64.45',
          brandLogo: Text(
            'CAL\nTEX',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0066B2),
              height: 1.1,
            ),
          ),
          fuelTypes: const ['Gasoline', 'Diesel'],
          hours: '6AM – 10PM',
        ),
        GasStationData(
          rank: 4,
          label: 'Phoenix — South Super Hwy',
          branch: 'South Super Hwy',
          price: '₱64.90',
          brandLogo: Text(
            'PHO\nENX',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: const Color(0xFFFF6600),
              height: 1.1,
            ),
          ),
          fuelTypes: const ['Gasoline', 'Diesel', 'Flex'],
          hours: '5AM – 11PM',
        ),
        GasStationData(
          rank: 5,
          label: 'Seaoil — Roxas Blvd',
          branch: 'Roxas Blvd',
          price: '₱65.20',
          brandLogo: Text(
            'SEA\nOIL',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0D5FA6),
              height: 1.1,
            ),
          ),
          fuelTypes: const ['Gasoline', 'Diesel'],
          hours: 'Open 24hrs',
        ),
      ];

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
        ..._stations.map((s) => GasStationCard(station: s)),
        const SizedBox(height: 4),
      ],
    );
  }
}