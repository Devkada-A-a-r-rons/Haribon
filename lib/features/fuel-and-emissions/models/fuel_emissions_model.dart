import 'package:flutter/material.dart';

class FuelEmissionsData {
  final String totalFuelUsed;
  final String totalFuelCost;
  final String costVariance;
  final String costVarianceLabel;
  final bool isOverBudget;
  
  final String totalCo2;
  final String co2Variance;
  final int treesEquivalent;

  final List<FuelBreakdownItem> consumptionBreakdown;
  final List<EfficiencyLossInsight> efficiencyLossInsights;
  final List<OptimizationTip> optimizationTips;

  const FuelEmissionsData({
    required this.totalFuelUsed,
    required this.totalFuelCost,
    required this.costVariance,
    required this.costVarianceLabel,
    required this.isOverBudget,
    required this.totalCo2,
    required this.co2Variance,
    required this.treesEquivalent,
    required this.consumptionBreakdown,
    required this.efficiencyLossInsights,
    required this.optimizationTips,
  });
}

class FuelBreakdownItem {
  final String category;
  final String percentage;
  final String label;
  final Color color;

  const FuelBreakdownItem({
    required this.category,
    required this.percentage,
    required this.label,
    required this.color,
  });
}

class EfficiencyLossInsight {
  final String title;
  final String value;
  final String description;
  final IconData icon;

  const EfficiencyLossInsight({
    required this.title,
    required this.value,
    required this.description,
    required this.icon,
  });
}

class OptimizationTip {
  final String title;
  final String savings;
  final String description;
  final IconData icon;

  const OptimizationTip({
    required this.title,
    required this.savings,
    required this.description,
    required this.icon,
  });
}
