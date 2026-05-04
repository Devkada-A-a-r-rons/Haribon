import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_colors.dart';

class HomeGreeting extends StatelessWidget {
  final String userName;
  final double weeklyCo2Saved;

  const HomeGreeting({
    super.key,
    required this.userName,
    required this.weeklyCo2Saved,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Good morning, $userName!',
          style: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.eco, color: AppColors.success, size: 20),
            const SizedBox(width: 8),
            Text(
              'You saved ${weeklyCo2Saved.toStringAsFixed(1)}kg of CO2 this week.',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.success,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
