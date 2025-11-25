import 'package:freezed_annotation/freezed_annotation.dart';

part 'failures.freezed.dart';

@freezed
class Failure with _$Failure {
  const factory Failure.serverFailure({
    required String message,
  }) = ServerFailure;
  
  const factory Failure.cacheFailure({
    required String message,
  }) = CacheFailure;
  
  const factory Failure.networkFailure({
    required String message,
  }) = NetworkFailure;
  
  const factory Failure.authenticationFailure({
    required String message,
  }) = AuthenticationFailure;
  
  const factory Failure.validationFailure({
    required String message,
  }) = ValidationFailure;
  
  const factory Failure.permissionFailure({
    required String message,
  }) = PermissionFailure;
  
  const factory Failure.notFoundFailure({
    required String message,
  }) = NotFoundFailure;
  
  const factory Failure.storageFailure({
    required String message,
  }) = StorageFailure;
  
  const factory Failure.gpsFailure({
    required String message,
  }) = GpsFailure;
  
  const factory Failure.subscriptionFailure({
    required String message,
  }) = SubscriptionFailure;
  
  const factory Failure.unknownFailure({
    required String message,
  }) = UnknownFailure;
}

// Extension to get user-friendly messages
extension FailureX on Failure {
  String get userMessage {
    return when(
      serverFailure: (message) => 'Erreur serveur: $message',
      cacheFailure: (message) => 'Erreur de cache: $message',
      networkFailure: (message) => 'Erreur réseau: $message',
      authenticationFailure: (message) => 'Erreur d\'authentification: $message',
      validationFailure: (message) => 'Erreur de validation: $message',
      permissionFailure: (message) => 'Permission refusée: $message',
      notFoundFailure: (message) => 'Non trouvé: $message',
      storageFailure: (message) => 'Erreur de stockage: $message',
      gpsFailure: (message) => 'Erreur GPS: $message',
      subscriptionFailure: (message) => 'Erreur d\'abonnement: $message',
      unknownFailure: (message) => 'Erreur inconnue: $message',
    );
  }
}
