import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../common/widgets/app_bar.dart';
import 'widgets/trip_card.dart';
import 'widgets/history_images.dart';
import 'trip-details/trip_details_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceMain,
      appBar: const CommonAppBar(title: 'History'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trip History',
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Review your past journeys and\nefficiency insights at a glance.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            TripCard(
              route: 'Pampanga → Baguio',
              badgeText: '92 EXCELLENT',
              badgeColor: AppColors.badgeExcellentBg, 
              badgeTextColor: AppColors.badgeExcellentText, 
              badgeIcon: Icons.auto_awesome,
              date: 'OCT 12, 2023 • 08:30 AM',
              distance: '145 km',
              fuelUsed: '8.2 L',
              cost: '₱540',
              imageWidget: const AgilaImageWidget(),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TripDetailsScreen()),
                );
              },
            ),
            const SizedBox(height: 24),
            TripCard(
              route: 'Manila → Bicol',
              badgeText: '84 GOOD',
              badgeColor: AppColors.badgeGoodBg, 
              badgeTextColor: AppColors.insightOlive, 
              badgeIcon: Icons.eco_outlined,
              date: 'SEP 28, 2023 • 05:15 AM',
              distance: '360 km',
              fuelUsed: '24.5 L',
              cost: '₱1,620',
              imageWidget: const BirdGradientImageWidget(),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TripDetailsScreen()),
                );
              },
            ),
            const SizedBox(height: 24),
            TripCard(
              route: 'Tagaytay → Manila',
              badgeText: '96 OPTIMAL',
              badgeColor: AppColors.badgeExcellentBg, // Light green
              badgeTextColor: AppColors.badgeExcellentText, // Dark green
              badgeIcon: Icons.eco_outlined,
              date: 'SEP 15, 2023 • 04:45 PM',
              distance: '65 km',
              fuelUsed: '3.8 L',
              cost: '₱250',
              imageWidget: const AerovistaImageWidget(),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TripDetailsScreen()),
                );
              },
            ),
            const SizedBox(height: 48), // Padding for bottom nav
          ],
        ),
      ),
    );
  }
}
