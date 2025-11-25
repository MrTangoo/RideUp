class EnvConfig {
  // Supabase Configuration
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://your-project.supabase.co',
  );
  
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'your-anon-key',
  );
  
  // Google Maps API Keys
  static const String googleMapsApiKeyAndroid = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY_ANDROID',
    defaultValue: '',
  );
  
  static const String googleMapsApiKeyIOS = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY_IOS',
    defaultValue: '',
  );
  
  // Google Sign-In
  static const String googleClientIdIOS = String.fromEnvironment(
    'GOOGLE_CLIENT_ID_IOS',
    defaultValue: '',
  );
  
  static const String googleClientIdAndroid = String.fromEnvironment(
    'GOOGLE_CLIENT_ID_ANDROID',
    defaultValue: '',
  );
  
  // Firebase
  static const String firebaseProjectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
    defaultValue: '',
  );
  
  // App Configuration
  static const String appName = String.fromEnvironment(
    'APP_NAME',
    defaultValue: 'RideUp',
  );
  
  static const String appVersion = String.fromEnvironment(
    'APP_VERSION',
    defaultValue: '1.0.0',
  );
}
