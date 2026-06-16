import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:nearby_connections/nearby_connections.dart';
import '../../config/constants.dart';
import '../../models/mesh_message.dart';
import '../../models/peer_info.dart';
import '../../models/enums.dart';

/// High-bandwidth transport service using Google Nearby Connections API.
///
/// Android only — uses WiFi Direct for larger payloads (images, detailed alerts).
/// Falls back gracefully on iOS (no-op).
class NearbyService {
  static final NearbyService _instance = NearbyService._();
  static NearbyService get instance => _instance;
  NearbyService._();

  final Nearby _nearby = Nearby();
  String _userName = 'DisasterNet User';
  bool _isAdvertising = false;
  bool _isDiscovering = false;

  // Connected endpoints
  final Map<String, PeerInfo> _connectedEndpoints = {};

  // Stream controllers
  final _messageReceivedController = StreamController<MeshMessage>.broadcast();
  final _peerFoundController = StreamController<PeerInfo>.broadcast();
  final _peerLostController = StreamController<String>.broadcast();
  final _connectionController = StreamController<PeerInfo>.broadcast();

  // Public streams
  Stream<MeshMessage> get onMessageReceived => _messageReceivedController.stream;
  Stream<PeerInfo> get onPeerFound => _peerFoundController.stream;
  Stream<String> get onPeerLost => _peerLostController.stream;
  Stream<PeerInfo> get onConnection => _connectionController.stream;

  // State
  bool get isAdvertising => _isAdvertising;
  bool get isDiscovering => _isDiscovering;
  bool get isSupported => Platform.isAndroid;
  Map<String, PeerInfo> get connectedEndpoints =>
      Map.unmodifiable(_connectedEndpoints);

  /// Check and request permissions (Android only).
  /// Permissions are handled via permission_handler in PermissionHelper.
  /// This just returns true if on Android (assume permissions are granted).
  Future<bool> checkPermissions() async {
    if (!Platform.isAndroid) return false;
    // Permissions are managed by PermissionHelper.requestMeshPermissions()
    // which should be called before starting NearbyService.
    return true;
  }

  /// Start advertising this device to nearby peers.
  Future<bool> startAdvertising({String? userName}) async {
    if (!Platform.isAndroid) return false;
    if (_isAdvertising) return true;

    _userName = userName ?? _userName;

    try {
      final result = await _nearby.startAdvertising(
        _userName,
        Strategy.P2P_CLUSTER, // Everyone can advertise & discover
        onConnectionInitiated: _onConnectionInitiated,
        onConnectionResult: _onConnectionResult,
        onDisconnected: _onDisconnected,
        serviceId: AppConstants.meshServiceId,
      );
      _isAdvertising = result;
      debugPrint('[NearbyService] Advertising started: $result');
      return result;
    } catch (e) {
      debugPrint('[NearbyService] Advertising failed: $e');
      return false;
    }
  }

  /// Start discovering nearby advertising devices.
  Future<bool> startDiscovery({String? userName}) async {
    if (!Platform.isAndroid) return false;
    if (_isDiscovering) return true;

    _userName = userName ?? _userName;

    try {
      final result = await _nearby.startDiscovery(
        _userName,
        Strategy.P2P_CLUSTER,
        onEndpointFound: _onEndpointFound,
        onEndpointLost: _onEndpointLost,
        serviceId: AppConstants.meshServiceId,
      );
      _isDiscovering = result;
      debugPrint('[NearbyService] Discovery started: $result');
      return result;
    } catch (e) {
      debugPrint('[NearbyService] Discovery failed: $e');
      return false;
    }
  }

  /// Send bytes payload to a connected endpoint.
  Future<void> sendMessage(String endpointId, MeshMessage message) async {
    if (!Platform.isAndroid) return;

    try {
      final data = message.toBytes();
      await _nearby.sendBytesPayload(endpointId, data);
      debugPrint(
          '[NearbyService] Sent ${message.type.name} to $endpointId (${data.length} bytes)');
    } catch (e) {
      debugPrint('[NearbyService] Send failed: $e');
    }
  }

