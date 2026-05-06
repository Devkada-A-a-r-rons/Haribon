import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../models/fuel_emissions_model.dart';

class MockFuelEmissionsData {
  static final FuelEmissionsData dashboardData = FuelEmissionsData(
    totalFuelUsed: '1,452 L',
    totalFuelCost: '₱ 87,120',
    costVariance: '+₱4,500',
    costVarianceLabel: 'Over Budget',
    isOverBudget: true,
    totalCo2: '3.4',
    co2Variance: '+12% vs last month',
    treesEquivalent: 156,
    consumptionBreakdown: [
      FuelBreakdownItem(category: 'Highway', percentage: '45%', label: '653 L', color: AppColors.brandHaribon),
      FuelBreakdownItem(category: 'City', percentage: '35%', label: '508 L', color: AppColors.primaryMain),
      FuelBreakdownItem(category: 'Idle', percentage: '15%', label: '217 L', color: AppColors.insightRed),
      FuelBreakdownItem(category: 'Other', percentage: '5%', label: '74 L', color: AppColors.greyLight),
    ],
    efficiencyLossInsights: [
      EfficiencyLossInsight(
        title: 'Excessive Idling',
        value: '14.2 L',
        description: 'Lost to idling > 3 mins in heavy traffic zones.',
        icon: Icons.timer_outlined,
      ),
      EfficiencyLossInsight(
        title: 'Aggressive Acceleration',
        value: '8.5 L',
        description: 'Hard acceleration events recorded primarily on urban routes.',
        icon: Icons.speed_outlined,
      ),
    ],
    optimizationTips: [
      OptimizationTip(
        title: 'Reduce Highway Speed',
        savings: 'Save up to ₱1,200',
        description: 'Cruising at 90 km/h instead of 110 km/h improves efficiency by 15%.',
        icon: Icons.speed,
      ),
      OptimizationTip(
        title: 'Smart Route Planning',
        savings: 'Save ~4.2 L/week',
        description: 'Avoid EDSA between 5 PM and 7 PM to reduce extreme idling.',
        icon: Icons.alt_route,
      ),
    ],
  );
}
