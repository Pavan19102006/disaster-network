import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../config/constants.dart';
import '../../models/enums.dart';
import '../../models/mesh_message.dart';
import '../../models/sos_signal.dart';
import '../mesh/mesh_service.dart';
import '../mesh/mesh_router.dart';

/// SOS broadcasting and receiving service.
///
/// Handles sending periodic SOS broadcasts, receiving SOS signals,
/// and managing acknowledgments ("I'm Coming" responses).
class SOSService {
  static final SOSService _instance = SOSService._();
  static SOSService get instance => _instance;
  SOSService._();

  final _meshService = MeshService.instance;
  final _meshRouter = MeshRouter.instance;

  Timer? _broadcastTimer;
  SOSSignal? _activeSignal;
  final Map<String, SOSSignal> _receivedSignals = {};

  // Stream controllers
  final _sosStatusController = StreamController<SOSStatus>.broadcast();
  final _receivedSOSController = StreamController<SOSSignal>.broadcast();
  final _sosAckController = StreamController<String>.broadcast();

  // Public streams
  Stream<SOSStatus> get onStatusChanged => _sosStatusController.stream;
  Stream<SOSSignal> get onSOSReceived => _receivedSOSController.stream;
  Stream<String> get onSOSAcknowledged => _sosAckController.stream;

  // State
  SOSSignal? get activeSignal => _activeSignal;
  bool get isBroadcasting => _activeSignal != null;
  Map<String, SOSSignal> get receivedSignals =>
      Map.unmodifiable(_receivedSignals);

  /// Start broadcasting an SOS signal.
  Future<void> startSOS({
    required EmergencyType type,
    required double latitude,
    required double longitude,
    String? description,
    String? senderName,
  }) async {
    final signal = SOSSignal(
      id: const Uuid().v4(),
      senderId: _meshService.currentUserId ?? 'unknown',
      senderName: senderName ?? 'User',
      emergencyType: type,
      latitude: latitude,
      longitude: longitude,
      timestamp: DateTime.now(),
      description: description,
    );

    _activeSignal = signal;
    _sosStatusController.add(SOSStatus.broadcasting);

    // Send initial broadcast
    await _broadcastSOS();

    // Set up periodic re-broadcast
    _broadcastTimer = Timer.periodic(
      AppConstants.sosBroadcastInterval,
      (_) => _broadcastSOS(),
    );

    debugPrint(
        '[SOSService] SOS started: ${type.label} at ($latitude, $longitude)');
  }

  /// Stop broadcasting SOS.
  void stopSOS() {
    _broadcastTimer?.cancel();
    _broadcastTimer = null;
    _activeSignal = null;
    _sosStatusController.add(SOSStatus.resolved);
    debugPrint('[SOSService] SOS stopped');
  }

  /// Send "I'm Coming" acknowledgment for a received SOS.
  Future<void> acknowledgeSOS(String sosId) async {
    final signal = _receivedSignals[sosId];
    if (signal == null) return;

    final message = _meshRouter.prepareMessage(
      type: MessageType.sosAck,
      senderId: _meshService.currentUserId ?? 'unknown',
      senderName: 'User',
      payload: {
        'sosId': sosId,
        'responderId': _meshService.currentUserId,
      },
      ttl: AppConstants.sosMaxHops,
    );

    await _meshService.sendBroadcast(message);
    debugPrint('[SOSService] Acknowledged SOS: $sosId');
  }

  /// Handle incoming SOS message from mesh network.
  void handleIncomingMessage(MeshMessage message) {
    if (message.type == MessageType.sos) {
      _handleSOSSignal(message);
    } else if (message.type == MessageType.sosAck) {
      _handleSOSAck(message);
    }
  }

  void _handleSOSSignal(MeshMessage message) {
    try {
      final signal = SOSSignal.fromJson(message.payload);

      // Don't alert for own SOS
      if (signal.senderId == _meshService.currentUserId) return;

      // Update or add signal
      _receivedSignals[signal.id] = signal;
      _receivedSOSController.add(signal);

      debugPrint(
          '[SOSService] Received SOS from ${signal.senderName}: ${signal.emergencyType.label}');
    } catch (e) {
      debugPrint('[SOSService] Error parsing SOS: $e');
    }
  }

  void _handleSOSAck(MeshMessage message) {
    final sosId = message.payload['sosId'] as String?;
    if (sosId == null) return;

    // If this is an ack for our SOS
    if (_activeSignal?.id == sosId) {
      _activeSignal = _activeSignal!.copyWith(
        status: SOSStatus.acknowledged,
        acknowledgedBy: [
          ..._activeSignal!.acknowledgedBy,
          message.senderId,
        ],
      );
      _sosStatusController.add(SOSStatus.acknowledged);
      _sosAckController.add(message.senderId);
      debugPrint('[SOSService] Our SOS acknowledged by ${message.senderId}');
    }
  }

  Future<void> _broadcastSOS() async {
    if (_activeSignal == null) return;

    final message = _meshRouter.prepareMessage(
      type: MessageType.sos,
      senderId: _activeSignal!.senderId,
      senderName: _activeSignal!.senderName,
      payload: _activeSignal!.toJson(),
      ttl: AppConstants.sosMaxHops,
    );

    await _meshService.sendBroadcast(message);
  }

  /// Clean up resources.
  void dispose() {
    stopSOS();
    _sosStatusController.close();
    _receivedSOSController.close();
    _sosAckController.close();
  }
}
