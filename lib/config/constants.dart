class AppConstants {
  AppConstants._();

  // App
  static const String appName = 'DisasterNet';
  static const String appVersion = '1.0.0';

  // Bridgefy
  static const String bridgefyApiKey = 'YOUR_BRIDGEFY_API_KEY'; // Replace with real key
  static const String meshServiceId = 'com.disasternetwork.mesh';

  // Mesh networking
  static const int defaultTTL = 5;
  static const int maxMessageSize = 256; // Bridgefy BLE limit ~256 bytes
  static const int nearbyMaxPayload = 32768; // 32KB for nearby_connections
  static const Duration peerTimeout = Duration(minutes: 5);
  static const Duration sosBroadcastInterval = Duration(seconds: 30);
  static const Duration locationShareInterval = Duration(seconds: 60);
  static const Duration peerDiscoveryInterval = Duration(seconds: 15);

  // SOS
  static const Duration sosHoldDuration = Duration(seconds: 3);
  static const int sosMaxHops = 10;

  // Alerts
  static const Duration alertDefaultExpiry = Duration(hours: 24);
  static const int maxAlertDescriptionLength = 500;

  // Location
  static const double locationAccuracyThreshold = 50.0;
  static const Duration locationUpdateInterval = Duration(seconds: 30);

  // UI
  static const double cardBorderRadius = 16.0;
  static const double buttonBorderRadius = 12.0;
  static const double glassOpacity = 0.05;
  static const double glassBorderOpacity = 0.1;
  static const double blurSigma = 20.0;
}
