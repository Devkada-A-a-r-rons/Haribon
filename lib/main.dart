import 'package:flutter/material.dart';
import './theme/app_theme.dart';
import './features/summary/trip_summary_screen.dart';

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
      home: TripSummaryScreen.mock(),
    );
  }
}