import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'widgets/onboarding_step_header.dart';
import 'widgets/step_1_welcome.dart';
import 'widgets/step_2_planning.dart';
import 'widgets/step_3_refueling.dart';
import 'widgets/step_4_insight.dart';

import '../../core/database/database_service.dart';
import '../../core/supabase/supabase_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 1;
  final int _totalSteps = 4;

  // Data collected during onboarding
  String _userName = '';
  String _vehicleType = '';
  String _travelFrequency = '';
  double _avgRefuelingCost = 0.0;
  String _planningStyle = '';
  String _refuelingPriority = '';

  void _nextPage() {
    if (_currentStep < _totalSteps) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentStep > 1) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _finishOnboarding() async {
    final Map<String, dynamic> onboardingData = {
      'user_name': _userName,
      'vehicle_type': _vehicleType,
      'travel_frequency': _travelFrequency,
      'avg_refueling_cost': _avgRefuelingCost,
      'planning_style': _planningStyle,
      'refueling_priority': _refuelingPriority,
    };

    try {
      // Save locally
      await DatabaseService().saveOnboardingData(onboardingData);
      
      // Save to Supabase
      await SupabaseService().saveOnboardingData(onboardingData);

      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      debugPrint('Error finishing onboarding: $e');
      // Still navigate to home even if save fails, or show error?
      // For now, let's navigate.
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceMain,
      body: SafeArea(
        child: Column(
          children: [
            OnboardingStepHeader(
              currentStep: _currentStep,
              totalSteps: _totalSteps,
              onBack: _currentStep > 1 ? _previousPage : null,
              onSkip: _currentStep < _totalSteps ? () => _pageController.jumpToPage(_totalSteps - 1) : null,
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentStep = index + 1;
                  });
                },
                children: [
                  Step1Welcome(onContinue: (name, vehicle, frequency, cost) {
                    setState(() {
                      _userName = name;
                      _vehicleType = vehicle;
                      _travelFrequency = frequency;
                      _avgRefuelingCost = double.tryParse(cost) ?? 0.0;
                    });
                    _nextPage();
                  }),
                  Step2Planning(onContinue: (style) {
                    setState(() {
                      _planningStyle = style;
                    });
                    _nextPage();
                  }),
                  Step3Refueling(onContinue: (priority) {
                    setState(() {
                      _refuelingPriority = priority;
                    });
                    _nextPage();
                  }),
                  Step4Insight(onFinish: _finishOnboarding),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
