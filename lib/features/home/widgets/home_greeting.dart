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
          'Hi $userName,',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Where do you\nwanna go?',
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryMain,
            letterSpacing: 1.5,
            height: 1.15,
          ),
        ),
      ],
    );
  }
}

