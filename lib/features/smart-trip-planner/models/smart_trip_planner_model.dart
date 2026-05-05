import 'package:flutter/material.dart';

class SmartTripPlannerData {
  final String totalBudget;
  final String estCost;
  final String balance;
  final bool isOverBudget;

  final List<PlannerInsight> aiInsights;
  final FuelReadiness fuelReadiness;
  final List<RefuelingStep> refuelingPlan;
  final ExpensePlan expensePlan;
  final VisualBreakdown visualBreakdown;

  const SmartTripPlannerData({
    required this.totalBudget,
    required this.estCost,
    required this.balance,
    required this.isOverBudget,
    required this.aiInsights,
    required this.fuelReadiness,
    required this.refuelingPlan,
    required this.expensePlan,
    required this.visualBreakdown,
  });
}

class PlannerInsight {
  final String text;
  final Color dotColor;

  const PlannerInsight({
    required this.text,
    required this.dotColor,
  });
}

class FuelReadiness {
  final String statusLabel;
  final Color statusColor;
  final Color statusBgColor;
  final String currentTankLevel;
  final String warningMessage;

  const FuelReadiness({
    required this.statusLabel,
    required this.statusColor,
    required this.statusBgColor,
    required this.currentTankLevel,
    required this.warningMessage,
  });
}

class RefuelingStep {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final bool isFirst;
  final bool isLast;
  final String? highlight;
  final bool isRed;

  const RefuelingStep({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    this.isFirst = false,
    this.isLast = false,
    this.highlight,
    this.isRed = false,
  });
}

class ExpensePlan {
  final int travelers;
  final int meals;
  final String diningStyle;
  
  final int nights;
  final int rooms;
  final String accommodationType;

  final String tollsSubtitle;
  final String tollsAmount;

  final String parkingSubtitle;
  final String parkingAmount;

  const ExpensePlan({
    required this.travelers,
    required this.meals,
    required this.diningStyle,
    required this.nights,
    required this.rooms,
    required this.accommodationType,
    required this.tollsSubtitle,
    required this.tollsAmount,
    required this.parkingSubtitle,
    required this.parkingAmount,
  });
}

class VisualBreakdown {
  final List<BreakdownCategory> categories;

  const VisualBreakdown({
    required this.categories,
  });
}

class BreakdownCategory {
  final String name;
  final String amount;
  final Color color;
  final String percentage;

  const BreakdownCategory({
    required this.name,
    required this.amount,
    required this.color,
    required this.percentage,
  });
}
