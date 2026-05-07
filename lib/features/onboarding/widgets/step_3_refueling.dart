import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import 'selection_card.dart';
import 'continue_button.dart';

class Step3Refueling extends StatefulWidget {
  final Function(String) onContinue;

  const Step3Refueling({super.key, required this.onContinue});

  @override
  State<Step3Refueling> createState() => _Step3RefuelingState();
}

class _Step3RefuelingState extends State<Step3Refueling> {
  String _selectedOption = 'Cheapest fuel';

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
                    'What matters most\nwhen refueling?',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Select your primary concern to help Haribon optimize your journey stops.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SelectionCard(
                    icon: Icons.attach_money,
                    title: 'Cheapest fuel',
                    subtitle: 'Prioritize lowest cost per gallon',
                    isSelected: _selectedOption == 'Cheapest fuel',
                    onTap: () =>
                        setState(() => _selectedOption = 'Cheapest fuel'),
                    iconColor: Colors.blue,
                    iconBackgroundColor: Colors.blue.withOpacity(0.1),
                  ),
                  SelectionCard(
                    icon: Icons.location_on_outlined,
                    title: 'Convenience',
                    subtitle: 'Nearest available station on route',
                    isSelected: _selectedOption == 'Convenience',
                    onTap: () =>
                        setState(() => _selectedOption = 'Convenience'),
                    iconColor: Colors.green,
                    iconBackgroundColor: Colors.green.withOpacity(0.1),
                  ),
                  SelectionCard(
                    icon: Icons.battery_full_outlined,
                    title: 'Full tank security',
                    subtitle: 'Top up early, never run low',
                    isSelected: _selectedOption == 'Full tank security',
                    onTap: () =>
                        setState(() => _selectedOption = 'Full tank security'),
                    iconColor: Colors.blueGrey,
                    iconBackgroundColor: Colors.blueGrey.withOpacity(0.1),
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
