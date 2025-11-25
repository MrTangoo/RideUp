import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/horse_model.dart';

class HorsesRepository {
  final SupabaseClient _supabase = Supabase.instance.client;
  final Uuid _uuid = const Uuid();
  
  // Get all horses for current user
  Future<Either<Failure, List<HorseModel>>> getHorses() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        return const Left(
          Failure.authenticationFailure(message: 'Utilisateur non connecté'),
        );
      }
      
      final response = await _supabase
          .from('horses')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      
      final horses = (response as List)
          .map((json) => HorseModel.fromJson(json))
          .toList();
      
      return Right(horses);
    } on PostgrestException catch (e) {
      return Left(Failure.serverFailure(message: e.message));
    } catch (e) {
      return Left(Failure.unknownFailure(message: e.toString()));
    }
  }
  
  // Get single horse by ID
  Future<Either<Failure, HorseModel>> getHorse(String horseId) async {
    try {
      final response = await _supabase
          .from('horses')
          .select()
          .eq('id', horseId)
          .single();
      
      final horse = HorseModel.fromJson(response);
      return Right(horse);
    } on PostgrestException catch (e) {
      return Left(Failure.serverFailure(message: e.message));
    } catch (e) {
      return Left(Failure.unknownFailure(message: e.toString()));
    }
  }
  
  // Check if user can add more horses (freemium logic)
  Future<Either<Failure, bool>> canAddHorse() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        return const Left(
          Failure.authenticationFailure(message: 'Utilisateur non connecté'),
        );
      }
      
      // Get user plan
      final userResponse = await _supabase
          .from('users')
          .select('plan')
          .eq('id', userId)
          .single();
      
      final plan = userResponse['plan'] as String;
      
      // Get current horse count
      final horsesResponse = await _supabase
          .from('horses')
          .select('id')
          .eq('user_id', userId);
      
      final horseCount = (horsesResponse as List).length;
      
      // Check limits
      if (plan == 'premium') {
        return const Right(true);
      } else {
        return Right(horseCount < AppConstants.freeMaxHorses);
      }
    } on PostgrestException catch (e) {
      return Left(Failure.serverFailure(message: e.message));
    } catch (e) {
      return Left(Failure.unknownFailure(message: e.toString()));
    }
  }
  
  // Create new horse
  Future<Either<Failure, HorseModel>> createHorse({
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
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        return const Left(
          Failure.authenticationFailure(message: 'Utilisateur non connecté'),
        );
      }
      
      // Check if user can add horse
      final canAdd = await canAddHorse();
      if (canAdd.isLeft()) {
        return Left(canAdd.fold((l) => l, (r) => const Failure.unknownFailure(message: 'Erreur')));
      }
      
      final canAddResult = canAdd.getOrElse(() => false);
      if (!canAddResult) {
        return const Left(
          Failure.subscriptionFailure(
            message: 'Limite de chevaux atteinte. Passez à Premium pour ajouter plus de chevaux.',
          ),
        );
      }
      
      // Upload photo if provided
      String? photoUrl;
      if (photo != null) {
        final uploadResult = await _uploadPhoto(photo);
        if (uploadResult.isLeft()) {
          return Left(uploadResult.fold((l) => l, (r) => const Failure.unknownFailure(message: 'Erreur')));
        }
        photoUrl = uploadResult.getOrElse(() => null);
      }
      
      // Create horse record
      final horseData = {
        'user_id': userId,
        'name': name,
        'breed': breed,
        'sex': sex,
        'age': age,
        'weight': weight,
        'height': height,
        'photo_url': photoUrl,
        'health_info': healthInfo,
        'particularities': particularities,
        'notes': notes,
        'created_at': DateTime.now().toIso8601String(),
      };
      
      final response = await _supabase
          .from('horses')
          .insert(horseData)
          .select()
          .single();
      
      final horse = HorseModel.fromJson(response);
      return Right(horse);
    } on PostgrestException catch (e) {
      return Left(Failure.serverFailure(message: e.message));
    } catch (e) {
      return Left(Failure.unknownFailure(message: e.toString()));
    }
  }
  
  // Update horse
  Future<Either<Failure, HorseModel>> updateHorse({
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
    try {
      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      if (name != null) updates['name'] = name;
      if (breed != null) updates['breed'] = breed;
      if (sex != null) updates['sex'] = sex;
      if (age != null) updates['age'] = age;
      if (weight != null) updates['weight'] = weight;
      if (height != null) updates['height'] = height;
      if (healthInfo != null) updates['health_info'] = healthInfo;
      if (particularities != null) updates['particularities'] = particularities;
      if (notes != null) updates['notes'] = notes;
      
      // Upload new photo if provided
      if (photo != null) {
        final uploadResult = await _uploadPhoto(photo);
        if (uploadResult.isLeft()) {
          return Left(uploadResult.fold((l) => l, (r) => const Failure.unknownFailure(message: 'Erreur')));
        }
        final photoUrl = uploadResult.getOrElse(() => null);
        if (photoUrl != null) {
          updates['photo_url'] = photoUrl;
        }
      }
      
      final response = await _supabase
          .from('horses')
          .update(updates)
          .eq('id', horseId)
          .select()
          .single();
      
      final horse = HorseModel.fromJson(response);
      return Right(horse);
    } on PostgrestException catch (e) {
      return Left(Failure.serverFailure(message: e.message));
    } catch (e) {
      return Left(Failure.unknownFailure(message: e.toString()));
    }
  }
  
  // Delete horse
  Future<Either<Failure, void>> deleteHorse(String horseId) async {
    try {
      await _supabase.from('horses').delete().eq('id', horseId);
      return const Right(null);
    } on PostgrestException catch (e) {
      return Left(Failure.serverFailure(message: e.message));
    } catch (e) {
      return Left(Failure.unknownFailure(message: e.toString()));
    }
  }
  
  // Upload photo to Supabase Storage
  Future<Either<Failure, String?>> _uploadPhoto(File photo) async {
    try {
      // Compress image
      final tempDir = await getTemporaryDirectory();
      final targetPath = '${tempDir.path}/${_uuid.v4()}.jpg';
      
      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        photo.path,
        targetPath,
        quality: AppConstants.imageQuality,
        minWidth: AppConstants.maxImageWidth,
        minHeight: AppConstants.maxImageHeight,
      );
      
      if (compressedFile == null) {
        return const Left(
          Failure.storageFailure(message: 'Échec de la compression de l\'image'),
        );
      }
      
      // Upload to Supabase Storage
      final fileName = '${_uuid.v4()}.jpg';
      final filePath = 'horses/$fileName';
      
      await _supabase.storage
          .from('photos')
          .upload(filePath, compressedFile);
      
      // Get public URL
      final publicUrl = _supabase.storage
          .from('photos')
          .getPublicUrl(filePath);
      
      return Right(publicUrl);
    } catch (e) {
      return Left(Failure.storageFailure(message: e.toString()));
    }
  }
}
