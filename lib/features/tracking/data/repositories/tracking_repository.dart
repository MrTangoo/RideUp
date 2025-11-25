import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/failures.dart';
import '../models/activity_model.dart';
import '../models/activity_point_model.dart';

class TrackingRepository {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  // Create activity
  Future<Either<Failure, ActivityModel>> createActivity({
    required String horseId,
    required DateTime startTime,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        return const Left(
          Failure.authenticationFailure(message: 'Utilisateur non connecté'),
        );
      }
      
      final activityData = {
        'horse_id': horseId,
        'user_id': userId,
        'start_time': startTime.toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
      };
      
      final response = await _supabase
          .from('activities')
          .insert(activityData)
          .select()
          .single();
      
      final activity = ActivityModel.fromJson(response);
      return Right(activity);
    } on PostgrestException catch (e) {
      return Left(Failure.serverFailure(message: e.message));
    } catch (e) {
      return Left(Failure.unknownFailure(message: e.toString()));
    }
  }
  
  // Update activity
  Future<Either<Failure, ActivityModel>> updateActivity({
    required String activityId,
    DateTime? endTime,
    double? distance,
    double? maxSpeed,
    double? avgSpeed,
    double? calories,
    double? workload,
    double? elevationGain,
    int? durationSeconds,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      if (endTime != null) updates['end_time'] = endTime.toIso8601String();
      if (distance != null) updates['distance'] = distance;
      if (maxSpeed != null) updates['max_speed'] = maxSpeed;
      if (avgSpeed != null) updates['avg_speed'] = avgSpeed;
      if (calories != null) updates['calories'] = calories;
      if (workload != null) updates['workload'] = workload;
      if (elevationGain != null) updates['elevation_gain'] = elevationGain;
      if (durationSeconds != null) updates['duration_seconds'] = durationSeconds;
      
      final response = await _supabase
          .from('activities')
          .update(updates)
          .eq('id', activityId)
          .select()
          .single();
      
      final activity = ActivityModel.fromJson(response);
      return Right(activity);
    } on PostgrestException catch (e) {
      return Left(Failure.serverFailure(message: e.message));
    } catch (e) {
      return Left(Failure.unknownFailure(message: e.toString()));
    }
  }
  
  // Save activity points (batch)
  Future<Either<Failure, void>> saveActivityPoints({
    required String activityId,
    required List<ActivityPointModel> points,
  }) async {
    try {
      final pointsData = points.map((point) => {
        'activity_id': activityId,
        'lat': point.lat,
        'lng': point.lng,
        'speed': point.speed,
        'altitude': point.altitude,
        'timestamp': point.timestamp.toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
      }).toList();
      
      await _supabase.from('activity_points').insert(pointsData);
      
      return const Right(null);
    } on PostgrestException catch (e) {
      return Left(Failure.serverFailure(message: e.message));
    } catch (e) {
      return Left(Failure.unknownFailure(message: e.toString()));
    }
  }
  
  // Get activities
  Future<Either<Failure, List<ActivityModel>>> getActivities({
    String? horseId,
    int limit = 20,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        return const Left(
          Failure.authenticationFailure(message: 'Utilisateur non connecté'),
        );
      }
      
      var query = _supabase
          .from('activities')
          .select()
          .eq('user_id', userId)
          .order('start_time', ascending: false)
          .limit(limit);
      
      if (horseId != null) {
        query = query.eq('horse_id', horseId);
      }
      
      final response = await query;
      
      final activities = (response as List)
          .map((json) => ActivityModel.fromJson(json))
          .toList();
      
      return Right(activities);
    } on PostgrestException catch (e) {
      return Left(Failure.serverFailure(message: e.message));
    } catch (e) {
      return Left(Failure.unknownFailure(message: e.toString()));
    }
  }
  
  // Get activity with points
  Future<Either<Failure, Map<String, dynamic>>> getActivityWithPoints(String activityId) async {
    try {
      final activityResponse = await _supabase
          .from('activities')
          .select()
          .eq('id', activityId)
          .single();
      
      final pointsResponse = await _supabase
          .from('activity_points')
          .select()
          .eq('activity_id', activityId)
          .order('timestamp');
      
      final activity = ActivityModel.fromJson(activityResponse);
      final points = (pointsResponse as List)
          .map((json) => ActivityPointModel.fromJson(json))
          .toList();
      
      return Right({
        'activity': activity,
        'points': points,
      });
    } on PostgrestException catch (e) {
      return Left(Failure.serverFailure(message: e.message));
    } catch (e) {
      return Left(Failure.unknownFailure(message: e.toString()));
    }
  }
}
