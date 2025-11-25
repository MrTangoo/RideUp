import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LocalStorageService {
  static const String _settingsBox = 'settings';
  static const String _cacheBox = 'cache';
  static const String _offlineDataBox = 'offline_data';
  
  // Initialize Hive
  static Future<void> initialize() async {
    await Hive.initFlutter();
    
    // Open boxes
    await Hive.openBox(_settingsBox);
    await Hive.openBox(_cacheBox);
    await Hive.openBox(_offlineDataBox);
  }
  
  // Settings methods
  Future<void> saveSetting(String key, dynamic value) async {
    final box = Hive.box(_settingsBox);
    await box.put(key, value);
  }
  
  T? getSetting<T>(String key, {T? defaultValue}) {
    final box = Hive.box(_settingsBox);
    return box.get(key, defaultValue: defaultValue) as T?;
  }
  
  Future<void> deleteSetting(String key) async {
    final box = Hive.box(_settingsBox);
    await box.delete(key);
  }
  
  // Cache methods
  Future<void> cacheData(String key, dynamic value, {Duration? ttl}) async {
    final box = Hive.box(_cacheBox);
    final data = {
      'value': value,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'ttl': ttl?.inMilliseconds,
    };
    await box.put(key, data);
  }
  
  T? getCachedData<T>(String key) {
    final box = Hive.box(_cacheBox);
    final data = box.get(key);
    
    if (data == null) return null;
    
    final timestamp = data['timestamp'] as int;
    final ttl = data['ttl'] as int?;
    
    // Check if cache is expired
    if (ttl != null) {
      final expiryTime = timestamp + ttl;
      if (DateTime.now().millisecondsSinceEpoch > expiryTime) {
        box.delete(key);
        return null;
      }
    }
    
    return data['value'] as T?;
  }
  
  Future<void> clearCache() async {
    final box = Hive.box(_cacheBox);
    await box.clear();
  }
  
  // Offline data methods
  Future<void> saveOfflineData(String key, dynamic value) async {
    final box = Hive.box(_offlineDataBox);
    await box.put(key, value);
  }
  
  T? getOfflineData<T>(String key) {
    final box = Hive.box(_offlineDataBox);
    return box.get(key) as T?;
  }
  
  Future<void> deleteOfflineData(String key) async {
    final box = Hive.box(_offlineDataBox);
    await box.delete(key);
  }
  
  Future<void> clearOfflineData() async {
    final box = Hive.box(_offlineDataBox);
    await box.clear();
  }
  
  Map<dynamic, dynamic> getAllOfflineData() {
    final box = Hive.box(_offlineDataBox);
    return box.toMap();
  }
  
  // Clear all data
  Future<void> clearAll() async {
    await Hive.box(_settingsBox).clear();
    await Hive.box(_cacheBox).clear();
    await Hive.box(_offlineDataBox).clear();
  }
}

// Provider
final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService();
});
