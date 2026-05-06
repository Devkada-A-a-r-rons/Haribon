import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../models/history_model.dart';

class MockHistoryData {
  static final List<TripHistory> tripHistoryList = [
    TripHistory(
      id: '1',
      route: 'Pampanga → Baguio',
      badgeText: '92 EXCELLENT',
      badgeColor: AppColors.badgeExcellentBg,
      badgeTextColor: AppColors.badgeExcellentText,
      badgeIcon: Icons.auto_awesome,
      date: 'OCT 12, 2023 • 08:30 AM',
      distance: '145 km',
      fuelUsed: '8.2 L',
      cost: '₱540',
      type: TripHistoryType.agila,
    ),
    TripHistory(
      id: '2',
      route: 'Manila → Bicol',
      badgeText: '84 GOOD',
      badgeColor: AppColors.badgeGoodBg,
      badgeTextColor: AppColors.textTertiary,
      badgeIcon: Icons.eco_outlined,
      date: 'SEP 28, 2023 • 05:15 AM',
      distance: '360 km',
      fuelUsed: '24.5 L',
      cost: '₱1,620',
      type: TripHistoryType.night,
    ),
    TripHistory(
      id: '3',
      route: 'Tagaytay → Manila',
      badgeText: '96 OPTIMAL',
      badgeColor: AppColors.badgeExcellentBg,
      badgeTextColor: AppColors.badgeExcellentText,
      badgeIcon: Icons.eco_outlined,
      date: 'SEP 15, 2023 • 04:45 PM',
      distance: '65 km',
      fuelUsed: '3.8 L',
      cost: '₱250',
      type: TripHistoryType.aerovista,
    ),
  ];

  static final TripDetailsModel tripDetailsMock = TripDetailsModel(
    routeName: 'Pampanga → Baguio',
    dateDuration: 'Oct 24, 2023 • 3h 45m',
    totalFuelUsed: '14.2',
    totalDistance: '145',
    totalCost: '₱1,508',
    customFuelUsed: '+₱317 vs Avg',
    trafficPercent: '30%',
    terrainPercent: '40%',
    idlePercent: '10%',
    efficiencyPercent: '20%',
    timelineEvents: [
      TimelineEvent(
        time: '08:15',
        location: 'ANGELES',
        title: 'Shell Angeles • 12L',
        trailingText: '₱756',
        trailingColor: AppColors.success,
        isPassed: true,
      ),
      TimelineEvent(
        time: '10:30',
        location: 'TARLAC',
        title: 'Petron Tarlac',
        trailingText: 'Skipped',
        trailingColor: AppColors.textTertiary,
        isPassed: false,
      ),
    ],
    routeInsights: [
      RouteInsight(
        title: 'Drafting Win',
        description: 'You saved 0.4L by maintaining steady highway distance behind larger vehicles.',
        icon: Icons.trending_down,
        iconBackgroundColor: AppColors.insightBlueBg,
        iconColor: AppColors.textSecondary,
      ),
      RouteInsight(
        title: 'Kennon Road vs Marcos Hwy',
        description: 'Taking Marcos Highway added 2.4L in climb consumption but saved 15m in traffic.',
        icon: Icons.terrain,
        iconBackgroundColor: AppColors.insightYellowBg,
        iconColor: AppColors.textTertiary,
      ),
      RouteInsight(
        title: 'Optimization Tip',
        description: 'Hard braking detected 12 times. Smoothing deceleration can save up to ₱45 on this route.',
        icon: Icons.energy_savings_leaf_outlined,
        iconBackgroundColor: AppColors.insightRedBg,
        iconColor: AppColors.insightRed,
      ),
    ],
    carbonKg: 53.6,
    treesEquivalent: 2,
  );
}
