import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/activity_model.dart';
import '../../data/models/activity_point_model.dart';
import '../../data/repositories/tracking_repository.dart';
import '../../../../services/gps_service.dart';

part 'tracking_provider.g.dart';

// Tracking Repository Provider
@riverpod
TrackingRepository trackingRepository(TrackingRepositoryRef ref) {
  return TrackingRepository();
}

// Activities List Provider
@riverpod
Future<List<ActivityModel>> activitiesList(
  ActivitiesListRef ref, {
  String? horseId,
}) async {
  final repository = ref.watch(trackingRepositoryProvider);
  final result = await repository.getActivities(horseId: horseId);
  
  return result.fold(
    (failure) => throw Exception(failure.userMessage),
    (activities) => activities,
  );
}

// Single Activity Provider
@riverpod
Future<Map<String, dynamic>> activityWithPoints(
  ActivityWithPointsRef ref,
  String activityId,
) async {
  final repository = ref.watch(trackingRepositoryProvider);
  final result = await repository.getActivityWithPoints(activityId);
  
  return result.fold(
    (failure) => throw Exception(failure.userMessage),
    (data) => data,
  );
}

// Tracking State Provider
class TrackingState {
  final bool isTracking;
  final ActivityModel? currentActivity;
  final List<ActivityPointModel> points;
  final Map<String, dynamic> stats;

  TrackingState({
    this.isTracking = false,
    this.currentActivity,
    this.points = const [],
    this.stats = const {},
  });

  TrackingState copyWith({
    bool? isTracking,
    ActivityModel? currentActivity,
    List<ActivityPointModel>? points,
    Map<String, dynamic>? stats,
  }) {
    return TrackingState(
      isTracking: isTracking ?? this.isTracking,
      currentActivity: currentActivity ?? this.currentActivity,
      points: points ?? this.points,
      stats: stats ?? this.stats,
    );
  }
}

// Tracking Controller
@riverpod
class TrackingController extends _$TrackingController {
  @override
  TrackingState build() {
    return TrackingState();
  }
  
  Future<String?> startTracking(String horseId) async {
    final repository = ref.read(trackingRepositoryProvider);
    final gpsService = ref.read(gpsServiceProvider);
    
    // Create activity
    final result = await repository.createActivity(
      horseId: horseId,
      startTime: DateTime.now(),
    );
    
    return result.fold(
      (failure) => failure.userMessage,
      (activity) async {
        state = state.copyWith(
          isTracking: true,
          currentActivity: activity,
          points: [],
          stats: {},
        );
        
        // Start GPS tracking
        try {
          await gpsService.startTracking(
            onNewPoint: (point) {
              final updatedPoints = [...state.points, point];
              state = state.copyWith(points: updatedPoints);
            },
            onStatsUpdate: (stats) {
              state = state.copyWith(stats: stats);
            },
          );
          return null;
        } catch (e) {
          return e.toString();
        }
      },
    );
  }
  
  Future<String?> stopTracking() async {
    if (state.currentActivity == null) return 'Aucune activité en cours';
    
    final repository = ref.read(trackingRepositoryProvider);
    final gpsService = ref.read(gpsServiceProvider);
    
    // Stop GPS
    gpsService.stopTracking();
    
    // Get final stats
    final stats = gpsService.getCurrentStats();
    
    // Update activity with final stats
    final updateResult = await repository.updateActivity(
      activityId: state.currentActivity!.id,
      endTime: DateTime.now(),
      distance: stats['distance'],
      maxSpeed: stats['maxSpeed'],
      avgSpeed: stats['avgSpeed'],
      calories: stats['calories'],
      workload: stats['workload'],
      elevationGain: stats['elevationGain'],
      durationSeconds: stats['durationSeconds'],
    );
    
    if (updateResult.isLeft()) {
      return updateResult.fold((l) => l.userMessage, (r) => null);
    }
    
    // Save GPS points
    final points = gpsService.getCurrentPoints();
    if (points.isNotEmpty) {
      final pointsWithActivityId = points.map((p) => ActivityPointModel(
        id: '',
        activityId: state.currentActivity!.id,
        lat: p.lat,
        lng: p.lng,
        speed: p.speed,
        altitude: p.altitude,
        timestamp: p.timestamp,
      )).toList();
      
      await repository.saveActivityPoints(
        activityId: state.currentActivity!.id,
        points: pointsWithActivityId,
      );
    }
    
    // Reset state
    state = TrackingState();
    
    // Invalidate activities list
    ref.invalidate(activitiesListProvider);
    
    return null;
  }
  
  void pauseTracking() {
    final gpsService = ref.read(gpsServiceProvider);
    gpsService.pauseTracking();
  }
  
  void resumeTracking() {
    final gpsService = ref.read(gpsServiceProvider);
    gpsService.resumeTracking();
  }
}
