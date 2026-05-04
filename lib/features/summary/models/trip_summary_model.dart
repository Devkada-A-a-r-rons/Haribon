import 'package:flutter/material.dart';

/// Data models for the Trip Summary feature.

class TripSummary {
  final String destination;
  final String origin;
  final String date;
  final Duration duration;
  final double distanceKm;
  final int efficiencyScore;
  final String efficiencyRating;
  final String efficiencyPercentile;
  final TripStats stats;
  final List<FuelStop> fuelStops;
  final String aiInsight;
  final List<RouteSegment> routeSegments;
  final int treesEquivalent;

  const TripSummary({
    required this.destination,
    required this.origin,
    required this.date,
    required this.duration,
    required this.distanceKm,
    required this.efficiencyScore,
    required this.efficiencyRating,
    required this.efficiencyPercentile,
    required this.stats,
    required this.fuelStops,
    required this.aiInsight,
    required this.routeSegments,
    required this.treesEquivalent,
  });

  String get durationLabel {
    final h = duration.inHours;
    final m = duration.inMinutes % 60;
    return '${h}h ${m}m';
  }
}

class TripStats {
  final double fuelLiters;
  final double fuelCostPhp;
  final double avgSpeedKmh;
  final double co2SavedKg;
  final double costVsEstimatePhp; // negative = under budget

  const TripStats({
    required this.fuelLiters,
    required this.fuelCostPhp,
    required this.avgSpeedKmh,
    required this.co2SavedKg,
    required this.costVsEstimatePhp,
  });
}

class FuelStop {
  final String stationName;
  final String brand;
  final double liters;
  final double pricePerLiter;
  final Color brandColor;

  const FuelStop({
    required this.stationName,
    required this.brand,
    required this.liters,
    required this.pricePerLiter,
    required this.brandColor,
  });

  double get totalCost => liters * pricePerLiter;
}

class RouteSegment {
  final String label;
  final Duration duration;
  final double fraction; // 0.0 – 1.0, relative to total time
  final Color color;

  const RouteSegment({
    required this.label,
    required this.duration,
    required this.fraction,
    required this.color,
  });

  String get durationLabel {
    final h = duration.inHours;
    final m = duration.inMinutes % 60;
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }
}
