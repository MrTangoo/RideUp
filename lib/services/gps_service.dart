import 'dart:async';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_constants.dart';
import '../core/error/failures.dart';
import '../features/tracking/data/models/activity_point_model.dart';

class GpsService {
  StreamSubscription<Position>? _positionSubscription;
  final List<ActivityPointModel> _currentPoints = [];
  Position? _lastPosition;
  
  // Statistics
  double _totalDistance = 0.0;
  double _maxSpeed = 0.0;
  double _totalSpeed = 0.0;
  int _speedCount = 0;
  double _elevationGain = 0.0;
  double? _lastAltitude;
  
  // Gait tracking
  int _walkSeconds = 0;
  int _trotSeconds = 0;
  int _gallopSeconds = 0;
  
  // Check and request location permissions
  Future<bool> checkPermissions() async {
    bool serviceEnabled;
    LocationPermission permission;
    
    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }
    
    // Check permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return false;
    }
    
    return true;
  }
  
  // Start tracking
  Future<void> startTracking({
    required Function(ActivityPointModel) onNewPoint,
    required Function(Map<String, dynamic>) onStatsUpdate,
  }) async {
    final hasPermission = await checkPermissions();
    if (!hasPermission) {
      throw Exception('Location permissions not granted');
    }
    
    // Reset statistics
    _currentPoints.clear();
    _totalDistance = 0.0;
    _maxSpeed = 0.0;
    _totalSpeed = 0.0;
    _speedCount = 0;
    _elevationGain = 0.0;
    _lastAltitude = null;
    _lastPosition = null;
    _walkSeconds = 0;
    _trotSeconds = 0;
    _gallopSeconds = 0;
    
    // Configure location settings
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5, // Minimum 5 meters between updates
    );
    
    // Start listening to position updates
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      _handleNewPosition(position, onNewPoint, onStatsUpdate);
    });
  }
  
  // Handle new GPS position
  void _handleNewPosition(
    Position position,
    Function(ActivityPointModel) onNewPoint,
    Function(Map<String, dynamic>) onStatsUpdate,
  ) {
    final now = DateTime.now();
    
    // Calculate speed (m/s)
    final speed = position.speed;
    
    // Calculate distance from last position
    if (_lastPosition != null) {
      final distance = Geolocator.distanceBetween(
        _lastPosition!.latitude,
        _lastPosition!.longitude,
        position.latitude,
        position.longitude,
      );
      
      // Only add point if moved minimum distance
      if (distance >= AppConstants.gpsMinDistanceMeters) {
        _totalDistance += distance;
        
        // Update max speed
        if (speed > _maxSpeed) {
          _maxSpeed = speed;
        }
        
        // Update average speed
        _totalSpeed += speed;
        _speedCount++;
        
        // Calculate elevation gain
        if (position.altitude != null) {
          if (_lastAltitude != null && position.altitude! > _lastAltitude!) {
            _elevationGain += (position.altitude! - _lastAltitude!);
          }
          _lastAltitude = position.altitude;
        }
        
        // Track gait time
        final speedKmh = speed * 3.6;
        if (speedKmh < AppConstants.walkMaxSpeed) {
          _walkSeconds += 2; // Approximate 2 seconds per update
        } else if (speedKmh < AppConstants.trotMaxSpeed) {
          _trotSeconds += 2;
        } else {
          _gallopSeconds += 2;
        }
        
        // Create activity point
        final point = ActivityPointModel(
          id: '', // Will be set when saved to database
          activityId: '', // Will be set when saved to database
          lat: position.latitude,
          lng: position.longitude,
          speed: speed,
          altitude: position.altitude,
          timestamp: now,
        );
        
        _currentPoints.add(point);
        onNewPoint(point);
        
        // Update statistics
        final stats = getCurrentStats();
        onStatsUpdate(stats);
        
        _lastPosition = position;
      }
    } else {
      // First position
      _lastPosition = position;
      _lastAltitude = position.altitude;
    }
  }
  
  // Get current statistics
  Map<String, dynamic> getCurrentStats() {
    final avgSpeed = _speedCount > 0 ? _totalSpeed / _speedCount : 0.0;
    final totalSeconds = _walkSeconds + _trotSeconds + _gallopSeconds;
    
    // Calculate workload (0-100 scale)
    // Based on distance, speed, and gait distribution
    double workload = 0.0;
    if (totalSeconds > 0) {
      final walkRatio = _walkSeconds / totalSeconds;
      final trotRatio = _trotSeconds / totalSeconds;
      final gallopRatio = _gallopSeconds / totalSeconds;
      
      workload = (walkRatio * 20) + (trotRatio * 50) + (gallopRatio * 80);
      
      // Adjust for distance
      final distanceKm = _totalDistance / 1000;
      if (distanceKm > 10) workload = min(100, workload * 1.2);
      if (distanceKm > 20) workload = min(100, workload * 1.3);
    }
    
    // Calculate calories
    final distanceKm = _totalDistance / 1000;
    final calories = (distanceKm * AppConstants.caloriesPerKmWalk * (_walkSeconds / max(1, totalSeconds))) +
                     (distanceKm * AppConstants.caloriesPerKmTrot * (_trotSeconds / max(1, totalSeconds))) +
                     (distanceKm * AppConstants.caloriesPerKmGallop * (_gallopSeconds / max(1, totalSeconds)));
    
    return {
      'distance': _totalDistance,
      'maxSpeed': _maxSpeed,
      'avgSpeed': avgSpeed,
      'elevationGain': _elevationGain,
      'calories': calories,
      'workload': workload,
      'durationSeconds': totalSeconds,
      'pointsCount': _currentPoints.length,
      'gaitDistribution': {
        'walk': _walkSeconds,
        'trot': _trotSeconds,
        'gallop': _gallopSeconds,
      },
    };
  }
  
  // Get current points
  List<ActivityPointModel> getCurrentPoints() {
    return List.unmodifiable(_currentPoints);
  }
  
  // Stop tracking
  void stopTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
  }
  
  // Pause tracking
  void pauseTracking() {
    _positionSubscription?.pause();
  }
  
  // Resume tracking
  void resumeTracking() {
    _positionSubscription?.resume();
  }
  
  // Dispose
  void dispose() {
    stopTracking();
    _currentPoints.clear();
  }
}

// Provider for GPS service
final gpsServiceProvider = Provider<GpsService>((ref) {
  final service = GpsService();
  ref.onDispose(() => service.dispose());
  return service;
});
