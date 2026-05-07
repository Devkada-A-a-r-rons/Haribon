import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../theme/app_colors.dart';
import 'continue_button.dart';

class Step1Welcome extends StatefulWidget {
  final Function(String name, String vehicle, String frequency, String cost)
  onContinue;

  const Step1Welcome({super.key, required this.onContinue});

  @override
  State<Step1Welcome> createState() => _Step1WelcomeState();
}

class _Step1WelcomeState extends State<Step1Welcome> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _costController = TextEditingController(
    text: "0.00",
  );
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
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: Theme.of(context).textTheme.headlineMedium,
                      children: [
                        const TextSpan(text: 'welcome to '),
                        TextSpan(
                          text: 'haribon',
                          style: TextStyle(color: AppColors.primaryMain),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your journey to smarter, greener travel starts here.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),

                  // Name Question
                  _buildQuestionLabel('What should we call you?'),
                  const SizedBox(height: 8),
                  _buildShadowBox(
                    child: TextField(
                      controller: _nameController,
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Enter your name',
                        hintStyle: const TextStyle(fontSize: 13),
                        fillColor: Colors.white,
                        suffixIcon: const Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Icon(
                            Icons.face_outlined,
                            color: AppColors.textTertiary,
                            size: 18,
                          ),
                        ),
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
                  const SizedBox(height: 32),

                  // Vehicle Question
                  _buildQuestionLabel('What vehicle do you drive?'),
                  const SizedBox(height: 8),
                  _buildShadowBox(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedVehicle,
                          isExpanded: true,
                          icon: const Icon(
                            Icons.keyboard_arrow_down,
                            color: AppColors.textTertiary,
                            size: 18,
                          ),
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                          ),
                          items: _vehicles.map((String vehicle) {
                            return DropdownMenuItem<String>(
                              value: vehicle,
                              child: Text(
                                vehicle,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: vehicle == 'Select vehicle type'
                                      ? AppColors.textTertiary
                                      : AppColors.textPrimary,
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
                  ),
                  const SizedBox(height: 20),

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
                  const SizedBox(height: 20),

                  // Cost Question
                  _buildQuestionLabel('Average refueling cost?'),
                  const SizedBox(height: 8),
                  _buildShadowBox(
                    child: TextField(
                      controller: _costController,
                      style: const TextStyle(fontSize: 13),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textInputAction: TextInputAction.done,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}'),
                        ),
                      ],
                      decoration: const InputDecoration(
                        fillColor: Colors.white,
                        prefixIcon: Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Text(
                            '₱',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ContinueButton(
            onPressed: () => widget.onContinue(
              _nameController.text,
              _selectedVehicle,
              _travelFrequency,
              _costController.text,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShadowBox({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildQuestionLabel(String label) {
    return Center(
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
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
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primaryMain : AppColors.surfaceDim,
              width: 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
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
          Icon(
            icon,
            size: 16,
            color: isPrimary ? AppColors.primaryMain : AppColors.textTertiary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 10,
                color: isPrimary
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
                fontWeight: isPrimary ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
