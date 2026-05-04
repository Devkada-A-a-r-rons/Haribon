import 'package:flutter/material.dart';

class InsightCard extends StatelessWidget {
  const InsightCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
            children: [
              const Icon(Icons.lightbulb_outline, color: Color(0xFF3B5B78), size: 18),
              const SizedBox(width: 8),
              Text(
                'AI Budget Insights',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF3B5B78),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInsightRow(theme, const Color(0xFF4A6B5D), 'Refuel at Shell Angeles to save\n₱60'),
          const SizedBox(height: 12),
          _buildInsightRow(theme, const Color(0xFF3B5B78), 'Food is your 2nd biggest\nexpense'),
          const SizedBox(height: 12),
          _buildInsightRow(theme, const Color(0xFFC62828), 'Over budget by ₱180'),
        ],
      ),
    );
  }

  Widget _buildInsightRow(ThemeData theme, Color dotColor, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0xFF1B2430),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
