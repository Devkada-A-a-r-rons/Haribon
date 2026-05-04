import 'package:flutter/material.dart';

class EfficiencyLossInsightsCard extends StatelessWidget {
  const EfficiencyLossInsightsCard({super.key});

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
            'EFFICIENCY LOSS INSIGHTS',
            style: textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: const Color(0xFF1B2430),
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 20),
          _buildInsightItem(
            textTheme: textTheme,
            icon: Icons.terrain,
            iconColor: const Color(0xFFC62828),
            bgColor: const Color(0xFFFFEBEE),
            text: 'Mountain terrain increased fuel usage by 15%',
          ),
          const SizedBox(height: 16),
          _buildInsightItem(
            textTheme: textTheme,
            icon: Icons.directions_car,
            iconColor: const Color(0xFFF57C00),
            bgColor: const Color(0xFFFFF3E0),
            text: 'Traffic added 8% consumption',
          ),
          const SizedBox(height: 16),
          _buildInsightItem(
            textTheme: textTheme,
            icon: Icons.access_time,
            iconColor: const Color(0xFF607D8B),
            bgColor: const Color(0xFFECEFF1),
            text: 'Idle time wasted 0.5L',
            hideDivider: true,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem({
    required TextTheme textTheme,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String text,
    bool hideDivider = false,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: textTheme.bodySmall?.copyWith(color: const Color(0xFF1B2430), height: 1.4),
              ),
            ),
          ],
        ),
        if (!hideDivider) ...[
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFF0F2F5)),
        ],
      ],
    );
  }
}
