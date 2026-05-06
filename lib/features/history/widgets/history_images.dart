import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:haribon/theme/app_colors.dart';

class HaribonImageWidget extends StatelessWidget {
  const HaribonImageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.containerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceDim, width: 1),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.directions_car, size: 64, color: AppColors.brandHaribon),
            Text(
              'HARIBON',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: AppColors.brandHaribon,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BirdGradientImageWidget extends StatelessWidget {
  const BirdGradientImageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: ColorFiltered(
          colorFilter: const ColorFilter.mode(AppColors.primaryMain, BlendMode.srcIn),
          child: Image.asset('assets/images/haribon_logo.png', height: 80, fit: BoxFit.contain),
        ),
      ),
    );
  }
}

class AerovistaImageWidget extends StatelessWidget {
  const AerovistaImageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.containerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sports_motorsports_outlined, size: 64, color: AppColors.primaryMain),
            Text(
              'AEROVISTA',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppColors.primaryMain,
                letterSpacing: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

