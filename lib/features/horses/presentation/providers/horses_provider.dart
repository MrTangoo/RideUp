import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:io';
import '../data/models/horse_model.dart';
import '../data/repositories/horses_repository.dart';

part 'horses_provider.g.dart';

// Horses Repository Provider
@riverpod
HorsesRepository horsesRepository(HorsesRepositoryRef ref) {
  return HorsesRepository();
}

// Horses List Provider
@riverpod
Future<List<HorseModel>> horsesList(HorsesListRef ref) async {
  final repository = ref.watch(horsesRepositoryProvider);
  final result = await repository.getHorses();
  
  return result.fold(
    (failure) => throw Exception(failure.userMessage),
    (horses) => horses,
  );
}

// Single Horse Provider
@riverpod
Future<HorseModel> horse(HorseRef ref, String horseId) async {
  final repository = ref.watch(horsesRepositoryProvider);
  final result = await repository.getHorse(horseId);
  
  return result.fold(
    (failure) => throw Exception(failure.userMessage),
    (horse) => horse,
  );
}

// Can Add Horse Provider
@riverpod
Future<bool> canAddHorse(CanAddHorseRef ref) async {
  final repository = ref.watch(horsesRepositoryProvider);
  final result = await repository.canAddHorse();
  
  return result.fold(
    (failure) => false,
    (canAdd) => canAdd,
  );
}

// Horses Controller
@riverpod
class HorsesController extends _$HorsesController {
  @override
  FutureOr<void> build() {
    // No initial state needed
  }
  
  Future<String?> createHorse({
    required String name,
    String? breed,
    String? sex,
    int? age,
    double? weight,
    double? height,
    String? healthInfo,
    String? particularities,
    String? notes,
    File? photo,
  }) async {
    state = const AsyncValue.loading();
    
    final repository = ref.read(horsesRepositoryProvider);
    final result = await repository.createHorse(
      name: name,
      breed: breed,
      sex: sex,
      age: age,
      weight: weight,
      height: height,
      healthInfo: healthInfo,
      particularities: particularities,
      notes: notes,
      photo: photo,
    );
    
    return result.fold(
      (failure) {
        state = AsyncValue.error(failure, StackTrace.current);
        return failure.userMessage;
      },
      (horse) {
        state = const AsyncValue.data(null);
        // Invalidate horses list to refresh
        ref.invalidate(horsesListProvider);
        return null;
      },
    );
  }
  
  Future<String?> updateHorse({
    required String horseId,
    String? name,
    String? breed,
    String? sex,
    int? age,
    double? weight,
    double? height,
    String? healthInfo,
    String? particularities,
    String? notes,
    File? photo,
  }) async {
    state = const AsyncValue.loading();
    
    final repository = ref.read(horsesRepositoryProvider);
    final result = await repository.updateHorse(
      horseId: horseId,
      name: name,
      breed: breed,
      sex: sex,
      age: age,
      weight: weight,
      height: height,
      healthInfo: healthInfo,
      particularities: particularities,
      notes: notes,
      photo: photo,
    );
    
    return result.fold(
      (failure) {
        state = AsyncValue.error(failure, StackTrace.current);
        return failure.userMessage;
      },
      (horse) {
        state = const AsyncValue.data(null);
        // Invalidate horses list and single horse to refresh
        ref.invalidate(horsesListProvider);
        ref.invalidate(horseProvider(horseId));
        return null;
      },
    );
  }
  
  Future<String?> deleteHorse(String horseId) async {
    state = const AsyncValue.loading();
    
    final repository = ref.read(horsesRepositoryProvider);
    final result = await repository.deleteHorse(horseId);
    
    return result.fold(
      (failure) {
        state = AsyncValue.error(failure, StackTrace.current);
        return failure.userMessage;
      },
      (_) {
        state = const AsyncValue.data(null);
        // Invalidate horses list to refresh
        ref.invalidate(horsesListProvider);
        return null;
      },
    );
  }
}
