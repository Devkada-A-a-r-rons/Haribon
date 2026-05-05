import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_colors.dart';
class SummaryHeader extends StatelessWidget {
  final String destination;
  final String date;

  const SummaryHeader({
    super.key,
    required this.destination,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
      child: Row(
        children: [
          // Back button
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            color: AppColors.textPrimary,
            style: IconButton.styleFrom(
              backgroundColor: AppColors.containerLowest,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: AppColors.textTertiary.withValues(alpha: 0.2),
                ),
              ),
              padding: const EdgeInsets.all(8),
              minimumSize: const Size(36, 36),
            ),
          ),
          const SizedBox(width: 12),

          // Title + subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trip Summary',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$destination · $date',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Shared summary-specific color constants used across widgets.
abstract class SummaryColors {
  static const primary = AppColors.bluePrimary;
  static const eco = AppColors.greenDark;
  static const amber = AppColors.amberPrimary;
  static const surface = AppColors.blueGreyWhite;
  static const container = AppColors.blueSoftBg;
  static const white = AppColors.whitePrimary;
}
