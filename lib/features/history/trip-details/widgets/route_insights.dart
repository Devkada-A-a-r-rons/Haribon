import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../theme/app_colors.dart';

class RouteInsights extends StatelessWidget {
  const RouteInsights({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.lightbulb_outline, color: const Color(0xFF1E3A8A)),
            const SizedBox(width: 8),
            Text(
              'Route Insights',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildInsightCard(
          title: 'Drafting Win',
          description: 'You saved 0.4L by maintaining steady highway distance behind larger vehicles.',
          icon: Icons.trending_down,
          iconBackgroundColor: const Color(0xFFE3EDF6),
          iconColor: const Color(0xFF3B5B72),
        ),
        const SizedBox(height: 12),
        _buildInsightCard(
          title: 'Kennon Road vs Marcos Hwy',
          description: 'Taking Marcos Highway added 2.4L in climb consumption but saved 15m in traffic.',
          icon: Icons.terrain,
          iconBackgroundColor: const Color(0xFFF3EED4), // light yellow background
          iconColor: const Color(0xFF827717), // olive icon
        ),
        const SizedBox(height: 12),
        _buildInsightCard(
          title: 'Optimization Tip',
          description: 'Hard braking detected 12 times. Smoothing deceleration can save up to ₱45 on this route.',
          icon: Icons.energy_savings_leaf_outlined,
          iconBackgroundColor: const Color(0xFFFBE4E4), // light red background
          iconColor: const Color(0xFFD32F2F), // red icon
        ),
      ],
    );
  }

  Widget _buildInsightCard({
    required String title,
    required String description,
    required IconData icon,
    required Color iconBackgroundColor,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceBright,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceDim.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBackgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.inter(
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
}
