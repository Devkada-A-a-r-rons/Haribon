import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_colors.dart';

class GasStationData {
  final int rank;
  final String label;
  final String branch;
  final String price;
  final Widget brandLogo;
  final List<String> fuelTypes;
  final String hours;
  final bool isBestDeal;

  const GasStationData({
    required this.rank,
    required this.label,
    required this.branch,
    required this.price,
    required this.brandLogo,
    required this.fuelTypes,
    required this.hours,
    this.isBestDeal = false,
  });
}

class GasStationCard extends StatelessWidget {
  final GasStationData station;

  const GasStationCard({super.key, required this.station});

  Color get _rankBgColor {
    switch (station.rank) {
      case 1:
        return const Color(0xFFFFF3CC);
      case 2:
        return const Color(0xFFF0F0F0);
      case 3:
        return const Color(0xFFFDEADF);
      default:
        return const Color(0xFFF4F6FA);
    }
  }

  Color get _rankTextColor {
    switch (station.rank) {
      case 1:
        return const Color(0xFFB8860B);
      case 2:
        return const Color(0xFF555555);
      case 3:
        return const Color(0xFFA0522D);
      default:
        return const Color(0xFF888888);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: station.isBestDeal
                  ? AppColors.greenAccent
                  : Colors.grey.withOpacity(0.15),
              width: station.isBestDeal ? 1.5 : 0.5,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Rank Badge
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: _rankBgColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '${station.rank}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _rankTextColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Brand Logo
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.15),
                    width: 0.5,
                  ),
                ),
                alignment: Alignment.center,
                child: station.brandLogo,
              ),
              const SizedBox(width: 12),

              // Station Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      station.label,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1A1A),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          size: 11,
                          color: Color(0xFF888888),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          station.hours,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: const Color(0xFF888888),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: station.fuelTypes
                          .map<Widget>((type) => _FuelPill(label: type))
                          .toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // Price Block
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    station.price,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                  Text(
                    'per liter',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: const Color(0xFF888888),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Best Deal Badge
        if (station.isBestDeal)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.greenAccent,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(10),
                ),
              ),
              child: Text(
                'BEST DEAL',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _FuelPill extends StatelessWidget {
  final String label;

  const _FuelPill({required this.label});

  bool get _isDiesel =>
      label.toLowerCase().contains('diesel') ||
      label.toLowerCase().contains('flex');

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: _isDiesel
            ? const Color(0xFFEEF3FD)
            : const Color(0xFFEDF9F3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: _isDiesel
              ? const Color(0xFF2A5BAD)
              : const Color(0xFF1A7A48),
        ),
      ),
    );
  }
}