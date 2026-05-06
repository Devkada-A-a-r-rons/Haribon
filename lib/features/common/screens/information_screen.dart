import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_colors.dart';
import '../widgets/app_bar.dart';

class AppInformationScreen extends StatelessWidget {
  const AppInformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceMain,
      appBar: const CommonAppBar(title: 'About Haribon', showSettings: false, showInfo: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How Haribon Works',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Haribon helps you track your fuel consumption, estimate travel costs, and minimize your carbon footprint.',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            _buildFeatureCard(
              context,
              icon: Icons.route,
              title: 'Smart Trip Planner',
              description: 'Plan your trips with AI-powered routing that optimizes for the least fuel consumption and minimal traffic.',
              color: AppColors.primaryMain,
            ),
            const SizedBox(height: 16),
            _buildFeatureCard(
              context,
              icon: Icons.insights,
              title: 'Vehicle Intelligence',
              description: 'Get deep insights into your vehicle\'s health, fuel efficiency trends, and personalized recommendations.',
              color: AppColors.orangePrimary,
            ),
            const SizedBox(height: 16),
            _buildFeatureCard(
              context,
              icon: Icons.co2,
              title: 'Fuel & Emissions',
              description: 'Track your carbon footprint and learn how to reduce emissions with eco-driving tips and efficiency scores.',
              color: AppColors.tealDark,
            ),
            const SizedBox(height: 16),
            _buildFeatureCard(
              context,
              icon: Icons.history,
              title: 'Trip History',
              description: 'Review your past trips, compare costs, and see how much CO2 you\'ve saved over time.',
              color: AppColors.blueGreyDark,
            ),
            const SizedBox(height: 32),
            Text(
              'How to Use the App',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildStep(
              context,
              number: '1',
              title: 'Set Up Vehicle',
              description: 'Go to Settings to configure your car\'s make, model, and fuel type for accurate data.',
            ),
            const SizedBox(height: 16),
            _buildStep(
              context,
              number: '2',
              title: 'Plan a Trip',
              description: 'Use the Smart Trip Planner to estimate fuel cost and emissions before you drive.',
            ),
            const SizedBox(height: 16),
            _buildStep(
              context,
              number: '3',
              title: 'Review Insights',
              description: 'Check Vehicle Intelligence and Fuel & Emissions tabs to get AI-powered eco-driving tips.',
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, {required IconData icon, required String title, required String description, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.containerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceDim.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(BuildContext context, {required String number, required String title, required String description}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primaryMain,
            shape: BoxShape.circle,
          ),
          child: Text(
            number,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

