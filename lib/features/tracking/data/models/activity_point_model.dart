import 'package:freezed_annotation/freezed_annotation.dart';

part 'activity_point_model.freezed.dart';
part 'activity_point_model.g.dart';

@freezed
class ActivityPointModel with _$ActivityPointModel {
  const factory ActivityPointModel({
    required String id,
    required String activityId,
    required double lat,
    required double lng,
    @Default(0.0) double speed,
    double? altitude,
    required DateTime timestamp,
    DateTime? createdAt,
  }) = _ActivityPointModel;
  
  factory ActivityPointModel.fromJson(Map<String, dynamic> json) =>
      _$ActivityPointModelFromJson(json);
}

extension ActivityPointModelX on ActivityPointModel {
  double get speedKmh => speed * 3.6;
  
  String get gait {
    final kmh = speedKmh;
    if (kmh < 7.0) return 'Pas';
    if (kmh < 15.0) return 'Trot';
    return 'Galop';
  }
}
