import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:haribon/theme/app_colors.dart';

class CarbonImpact extends StatelessWidget {
  const CarbonImpact({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.containerLowest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.containerLow,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.park,
              color: AppColors.success, // Dark green tree
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CARBON IMPACT',
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: AppColors.success,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                    ),
                    children: [
                      TextSpan(
                        text: '53.6 kg CO2 ',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppColors.success,
                        ),
                      ),
                      TextSpan(
                        text: '/ 2 Trees',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
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