  /// Broadcast message to all connected endpoints.
  Future<void> broadcastMessage(MeshMessage message) async {
    for (final endpointId in _connectedEndpoints.keys) {
      await sendMessage(endpointId, message);
    }
  }

  /// Stop advertising.
  Future<void> stopAdvertising() async {
    if (!Platform.isAndroid) return;
    try {
      await _nearby.stopAdvertising();
      _isAdvertising = false;
    } catch (e) {
      debugPrint('[NearbyService] Stop advertising failed: $e');
    }
  }

  /// Stop discovery.
  Future<void> stopDiscovery() async {
    if (!Platform.isAndroid) return;
    try {
      await _nearby.stopDiscovery();
      _isDiscovering = false;
    } catch (e) {
      debugPrint('[NearbyService] Stop discovery failed: $e');
    }
  }

  /// Stop everything and disconnect all endpoints.
  Future<void> stopAll() async {
    await stopAdvertising();
    await stopDiscovery();
    if (Platform.isAndroid) {
      await _nearby.stopAllEndpoints();
    }
    _connectedEndpoints.clear();
  }

  // --- Callbacks ---

  void _onEndpointFound(String id, String name, String serviceId) {
    debugPrint('[NearbyService] Found: $name ($id)');
    final peer = PeerInfo(
      id: id,
      name: name,
      status: PeerConnectionStatus.discovered,
      transport: TransportType.nearby,
      lastSeen: DateTime.now(),
    );
    _peerFoundController.add(peer);

    // Auto-connect
    _requestConnection(id);
  }

  void _onEndpointLost(String? id) {
    if (id != null) {
      debugPrint('[NearbyService] Lost: $id');
      _connectedEndpoints.remove(id);
      _peerLostController.add(id);
    }
  }

  Future<void> _requestConnection(String endpointId) async {
    try {
      await _nearby.requestConnection(
        _userName,
        endpointId,
        onConnectionInitiated: _onConnectionInitiated,
        onConnectionResult: _onConnectionResult,
        onDisconnected: _onDisconnected,
      );
    } catch (e) {
      debugPrint('[NearbyService] Connection request failed: $e');
    }
  }

  void _onConnectionInitiated(String id, ConnectionInfo info) {
    debugPrint('[NearbyService] Connection initiated with: ${info.endpointName}');
    // Auto-accept connections
    _nearby.acceptConnection(
      id,
      onPayLoadRecieved: (endpointId, payload) {
        _handlePayload(endpointId, payload);
      },
      onPayloadTransferUpdate: (endpointId, update) {
        debugPrint('[NearbyService] Transfer update: ${update.status}');
      },
    );
  }

  void _onConnectionResult(String id, Status status) {
    debugPrint('[NearbyService] Connection result with $id: $status');
    if (status == Status.CONNECTED) {
      final peer = PeerInfo(
        id: id,
        name: 'Peer $id',
        status: PeerConnectionStatus.connected,
        transport: TransportType.nearby,
        lastSeen: DateTime.now(),
      );
      _connectedEndpoints[id] = peer;
      _connectionController.add(peer);
    }
  }

  void _onDisconnected(String id) {
    debugPrint('[NearbyService] Disconnected from: $id');
    _connectedEndpoints.remove(id);
    _peerLostController.add(id);
  }

  void _handlePayload(String endpointId, Payload payload) {
    if (payload.type == PayloadType.BYTES && payload.bytes != null) {
      try {
        final message = MeshMessage.fromBytes(payload.bytes!);
        _messageReceivedController.add(message);
        debugPrint(
            '[NearbyService] Received ${message.type.name} from $endpointId');
      } catch (e) {
        debugPrint('[NearbyService] Error parsing payload: $e');
      }
    }
  }

  /// Clean up
  void dispose() {
    stopAll();
    _messageReceivedController.close();
    _peerFoundController.close();
    _peerLostController.close();
    _connectionController.close();
  }
}
