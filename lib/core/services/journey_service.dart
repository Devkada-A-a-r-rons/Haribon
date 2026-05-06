import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Represents the live state of an active journey.
class JourneyState {
  final double currentFuelLiters;
  final double distanceTraveledKm;
  final double fuelConsumedLiters;
  final double fuelCostPhp;
  final bool isActive;
  final LatLng? currentPosition;

  const JourneyState({
    required this.currentFuelLiters,
    required this.distanceTraveledKm,
    required this.fuelConsumedLiters,
    required this.fuelCostPhp,
    required this.isActive,
    this.currentPosition,
  });

  JourneyState copyWith({
    double? currentFuelLiters,
    double? distanceTraveledKm,
    double? fuelConsumedLiters,
    double? fuelCostPhp,
    bool? isActive,
    LatLng? currentPosition,
  }) {
    return JourneyState(
      currentFuelLiters: currentFuelLiters ?? this.currentFuelLiters,
      distanceTraveledKm: distanceTraveledKm ?? this.distanceTraveledKm,
      fuelConsumedLiters: fuelConsumedLiters ?? this.fuelConsumedLiters,
      fuelCostPhp: fuelCostPhp ?? this.fuelCostPhp,
      isActive: isActive ?? this.isActive,
      currentPosition: currentPosition ?? this.currentPosition,
    );
  }
}

/// Manages an active road trip:
/// - Tracks distance traveled using GPS (web) or device GPS (mobile)
/// - Deducts fuel based on vehicle's `liters_per_km` from the JSON/Supabase
/// - Emits JourneyState updates every second
/// - Saves final state to Supabase `smart_trips` on end
class JourneyService {
  static final JourneyService _instance = JourneyService._internal();
  factory JourneyService() => _instance;
  JourneyService._internal();

  final _controller = StreamController<JourneyState>.broadcast();
  Stream<JourneyState> get stateStream => _controller.stream;

  Timer? _simulationTimer;
  JourneyState? _currentState;
  Map<String, dynamic>? _vehicleConfig;
  double _litersPerKm = 0.08; // default if no vehicle config
  double _fuelPricePerLiter = 65.0;
  LatLng? _lastPosition;
  final Distance _distance = const Distance();
  bool _isActive = false;

  bool get isActive => _isActive;
  JourneyState? get currentState => _currentState;

  /// Start the journey with vehicle config from Supabase/JSON.
  /// [config] should contain: 'current_fuel_liters', 'liters_per_km', 'km_per_liter'
  /// [fuelPricePerLiter] is today's average fuel price
  Future<void> startJourney({
    required Map<String, dynamic> vehicleConfig,
    required double fuelPricePerLiter,
    required LatLng startPosition,
  }) async {
    _vehicleConfig = vehicleConfig;
    _fuelPricePerLiter = fuelPricePerLiter;
    _lastPosition = startPosition;

    // Determine liters_per_km from vehicle config
    final kml = (vehicleConfig['km_per_liter'] as num?)?.toDouble();
    final lkm = (vehicleConfig['liters_per_km'] as num?)?.toDouble();
    if (lkm != null && lkm > 0) {
      _litersPerKm = lkm;
    } else if (kml != null && kml > 0) {
      _litersPerKm = 1.0 / kml;
    }

    final startFuel = (vehicleConfig['current_fuel_liters'] as num?)?.toDouble() ?? 15.0;
    _isActive = true;

    _currentState = JourneyState(
      currentFuelLiters: startFuel,
      distanceTraveledKm: 0.0,
      fuelConsumedLiters: 0.0,
      fuelCostPhp: 0.0,
      isActive: true,
      currentPosition: startPosition,
    );
    _controller.add(_currentState!);

    // On web: use a realistic simulation (GPS not always available)
    // On mobile: would normally use geolocator package
    // For now: simulation mode that deducts ~1km/min at highway speeds (60km/h avg)
    _startSimulation();
    debugPrint('[JourneyService] Journey started. liters/km: $_litersPerKm');
  }

  void _startSimulation() {
    _simulationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_currentState == null || !_isActive) return;

      const kmPerSecond = 60.0 / 3600.0;
      final fuelUsed = kmPerSecond * _litersPerKm;
      final newFuel = (_currentState!.currentFuelLiters - fuelUsed).clamp(0.0, 200.0);
      final newDist = _currentState!.distanceTraveledKm + kmPerSecond;
      final newConsumed = _currentState!.fuelConsumedLiters + fuelUsed;
      final newCost = newConsumed * _fuelPricePerLiter;

      LatLng? newPos = _currentState!.currentPosition;
      if (_lastPosition != null) {
        newPos = _currentState!.currentPosition;
      }

      _currentState = _currentState!.copyWith(
        currentFuelLiters: newFuel,
        distanceTraveledKm: newDist,
        fuelConsumedLiters: newConsumed,
        fuelCostPhp: newCost,
        currentPosition: newPos,
      );
      
      _controller.add(_currentState!);

      if (newFuel <= 0.1) {
        stopJourney();
      }
    });
  }

  /// Update position from GPS (if available). Calculates real distance delta.
  void updatePosition(LatLng newPosition) {
    if (_currentState == null || _lastPosition == null || !_isActive) return;
    final deltaKm = _distance.as(LengthUnit.Kilometer, _lastPosition!, newPosition);
    if (deltaKm < 0.001) return; // ignore tiny noise

    final fuelUsed = deltaKm * _litersPerKm;
    final newFuel = (_currentState!.currentFuelLiters - fuelUsed).clamp(0.0, 200.0);
    final newConsumed = _currentState!.fuelConsumedLiters + fuelUsed;

    _currentState = _currentState!.copyWith(
      currentFuelLiters: newFuel,
      distanceTraveledKm: _currentState!.distanceTraveledKm + deltaKm,
      fuelConsumedLiters: newConsumed,
      fuelCostPhp: newConsumed * _fuelPricePerLiter,
      currentPosition: newPosition,
    );
    _lastPosition = newPosition;
    _controller.add(_currentState!);
  }

  /// Stop the journey and save results to Supabase.
  Future<void> stopJourney() async {
    _isActive = false;
    _simulationTimer?.cancel();
    _simulationTimer = null;

    if (_currentState != null) {
      _currentState = _currentState!.copyWith(isActive: false);
      _controller.add(_currentState!);

      // Save final state to Supabase
      try {
        await Supabase.instance.client.from('smart_trips').insert({
          'origin_name': _vehicleConfig?['origin_name'] ?? 'Start',
          'destination_name': _vehicleConfig?['destination_name'] ?? 'Destination',
          'distance_km': _currentState!.distanceTraveledKm,
          'est_fuel_cost': _currentState!.fuelCostPhp,
          'est_fuel_liters': _currentState!.fuelConsumedLiters,
          'created_at': DateTime.now().toIso8601String(),
        });
        debugPrint('[JourneyService] Journey saved to Supabase.');
      } catch (e) {
        debugPrint('[JourneyService] Failed to save journey: $e');
      }
    }
  }

  void dispose() {
    _simulationTimer?.cancel();
    _controller.close();
  }
}
