import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../theme/app_colors.dart';

class MetricsGrid extends StatelessWidget {
  final Map<String, dynamic> tripData;
  const MetricsGrid({super.key, required this.tripData});

  @override
  Widget build(BuildContext context) {
    // Correctly fetch values using fallbacks for active plans vs saved trips
    final fuelCost = (tripData['est_fuel_cost'] ?? tripData['budget'] ?? 0.0).toDouble();
    final toll = (tripData['toll_fee'] ?? 0.0).toDouble();
    final budget = (tripData['total_budget'] ?? tripData['budget'] ?? 0.0).toDouble();
    final distance = (tripData['distance_km'] ?? tripData['route_distance_km'] ?? 0.0).toDouble();
    final liters = fuelCost > 0 ? (fuelCost / 68.0) : (distance * 0.08); // fallback calculation
    final fuelCapacity = (tripData['fuel_capacity'] ?? 45.0).toDouble();

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'FUEL CAPACITY',
                value: '${fuelCapacity.toStringAsFixed(0)}L',
                icon: Icons.local_gas_station_outlined,
                subtitle: 'Vehicle Spec',
                backgroundColor: AppColors.containerLow,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMetricCard(
                title: 'DISTANCE',
                value: '${distance.toStringAsFixed(0)} km',
                icon: Icons.location_on_outlined,
                subtitle: 'Start to Finish',
                backgroundColor: AppColors.containerLow,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildFuelUsedCard(liters),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMetricCard(
                title: 'TOTAL BUDGET',
                value: '₱${budget.toStringAsFixed(0)}',
                icon: Icons.account_balance_wallet_outlined,
                subtitle: 'Allocated Funds',
                backgroundColor: AppColors.historyBlueGray,
                textColor: Colors.white,
                subtitleColor: Colors.white70,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required String subtitle,
    required Color backgroundColor,
    Color? textColor,
    Color? subtitleColor,
  }) {
    final colorText = textColor ?? AppColors.textPrimary;
    final colorSubText = subtitleColor ?? AppColors.textSecondary;
    final colorTitle = textColor ?? AppColors.historyNavy; // dark navy for title

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: colorTitle,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: colorText,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(icon, size: 12, color: colorSubText),
              const SizedBox(width: 4),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: colorSubText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFuelUsedCard(double liters) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: AppColors.surfaceDim.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'FUEL USED',
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: AppColors.historyNavy,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                liters.toStringAsFixed(1),
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'L',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                flex: 4,
                child: Container(
                  height: 4,
                  decoration: const BoxDecoration(
                    color: AppColors.historyBlue,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(2),
                      bottomLeft: Radius.circular(2),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  height: 4,
                  decoration: const BoxDecoration(
                    color: AppColors.insightRed,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(2),
                      bottomRight: Radius.circular(2),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
