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
    return Column(
      children: [
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                Text(
                  'Insight Level',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
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
                SelectionCard(
                  icon: Icons.bar_chart,
                  title: 'Yes (Detailed breakdowns)',
                  subtitle: 'Full analytics, cost per km, and AI trends.',
                  isSelected: _selectedOption == 'Yes (Detailed breakdowns)',
                  onTap: () => setState(
                    () => _selectedOption = 'Yes (Detailed breakdowns)',
                  ),
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
                  isSelected:
                      _selectedOption == 'Simple (Just recommendations)',
                  onTap: () => setState(
                    () => _selectedOption = 'Simple (Just recommendations)',
                  ),
                  iconColor: Colors.blueGrey,
                  iconBackgroundColor: Colors.blueGrey.withOpacity(0.1),
                ),
              ],
            ),
          ),
        ),
        Expanded(child: SizedBox(height: 0)),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              FilledButton(
                onPressed: widget.onFinish,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryMain,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        'Finish Setup',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'SETUP HARIBON ECOSYSTEM',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  letterSpacing: 2,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
