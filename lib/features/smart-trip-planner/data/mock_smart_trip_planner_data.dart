import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../models/smart_trip_planner_model.dart';

class MockSmartTripPlannerData {
  static final SmartTripPlannerData plannerData = SmartTripPlannerData(
    totalBudget: '₱2,500',
    estCost: '₱2,680',
    balance: '-₱180',
    isOverBudget: true,
    aiInsights: [
      PlannerInsight(text: 'Refuel at Shell Angeles to save\n₱60', dotColor: AppColors.tealDark),
      PlannerInsight(text: 'Food is your 2nd biggest\nexpense', dotColor: AppColors.blueGreyDark),
      PlannerInsight(text: 'Over budget by ₱180', dotColor: AppColors.redDark),
    ],
    fuelReadiness: FuelReadiness(
      statusLabel: 'Refill Needed',
      statusColor: AppColors.redDark,
      statusBgColor: AppColors.redSoftBg,
      currentTankLevel: 'Current Tank: 8L (96km)',
      warningMessage: 'Warning: 10.3L more needed for the 220km trip to Baguio.',
    ),
    refuelingPlan: [
      RefuelingStep(
        title: 'Pampanga',
        subtitle: 'DEPARTURE POINT',
        icon: Icons.adjust,
        iconColor: AppColors.bluePale,
        isFirst: true,
      ),
      RefuelingStep(
        title: 'Shell Angeles',
        subtitle: 'Recommended 12L @ P63/L',
        icon: Icons.close,
        iconColor: AppColors.blueGreyDark,
        highlight: 'Optimal\nPrice',
      ),
      RefuelingStep(
        title: 'Petron Tarlac',
        subtitle: 'Optional Backup',
        icon: Icons.circle,
        iconColor: AppColors.greyLight,
      ),
      RefuelingStep(
        title: 'Shell Baguio Road',
        subtitle: 'Skip: High Peak Price',
        icon: Icons.circle,
        iconColor: AppColors.greyLight,
        isRed: true,
      ),
      RefuelingStep(
        title: 'Baguio City',
        subtitle: '220KM JOURNEY END',
        icon: Icons.location_on,
        iconColor: AppColors.greenLightBg,
        isLast: true,
      ),
    ],
    expensePlan: ExpensePlan(
      travelers: 4,
      meals: 3,
      diningStyle: 'Mixed',
      nights: 1,
      rooms: 1,
      accommodationType: 'Airbnb',
      tollsSubtitle: 'class 1 vehicle',
      tollsAmount: '₱780',
      parkingSubtitle: 'Est. 2 Full Days',
      parkingAmount: '₱300',
    ),
    visualBreakdown: VisualBreakdown(
      categories: [
        BreakdownCategory(name: 'Fuel', amount: '₱1,200', color: AppColors.blueLightAccent, percentage: '45%'),
        BreakdownCategory(name: 'Tolls', amount: '₱780', color: AppColors.olivePrimary, percentage: '29%'),
        BreakdownCategory(name: 'Food', amount: '₱400', color: AppColors.tealDark, percentage: '15%'),
        BreakdownCategory(name: 'Parking', amount: '₱300', color: AppColors.blueGreySecondary, percentage: '11%'),
      ],
    ),
  );
}
