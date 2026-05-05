import 'package:flutter/material.dart';
import 'widgets/profile_header.dart';
import 'widgets/setting_section.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
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
            color: const Color(0xFF1B2430),
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
                color: const Color(0xFF7AA8F9), // Light blue app theme color equivalent to the mockup
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
                options: const ['Rigid', 'Flexible', 'Spontaneous'],
                initialIndex: 1, // Flexible is selected
                onChanged: (index) {},
              ),
              SettingSection(
                icon: Icons.local_gas_station_outlined,
                sectionTitle: 'REFUELING PRIORITY',
                question: 'What matters most when refueling?',
                options: const ['Cost', 'Distance', 'Security'],
                initialIndex: 0, // Cost is selected
                onChanged: (index) {},
              ),
              SettingSection(
                icon: Icons.lightbulb_outline,
                sectionTitle: 'INSIGHT LEVEL',
                question: 'How much detail do you want?',
                options: const ['Simple', 'Balanced', 'Detailed'],
                initialIndex: 1, // Balanced is selected
                onChanged: (index) {},
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
                    backgroundColor: const Color(0xFF4A6B5D), // Dark green color
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
                      color: const Color(0xFF7AA8F9), // Light blue
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
