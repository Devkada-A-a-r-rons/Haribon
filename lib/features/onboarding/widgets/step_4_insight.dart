import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import 'selection_card.dart';

class Step4Insight extends StatefulWidget {
  final VoidCallback onFinish;

  const Step4Insight({super.key, required this.onFinish});

  @override
  State<Step4Insight> createState() => _Step4InsightState();
}

class _Step4InsightState extends State<Step4Insight> {
  String _selectedOption = 'Yes (Detailed breakdowns)';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
          Text(
            'Insight Level',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Do you want detailed fuel insights?',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 24),
          // Top illustration mock
          Container(
            height: 140,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.containerLow,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Efficiency Score', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check, size: 10, color: AppColors.primaryMain),
                          const SizedBox(width: 4),
                          Text('Top 12% of Haribon users', style: TextStyle(fontSize: 8, color: AppColors.primaryMain)),
                        ],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStat('Fuel Used', '18.4L', 'P1,380'),
                    _buildStat('Avg Speed', '62 km/h', ''),
                    _buildStat('CO2 Saved', '2.1kg', ''),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SelectionCard(
            icon: Icons.bar_chart,
            title: 'Yes (Detailed breakdowns)',
            subtitle: 'Full analytics, cost per km, and AI trends.',
            isSelected: _selectedOption == 'Yes (Detailed breakdowns)',
            onTap: () => setState(() => _selectedOption = 'Yes (Detailed breakdowns)'),
            iconColor: Colors.blue,
            iconBackgroundColor: Colors.blue.withOpacity(0.1),
          ),
          SelectionCard(
            icon: Icons.balance,
            title: 'Balanced',
            subtitle: 'Essential summaries and key savings metrics.',
            isSelected: _selectedOption == 'Balanced',
            onTap: () => setState(() => _selectedOption = 'Balanced'),
            iconColor: Colors.green,
            iconBackgroundColor: Colors.green.withOpacity(0.1),
          ),
          SelectionCard(
            icon: Icons.lightbulb_outline,
            title: 'Simple (Just recommendations)',
            subtitle: 'Actionable tips without the heavy data charts.',
            isSelected: _selectedOption == 'Simple (Just recommendations)',
            onTap: () => setState(() => _selectedOption = 'Simple (Just recommendations)'),
            iconColor: Colors.blueGrey,
            iconBackgroundColor: Colors.blueGrey.withOpacity(0.1),
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: widget.onFinish,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF2E59D1), // Darker blue like in screenshot
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text('Finish Setup', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'SETUP AGILA ECOSYSTEM',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  letterSpacing: 2,
                  color: AppColors.textTertiary,
                ),
          ),
          const SizedBox(height: 16),
          // Community card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const CircleAvatar(radius: 12, backgroundColor: Colors.white, child: Icon(Icons.people, size: 14)),
                const SizedBox(width: 12),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                      children: [
                        const TextSpan(text: 'Join '),
                        TextSpan(text: '12,000+ drivers', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryMain)),
                        const TextSpan(text: ' optimizing their routes today.'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
            ),
    );
  }

  Widget _buildStat(String label, String value, String subValue) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 8, color: AppColors.textTertiary)),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        if (subValue.isNotEmpty) Text(subValue, style: TextStyle(fontSize: 8, color: AppColors.textTertiary)),
      ],
    );
  }
}
