import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import 'selection_card.dart';

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
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
          Text(
            'What matters most\nwhen refueling?',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  height: 1.1,
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
            onTap: () => setState(() => _selectedOption = 'Cheapest fuel'),
            iconColor: Colors.blue,
            iconBackgroundColor: Colors.blue.withOpacity(0.1),
          ),
          SelectionCard(
            icon: Icons.location_on_outlined,
            title: 'Convenience',
            subtitle: 'Nearest available station on route',
            isSelected: _selectedOption == 'Convenience',
            onTap: () => setState(() => _selectedOption = 'Convenience'),
            iconColor: Colors.green,
            iconBackgroundColor: Colors.green.withOpacity(0.1),
          ),
          SelectionCard(
            icon: Icons.battery_full_outlined,
            title: 'Full tank security',
            subtitle: 'Top up early, never run low',
            isSelected: _selectedOption == 'Full tank security',
            onTap: () => setState(() => _selectedOption = 'Full tank security'),
            iconColor: Colors.blueGrey,
            iconBackgroundColor: Colors.blueGrey.withOpacity(0.1),
          ),
          const SizedBox(height: 32),
          Container(
            height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: AppColors.containerLow,
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.white.withOpacity(0.8),
                  ],
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Smart stops save users an average of',
                      style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                    ),
                    Text(
                      '\$45/mo',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryMain),
                    ),
                  ],
                ),
              ),
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
        ],
      ),
      ),
    );
  }
}
