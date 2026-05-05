import 'package:flutter/material.dart';
import './theme/app_theme.dart';
import './features/summary/main_summary_screen.dart';
import './features/summary/trip_summary_screen.dart';
import './features/common/widgets/nav_bar.dart';
import './features/vehicle-intelligence/vehicle_intelligence_screen.dart';
import './features/smart-trip-planner/smart-trip-planner.dart';
import './features/fuel-and-emissions/fuel-and-emissions.dart';
import './features/home/home_screen.dart';
import './features/chatbot/chatbot_screen.dart';
import './features/settings/settings_screen.dart';
import './features/onboarding/onboarding_screen.dart';
import './features/history/history_screen.dart';
import 'package:haribon/theme/app_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:device_preview/device_preview.dart';


void main() {
  runApp(DevicePreview(enabled: !kReleaseMode, builder: (context) => const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Haribon',
      debugShowCheckedModeBanner: false,
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      theme: AppTheme.lightTheme,
      // home: const MainScreen(), // Uncomment this to bypass onboarding
      home: const OnboardingScreen(), 
      routes: {
        '/home': (context) => const MainScreen(),
        '/smart-trip-planner': (context) => const SmartTripPlanner(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0; // Default to Home

  final List<Widget> _screens = [
    const HomeScreen(),
    const VehicleIntelligenceScreen(),
    const SmartTripPlanner(),
    MainSummaryScreen.mock(),
    const HistoryScreen(),
    const FuelAndEmissionsScreen(),
    const ChatbotScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: CommonNavBar(
        activeIndex: _currentIndex,
        onTabSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      floatingActionButton: _currentIndex == 6 
        ? null 
        : FloatingActionButton(
            onPressed: () {
              setState(() {
                _currentIndex = 6; // Switch to Chatbot
              });
            },
            backgroundColor: AppColors.blueAccent,
            child: const Icon(Icons.auto_awesome, color: Colors.white),
          ),
    );
  }
}
