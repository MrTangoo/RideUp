import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'local_storage_service.dart';

class SyncService {
  final LocalStorageService _localStorage;
  final SupabaseClient _supabase = Supabase.instance.client;
  final Connectivity _connectivity = Connectivity();
  
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isSyncing = false;
  
  SyncService(this._localStorage);
  
  // Initialize sync service
  void initialize() {
    // Listen to connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((results) {
      final result = results.isNotEmpty ? results.first : ConnectivityResult.none;
      if (result != ConnectivityResult.none && !_isSyncing) {
        syncOfflineData();
      }
    });
  }
  
  // Check if online
  Future<bool> isOnline() async {
    final results = await _connectivity.checkConnectivity();
    final result = results.isNotEmpty ? results.first : ConnectivityResult.none;
    return result != ConnectivityResult.none;
  }
  
  // Sync offline data
  Future<void> syncOfflineData() async {
    if (_isSyncing) return;
    
    _isSyncing = true;
    
    try {
      final online = await isOnline();
      if (!online) {
        print('Device is offline, skipping sync');
        return;
      }
      
      final offlineData = _localStorage.getAllOfflineData();
      
      if (offlineData.isEmpty) {
        print('No offline data to sync');
        return;
      }
      
      print('Syncing ${offlineData.length} offline items...');
      
      // Sync each item
      for (final entry in offlineData.entries) {
        try {
          final key = entry.key as String;
          final data = entry.value as Map<String, dynamic>;
          
          await _syncItem(key, data);
          
          // Remove from offline storage after successful sync
          await _localStorage.deleteOfflineData(key);
        } catch (e) {
          print('Error syncing item ${entry.key}: $e');
          // Keep item in offline storage for retry
        }
      }
      
      print('Sync completed');
    } finally {
      _isSyncing = false;
    }
  }
  
  // Sync individual item
  Future<void> _syncItem(String key, Map<String, dynamic> data) async {
    final type = data['type'] as String;
    final operation = data['operation'] as String;
    final payload = data['payload'] as Map<String, dynamic>;
    
    switch (type) {
      case 'horse':
        await _syncHorse(operation, payload);
        break;
      case 'activity':
        await _syncActivity(operation, payload);
        break;
      case 'health_event':
        await _syncHealthEvent(operation, payload);
        break;
      case 'planning':
        await _syncPlanning(operation, payload);
        break;
      default:
        print('Unknown sync type: $type');
    }
  }
  
  // Sync horse
  Future<void> _syncHorse(String operation, Map<String, dynamic> payload) async {
    switch (operation) {
      case 'create':
        await _supabase.from('horses').insert(payload);
        break;
      case 'update':
        await _supabase.from('horses').update(payload).eq('id', payload['id']);
        break;
      case 'delete':
        await _supabase.from('horses').delete().eq('id', payload['id']);
        break;
    }
  }
  
  // Sync activity
  Future<void> _syncActivity(String operation, Map<String, dynamic> payload) async {
    switch (operation) {
      case 'create':
        await _supabase.from('activities').insert(payload);
        break;
      case 'update':
        await _supabase.from('activities').update(payload).eq('id', payload['id']);
        break;
      case 'delete':
        await _supabase.from('activities').delete().eq('id', payload['id']);
        break;
    }
  }
  
  // Sync health event
  Future<void> _syncHealthEvent(String operation, Map<String, dynamic> payload) async {
    switch (operation) {
      case 'create':
        await _supabase.from('health_events').insert(payload);
        break;
      case 'update':
        await _supabase.from('health_events').update(payload).eq('id', payload['id']);
        break;
      case 'delete':
        await _supabase.from('health_events').delete().eq('id', payload['id']);
        break;
    }
  }
  
  // Sync planning
  Future<void> _syncPlanning(String operation, Map<String, dynamic> payload) async {
    switch (operation) {
      case 'create':
        await _supabase.from('planning').insert(payload);
        break;
      case 'update':
        await _supabase.from('planning').update(payload).eq('id', payload['id']);
        break;
      case 'delete':
        await _supabase.from('planning').delete().eq('id', payload['id']);
        break;
    }
  }
  
  // Queue offline operation
  Future<void> queueOfflineOperation({
    required String type,
    required String operation,
    required Map<String, dynamic> payload,
  }) async {
    final key = '${type}_${operation}_${DateTime.now().millisecondsSinceEpoch}';
    final data = {
      'type': type,
      'operation': operation,
      'payload': payload,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    await _localStorage.saveOfflineData(key, data);
    
    // Try to sync immediately if online
    if (await isOnline()) {
      syncOfflineData();
    }
  }
  
  // Dispose
  void dispose() {
    _connectivitySubscription?.cancel();
  }
}

// Provider
final syncServiceProvider = Provider<SyncService>((ref) {
  final localStorage = ref.watch(localStorageServiceProvider);
  final service = SyncService(localStorage);
  service.initialize();
  ref.onDispose(() => service.dispose());
  return service;
});
