import 'enums.dart';

/// Represents an SOS distress signal broadcast through the mesh.
class SOSSignal {
  final String id;
  final String senderId;
  final String senderName;
  final EmergencyType emergencyType;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final SOSStatus status;
  final String? description;
  final List<String> acknowledgedBy;
  final int hopCount;

  const SOSSignal({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.emergencyType,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.status = SOSStatus.broadcasting,
    this.description,
    this.acknowledgedBy = const [],
    this.hopCount = 0,
  });

  SOSSignal copyWith({
    SOSStatus? status,
    List<String>? acknowledgedBy,
  }) {
    return SOSSignal(
      id: id,
      senderId: senderId,
      senderName: senderName,
      emergencyType: emergencyType,
      latitude: latitude,
      longitude: longitude,
      timestamp: timestamp,
      status: status ?? this.status,
      description: description,
      acknowledgedBy: acknowledgedBy ?? this.acknowledgedBy,
      hopCount: hopCount,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'senderId': senderId,
        'senderName': senderName,
        'emergencyType': emergencyType.name,
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': timestamp.toIso8601String(),
        'status': status.name,
        'description': description,
        'acknowledgedBy': acknowledgedBy,
        'hopCount': hopCount,
      };

  factory SOSSignal.fromJson(Map<String, dynamic> json) {
    return SOSSignal(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      senderName: (json['senderName'] as String?) ?? 'Unknown',
      emergencyType: EmergencyType.values
          .firstWhere((e) => e.name == json['emergencyType']),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      status: SOSStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SOSStatus.broadcasting,
      ),
      description: json['description'] as String?,
      acknowledgedBy:
          List<String>.from((json['acknowledgedBy'] as List?) ?? []),
      hopCount: (json['hopCount'] as int?) ?? 0,
    );
  }

  /// Time elapsed since SOS was sent
  Duration get elapsed => DateTime.now().difference(timestamp);

  /// Human-readable elapsed time
  String get elapsedText {
    final d = elapsed;
    if (d.inSeconds < 60) return '${d.inSeconds}s ago';
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    if (d.inHours < 24) return '${d.inHours}h ago';
    return '${d.inDays}d ago';
  }
}
