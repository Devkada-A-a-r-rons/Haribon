import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import 'selection_card.dart';
import 'continue_button.dart';

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
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    'How much do you\nplan ahead?',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
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
                    subtitle:
                        'Detailed routes and scheduled stops for total control.',
                    isSelected: _selectedOption == 'I plan everything',
                    onTap: () =>
                        setState(() => _selectedOption = 'I plan everything'),
                  ),
                  SelectionCard(
                    icon: Icons.calendar_today_outlined,
                    title: 'Some planning',
                    subtitle:
                        'Flexible schedules with automated AI route suggestions.',
                    isSelected: _selectedOption == 'Some planning',
                    onTap: () =>
                        setState(() => _selectedOption = 'Some planning'),
                  ),
                  SelectionCard(
                    icon: Icons.explore_outlined,
                    title: 'I decide along the way',
                    subtitle:
                        'Pure discovery. Let the Haribon AI find hidden gems live.',
                    isSelected: _selectedOption == 'I decide along the way',
                    onTap: () => setState(
                      () => _selectedOption = 'I decide along the way',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Your preferences help us calculate eco-savings.',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textTertiary),
              ),
              const SizedBox(height: 8),
              ContinueButton(
                onPressed: () => widget.onContinue(_selectedOption),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
