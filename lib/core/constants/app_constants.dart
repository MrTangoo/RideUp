class AppConstants {
  // Freemium Limits
  static const int freeMaxHorses = 1;
  static const int premiumMaxHorses = 999;
  
  // Gait Detection Speed Thresholds (km/h)
  static const double walkMaxSpeed = 7.0;
  static const double trotMaxSpeed = 15.0;
  static const double gallopMinSpeed = 15.0;
  
  // GPS Tracking
  static const int gpsUpdateIntervalMs = 2000; // 2 seconds
  static const int gpsBatchSize = 10; // Send every 10 points
  static const double gpsMinDistanceMeters = 5.0; // Minimum distance for new point
  
  // Activity Calculations
  static const double caloriesPerKmWalk = 3.5;
  static const double caloriesPerKmTrot = 5.0;
  static const double caloriesPerKmGallop = 7.5;
  
  // Workload Calculation (0-100 scale)
  static const double workloadLightThreshold = 30.0;
  static const double workloadModerateThreshold = 60.0;
  static const double workloadIntenseThreshold = 80.0;
  
  // Recovery Recommendations (hours)
  static const int recoveryLightWorkload = 12;
  static const int recoveryModerateWorkload = 24;
  static const int recoveryIntenseWorkload = 48;
  
  // Health Event Types
  static const List<String> healthEventTypes = [
    'Vaccination',
    'Farrier',
    'Veterinary Visit',
    'Dental Care',
    'Deworming',
    'Other',
  ];
  
  // Health Event Intervals (days)
  static const Map<String, int> healthEventIntervals = {
    'Vaccination': 365,
    'Farrier': 42, // 6 weeks
    'Dental Care': 180, // 6 months
    'Deworming': 90, // 3 months
  };
  
  // Planning Event Types
  static const List<String> planningEventTypes = [
    'Training',
    'Rest Day',
    'Competition',
    'Veterinary Appointment',
    'Farrier Appointment',
    'Other',
  ];
  
  // Document Types
  static const List<String> documentTypes = [
    'Medical Record',
    'Vaccination Certificate',
    'Insurance',
    'Registration Papers',
    'Other',
  ];
  
  // Notification Channels
  static const String notificationChannelId = 'rideup_notifications';
  static const String notificationChannelName = 'RideUp Notifications';
  static const String notificationChannelDescription = 'Notifications for health events and reminders';
  
  // Image Compression
  static const int maxImageWidth = 1920;
  static const int maxImageHeight = 1080;
  static const int imageQuality = 85;
  
  // Pagination
  static const int defaultPageSize = 20;
  
  // Cache Duration
  static const Duration cacheDuration = Duration(hours: 1);
  
  // Sync Intervals
  static const Duration syncInterval = Duration(minutes: 5);
  
  // Map Settings
  static const double defaultMapZoom = 15.0;
  static const double trackingMapZoom = 17.0;
}
