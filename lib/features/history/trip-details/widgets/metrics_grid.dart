import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../theme/app_colors.dart';

class MetricsGrid extends StatelessWidget {
  final Map<String, dynamic> tripData;
  const MetricsGrid({super.key, required this.tripData});

  @override
  Widget build(BuildContext context) {
    final fuelCost = (tripData['est_fuel_cost'] ?? tripData['budget'] ?? 0.0).toDouble();
    final toll = (tripData['toll_fee'] ?? 0.0).toDouble();
    final budget = (tripData['total_budget'] ?? tripData['budget'] ?? 0.0).toDouble();
    final distance = (tripData['distance_km'] ?? tripData['route_distance_km'] ?? 0.0).toDouble();
    final liters = fuelCost > 0 ? (fuelCost / 68.0) : (distance * 0.08);
    final fuelCapacity = (tripData['fuel_capacity'] ?? 45.0).toDouble();

    final metrics = [
      _Metric(label: 'FUEL CAPACITY', value: '${fuelCapacity.toStringAsFixed(0)}L', sub: 'Vehicle Spec', icon: Icons.local_gas_station_outlined),
      _Metric(label: 'DISTANCE', value: '${distance.toStringAsFixed(0)} km', sub: 'Start to Finish', icon: Icons.location_on_outlined),
      _Metric(label: 'FUEL USED', value: '${liters.toStringAsFixed(1)}L', sub: 'Estimated', icon: Icons.water_drop_outlined),
      _Metric(label: 'TOTAL BUDGET', value: '₱${budget.toStringAsFixed(0)}', sub: 'Allocated Funds', icon: Icons.account_balance_wallet_outlined),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: metrics.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.6,
      ),
      itemBuilder: (_, i) => _MetricTile(metric: metrics[i]),
    );
  }
}

class _Metric {
  final String label;
  final String value;
  final String sub;
  final IconData icon;
  const _Metric({required this.label, required this.value, required this.sub, required this.icon});
}

class _MetricTile extends StatelessWidget {
  final _Metric metric;
  const _MetricTile({required this.metric});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.containerLowest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            metric.label,
            style: GoogleFonts.poppins(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: AppColors.textTertiary,
              letterSpacing: 1,
            ),
          ),
          Text(
            metric.value,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          Row(
            children: [
              Icon(metric.icon, size: 11, color: AppColors.textTertiary),
              const SizedBox(width: 4),
              Text(
                metric.sub,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
