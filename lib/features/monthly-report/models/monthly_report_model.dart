/// Data models for the Monthly Report feature.

class MonthlyReport {
  final String month;
  final String year;
  final int totalTrips;
  final double totalDistanceKm;
  final double totalFuelCostPhp;
  final double totalEmissionsCo2Kg;
  final int averageEfficiencyScore;
  final List<DailyTripSummary> dailyTrips;
  final MonthlyStats stats;
  final List<TrendData> efficiencyTrend;
  final List<VehicleUsageDay> vehicleUsage;
  final String topInsight;

  const MonthlyReport({
    required this.month,
    required this.year,
    required this.totalTrips,
    required this.totalDistanceKm,
    required this.totalFuelCostPhp,
    required this.totalEmissionsCo2Kg,
    required this.averageEfficiencyScore,
    required this.dailyTrips,
    required this.stats,
    required this.efficiencyTrend,
    required this.vehicleUsage,
    required this.topInsight,
  });

  String get displayPeriod => '$month $year';

  String get formattedTotalCost => '₱${totalFuelCostPhp.toStringAsFixed(0)}';

  String get formattedDistance => '${totalDistanceKm.toStringAsFixed(0)} km';

  String get formattedEmissions => '${totalEmissionsCo2Kg.toStringAsFixed(2)} kg';
}

class MonthlyStats {
  final double avgFuelCostPerTrip;
  final double avgDistancePerTrip;
  final double avgEmissionsPerTrip;
  final int bestEfficiencyScore;
  final int worstEfficiencyScore;
  final double avgSpeedKmh;
  final int daysWithTrips;

  const MonthlyStats({
    required this.avgFuelCostPerTrip,
    required this.avgDistancePerTrip,
    required this.avgEmissionsPerTrip,
    required this.bestEfficiencyScore,
    required this.worstEfficiencyScore,
    required this.avgSpeedKmh,
    required this.daysWithTrips,
  });

  String get bestScoreLabel => 'Best: $bestEfficiencyScore%';

  String get worstScoreLabel => 'Lowest: $worstEfficiencyScore%';
}

class DailyTripSummary {
  final String date;
  final int dayOfMonth;
  final String dayName;
  final List<TripEntry> trips;
  final double dailyTotalDistance;
  final double dailyTotalCost;
  final int dayEfficiencyScore;

  const DailyTripSummary({
    required this.date,
    required this.dayOfMonth,
    required this.dayName,
    required this.trips,
    required this.dailyTotalDistance,
    required this.dailyTotalCost,
    required this.dayEfficiencyScore,
  });

  bool get hasTrips => trips.isNotEmpty;
}

class TripEntry {
  final String origin;
  final String destination;
  final String time;
  final double distanceKm;
  final double costPhp;
  final int efficiencyScore;

  const TripEntry({
    required this.origin,
    required this.destination,
    required this.time,
    required this.distanceKm,
    required this.costPhp,
    required this.efficiencyScore,
  });
}

class TrendData {
  final int dayOfMonth;
  final int efficiencyScore;
  final String dayLabel;

  const TrendData({
    required this.dayOfMonth,
    required this.efficiencyScore,
    required this.dayLabel,
  });
}

class VehicleUsageDay {
  final int dayOfMonth;
  final bool used;
  final int tripsCount;

  const VehicleUsageDay({
    required this.dayOfMonth,
    required this.used,
    required this.tripsCount,
  });
}
