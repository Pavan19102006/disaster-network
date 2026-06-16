import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:bridgefy/bridgefy.dart';
import 'package:uuid/uuid.dart';
import '../../config/constants.dart';
import '../../models/enums.dart';
import '../../models/mesh_message.dart';
import '../../models/peer_info.dart';

/// Core mesh networking service wrapping Bridgefy SDK.
///
/// Handles initialization, peer discovery, message sending/receiving,
/// and broadcast/direct messaging via BLE mesh.
class MeshService {
  static final MeshService _instance = MeshService._();
  static MeshService get instance => _instance;
  MeshService._();

  final Bridgefy _bridgefy = Bridgefy();
  String? _currentUserId;
  bool _isStarted = false;

  // Stream controllers for reactive UI
  final _peerConnectedController = StreamController<String>.broadcast();
  final _peerDisconnectedController = StreamController<String>.broadcast();
  final _messageReceivedController =
      StreamController<MeshMessage>.broadcast();
  final _messageSentController = StreamController<String>.broadcast();
  final _messageFailedController = StreamController<String>.broadcast();

  // Connected peers tracking
  final Map<String, PeerInfo> _connectedPeers = {};

  // Seen message IDs for deduplication
  final Set<String> _seenMessageIds = {};

  // Public streams
  Stream<String> get onPeerConnected => _peerConnectedController.stream;
  Stream<String> get onPeerDisconnected => _peerDisconnectedController.stream;
  Stream<MeshMessage> get onMessageReceived =>
      _messageReceivedController.stream;
  Stream<String> get onMessageSent => _messageSentController.stream;
  Stream<String> get onMessageFailed => _messageFailedController.stream;

  // State
  String? get currentUserId => _currentUserId;
  bool get isStarted => _isStarted;
  Map<String, PeerInfo> get connectedPeers => Map.unmodifiable(_connectedPeers);
  int get peerCount => _connectedPeers.length;

  /// Initialize Bridgefy SDK with API key.
  /// Requires internet for first-time API key validation only.
  Future<void> initialize() async {
    try {
      await _bridgefy.initialize(
        apiKey: AppConstants.bridgefyApiKey,
        delegate: _BridgefyDelegateImpl(this),
        verboseLogging: kDebugMode,
      );
      debugPrint('[MeshService] Bridgefy initialized');
    } catch (e) {
      debugPrint('[MeshService] Init failed: $e');
      rethrow;
    }
  }

  /// Start the mesh network.
  Future<void> start({String? userName}) async {
    try {
      _currentUserId = const Uuid().v4();
      await _bridgefy.start(
        userId: _currentUserId!,
        propagationProfile: BridgefyPropagationProfile.standard,
      );
      _isStarted = true;
      debugPrint('[MeshService] Started with userId: $_currentUserId');
    } catch (e) {
      debugPrint('[MeshService] Start failed: $e');
      rethrow;
    }
  }

  /// Stop the mesh network.
  Future<void> stop() async {
    try {
      await _bridgefy.stop();
      _isStarted = false;
      _connectedPeers.clear();
      debugPrint('[MeshService] Stopped');
    } catch (e) {
      debugPrint('[MeshService] Stop failed: $e');
    }
  }

  /// Send a broadcast message to all peers in the mesh.
  Future<String?> sendBroadcast(MeshMessage message) async {
    try {
      final data = message.toBytes();

      // Bridgefy has ~256 byte limit; check size
      if (data.length > AppConstants.maxMessageSize) {
        debugPrint(
            '[MeshService] Message too large for BLE: ${data.length} bytes');
        return null;
      }

      final messageId = await _bridgefy.send(
        data: data,
        transmissionMode: BridgefyTransmissionMode(
          type: BridgefyTransmissionModeType.broadcast,
          uuid: _currentUserId!,
        ),
      );

      _seenMessageIds.add(message.id);
      _messageSentController.add(messageId);
      debugPrint('[MeshService] Broadcast sent: ${message.type.name}');
      return messageId;
    } catch (e) {
      debugPrint('[MeshService] Broadcast failed: $e');
      _messageFailedController.add(message.id);
      return null;
    }
  }

  /// Send a direct message to a specific peer.
  Future<String?> sendDirect(MeshMessage message, String recipientId) async {
    try {
      final data = message.toBytes();

      if (data.length > AppConstants.maxMessageSize) {
        debugPrint(
            '[MeshService] Message too large for BLE: ${data.length} bytes');
        return null;
      }

      final messageId = await _bridgefy.send(
        data: data,
        transmissionMode: BridgefyTransmissionMode(
          type: BridgefyTransmissionModeType.p2p,
          uuid: recipientId,
        ),
      );

      _seenMessageIds.add(message.id);
      _messageSentController.add(messageId);
      debugPrint('[MeshService] Direct sent to $recipientId');
      return messageId;
    } catch (e) {
      debugPrint('[MeshService] Direct send failed: $e');
      _messageFailedController.add(message.id);
      return null;
    }
  }

