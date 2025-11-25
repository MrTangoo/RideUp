import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../../../core/error/failures.dart';
import '../models/user_model.dart';

class AuthRepository {
  final SupabaseClient _supabase = Supabase.instance.client;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  
  // Get current user
  Future<Either<Failure, UserModel?>> getCurrentUser() async {
    try {
      final session = _supabase.auth.currentSession;
      if (session == null) {
        return const Right(null);
      }
      
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', session.user.id)
          .single();
      
      final user = UserModel.fromJson(response);
      return Right(user);
    } on PostgrestException catch (e) {
      return Left(Failure.serverFailure(message: e.message));
    } catch (e) {
      return Left(Failure.unknownFailure(message: e.toString()));
    }
  }
  
  // Sign in with email and password
  Future<Either<Failure, UserModel>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user == null) {
        return const Left(
          Failure.authenticationFailure(message: 'Échec de la connexion'),
        );
      }
      
      final userResponse = await _supabase
          .from('users')
          .select()
          .eq('id', response.user!.id)
          .single();
      
      final user = UserModel.fromJson(userResponse);
      return Right(user);
    } on AuthException catch (e) {
      return Left(Failure.authenticationFailure(message: e.message));
    } on PostgrestException catch (e) {
      return Left(Failure.serverFailure(message: e.message));
    } catch (e) {
      return Left(Failure.unknownFailure(message: e.toString()));
    }
  }
  
  // Sign up with email and password
  Future<Either<Failure, UserModel>> signUpWithEmail({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
        },
      );
      
      if (response.user == null) {
        return const Left(
          Failure.authenticationFailure(message: 'Échec de l\'inscription'),
        );
      }
      
      // Create user profile in users table
      final userProfile = {
        'id': response.user!.id,
        'email': email,
        'full_name': fullName,
        'plan': 'free',
        'created_at': DateTime.now().toIso8601String(),
      };
      
      await _supabase.from('users').insert(userProfile);
      
      final user = UserModel(
        id: response.user!.id,
        email: email,
        fullName: fullName,
        plan: 'free',
        createdAt: DateTime.now(),
      );
      
      return Right(user);
    } on AuthException catch (e) {
      return Left(Failure.authenticationFailure(message: e.message));
    } on PostgrestException catch (e) {
      return Left(Failure.serverFailure(message: e.message));
    } catch (e) {
      return Left(Failure.unknownFailure(message: e.toString()));
    }
  }
  
  // Sign in with Google
  Future<Either<Failure, UserModel>> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return const Left(
          Failure.authenticationFailure(message: 'Connexion Google annulée'),
        );
      }
      
      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;
      
      if (accessToken == null || idToken == null) {
        return const Left(
          Failure.authenticationFailure(message: 'Échec de l\'authentification Google'),
        );
      }
      
      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
      
      if (response.user == null) {
        return const Left(
          Failure.authenticationFailure(message: 'Échec de la connexion'),
        );
      }
      
      // Check if user profile exists, create if not
      final existingUser = await _supabase
          .from('users')
          .select()
          .eq('id', response.user!.id)
          .maybeSingle();
      
      if (existingUser == null) {
        final userProfile = {
          'id': response.user!.id,
          'email': response.user!.email,
          'full_name': googleUser.displayName,
          'avatar_url': googleUser.photoUrl,
          'plan': 'free',
          'created_at': DateTime.now().toIso8601String(),
        };
        
        await _supabase.from('users').insert(userProfile);
      }
      
      final userResponse = await _supabase
          .from('users')
          .select()
          .eq('id', response.user!.id)
          .single();
      
      final user = UserModel.fromJson(userResponse);
      return Right(user);
    } catch (e) {
      return Left(Failure.authenticationFailure(message: e.toString()));
    }
  }
  
  // Sign in with Apple
  Future<Either<Failure, UserModel>> signInWithApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      
      final idToken = credential.identityToken;
      if (idToken == null) {
        return const Left(
          Failure.authenticationFailure(message: 'Échec de l\'authentification Apple'),
        );
      }
      
      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
      );
      
      if (response.user == null) {
        return const Left(
          Failure.authenticationFailure(message: 'Échec de la connexion'),
        );
      }
      
      // Check if user profile exists, create if not
      final existingUser = await _supabase
          .from('users')
          .select()
          .eq('id', response.user!.id)
          .maybeSingle();
      
      if (existingUser == null) {
        final fullName = credential.givenName != null && credential.familyName != null
            ? '${credential.givenName} ${credential.familyName}'
            : null;
        
        final userProfile = {
          'id': response.user!.id,
          'email': credential.email ?? response.user!.email,
          'full_name': fullName,
          'plan': 'free',
          'created_at': DateTime.now().toIso8601String(),
        };
        
        await _supabase.from('users').insert(userProfile);
      }
      
      final userResponse = await _supabase
          .from('users')
          .select()
          .eq('id', response.user!.id)
          .single();
      
      final user = UserModel.fromJson(userResponse);
      return Right(user);
    } catch (e) {
      return Left(Failure.authenticationFailure(message: e.toString()));
    }
  }
  
  // Reset password
  Future<Either<Failure, void>> resetPassword({
    required String email,
  }) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(Failure.authenticationFailure(message: e.message));
    } catch (e) {
      return Left(Failure.unknownFailure(message: e.toString()));
    }
  }
  
  // Sign out
  Future<Either<Failure, void>> signOut() async {
    try {
      await _supabase.auth.signOut();
      await _googleSignIn.signOut();
      return const Right(null);
    } catch (e) {
      return Left(Failure.authenticationFailure(message: e.toString()));
    }
  }
  
  // Update user profile
  Future<Either<Failure, UserModel>> updateProfile({
    String? fullName,
    String? avatarUrl,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        return const Left(
          Failure.authenticationFailure(message: 'Utilisateur non connecté'),
        );
      }
      
      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      if (fullName != null) updates['full_name'] = fullName;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
      
      await _supabase.from('users').update(updates).eq('id', userId);
      
      final userResponse = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single();
      
      final user = UserModel.fromJson(userResponse);
      return Right(user);
    } on PostgrestException catch (e) {
      return Left(Failure.serverFailure(message: e.message));
    } catch (e) {
      return Left(Failure.unknownFailure(message: e.toString()));
    }
  }
  
  // Listen to auth state changes
  Stream<UserModel?> get authStateChanges {
    return _supabase.auth.onAuthStateChange.asyncMap((event) async {
      final user = event.session?.user;
      if (user == null) return null;
      
      try {
        final response = await _supabase
            .from('users')
            .select()
            .eq('id', user.id)
            .single();
        
        return UserModel.fromJson(response);
      } catch (e) {
        return null;
      }
    });
  }
}
