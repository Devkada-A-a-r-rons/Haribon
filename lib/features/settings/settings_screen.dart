import 'package:flutter/material.dart';
import 'widgets/profile_header.dart';
import 'widgets/setting_section.dart';
import 'package:haribon/theme/app_colors.dart';
import '../../core/database/database_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final DatabaseService _dbService = DatabaseService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  
  String _vehicleType = 'Sedan';
  int _planningStyleIndex = 1;
  int _refuelingPriorityIndex = 0;
  int _insightLevelIndex = 1;
  int _travelFrequencyIndex = 1;
  bool _isLoading = true;

  final List<String> _planningOptions = ['Rigid', 'Some planning', 'I decide along the way'];
  final List<String> _refuelingOptions = ['Cheapest', 'Convenience', 'Full Tank Security'];
  final List<String> _insightOptions = ['Simple', 'Balanced', 'Detailed'];
  final List<String> _frequencyOptions = ['Daily', 'Weekly', 'Monthly'];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final data = await _dbService.getOnboardingData();
    if (data != null) {
      setState(() {
        _nameController.text = data['user_name'] ?? 'Haribon User';
        _costController.text = (data['avg_refueling_cost'] ?? 0.0).toString();
        
        // Safety check for vehicle type dropdown
        final savedVehicle = data['vehicle_type'] ?? 'Sedan';
        final validVehicles = ['Sedan', 'SUV', 'Hatchback', 'Truck', 'Motorcycle'];
        if (validVehicles.contains(savedVehicle)) {
          _vehicleType = savedVehicle;
        } else {
          // If the saved vehicle is a specific model (e.g., Lexus), default to Sedan for the category dropdown
          _vehicleType = 'Sedan';
        }
        
        // Find indexes
        _planningStyleIndex = _planningOptions.indexOf(data['planning_style'] ?? 'Some planning');
        if (_planningStyleIndex == -1) _planningStyleIndex = 1;

        _refuelingPriorityIndex = _refuelingOptions.indexOf(data['refueling_priority'] ?? 'Cheapest');
        if (_refuelingPriorityIndex == -1) _refuelingPriorityIndex = 0;

        _travelFrequencyIndex = _frequencyOptions.indexOf(data['travel_frequency'] ?? 'Weekly');
        if (_travelFrequencyIndex == -1) _travelFrequencyIndex = 1;
        
        _isLoading = false;
      });
    } else {
      setState(() {
        _nameController.text = 'New User';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveData() async {
    // NaN Guard: Ensure cost is a valid number
    double cost = 0.0;
    try {
      cost = double.parse(_costController.text.replaceAll(',', ''));
    } catch (_) {
      cost = 0.0;
    }

    final updatedData = {
      'user_name': _nameController.text,
      'vehicle_type': _vehicleType,
      'avg_refueling_cost': cost,
      'planning_style': _planningOptions[_planningStyleIndex],
      'refueling_priority': _refuelingOptions[_refuelingPriorityIndex],
      'travel_frequency': _frequencyOptions[_travelFrequencyIndex],
    };

    await _dbService.updateLatestOnboardingData(updatedData);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings updated successfully!'),
          backgroundColor: AppColors.tealDark,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _costController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.surfaceMain,
        body: Center(child: CircularProgressIndicator(color: AppColors.blueAccent)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surfaceMain,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceMain,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Settings',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.navyDarker,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileHeader(controller: _nameController),
              const SizedBox(height: 40),
              SettingSection(
                icon: Icons.route_outlined,
                sectionTitle: 'PLANNING STYLE',
                question: 'How do you plan your trips?',
                options: _planningOptions,
                initialIndex: _planningStyleIndex,
                onChanged: (index) => setState(() => _planningStyleIndex = index),
              ),
              SettingSection(
                icon: Icons.local_gas_station_outlined,
                sectionTitle: 'REFUELING PRIORITY',
                question: 'What matters most when refueling?',
                options: _refuelingOptions,
                initialIndex: _refuelingPriorityIndex,
                onChanged: (index) => setState(() => _refuelingPriorityIndex = index),
              ),
              SettingSection(
                icon: Icons.lightbulb_outline,
                sectionTitle: 'INSIGHT LEVEL',
                question: 'How much detail do you want?',
                options: _insightOptions,
                initialIndex: _insightLevelIndex,
                onChanged: (index) => setState(() => _insightLevelIndex = index),
              ),
              SettingSection(
                icon: Icons.calendar_month_outlined,
                sectionTitle: 'TRAVEL FREQUENCY',
                question: 'How often do you travel?',
                options: _frequencyOptions,
                initialIndex: _travelFrequencyIndex,
                onChanged: (index) => setState(() => _travelFrequencyIndex = index),
              ),
              // Vehicle Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.directions_car_outlined, size: 14, color: AppColors.blueGreyDark),
                      const SizedBox(width: 8),
                      Text(
                        'VEHICLE TYPE'.toUpperCase(),
                        style: textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          color: AppColors.blueGreySecondary,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'What vehicle do you drive?',
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.navyDarker,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.containerLow,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _vehicleType,
                        isExpanded: true,
                        items: ['Sedan', 'SUV', 'Hatchback', 'Truck', 'Motorcycle'].map((String v) {
                          return DropdownMenuItem(value: v, child: Text(v));
                        }).toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => _vehicleType = v);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
              // Refueling Cost Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.payments_outlined, size: 14, color: AppColors.blueGreyDark),
                      const SizedBox(width: 8),
                      Text(
                        'REFUELING COST'.toUpperCase(),
                        style: textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          color: AppColors.blueGreySecondary,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Average refueling cost?',
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.navyDarker,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _costController,
                    decoration: InputDecoration(
                      hintText: '0.00',
                      prefixIcon: const Padding(
                        padding: EdgeInsets.all(14.0),
                        child: Text('₱', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      fillColor: AppColors.containerLow,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
              const SizedBox(height: 16),
              // Save Changes button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _saveData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.tealDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Save Changes',
                    style: textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
