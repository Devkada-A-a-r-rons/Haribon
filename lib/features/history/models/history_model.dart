import 'package:flutter/material.dart';

class TripHistory {
  final String id;
  final String route;
  final String date;
  final String distance;
  final String fuelUsed;
  final String cost;
  final String badgeText;
  final Color badgeColor;
  final Color badgeTextColor;
  final IconData badgeIcon;
  final TripHistoryType type;

  const TripHistory({
    required this.id,
    required this.route,
    required this.date,
    required this.distance,
    required this.fuelUsed,
    required this.cost,
    required this.badgeText,
    required this.badgeColor,
    required this.badgeTextColor,
    required this.badgeIcon,
    required this.type,
  });
}

enum TripHistoryType {
  agila,
  aerovista,
  night,
}

class TripDetailsModel {
  final String routeName;
  final String dateDuration;
  final String totalFuelUsed;
  final String totalDistance;
  final String totalCost;
  final String customFuelUsed;
  
  // Consumption Breakdown
  final String trafficPercent;
  final String terrainPercent;
  final String idlePercent;
  final String efficiencyPercent;

  // Timeline
  final List<TimelineEvent> timelineEvents;

  // Insights
  final List<RouteInsight> routeInsights;
  
  // Carbon
  final double carbonKg;
  final int treesEquivalent;

  const TripDetailsModel({
    required this.routeName,
    required this.dateDuration,
    required this.totalFuelUsed,
    required this.totalDistance,
    required this.totalCost,
    required this.customFuelUsed,
    required this.trafficPercent,
    required this.terrainPercent,
    required this.idlePercent,
    required this.efficiencyPercent,
    required this.timelineEvents,
    required this.routeInsights,
    required this.carbonKg,
    required this.treesEquivalent,
  });
}

class TimelineEvent {
  final String time;
  final String location;
  final String title;
  final String trailingText;
  final Color trailingColor;
  final bool isPassed;

  const TimelineEvent({
    required this.time,
    required this.location,
    required this.title,
    required this.trailingText,
    required this.trailingColor,
    required this.isPassed,
  });
}

class RouteInsight {
  final String title;
  final String description;
  final IconData icon;
  final Color iconBackgroundColor;
  final Color iconColor;

  const RouteInsight({
    required this.title,
    required this.description,
    required this.icon,
    required this.iconBackgroundColor,
    required this.iconColor,
  });
}
