import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();
  
  /// Notifies listeners when configuration or onboarding data changes.
  final ChangeNotifier onConfigChanged = ChangeNotifier();

  static Database? _database;

  Future<Database> get database async {
    if (kIsWeb) {
      throw UnsupportedError('sqflite is not supported on web');
    }
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (kIsWeb) throw UnsupportedError('Web not supported');
    String path = join(await getDatabasesPath(), 'haribon.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE user_onboarding (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_name TEXT,
        vehicle_type TEXT,
        travel_frequency TEXT,
        avg_refueling_cost REAL,
        planning_style TEXT,
        refueling_priority TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE TABLE trip_insights (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        origin TEXT,
        destination TEXT,
        vehicle_model TEXT,
        budget REAL,
        insights TEXT, -- JSON string
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');
  }

  Future<int> saveOnboardingData(Map<String, dynamic> data) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final existingStr = prefs.getString('onboarding_cache');
      final existing = existingStr != null
          ? Map<String, dynamic>.from(jsonDecode(existingStr))
          : <String, dynamic>{};
      existing.addAll(data);
      await prefs.setString('onboarding_cache', jsonEncode(existing));
      return 1;
    }
    final db = await database;
    final result = await db.insert('user_onboarding', data);
    onConfigChanged.notifyListeners();
    return result;
  }

  Future<void> updateLatestOnboardingData(Map<String, dynamic> data) async {
    if (kIsWeb) {
      await saveOnboardingData(data); // Merge logic is already in saveOnboardingData
      onConfigChanged.notifyListeners();
      return;
    }
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'user_onboarding',
      orderBy: 'created_at DESC',
      limit: 1,
    );
    if (maps.isNotEmpty) {
      final id = maps.first['id'];
      await db.update(
        'user_onboarding',
        data,
        where: 'id = ?',
        whereArgs: [id],
      );
    } else {
      await saveOnboardingData(data);
    }
    onConfigChanged.notifyListeners();
  }

  /// Save a trip record to a separate storage (web: SharedPreferences list, native: SQLite trips table)
  Future<void> saveTrip(Map<String, dynamic> tripData) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final existingStr = prefs.getString('trips_cache') ?? '[]';
      final List<dynamic> trips = jsonDecode(existingStr);
      trips.insert(0, tripData);
      // Keep last 50 trips
      final trimmed = trips.take(50).toList();
      await prefs.setString('trips_cache', jsonEncode(trimmed));
      return;
    }
    // Native: use onboarding db as a simple placeholder (future: add trips table)
    final db = await database;
    await db.insert('user_onboarding', {'last_trip': jsonEncode(tripData)});
  }

  /// Retrieve saved trips (web: SharedPreferences, native: stub)
  Future<List<Map<String, dynamic>>> getTrips() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final str = prefs.getString('trips_cache') ?? '[]';
      final list = jsonDecode(str) as List<dynamic>;
      return list.map((e) => Map<String, dynamic>.from(e)).toList();
    }
    return [];
  }

  /// Save full vehicle configuration and trip readiness to local storage
  Future<void> saveVehicleConfiguration(Map<String, dynamic> config) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final existingStr = prefs.getString('vehicle_configs_cache') ?? '[]';
      final List<dynamic> configs = jsonDecode(existingStr);
      configs.insert(0, config);
      final trimmed = configs.take(10).toList(); // keep last 10 configs
      await prefs.setString('vehicle_configs_cache', jsonEncode(trimmed));
      onConfigChanged.notifyListeners();
      return;
    }
    // Native SQLite fallback - just stashing it in user_onboarding for now
    // Future update: CREATE TABLE vehicle_configurations in SQLite
    final db = await database;
    await db.insert('user_onboarding', {'last_trip': jsonEncode({'config': config})});
    onConfigChanged.notifyListeners();
  }

  Future<Map<String, dynamic>?> getOnboardingData() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final cacheStr = prefs.getString('onboarding_cache');
      if (cacheStr != null) {
        return jsonDecode(cacheStr);
      }
      return null;
    }
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'user_onboarding',
      orderBy: 'created_at DESC',
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  Future<void> saveTripInsights(Map<String, dynamic> data) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final key = 'insights_${data['origin']}_${data['destination']}_${data['vehicle_model']}';
      await prefs.setString(key, jsonEncode(data));
      return;
    }
    final db = await database;
    await db.insert('trip_insights', {
      'origin': data['origin'],
      'destination': data['destination'],
      'vehicle_model': data['vehicle_model'],
      'budget': data['budget'],
      'insights': jsonEncode(data['insights']),
    });
  }

  Future<Map<String, dynamic>?> getTripInsights(String origin, String destination, String vehicleModel) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final key = 'insights_${origin}_${destination}_$vehicleModel';
      final str = prefs.getString(key);
      return str != null ? jsonDecode(str) : null;
    }
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'trip_insights',
      where: 'origin = ? AND destination = ? AND vehicle_model = ?',
      whereArgs: [origin, destination, vehicleModel],
      orderBy: 'created_at DESC',
      limit: 1,
    );
    if (maps.isNotEmpty) {
      final map = Map<String, dynamic>.from(maps.first);
      map['insights'] = jsonDecode(map['insights']);
      return map;
    }
    return null;
  }
}
