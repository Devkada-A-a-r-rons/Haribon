import 'package:flutter/material.dart';
import './theme/app_theme.dart';
import './features/vehicle-intelligence/vehicle_intelligence_screen.dart';
import './features/smart-trip-planner/smart-trip-planner.dart';

// Replace this with your real first screen
class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return const SmartTripPlanner();
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Haribon',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AppRoot(),
    );
  }
}
