import 'package:flutter/material.dart';

class FuelConsumptionBreakdownCard extends StatelessWidget {
  const FuelConsumptionBreakdownCard({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'FUEL CONSUMPTION BREAKDOWN',
            style: textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: const Color(0xFF1B2430),
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 16),
          // Stacked Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 16,
              child: Row(
                children: [
                  Expanded(flex: 70, child: Container(color: const Color(0xFF3B5B78))), // Base
                  Expanded(flex: 10, child: Container(color: const Color(0xFFF57C00))), // Traffic
                  Expanded(flex: 15, child: Container(color: const Color(0xFFC62828))), // Terrain
                  Expanded(flex: 5, child: Container(color: const Color(0xFFB0BEC5))),  // Idle
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Grid
          Row(
            children: [
              Expanded(child: _buildLegendItem(textTheme, Icons.local_gas_station, const Color(0xFF3B5B78), 'Base', '18.3L')),
              Expanded(child: _buildLegendItem(textTheme, Icons.directions_car, const Color(0xFFF57C00), 'Traffic', '+1.5L')),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildLegendItem(textTheme, Icons.terrain, const Color(0xFFC62828), 'Terrain', '+2.9L')),
              Expanded(child: _buildLegendItem(textTheme, Icons.timer, const Color(0xFFB0BEC5), 'Idle', '+0.5L')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(TextTheme textTheme, IconData icon, Color iconColor, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: iconColor),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: textTheme.labelSmall?.copyWith(color: const Color(0xFF6B7B8A), fontSize: 10)),
            const SizedBox(height: 2),
            Text(value, style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700, color: const Color(0xFF1B2430))),
          ],
        ),
      ],
    );
  }
}
