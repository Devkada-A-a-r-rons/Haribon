import 'package:flutter/material.dart';
import './theme/app_theme.dart';
import './features/summary/trip_summary_screen.dart';
import './features/common/widgets/nav_bar.dart';

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
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 2; // Default to Summary

  final List<Widget> _screens = [
    const Scaffold(body: Center(child: Text('Home Screen'))),
    const Scaffold(body: Center(child: Text('Planner Screen'))),
    TripSummaryScreen.mock(),
    const Scaffold(body: Center(child: Text('History Screen'))),
    const Scaffold(body: Center(child: Text('Insights Screen'))),
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
    );
  }
}
