import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../config/constants.dart';
import '../../models/enums.dart';
import '../../models/mesh_message.dart';

/// Mesh router implementing flood-fill routing with TTL, hop counting,
/// deduplication, and store-and-forward for offline peers.
class MeshRouter {
  static final MeshRouter _instance = MeshRouter._();
  static MeshRouter get instance => _instance;
  MeshRouter._();

  // Seen message IDs for deduplication (prevents infinite loops)
  final Set<String> _seenMessageIds = {};

  // Message queue for store-and-forward
  final List<MeshMessage> _messageQueue = [];

  // Callback for forwarding messages
  void Function(MeshMessage message)? onForwardMessage;

  /// Process an incoming message through the router.
  ///
  /// Returns true if the message is new and should be handled,
  /// false if it's a duplicate.
  bool processIncoming(MeshMessage message) {
    // 1. Deduplication check
    if (_seenMessageIds.contains(message.id)) {
      debugPrint('[MeshRouter] Duplicate: ${message.id}');
      return false;
    }

    // 2. Mark as seen
    _seenMessageIds.add(message.id);

    // 3. Evict old IDs if set grows too large (memory management)
    if (_seenMessageIds.length > 10000) {
      final toRemove = _seenMessageIds.take(5000).toList();
      _seenMessageIds.removeAll(toRemove);
    }

    // 4. Check if should relay
    if (message.shouldRelay) {
      _scheduleRelay(message);
    }

    return true;
  }

  /// Create a message ready for initial broadcast.
  MeshMessage prepareMessage({
    required MessageType type,
    required String senderId,
    required String senderName,
    required Map<String, dynamic> payload,
    int? ttl,
  }) {
    final message = MeshMessage(
      type: type,
      ttl: ttl ?? (type == MessageType.sos
          ? AppConstants.sosMaxHops
          : AppConstants.defaultTTL),
      senderId: senderId,
      senderName: senderName,
      payload: payload,
    );

    _seenMessageIds.add(message.id);
    return message;
  }

  /// Queue a message for store-and-forward.
  /// When new peers connect, queued messages will be forwarded.
  void queueForForward(MeshMessage message) {
    _messageQueue.add(message);

    // Limit queue size
    if (_messageQueue.length > 500) {
      _messageQueue.removeRange(0, 250);
    }
  }

  /// Get queued messages for a newly connected peer.
  List<MeshMessage> getQueuedMessages() {
    return List.unmodifiable(_messageQueue);
  }

  /// Clear the message queue.
  void clearQueue() {
    _messageQueue.clear();
  }

  /// Schedule a message for relay after a short random delay
  /// to avoid network congestion.
  void _scheduleRelay(MeshMessage message) {
    // Small random delay (100-500ms) to prevent all nodes relaying simultaneously
    final delay = Duration(
        milliseconds: 100 + (DateTime.now().millisecond % 400));

    Timer(delay, () {
      onForwardMessage?.call(message);
    });
  }

  /// Check if a message has been seen before.
  bool hasBeenSeen(String messageId) => _seenMessageIds.contains(messageId);

  /// Get router stats for debugging.
  Map<String, int> get stats => {
        'seenMessages': _seenMessageIds.length,
        'queuedMessages': _messageQueue.length,
      };

  /// Reset the router (for testing or reinitialization).
  void reset() {
    _seenMessageIds.clear();
    _messageQueue.clear();
  }
}
