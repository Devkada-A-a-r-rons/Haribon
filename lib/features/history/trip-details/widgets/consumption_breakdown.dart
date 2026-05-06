import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../theme/app_colors.dart';

class ConsumptionBreakdown extends StatelessWidget {
  const ConsumptionBreakdown({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.containerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceDim.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildBreakdownItem(Icons.traffic_outlined, 'TRAFFIC', '1.8L'),
          _buildDivider(),
          _buildBreakdownItem(Icons.terrain_outlined, 'TERRAIN', '2.4L'),
          _buildDivider(),
          _buildBreakdownItem(Icons.access_time, 'IDLE', '0.6L'),
          _buildDivider(),
          _buildBreakdownItem(Icons.speed, 'EFFICIENCY', '92%'),
        ],
      ),
    );
  }

  Widget _buildBreakdownItem(IconData icon, String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: AppColors.textTertiary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      color: AppColors.surfaceDim.withOpacity(0.5),
    );
  }
}

