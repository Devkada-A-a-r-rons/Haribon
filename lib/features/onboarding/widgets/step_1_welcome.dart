import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class Step1Welcome extends StatefulWidget {
  final Function(String name, String vehicle, String frequency, String cost) onContinue;

  const Step1Welcome({super.key, required this.onContinue});

  @override
  State<Step1Welcome> createState() => _Step1WelcomeState();
}

class _Step1WelcomeState extends State<Step1Welcome> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _costController = TextEditingController(text: "0.00");
  String _selectedVehicle = 'Select vehicle type';
  String _travelFrequency = 'Weekly';

  final List<String> _vehicles = [
    'Select vehicle type',
    'Sedan',
    'SUV',
    'Hatchback',
    'Truck',
    'Motorcycle',
    'Electric Vehicle',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _costController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Illustration mock
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.3),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      top: 30,
                      child: _buildMockCard("Cheapest gas stations near me", Icons.local_gas_station),
                    ),
                    Positioned(
                      top: 70,
                      child: _buildMockCard("Current fuel price in Baguio", Icons.monetization_on, isPrimary: true),
                    ),
                    Positioned(
                      top: 110,
                      child: _buildMockCard("How to improve my efficiency?", Icons.trending_up),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
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
            const SizedBox(height: 8),
            Text(
              'Your journey to smarter, greener travel starts here.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 32),
            
            // Name Question
            _buildQuestionLabel('What should we call you?'),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Enter your name',
                suffixIcon: const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Icon(Icons.face_outlined, color: AppColors.textTertiary, size: 20),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'This is how you\'ll appear in your eco-driving reports and AI route insights.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 11,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Vehicle Question
            _buildQuestionLabel('What vehicle do you drive?'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.containerLow,
                borderRadius: BorderRadius.circular(16),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedVehicle,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textTertiary),
                  items: _vehicles.map((String vehicle) {
                    return DropdownMenuItem<String>(
                      value: vehicle,
                      child: Text(
                        vehicle,
                        style: TextStyle(
                          color: vehicle == 'Select vehicle type' ? AppColors.textTertiary : AppColors.textPrimary,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() => _selectedVehicle = newValue);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Frequency Question
            _buildQuestionLabel('How often do you travel?'),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildFrequencyOption('Daily'),
                const SizedBox(width: 8),
                _buildFrequencyOption('Weekly'),
                const SizedBox(width: 8),
                _buildFrequencyOption('Monthly'),
              ],
            ),
            const SizedBox(height: 24),

            // Cost Question
            _buildQuestionLabel('Average refueling cost?'),
            const SizedBox(height: 8),
            TextField(
              controller: _costController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                prefixIcon: Padding(
                  padding: EdgeInsets.all(14.0),
                  child: Text(
                    '₱',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),

            FilledButton(
              onPressed: () => widget.onContinue(
                _nameController.text,
                _selectedVehicle,
                _travelFrequency,
                _costController.text,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Continue'),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 18),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionLabel(String label) {
    return Center(
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2E59D1), // Specific blue from image
            ),
      ),
    );
  }

  Widget _buildFrequencyOption(String title) {
    final bool isSelected = _travelFrequency == title;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _travelFrequency = title),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primaryMain : AppColors.surfaceDim,
              width: 1,
            ),
            boxShadow: isSelected ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
            ] : null,
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
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
