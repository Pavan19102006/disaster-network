import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/enums.dart';
import '../models/peer_info.dart';
import '../models/mesh_message.dart';
import '../services/mesh/mesh_service.dart';
import '../services/mesh/nearby_service.dart';

/// Provider for mesh network connection status.
final meshStatusProvider =
    StateNotifierProvider<MeshStatusNotifier, MeshState>((ref) {
  return MeshStatusNotifier();
});

/// Mesh network state
class MeshState {
  final bool isConnected;
  final bool isBridgefyStarted;
  final bool isNearbyStarted;
  final int peerCount;
  final Map<String, PeerInfo> peers;
  final List<MeshMessage> recentMessages;

  const MeshState({
    this.isConnected = false,
    this.isBridgefyStarted = false,
    this.isNearbyStarted = false,
    this.peerCount = 0,
    this.peers = const {},
    this.recentMessages = const [],
  });

  MeshState copyWith({
    bool? isConnected,
    bool? isBridgefyStarted,
    bool? isNearbyStarted,
    int? peerCount,
    Map<String, PeerInfo>? peers,
    List<MeshMessage>? recentMessages,
  }) {
    return MeshState(
      isConnected: isConnected ?? this.isConnected,
      isBridgefyStarted: isBridgefyStarted ?? this.isBridgefyStarted,
      isNearbyStarted: isNearbyStarted ?? this.isNearbyStarted,
      peerCount: peerCount ?? this.peerCount,
      peers: peers ?? this.peers,
      recentMessages: recentMessages ?? this.recentMessages,
    );
  }
}

class MeshStatusNotifier extends StateNotifier<MeshState> {
  MeshStatusNotifier() : super(const MeshState()) {
    _listenToMesh();
  }

  final _meshService = MeshService.instance;
  final _nearbyService = NearbyService.instance;
  final List<StreamSubscription> _subscriptions = [];

  void _listenToMesh() {
    _subscriptions.add(
      _meshService.onPeerConnected.listen((peerId) {
        final newPeers = Map<String, PeerInfo>.from(state.peers);
        newPeers[peerId] = PeerInfo(
          id: peerId,
          name: 'Peer ${peerId.substring(0, 6)}',
          status: PeerConnectionStatus.connected,
          transport: TransportType.ble,
          lastSeen: DateTime.now(),
        );
        state = state.copyWith(
          peers: newPeers,
          peerCount: newPeers.length,
          isConnected: true,
        );
      }),
    );

    _subscriptions.add(
      _meshService.onPeerDisconnected.listen((peerId) {
        final newPeers = Map<String, PeerInfo>.from(state.peers);
        newPeers.remove(peerId);
        state = state.copyWith(
          peers: newPeers,
          peerCount: newPeers.length,
          isConnected: newPeers.isNotEmpty,
        );
      }),
    );

    _subscriptions.add(
      _meshService.onMessageReceived.listen((message) {
        final messages = [...state.recentMessages, message];
        if (messages.length > 100) {
          messages.removeRange(0, messages.length - 100);
        }
        state = state.copyWith(recentMessages: messages);
      }),
    );
  }

  /// Initialize and start mesh networking.
  Future<void> startMesh() async {
    try {
      await _meshService.initialize();
      await _meshService.start();
      state = state.copyWith(isBridgefyStarted: true);

      // Also start nearby connections on Android
      if (_nearbyService.isSupported) {
        final hasPerms = await _nearbyService.checkPermissions();
        if (hasPerms) {
          await _nearbyService.startAdvertising();
          await _nearbyService.startDiscovery();
          state = state.copyWith(isNearbyStarted: true);
        }
      }
    } catch (e) {
      state = state.copyWith(isBridgefyStarted: false);
    }
  }

  /// Stop mesh networking.
  Future<void> stopMesh() async {
    await _meshService.stop();
    await _nearbyService.stopAll();
    state = const MeshState();
  }

  @override
  void dispose() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    super.dispose();
  }
}
