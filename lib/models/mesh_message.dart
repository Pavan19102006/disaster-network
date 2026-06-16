import 'dart:convert';
import 'dart:typed_data';
import 'package:uuid/uuid.dart';
import 'enums.dart';

/// Represents a message transmitted through the mesh network.
///
/// Messages are serialized to JSON for WiFi Direct / nearby_connections,
/// and to compact bytes for BLE / Bridgefy transmission.
class MeshMessage {
  final String id;
  final MessageType type;
  final int ttl;
  final int hopCount;
  final DateTime timestamp;
  final String senderId;
  final String senderName;
  final Map<String, dynamic> payload;
  final List<String> visitedNodes;

  MeshMessage({
    String? id,
    required this.type,
    this.ttl = 5,
    this.hopCount = 0,
    DateTime? timestamp,
    required this.senderId,
    this.senderName = 'Unknown',
    required this.payload,
    List<String>? visitedNodes,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now(),
        visitedNodes = visitedNodes ?? [];

  /// Create a copy with incremented hop count for relaying
  MeshMessage relay(String relayNodeId) {
    return MeshMessage(
      id: id,
      type: type,
      ttl: ttl - 1,
      hopCount: hopCount + 1,
      timestamp: timestamp,
      senderId: senderId,
      senderName: senderName,
      payload: payload,
      visitedNodes: [...visitedNodes, relayNodeId],
    );
  }

  /// Check if this message should still be relayed
  bool get shouldRelay => ttl > 0;

  /// Check if a node has already seen this message
  bool hasVisited(String nodeId) => visitedNodes.contains(nodeId);

  /// Serialize to JSON map
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'ttl': ttl,
        'hopCount': hopCount,
        'timestamp': timestamp.toIso8601String(),
        'senderId': senderId,
        'senderName': senderName,
        'payload': payload,
        'visitedNodes': visitedNodes,
      };

  /// Deserialize from JSON map
  factory MeshMessage.fromJson(Map<String, dynamic> json) {
    return MeshMessage(
      id: json['id'] as String,
      type: MessageType.values.firstWhere((e) => e.name == json['type']),
      ttl: json['ttl'] as int,
      hopCount: json['hopCount'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
      senderId: json['senderId'] as String,
      senderName: (json['senderName'] as String?) ?? 'Unknown',
      payload: Map<String, dynamic>.from(json['payload'] as Map),
      visitedNodes: List<String>.from(json['visitedNodes'] as List),
    );
  }

  /// Serialize to bytes for BLE transmission
  Uint8List toBytes() {
    final jsonStr = jsonEncode(toJson());
    return Uint8List.fromList(utf8.encode(jsonStr));
  }

  /// Deserialize from bytes
  factory MeshMessage.fromBytes(Uint8List bytes) {
    final jsonStr = utf8.decode(bytes);
    return MeshMessage.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
  }

  @override
  String toString() =>
      'MeshMessage(id: $id, type: ${type.name}, ttl: $ttl, hops: $hopCount)';
}
