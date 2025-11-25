import 'package:freezed_annotation/freezed_annotation.dart';

part 'horse_model.freezed.dart';
part 'horse_model.g.dart';

@freezed
class HorseModel with _$HorseModel {
  const factory HorseModel({
    required String id,
    required String userId,
    required String name,
    String? breed,
    String? sex,
    int? age,
    double? weight,
    double? height,
    String? photoUrl,
    String? healthInfo,
    String? particularities,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _HorseModel;
  
  factory HorseModel.fromJson(Map<String, dynamic> json) =>
      _$HorseModelFromJson(json);
}

extension HorseModelX on HorseModel {
  String get displayName => name;
  
  String get breedDisplay => breed ?? 'Non renseigné';
  
  String get sexDisplay {
    switch (sex?.toLowerCase()) {
      case 'male':
      case 'mâle':
      case 'stallion':
      case 'étalon':
        return 'Mâle';
      case 'female':
      case 'femelle':
      case 'mare':
      case 'jument':
        return 'Femelle';
      case 'gelding':
      case 'hongre':
        return 'Hongre';
      default:
        return 'Non renseigné';
    }
  }
  
  String get ageDisplay => age != null ? '$age ans' : 'Non renseigné';
  
  String get weightDisplay => weight != null ? '${weight!.toStringAsFixed(0)} kg' : 'Non renseigné';
  
  String get heightDisplay => height != null ? '${height!.toStringAsFixed(0)} cm' : 'Non renseigné';
}
