import 'enums.dart';

/// Information about a discovered peer device in the mesh network.
class PeerInfo {
  final String id;
  final String name;
  final PeerConnectionStatus status;
  final TransportType transport;
  final double? latitude;
  final double? longitude;
  final DateTime lastSeen;
  final int? signalStrength;
  final double? distanceMeters;
  final bool isSOSActive;

  const PeerInfo({
    required this.id,
    required this.name,
    this.status = PeerConnectionStatus.discovered,
    this.transport = TransportType.ble,
    this.latitude,
    this.longitude,
    required this.lastSeen,
    this.signalStrength,
    this.distanceMeters,
    this.isSOSActive = false,
  });

  PeerInfo copyWith({
    String? id,
    String? name,
    PeerConnectionStatus? status,
    TransportType? transport,
    double? latitude,
    double? longitude,
    DateTime? lastSeen,
    int? signalStrength,
    double? distanceMeters,
    bool? isSOSActive,
  }) {
    return PeerInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      transport: transport ?? this.transport,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      lastSeen: lastSeen ?? this.lastSeen,
      signalStrength: signalStrength ?? this.signalStrength,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      isSOSActive: isSOSActive ?? this.isSOSActive,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'status': status.name,
        'transport': transport.name,
        'latitude': latitude,
        'longitude': longitude,
        'lastSeen': lastSeen.toIso8601String(),
        'signalStrength': signalStrength,
        'distanceMeters': distanceMeters,
        'isSOSActive': isSOSActive,
      };

  factory PeerInfo.fromJson(Map<String, dynamic> json) {
    return PeerInfo(
      id: json['id'] as String,
      name: json['name'] as String,
      status: PeerConnectionStatus.values
          .firstWhere((e) => e.name == json['status']),
      transport:
          TransportType.values.firstWhere((e) => e.name == json['transport']),
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      lastSeen: DateTime.parse(json['lastSeen'] as String),
      signalStrength: json['signalStrength'] as int?,
      distanceMeters: json['distanceMeters'] as double?,
      isSOSActive: (json['isSOSActive'] as bool?) ?? false,
    );
  }

  /// Human-readable signal quality based on RSSI
  String get signalQuality {
    if (signalStrength == null) return 'Unknown';
    if (signalStrength! >= -50) return 'Excellent';
    if (signalStrength! >= -70) return 'Good';
    if (signalStrength! >= -85) return 'Fair';
    return 'Weak';
  }

  bool get hasLocation => latitude != null && longitude != null;
}
