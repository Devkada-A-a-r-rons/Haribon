import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../common/widgets/app_bar.dart';
import './widgets/compact_dropdown.dart';
import './widgets/compact_text_field.dart';
import './widgets/info_card.dart';
import './widgets/efficiency_card.dart';
import 'package:haribon/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/database/database_service.dart';
import '../summary/main_summary_screen.dart';

class VehicleIntelligenceScreen extends StatefulWidget {
  const VehicleIntelligenceScreen({super.key});

  @override
  State<VehicleIntelligenceScreen> createState() =>
      _VehicleIntelligenceScreenState();
}

class _VehicleIntelligenceScreenState extends State<VehicleIntelligenceScreen>
    with SingleTickerProviderStateMixin {
  // Tab controller
  late TabController _tabController;
  int _selectedTab = 0;

  // Vehicle dataset
  List<dynamic> _vehicles = [];
  bool _isLoadingVehicles = true;

  // Selections
  String? _selectedType;
  String? _selectedBrand;
  String? _selectedModel;
  Map<String, dynamic>? _selectedVehicle;

  // Fuel
  double _fuelLevel = 0.5;

  // Locations
  Map<String, dynamic>? _origin;
  Map<String, dynamic>? _destination;

  // Route
  double? _routeDistanceKm;
  double? _routeDurationHrs;
  bool _isCalculatingRoute = false;

  // Fuel Pricing Data from Supabase
  double _fuelPricePerLiter = 65.0;
  String? _lowestBrand;
  double? _lowestPrice;
  String? _highestBrand;
  double? _highestPrice;
  bool _isGasoline = true;
  String? _fuelGrade;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() => _selectedTab = _tabController.index);
    });
    _loadVehicles();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ─── Data Loading ──────────────────────────────────────────────
  Future<void> _loadVehicles() async {
    try {
      final jsonStr = await rootBundle
          .loadString('assets/Data/smartgas_vehicles_cleaned.json');
      setState(() {
        _vehicles = jsonDecode(jsonStr);
      });
      await _fetchFuelPrices();
      await _fetchLatestConfig(); // Hydrate form
      setState(() => _isLoadingVehicles = false);
    } catch (e) {
      debugPrint('Error loading vehicles: $e');
      setState(() => _isLoadingVehicles = false);
    }
  }

  Future<void> _fetchLatestConfig() async {
    try {
      final response = await Supabase.instance.client
          .from('vehicle_configurations')
          .select()
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response != null) {
        setState(() {
          _selectedType = response['vehicle_type'];
          _selectedBrand = response['brand'];
          _selectedModel = response['model'];
          _fuelLevel = (response['fuel_level_pct'] ?? 50) / 100.0;
          
          if (response['origin_name'] != null) {
             // We don't have the full place object, but we can set a placeholder or just the name
             _origin = {'display_name': response['origin_name'], 'lat': '14.5995', 'lon': '120.9842'}; // Lat/Lon defaults
          }
          if (response['destination_name'] != null) {
             _destination = {'display_name': response['destination_name'], 'lat': '14.5995', 'lon': '120.9842'};
          }
          
          // Re-calculate derived values
          _onModelSelected(_selectedModel!);
        });
      }
    } catch (e) {
      debugPrint('Error fetching latest config: $e');
    }
  }

  // ─── Cascading Dropdown Helpers ────────────────────────────────
  List<String> get _types {
    final set = _vehicles.map((v) => v['vehicle_type'].toString()).toSet().toList();
    set.sort();
    return set;
  }

  List<String> get _brands {
    if (_selectedType == null) return [];
    final set = _vehicles
        .where((v) => v['vehicle_type'] == _selectedType)
        .map((v) => v['brand'].toString())
        .toSet()
        .toList();
    set.sort();
    return set;
  }

  List<String> get _models {
    if (_selectedType == null || _selectedBrand == null) return [];
    final set = _vehicles
        .where((v) =>
            v['vehicle_type'] == _selectedType && v['brand'] == _selectedBrand)
        .map((v) => v['model'].toString())
        .toSet()
        .toList();
    set.sort();
    return set;
  }

  void _onModelSelected(String model) {
    final vehicle = _vehicles.firstWhere(
      (v) =>
          v['vehicle_type'] == _selectedType &&
          v['brand'] == _selectedBrand &&
          v['model'] == model,
      orElse: () => null,
    );
    setState(() {
      _selectedModel = model;
      _selectedVehicle = vehicle;
      _fuelLevel = 0.5;
      _fuelGrade = vehicle?['fuel_grade']?.toString();
      if (_fuelGrade != null) {
        _isGasoline = _fuelGrade!.toLowerCase() != 'diesel';
      } else {
        final m = model.toLowerCase();
        _isGasoline = !(m.contains('diesel') || m.contains('tdi') ||
            m.contains(' crdi') || m.contains(' d '));
        _fuelGrade = _isGasoline ? 'Gasoline' : 'Diesel';
      }
      _updateFuelMetrics();
    });
    _calculateRoute();
  }

  Future<void> _fetchFuelPrices() async {
    try {
      final response = await Supabase.instance.client
          .from('fuel_prices')
          .select()
          .order('updated_at', ascending: false);

      if (response != null && (response as List).isNotEmpty) {
        final List prices = response as List;
        final fuelKey =
            (_fuelGrade?.toLowerCase() == 'diesel') ? 'diesel' : 'gasoline';
        double total = 0;
        double min = double.infinity;
        double max = 0;
        String? minB, maxB;
        for (var p in prices) {
          final val = (p[fuelKey] as num).toDouble();
          total += val;
          if (val < min) { min = val; minB = p['brand']; }
          if (val > max) { max = val; maxB = p['brand']; }
        }
        setState(() {
          _fuelPricePerLiter = total / prices.length;
          _lowestPrice = min;
          _lowestBrand = minB;
          _highestPrice = max;
          _highestBrand = maxB;
        });
      }
    } catch (e) {
      debugPrint('Error fetching fuel prices: $e');
    }
  }

  void _updateFuelMetrics() => _fetchFuelPrices();

  // ─── Derived Values ────────────────────────────────────────────
  double get _tankSize =>
      (_selectedVehicle?['tank_size_liters'] as num?)?.toDouble() ?? 42.0;
  double get _currentLiters => _fuelLevel * _tankSize;
  double get _kmPerLiter =>
      (_selectedVehicle?['km_per_liter'] as num?)?.toDouble() ?? 0;
  double get _litersPerKm =>
      (_selectedVehicle?['liters_per_km'] as num?)?.toDouble() ?? 0;
  double get _cityLitersPerKm =>
      (_selectedVehicle?['city_liters_per_km'] as num?)?.toDouble() ?? 0;
  double get _highwayLitersPerKm =>
      (_selectedVehicle?['highway_liters_per_km'] as num?)?.toDouble() ?? 0;
  double get _fullTankRange =>
      (_selectedVehicle?['estimated_full_tank_range_km'] as num?)?.toDouble() ?? 0;
  String get _efficiencyCategory =>
      _selectedVehicle?['fuel_efficiency_category'] ?? '--';
  double get _currentRange =>
      _kmPerLiter > 0 ? _currentLiters * _kmPerLiter : 0;
  double get _cityRange =>
      _cityLitersPerKm > 0 ? _currentLiters / _cityLitersPerKm : 0;
  double get _highwayRange =>
      _highwayLitersPerKm > 0 ? _currentLiters / _highwayLitersPerKm : 0;

  // ─── OSRM Route Calculation ────────────────────────────────────
  Future<void> _calculateRoute() async {
    if (_origin == null || _destination == null) return;
    setState(() => _isCalculatingRoute = true);
    try {
      final lon1 = double.parse(_origin!['lon']);
      final lat1 = double.parse(_origin!['lat']);
      final lon2 = double.parse(_destination!['lon']);
      final lat2 = double.parse(_destination!['lat']);
      final targetUrl =
          'https://router.project-osrm.org/route/v1/driving/$lon1,$lat1;$lon2,$lat2?overview=false';
      final List<String> proxies = [
        'https://api.allorigins.win/get?url=',
        'https://corsproxy.io/?',
        'https://api.codetabs.com/v1/proxy?url=',
      ];
      String? bodyString;
      if (kIsWeb) {
        for (var proxy in proxies) {
          try {
            final proxyUrl = proxy == 'https://corsproxy.io/?'
                ? Uri.parse('$proxy$targetUrl')
                : Uri.parse('$proxy${Uri.encodeComponent(targetUrl)}');
            final res =
                await http.get(proxyUrl).timeout(const Duration(seconds: 5));
            if (res.statusCode == 200) {
              if (proxy.contains('allorigins')) {
                final wrapper = jsonDecode(res.body);
                bodyString = wrapper['contents'];
              } else {
                bodyString = res.body;
              }
              if (bodyString != null && bodyString.trim().startsWith('{')) break;
            }
          } catch (e) {
            continue;
          }
        }
      } else {
        final res = await http.get(Uri.parse(targetUrl));
        if (res.statusCode == 200) bodyString = res.body;
      }
      if (bodyString != null && bodyString.trim().startsWith('{')) {
        final data = jsonDecode(bodyString);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          setState(() {
            _routeDistanceKm =
                (route['distance'] as num).toDouble() / 1000.0;
            _routeDurationHrs =
                (route['duration'] as num).toDouble() / 3600.0;
          });
        }
      }
    } catch (e) {
      debugPrint('OSRM error: $e');
    } finally {
      if (mounted) setState(() => _isCalculatingRoute = false);
    }
  }

  void _clearRoute() {
    setState(() {
      _routeDistanceKm = null;
      _routeDurationHrs = null;
    });
  }

  // ─── Save Configuration ────────────────────────────────────────
  Future<void> _saveConfiguration() async {
    if (_selectedVehicle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a vehicle first.')),
      );
      return;
    }
    final onboardingData = await DatabaseService().getOnboardingData();
    final userName = onboardingData?['user_name'] ?? 'Anonymous';
    final config = {
      'user_name': userName,
      'vehicle_type': _selectedType,
      'brand': _selectedBrand,
      'model': _selectedModel,
      'tank_size_liters': _tankSize,
      'km_per_liter': _kmPerLiter,
      'fuel_level_pct': (_fuelLevel * 100).round(),
      'current_fuel_liters':
          double.parse(_currentLiters.toStringAsFixed(1)),
      'origin_name': _origin?['display_name'],
      'destination_name': _destination?['display_name'],
      'route_distance_km': _routeDistanceKm != null
          ? double.parse(_routeDistanceKm!.toStringAsFixed(2))
          : null,
      'estimated_range_km':
          double.parse(_currentRange.toStringAsFixed(1)),
      'created_at': DateTime.now().toIso8601String(),
    };
    await DatabaseService().saveOnboardingData({
      'vehicle_type': _selectedType,
      'vehicle_brand': _selectedBrand,
      'vehicle_model': _selectedModel,
    });
    await DatabaseService().saveVehicleConfiguration(config);
    try {
      await Supabase.instance.client
          .from('vehicle_configurations')
          .insert(config);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ Configuration saved for $userName!')),
        );
      }
    } catch (e) {
      debugPrint('Supabase save error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('✅ Saved locally (Supabase sync pending).')),
        );
      }
    }
  }

  // ─── UI ────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_isLoadingVehicles) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surfaceMain,
      appBar: const CommonAppBar(showBackButton: false),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vehicle Intelligence',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                          height: 1.1,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Configure your vehicle and view trip insights.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 11,
                        ),
                  ),
                  const SizedBox(height: 14),

                  // ── Pill Tab Bar (matches screenshot style) ──
                  Container(
                    height: 42,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        _buildTabPill(0, Icons.tune_rounded, 'Setup'),
                        _buildTabPill(1, Icons.insights_rounded, 'Insights'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),

            // ── Tab Content ──
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildSetupTab(),
                  _buildInsightsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Pill Tab Builder ──────────────────────────────────────────
  Widget _buildTabPill(int index, IconData icon, String label) {
  final isSelected = _selectedTab == index;
  return Expanded(
    child: GestureDetector(
      onTap: () => _tabController.animateTo(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        height: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryMain : Colors.transparent,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? Colors.white : Colors.black45,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.black45,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  // ─── Setup Tab ────────────────────────────────────────────────
  Widget _buildSetupTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Route Setup
          CompactTextField(
            label: 'Starting Point',
            hintText: 'Enter starting city or address',
            prefixIcon: Icons.location_on_outlined,
            initialValue: _origin?['display_name'],
            onLocationSelected: (place) {
              setState(() {
                _origin = (place.isEmpty) ? null : place;
                if (_origin == null) _clearRoute();
              });
              _calculateRoute();
            },
          ),
          if (_routeDistanceKm != null && !_isCalculatingRoute)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
              child: Row(
                children: [
                  Container(
                      width: 1,
                      height: 20,
                      color: Colors.grey.withOpacity(0.3)),
                  const SizedBox(width: 12),
                  const Icon(Icons.route,
                      size: 14, color: AppColors.primaryMain),
                  const SizedBox(width: 6),
                  Text(
                    '${_routeDistanceKm!.toStringAsFixed(1)} km · ${_routeDurationHrs! < 1 ? '${(_routeDurationHrs! * 60).toInt()} min' : '${_routeDurationHrs!.toStringAsFixed(1)} hrs'}',
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryMain),
                  ),
                ],
              ),
            )
          else
            const SizedBox(height: 12),
          CompactTextField(
            label: 'Destination',
            hintText: 'Enter destination city or address',
            prefixIcon: Icons.change_history_outlined,
            initialValue: _destination?['display_name'],
            onLocationSelected: (place) {
              setState(() {
                _destination = (place.isEmpty) ? null : place;
                if (_destination == null) _clearRoute();
              });
              _calculateRoute();
            },
          ),
          const SizedBox(height: 12),

          // Vehicle Cascading Dropdowns
          CompactDropdown(
            label: 'Vehicle Type',
            value: _selectedType,
            items: _types,
            hintText: 'Select type',
            onChanged: (val) {
              setState(() {
                _selectedType = val;
                _selectedBrand = null;
                _selectedModel = null;
                _selectedVehicle = null;
              });
            },
          ),
          const SizedBox(height: 12),
          CompactDropdown(
            label: 'Brand',
            value: _selectedBrand,
            items: _brands,
            hintText: _selectedType == null ? 'Select type first' : 'Select brand',
            onChanged: _selectedType == null
                ? null
                : (val) {
                    setState(() {
                      _selectedBrand = val;
                      _selectedModel = null;
                      _selectedVehicle = null;
                    });
                  },
          ),
          const SizedBox(height: 12),
          CompactDropdown(
            label: 'Model',
            value: _selectedModel,
            items: _models,
            hintText:
                _selectedBrand == null ? 'Select brand first' : 'Select model',
            onChanged: _selectedBrand == null
                ? null
                : (val) {
                    if (val != null) _onModelSelected(val);
                  },
          ),
          const SizedBox(height: 20),

          // Fuel Level Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Current Fuel Level',
                      style: TextStyle(fontSize: 10)),
                  Text(
                    '${(_fuelLevel * 100).toInt()}%',
                    style: const TextStyle(
                      color: AppColors.primaryMain,
                      fontWeight: FontWeight.w700,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  '${_currentLiters.toStringAsFixed(1)}L / ${_tankSize.toStringAsFixed(0)}L',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LayoutBuilder(
            builder: (context, constraints) {
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanUpdate: (details) {
                  setState(() {
                    double left = (details.localPosition.dx - 8)
                        .clamp(0.0, constraints.maxWidth - 16.0);
                    _fuelLevel = left / (constraints.maxWidth - 16.0);
                  });
                },
                onTapDown: (details) {
                  setState(() {
                    double left = (details.localPosition.dx - 8)
                        .clamp(0.0, constraints.maxWidth - 16.0);
                    _fuelLevel = left / (constraints.maxWidth - 16.0);
                  });
                },
                child: SizedBox(
                  height: 24,
                  width: constraints.maxWidth,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        top: 9,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.redDark,
                                AppColors.beigePrimary,
                                AppColors.success,
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        left: _fuelLevel * (constraints.maxWidth - 24.0),
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: AppColors.success, width: 2.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('E',
                  style: TextStyle(
                      fontSize: 10,
                      color: Colors.black54,
                      fontWeight: FontWeight.bold)),
              Text('F',
                  style: TextStyle(
                      fontSize: 10,
                      color: Colors.black54,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),

          // Save Button
          SizedBox(
            width: double.infinity,
            height: 44,
            child: FilledButton.icon(
              onPressed: _saveConfiguration,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryMain,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              icon: const Icon(Icons.auto_awesome, size: 16),
              label: const Text('Save',
                  style:
                      TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ─── Insights Tab ─────────────────────────────────────────────
  Widget _buildInsightsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Trip Readiness
          InfoCard(
            icon: Icons.route_outlined,
            title: 'Trip Readiness',
            trailing: _buildReadinessBadge(),
            child: _buildTripReadiness(),
          ),
          const SizedBox(height: 12),

          // Current Fuel Estimate
          InfoCard(
            icon: Icons.local_gas_station_outlined,
            title: 'Current Fuel Estimate',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '${(_fuelLevel * 100).toInt()}%',
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(${_currentLiters.toStringAsFixed(1)} Liters)',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  _selectedVehicle != null
                      ? 'Based on a ${_tankSize.toStringAsFixed(0)}L tank capacity\nfor ${_selectedBrand ?? ''} ${_selectedModel ?? ''}.'
                      : 'Select a vehicle in Setup to see fuel details.',
                  style: const TextStyle(fontSize: 11, height: 1.2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Estimated Range
          InfoCard(
            icon: Icons.location_on_outlined,
            title: 'Estimated Range',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedVehicle != null
                      ? '${_currentRange.toStringAsFixed(0)} km'
                      : '-- km',
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('City Range',
                        style: TextStyle(fontSize: 11)),
                    Text(
                      _selectedVehicle != null
                          ? '${_cityRange.toStringAsFixed(0)} km'
                          : '-- km',
                      style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Highway Range',
                        style: TextStyle(fontSize: 11)),
                    Text(
                      _selectedVehicle != null
                          ? '${_highwayRange.toStringAsFixed(0)} km'
                          : '-- km',
                      style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Efficiency Card
          EfficiencyCard(
            kmPerLiter: _kmPerLiter,
            litersPerKm: _litersPerKm,
            fullTankRangeKm: _fullTankRange,
            efficiencyCategory: _efficiencyCategory,
          ),
          const SizedBox(height: 16),

          // VIEW TRIP SUMMARY
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed:
                  (_routeDistanceKm == null || _selectedVehicle == null)
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MainSummaryScreen(
                                onPlanNext: () {
                                  Navigator.pushReplacementNamed(
                                    context,
                                    '/home',
                                    arguments: 1,
                                  );
                                },
                              ),
                            ),
                          );
                        },
              icon: const Icon(Icons.flag_rounded, size: 18),
              label: Text(
                'TRIP DETAILS',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryMain,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.surfaceDim,
                disabledForegroundColor: AppColors.textTertiary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ─── Trip Readiness Card Content ───────────────────────────────
  Widget _buildTripReadiness() {
    if (_isCalculatingRoute) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: CircularProgressIndicator(
              strokeWidth: 2, color: AppColors.primaryMain),
        ),
      );
    }

    if (_routeDistanceKm == null || _selectedVehicle == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Text(
          'Enter a route and select a vehicle in Setup to check trip readiness.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
        ),
      );
    }

    final fuelNeeded = _routeDistanceKm! * _litersPerKm;
    final canComplete = _currentLiters >= fuelNeeded;
    final deficit = fuelNeeded - _currentLiters;
    final fuelUsageRatio = (fuelNeeded / _currentLiters).clamp(0.0, 1.0);
    final totalTripCost = fuelNeeded * _fuelPricePerLiter;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          const Text('Trip Fuel Consumption',
              style: TextStyle(fontSize: 12)),
          const SizedBox(height: 8),
          Stack(
            children: [
              Container(
                height: 8,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: fuelUsageRatio,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: canComplete
                          ? [AppColors.primaryMain, AppColors.primaryMain]
                          : [Colors.orange, Colors.red],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${(fuelUsageRatio * 100).toInt()}% of current fuel',
                  style: const TextStyle(fontSize: 12)),
              Text('${_currentLiters.toStringAsFixed(1)}L available',
                  style: const TextStyle(fontSize: 12)),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          _readinessRow(
              'Fuel Grade', _fuelGrade ?? (_isGasoline ? 'Gasoline' : 'Diesel')),
          _readinessRow('Total Distance',
              '${_routeDistanceKm!.toStringAsFixed(1)} km'),
          _readinessRow(
              'Est. Drive Time',
              _routeDurationHrs! < 1
                  ? '${(_routeDurationHrs! * 60).toInt()} mins'
                  : '${_routeDurationHrs!.toStringAsFixed(1)} hrs'),
          _readinessRow(
              'Fuel Required', '${fuelNeeded.toStringAsFixed(1)} Liters'),
          _readinessRow('Market Average',
              '₱${_fuelPricePerLiter.toStringAsFixed(2)}/L'),
          _readinessRow('Estimated Cost',
              '₱${totalTripCost.toStringAsFixed(2)}',
              isBold: true),
          if (_isGasoline) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryMain.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: AppColors.primaryMain.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.tips_and_updates_outlined,
                      size: 14, color: AppColors.primaryMain),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Gasoline Insight: High-quality fuels can improve your ${(_kmPerLiter).toStringAsFixed(1)} km/L efficiency for this journey.',
                      style: const TextStyle(
                          fontSize: 9,
                          color: AppColors.primaryMain,
                          height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (_lowestBrand != null) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(height: 1, indent: 4, endIndent: 4),
            ),
            Row(
              children: [
                const Icon(Icons.stars, size: 12, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  'Best Price: $_lowestBrand (₱${_lowestPrice?.toStringAsFixed(2)})',
                  style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.info_outline,
                    size: 12, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'Highest: $_highestBrand (₱${_highestPrice?.toStringAsFixed(2)})',
                  style: const TextStyle(fontSize: 9, color: Colors.black45),
                ),
              ],
            ),
          ],
          if (!canComplete) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade100),
              ),
              child: Text(
                'Critical: You are short by ${deficit.toStringAsFixed(1)}L. Refuel at least ₱${(deficit * _fuelPricePerLiter).toStringAsFixed(0)} to complete this trip safely.',
                style: TextStyle(
                    fontSize: 10,
                    color: Colors.red.shade900,
                    height: 1.3),
              ),
            ),
          ],
      ],
    );
  }

  Widget _readinessRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  const TextStyle(fontSize: 12)),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight:
                  isBold ? FontWeight.w900 : FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildReadinessBadge() {
    if (_routeDistanceKm == null || _selectedVehicle == null) {
      return const SizedBox.shrink();
    }
    final fuelNeeded = _routeDistanceKm! * _litersPerKm;
    final canComplete = _currentLiters >= fuelNeeded;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: canComplete
            ? Colors.green.withOpacity(0.1)
            : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            canComplete ? Icons.check_circle : Icons.warning_rounded,
            size: 12,
            color: canComplete ? Colors.green.shade700 : Colors.orange.shade700,
          ),
          const SizedBox(width: 4),
          Text(
            canComplete ? 'Ready' : 'Refuel',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: canComplete ? Colors.green.shade700 : Colors.orange.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
