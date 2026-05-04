class VehicleEfficiencyModel {
  final String vehicleType;
  final String brand;
  final String model;
  final String fuelType;

  final double tankSizeLiters;
  final double litersPerKm;
  final double cityLitersPerKm;
  final double highwayLitersPerKm;
  final double kmPerLiter;
  final double estimatedFullTankRangeKm;
  final String fuelEfficiencyCategory;

  const VehicleEfficiencyModel({
    required this.vehicleType,
    required this.brand,
    required this.model,
    required this.fuelType,
    required this.tankSizeLiters,
    required this.litersPerKm,
    required this.cityLitersPerKm,
    required this.highwayLitersPerKm,
    required this.kmPerLiter,
    required this.estimatedFullTankRangeKm,
    required this.fuelEfficiencyCategory,
  });

  factory VehicleEfficiencyModel.fromJson(Map<String, dynamic> json) {
    return VehicleEfficiencyModel(
      vehicleType: json['vehicle_type'] ?? '',
      brand: json['brand'] ?? '',
      model: json['model'] ?? '',
      fuelType: json['fuel_type'] ?? '',
      tankSizeLiters: (json['tank_size_liters'] ?? 0).toDouble(),
      litersPerKm: (json['liters_per_km'] ?? 0).toDouble(),
      cityLitersPerKm: (json['city_liters_per_km'] ?? 0).toDouble(),
      highwayLitersPerKm: (json['highway_liters_per_km'] ?? 0).toDouble(),
      kmPerLiter: (json['km_per_liter'] ?? 0).toDouble(),
      estimatedFullTankRangeKm:
          (json['estimated_full_tank_range_km'] ?? 0).toDouble(),
      fuelEfficiencyCategory: json['fuel_efficiency_category'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vehicle_type': vehicleType,
      'brand': brand,
      'model': model,
      'fuel_type': fuelType,
      'tank_size_liters': tankSizeLiters,
      'liters_per_km': litersPerKm,
      'city_liters_per_km': cityLitersPerKm,
      'highway_liters_per_km': highwayLitersPerKm,
      'km_per_liter': kmPerLiter,
      'estimated_full_tank_range_km': estimatedFullTankRangeKm,
      'fuel_efficiency_category': fuelEfficiencyCategory,
    };
  }

  VehicleEfficiencyModel copyWith({
    String? vehicleType,
    String? brand,
    String? model,
    String? fuelType,
    double? tankSizeLiters,
    double? litersPerKm,
    double? cityLitersPerKm,
    double? highwayLitersPerKm,
    double? kmPerLiter,
    double? estimatedFullTankRangeKm,
    String? fuelEfficiencyCategory,
  }) {
    return VehicleEfficiencyModel(
      vehicleType: vehicleType ?? this.vehicleType,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      fuelType: fuelType ?? this.fuelType,
      tankSizeLiters: tankSizeLiters ?? this.tankSizeLiters,
      litersPerKm: litersPerKm ?? this.litersPerKm,
      cityLitersPerKm: cityLitersPerKm ?? this.cityLitersPerKm,
      highwayLitersPerKm: highwayLitersPerKm ?? this.highwayLitersPerKm,
      kmPerLiter: kmPerLiter ?? this.kmPerLiter,
      estimatedFullTankRangeKm:
          estimatedFullTankRangeKm ?? this.estimatedFullTankRangeKm,
      fuelEfficiencyCategory:
          fuelEfficiencyCategory ?? this.fuelEfficiencyCategory,
    );
  }
