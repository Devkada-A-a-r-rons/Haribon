import 'package:flutter/material.dart';
import 'widgets/profile_header.dart';
import 'widgets/setting_section.dart';
import 'package:haribon/theme/app_colors.dart';


class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.greyLightest,
      appBar: AppBar(
        backgroundColor: AppColors.greyLightest,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: CircleAvatar(
            backgroundColor: Colors.grey.shade300,
            backgroundImage: const NetworkImage('https://i.pravatar.cc/150?img=11'), // Placeholder avatar
          ),
        ),
        title: Text(
          'Settings',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.navyDarker,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'Save',
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.blueLightAccent, // Light blue app theme color equivalent to the mockup
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ProfileHeader(),
              const SizedBox(height: 40),
              SettingSection(
                icon: Icons.route_outlined,
                sectionTitle: 'PLANNING STYLE',
                question: 'How do you plan your trips?',
                options: const ['Rigid', 'Some planning', 'I decide along the way'],
                initialIndex: 1,
                onChanged: (index) {},
              ),
              SettingSection(
                icon: Icons.local_gas_station_outlined,
                sectionTitle: 'REFUELING PRIORITY',
                question: 'What matters most when refueling?',
                options: const ['Cheapest', 'Convenience', 'Full Tank Security'],
                initialIndex: 0,
                onChanged: (index) {},
              ),
              SettingSection(
                icon: Icons.lightbulb_outline,
                sectionTitle: 'INSIGHT LEVEL',
                question: 'How much detail do you want?',
                options: const ['Simple', 'Balanced', 'Detailed'],
                initialIndex: 1,
                onChanged: (index) {},
              ),
              SettingSection(
                icon: Icons.calendar_month_outlined,
                sectionTitle: 'TRAVEL FREQUENCY',
                question: 'How often do you travel?',
                options: const ['Daily', 'Weekly', 'Monthly'],
                initialIndex: 1,
                onChanged: (index) {},
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
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: 'Sedan',
                        isExpanded: true,
                        items: ['Sedan', 'SUV', 'Hatchback', 'Truck', 'Motorcycle'].map((String v) {
                          return DropdownMenuItem(value: v, child: Text(v));
                        }).toList(),
                        onChanged: (v) {},
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
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.tealDark, // Dark green color
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
              const SizedBox(height: 16),
              // Reset to Defaults
              Center(
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    'Reset to Defaults',
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.blueLightAccent, // Light blue
                      fontWeight: FontWeight.w600,
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
