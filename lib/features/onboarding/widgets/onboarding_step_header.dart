import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class OnboardingStepHeader extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final VoidCallback? onBack;
  final VoidCallback? onSkip;

  const OnboardingStepHeader({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.onBack,
    this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final progress = currentStep / totalSteps;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (currentStep > 1)
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                  onPressed: onBack,
                )
              else
                const SizedBox(width: 48),
              Text(
                'STEP $currentStep OF $totalSteps',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: AppColors.primaryMain,
                    ),
              ),
              if (onSkip != null)
                TextButton(
                  onPressed: onSkip,
                  child: Text(
                    'Skip',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.textTertiary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                )
              else
                const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.container,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryMain),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${(progress * 100).toInt()}% Complete',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textTertiary,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