  /// Handle incoming data from Bridgefy delegate
  void _handleReceivedData(Uint8List data, String messageId,
      BridgefyTransmissionMode transmissionMode) {
    try {
      final message = MeshMessage.fromBytes(data);

      // Deduplication
      if (_seenMessageIds.contains(message.id)) {
        debugPrint('[MeshService] Duplicate message ignored: ${message.id}');
        return;
      }

      _seenMessageIds.add(message.id);
      _messageReceivedController.add(message);
      debugPrint(
          '[MeshService] Received: ${message.type.name} from ${message.senderId} via ${transmissionMode.type.name}');

      // Auto-relay if TTL > 0 (mesh relay)
      if (message.shouldRelay && _currentUserId != null) {
        final relayed = message.relay(_currentUserId!);
        sendBroadcast(relayed);
        debugPrint(
            '[MeshService] Relayed message ${message.id} (TTL: ${relayed.ttl})');
      }
    } catch (e) {
      debugPrint('[MeshService] Error parsing received data: $e');
    }
  }

  void _handlePeerConnected(String userId) {
    _connectedPeers[userId] = PeerInfo(
      id: userId,
      name: 'Peer ${userId.substring(0, 6)}',
      status: PeerConnectionStatus.connected,
      transport: TransportType.ble,
      lastSeen: DateTime.now(),
    );
    _peerConnectedController.add(userId);
    debugPrint('[MeshService] Peer connected: $userId');
  }

  void _handlePeerDisconnected(String userId) {
    _connectedPeers.remove(userId);
    _peerDisconnectedController.add(userId);
    debugPrint('[MeshService] Peer disconnected: $userId');
  }

  /// Clean up resources
  void dispose() {
    _peerConnectedController.close();
    _peerDisconnectedController.close();
    _messageReceivedController.close();
    _messageSentController.close();
    _messageFailedController.close();
    stop();
  }
}

/// Bridgefy delegate implementation — matches the exact mixin BridgefyDelegate API
class _BridgefyDelegateImpl with BridgefyDelegate {
  final MeshService _service;

  _BridgefyDelegateImpl(this._service);

  @override
  void bridgefyDidConnect({required String userID}) {
    _service._handlePeerConnected(userID);
  }

  @override
  void bridgefyDidDisconnect({required String userID}) {
    _service._handlePeerDisconnected(userID);
  }

  @override
  void bridgefyDidReceiveData({
    required Uint8List data,
    required String messageId,
    required BridgefyTransmissionMode transmissionMode,
  }) {
    _service._handleReceivedData(data, messageId, transmissionMode);
  }

  @override
  void bridgefyDidSendMessage({required String messageID}) {
    _service._messageSentController.add(messageID);
  }

  @override
  void bridgefyDidFailSendingMessage(
      {required String messageID, BridgefyError? error}) {
    debugPrint('[Bridgefy] Failed to send $messageID: $error');
    _service._messageFailedController.add(messageID);
  }

  @override
  void bridgefyDidStart({required String currentUserID}) {
    debugPrint('[Bridgefy] Started with ID: $currentUserID');
  }

  @override
  void bridgefyDidFailToStart({required BridgefyError error}) {
    debugPrint('[Bridgefy] Failed to start: $error');
  }

  @override
  void bridgefyDidStop() {
    debugPrint('[Bridgefy] Stopped');
  }

  @override
  void bridgefyDidFailToStop({required BridgefyError error}) {
    debugPrint('[Bridgefy] Failed to stop: $error');
  }

  @override
  void bridgefyDidDestroySession() {
    debugPrint('[Bridgefy] Session destroyed');
  }

  @override
  void bridgefyDidFailToDestroySession() {
    debugPrint('[Bridgefy] Failed to destroy session');
  }

  @override
  void bridgefyDidEstablishSecureConnection({required String userID}) {
    debugPrint('[Bridgefy] Secure connection established with: $userID');
  }

  @override
  void bridgefyDidFailToEstablishSecureConnection(
      {required String userID, required BridgefyError error}) {
    debugPrint(
        '[Bridgefy] Failed secure connection with $userID: $error');
  }

  @override
  void bridgefyDidSendDataProgress({
    required String messageID,
    required int position,
    required int of,
  }) {
    debugPrint('[Bridgefy] Send progress $messageID: $position/$of');
  }
}
