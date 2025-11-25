import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/models/user_model.dart';
import '../data/repositories/auth_repository.dart';

part 'auth_provider.g.dart';

// Auth Repository Provider
@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  return AuthRepository();
}

// Current User Provider
@riverpod
Stream<UserModel?> authState(AuthStateRef ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChanges;
}

// Auth Controller
@riverpod
class AuthController extends _$AuthController {
  @override
  FutureOr<UserModel?> build() async {
    final authRepository = ref.watch(authRepositoryProvider);
    final result = await authRepository.getCurrentUser();
    
    return result.fold(
      (failure) => null,
      (user) => user,
    );
  }
  
  Future<String?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    
    final authRepository = ref.read(authRepositoryProvider);
    final result = await authRepository.signInWithEmail(
      email: email,
      password: password,
    );
    
    return result.fold(
      (failure) {
        state = AsyncValue.error(failure, StackTrace.current);
        return failure.userMessage;
      },
      (user) {
        state = AsyncValue.data(user);
        return null;
      },
    );
  }
  
  Future<String?> signUpWithEmail({
    required String email,
    required String password,
    String? fullName,
  }) async {
    state = const AsyncValue.loading();
    
    final authRepository = ref.read(authRepositoryProvider);
    final result = await authRepository.signUpWithEmail(
      email: email,
      password: password,
      fullName: fullName,
    );
    
    return result.fold(
      (failure) {
        state = AsyncValue.error(failure, StackTrace.current);
        return failure.userMessage;
      },
      (user) {
        state = AsyncValue.data(user);
        return null;
      },
    );
  }
  
  Future<String?> signInWithGoogle() async {
    state = const AsyncValue.loading();
    
    final authRepository = ref.read(authRepositoryProvider);
    final result = await authRepository.signInWithGoogle();
    
    return result.fold(
      (failure) {
        state = AsyncValue.error(failure, StackTrace.current);
        return failure.userMessage;
      },
      (user) {
        state = AsyncValue.data(user);
        return null;
      },
    );
  }
  
  Future<String?> signInWithApple() async {
    state = const AsyncValue.loading();
    
    final authRepository = ref.read(authRepositoryProvider);
    final result = await authRepository.signInWithApple();
    
    return result.fold(
      (failure) {
        state = AsyncValue.error(failure, StackTrace.current);
        return failure.userMessage;
      },
      (user) {
        state = AsyncValue.data(user);
        return null;
      },
    );
  }
  
  Future<String?> resetPassword({required String email}) async {
    final authRepository = ref.read(authRepositoryProvider);
    final result = await authRepository.resetPassword(email: email);
    
    return result.fold(
      (failure) => failure.userMessage,
      (_) => null,
    );
  }
  
  Future<void> signOut() async {
    final authRepository = ref.read(authRepositoryProvider);
    await authRepository.signOut();
    state = const AsyncValue.data(null);
  }
  
  Future<String?> updateProfile({
    String? fullName,
    String? avatarUrl,
  }) async {
    final authRepository = ref.read(authRepositoryProvider);
    final result = await authRepository.updateProfile(
      fullName: fullName,
      avatarUrl: avatarUrl,
    );
    
    return result.fold(
      (failure) => failure.userMessage,
      (user) {
        state = AsyncValue.data(user);
        return null;
      },
    );
  }
}
