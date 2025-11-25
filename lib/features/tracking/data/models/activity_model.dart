import 'package:freezed_annotation/freezed_annotation.dart';

part 'activity_model.freezed.dart';
part 'activity_model.g.dart';

@freezed
class ActivityModel with _$ActivityModel {
  const factory ActivityModel({
    required String id,
    required String horseId,
    required String userId,
    required DateTime startTime,
    DateTime? endTime,
    @Default(0.0) double distance,
    @Default(0.0) double maxSpeed,
    @Default(0.0) double avgSpeed,
    @Default(0.0) double calories,
    @Default(0.0) double workload,
    @Default(0.0) double elevationGain,
    @Default(0) int durationSeconds,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _ActivityModel;
  
  factory ActivityModel.fromJson(Map<String, dynamic> json) =>
      _$ActivityModelFromJson(json);
}

extension ActivityModelX on ActivityModel {
  Duration get duration => Duration(seconds: durationSeconds);
  
  double get distanceKm => distance / 1000;
  
  double get avgSpeedKmh => avgSpeed * 3.6;
  
  double get maxSpeedKmh => maxSpeed * 3.6;
  
  String get workloadLevel {
    if (workload < 30) return 'Léger';
    if (workload < 60) return 'Modéré';
    if (workload < 80) return 'Intense';
    return 'Très intense';
  }
  
  bool get isActive => endTime == null;
}
