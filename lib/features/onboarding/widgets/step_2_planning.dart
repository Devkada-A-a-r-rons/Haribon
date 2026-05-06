import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import 'selection_card.dart';

class Step2Planning extends StatefulWidget {
  final Function(String) onContinue;

  const Step2Planning({super.key, required this.onContinue});

  @override
  State<Step2Planning> createState() => _Step2PlanningState();
}

class _Step2PlanningState extends State<Step2Planning> {
  String _selectedOption = 'Some planning';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
          Text(
            'How much do you\nplan ahead?',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  height: 1.1,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            'Tailor your journey intelligence by choosing your preferred navigation style.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 32),
          SelectionCard(
            icon: Icons.map_outlined,
            title: 'I plan everything',
            subtitle: 'Detailed routes and scheduled stops for total control.',
            isSelected: _selectedOption == 'I plan everything',
            onTap: () => setState(() => _selectedOption = 'I plan everything'),
          ),
          SelectionCard(
            icon: Icons.calendar_today_outlined,
            title: 'Some planning',
            subtitle: 'Flexible schedules with automated AI route suggestions.',
            isSelected: _selectedOption == 'Some planning',
            onTap: () => setState(() => _selectedOption = 'Some planning'),
          ),
          SelectionCard(
            icon: Icons.explore_outlined,
            title: 'I decide along the way',
            subtitle: 'Pure discovery. Let the Haribon AI find hidden gems live.',
            isSelected: _selectedOption == 'I decide along the way',
            onTap: () => setState(() => _selectedOption = 'I decide along the way'),
          ),
          const SizedBox(height: 32),
          Container(
            height: 120,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.containerLow,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Efficiency Score',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.stars, color: AppColors.primaryMain, size: 14),
                          const SizedBox(width: 4),
                          Text('Top 12% of Haribon users', style: TextStyle(fontSize: 10)),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(Icons.directions_car, size: 40, color: AppColors.primaryMain.withOpacity(0.5)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => widget.onContinue(_selectedOption),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Continue'),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, size: 18),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Your preferences help us calculate eco-savings.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textTertiary,
                ),
          ),
        ],
      ),
      ),
    );
  }
}
