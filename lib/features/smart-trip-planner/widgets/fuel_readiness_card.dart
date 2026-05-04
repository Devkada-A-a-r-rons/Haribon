import 'package:flutter/material.dart';

class FuelReadinessCard extends StatelessWidget {
  const FuelReadinessCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.local_gas_station_outlined, color: Color(0xFF3B5B78)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Refill Needed',
                  style: textTheme.labelSmall?.copyWith(color: const Color(0xFFC62828), fontWeight: FontWeight.bold, fontSize: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('Fuel Readiness', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text('Current Tank: 8L (96km)', style: textTheme.bodySmall?.copyWith(color: const Color(0xFF6B7B8A))),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(8),
              border: const Border(left: BorderSide(color: Color(0xFFC62828), width: 3)),
            ),
            child: Text(
              'Warning: 10.3L more needed for the 220km trip to Baguio.',
              style: textTheme.bodySmall?.copyWith(color: const Color(0xFF1B2430), fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
