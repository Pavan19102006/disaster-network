/// Types of messages in the mesh network
enum MessageType {
  sos,
  location,
  alert,
  chat,
  peerDiscovery,
  ack,
  sosAck,
}

/// Emergency types for SOS signals
enum EmergencyType {
  medical('Medical Emergency', '🏥'),
  fire('Fire', '🔥'),
  trapped('Trapped/Stuck', '🆘'),
  flood('Flood', '🌊'),
  earthquake('Earthquake', '⚡'),
  general('General Emergency', '🚨');

  const EmergencyType(this.label, this.emoji);
  final String label;
  final String emoji;
}

/// Categories for community alerts
enum AlertCategory {
  dangerZone('Danger Zone', '⚠️'),
  safeZone('Safe Zone', '✅'),
  supplies('Supplies Available', '📦'),
  shelter('Shelter', '🏠'),
  roadBlocked('Road Blocked', '🚧'),
  rescueNeeded('Rescue Needed', '🚁'),
  waterSource('Water Source', '💧'),
  medicalCamp('Medical Camp', '⛑️');

  const AlertCategory(this.label, this.emoji);
  final String label;
  final String emoji;
}

/// Alert priority levels
enum AlertPriority {
  critical,
  high,
  medium,
  low,
}

/// Peer connection status
enum PeerConnectionStatus {
  discovered,
  connecting,
  connected,
  disconnected,
}

/// Connection transport type
enum TransportType {
  ble,
  wifiDirect,
  multipeer,
  nearby,
}

/// Message delivery status
enum DeliveryStatus {
  queued,
  sending,
  sent,
  delivered,
  read,
  failed,
}

/// Location sharing mode
enum LocationMode {
  highAccuracy('High Accuracy', 'Updates every 10s'),
  balanced('Balanced', 'Updates every 30s'),
  batterySaver('Battery Saver', 'Updates every 60s');

  const LocationMode(this.label, this.description);
  final String label;
  final String description;
}

/// SOS broadcast status
enum SOSStatus {
  inactive,
  broadcasting,
  acknowledged,
  resolved,
}
