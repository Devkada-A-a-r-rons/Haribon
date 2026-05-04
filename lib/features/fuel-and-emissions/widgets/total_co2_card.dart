import 'package:flutter/material.dart';

class TotalCo2Card extends StatelessWidget {
  const TotalCo2Card({super.key});

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
            'TOTAL CO2',
            style: textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: const Color(0xFF1B2430),
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '53.6 kg',
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF4A6B5D),
              fontSize: 28,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.park, size: 16, color: Color(0xFF4A6B5D)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Equivalent to 2 small trees needed to offset',
                  style: textTheme.bodySmall?.copyWith(color: const Color(0xFF4A6B5D)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
