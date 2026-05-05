import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'summary_header.dart';
import 'summary_shared.dart';
import '../models/trip_summary_model.dart';
import 'package:haribon/theme/app_colors.dart';


/// MODULE: FUEL STOP LOG
/// Timeline-style list of fuel stops with brand color, station, volume, price.
class FuelStopLog extends StatelessWidget {
  final List<FuelStop> stops;

  const FuelStopLog({super.key, required this.stops});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel(label: 'FUEL STOPS'),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: stops.length,
            separatorBuilder: (_, __) => Padding(
              padding: const EdgeInsets.only(left: 40),
              child: Divider(
                height: 24,
                color: AppColors.blueSoftBg,
                thickness: 1,
              ),
            ),
            itemBuilder: (_, i) => _FuelStopRow(stop: stops[i], index: i),
          ),
        ],
      ),
    );
  }
}

class _FuelStopRow extends StatelessWidget {
  final FuelStop stop;
  final int index;

  const _FuelStopRow({required this.stop, required this.index});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Brand colour dot with stop number
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: stop.brandColor.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(color: stop.brandColor, width: 1.5),
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: stop.brandColor,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Station info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stop.stationName,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.navyDarkest,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              Text(
                '${stop.liters.toStringAsFixed(1)} L  ·  ₱${stop.pricePerLiter.toStringAsFixed(2)}/L',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.greyAccent,
                ),
              ),
            ],
          ),
        ),

        // Total cost
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '₱${stop.totalCost.toStringAsFixed(0)}',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: SummaryColors.primary,
              ),
            ),
            Text(
              stop.brand,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: stop.brandColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
