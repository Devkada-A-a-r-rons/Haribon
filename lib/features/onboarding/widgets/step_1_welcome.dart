import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class Step1Welcome extends StatefulWidget {
  final Function(String) onContinue;

  const Step1Welcome({super.key, required this.onContinue});

  @override
  State<Step1Welcome> createState() => _Step1WelcomeState();
}

class _Step1WelcomeState extends State<Step1Welcome> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Illustration mock
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.3),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: 40,
                    child: _buildMockCard("Cheapest gas stations near me", Icons.local_gas_station),
                  ),
                  Positioned(
                    top: 80,
                    child: _buildMockCard("Current fuel price in Baguio", Icons.monetization_on, isPrimary: true),
                  ),
                  Positioned(
                    top: 120,
                    child: _buildMockCard("How to improve my efficiency?", Icons.trending_up),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
              children: [
                const TextSpan(text: 'Welcome to '),
                TextSpan(
                  text: 'Agila',
                  style: TextStyle(color: AppColors.primaryMain),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Your journey to smarter, greener\ntravel starts here.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
          ),
          const SizedBox(height: 32),
          Text(
            'What should we call you?',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryMain,
                ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: 'Enter your name',
              suffixIcon: Icon(Icons.timer_outlined, color: AppColors.textTertiary),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'This is how you\'ll appear in your eco-driving reports and AI route insights.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textTertiary,
                ),
          ),
          const Spacer(),
          FilledButton(
            onPressed: () => widget.onContinue(_nameController.text),
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
        ],
      ),
    );
  }

  Widget _buildMockCard(String text, IconData icon, {bool isPrimary = false}) {
    return Container(
      width: 250,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isPrimary ? AppColors.container : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: isPrimary ? AppColors.primaryMain : AppColors.textTertiary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 10,
                color: isPrimary ? AppColors.textPrimary : AppColors.textSecondary,
                fontWeight: isPrimary ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
