import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'widgets/onboarding_step_header.dart';
import 'widgets/step_1_welcome.dart';
import 'widgets/step_2_planning.dart';
import 'widgets/step_3_refueling.dart';
import 'widgets/step_4_insight.dart';

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
                    _userName = name;
                    // You could store other data here if needed for future use
                    _nextPage();
                  }),
                  Step2Planning(onContinue: (style) {
                    _planningStyle = style;
                    _nextPage();
                  }),
                  Step3Refueling(onContinue: (priority) {
                    _refuelingPriority = priority;
                    _nextPage();
                  }),
                  Step4Insight(onFinish: () {
                    // Navigate to main app
                    debugPrint('Onboarding finished for $_userName');
                    debugPrint('Planning Style: $_planningStyle');
                    debugPrint('Refueling Priority: $_refuelingPriority');
                    Navigator.of(context).pushReplacementNamed('/home');
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
