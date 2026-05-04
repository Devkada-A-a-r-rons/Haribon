import 'package:flutter/material.dart';

class TotalFuelCostCard extends StatelessWidget {
  const TotalFuelCostCard({super.key});

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
            'TOTAL FUEL COST',
            style: textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: const Color(0xFF1B2430),
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '₱1,508',
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF3B5B78),
              fontSize: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '₱317 extra from road conditions.',
            style: textTheme.bodySmall?.copyWith(color: const Color(0xFF6B7B8A)),
          ),
        ],
      ),
    );
  }
}
