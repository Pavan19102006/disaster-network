import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../../models/enums.dart';
import '../../models/mesh_message.dart';
import '../mesh/mesh_service.dart';
import '../mesh/mesh_router.dart';

/// GPS location tracking and sharing service.
///
/// GPS works fully offline (satellite-based, no internet needed).
/// Broadcasts location to mesh peers at configurable intervals.
class LocationService {
  static final LocationService _instance = LocationService._();
  static LocationService get instance => _instance;
  LocationService._();

  final _meshService = MeshService.instance;
  final _meshRouter = MeshRouter.instance;

  StreamSubscription<Position>? _positionSubscription;
  Timer? _shareTimer;
  Position? _currentPosition;
  LocationMode _mode = LocationMode.balanced;
  bool _isSharing = false;

  // Peer locations
  final Map<String, PeerLocation> _peerLocations = {};

  // Stream controllers
  final _locationController = StreamController<Position>.broadcast();
  final _peerLocationController =
      StreamController<Map<String, PeerLocation>>.broadcast();

  // Public streams
  Stream<Position> get onLocationChanged => _locationController.stream;
  Stream<Map<String, PeerLocation>> get onPeerLocationsChanged =>
      _peerLocationController.stream;

  // State
  Position? get currentPosition => _currentPosition;
  bool get isSharing => _isSharing;
  LocationMode get mode => _mode;
  Map<String, PeerLocation> get peerLocations =>
      Map.unmodifiable(_peerLocations);

  /// Check and request location permissions.
  Future<bool> checkPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('[LocationService] Location services disabled');
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('[LocationService] Permission denied');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint('[LocationService] Permission permanently denied');
      return false;
    }

    return true;
  }

  /// Start tracking location with the current mode.
  Future<void> startTracking({LocationMode? mode}) async {
    _mode = mode ?? _mode;

    final settings = _getLocationSettings();

    _positionSubscription?.cancel();
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: settings,
    ).listen(
      (position) {
        _currentPosition = position;
        _locationController.add(position);
      },
      onError: (error) {
        debugPrint('[LocationService] Stream error: $error');
      },
    );

    debugPrint('[LocationService] Tracking started (${_mode.label})');
  }

  /// Start sharing location with mesh peers.
  Future<void> startSharing() async {
    _isSharing = true;

    final interval = switch (_mode) {
      LocationMode.highAccuracy => const Duration(seconds: 10),
      LocationMode.balanced => const Duration(seconds: 30),
      LocationMode.batterySaver => const Duration(seconds: 60),
    };

    _shareTimer?.cancel();
    _shareTimer = Timer.periodic(interval, (_) => _shareLocation());

    debugPrint('[LocationService] Sharing started');
  }

  /// Stop sharing location.
  void stopSharing() {
    _shareTimer?.cancel();
    _shareTimer = null;
    _isSharing = false;
    debugPrint('[LocationService] Sharing stopped');
  }

  /// Stop tracking entirely.
  void stopTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    stopSharing();
    debugPrint('[LocationService] Tracking stopped');
  }

  /// Get current position once (snapshot).
  Future<Position?> getCurrentPosition() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      _currentPosition = position;
      return position;
    } catch (e) {
      debugPrint('[LocationService] Get position failed: $e');
      return _currentPosition;
    }
  }

  /// Handle incoming location message from mesh.
  void handleIncomingMessage(MeshMessage message) {
    if (message.type != MessageType.location) return;

    try {
      final lat = (message.payload['latitude'] as num?)?.toDouble();
      final lng = (message.payload['longitude'] as num?)?.toDouble();
      final accuracy = (message.payload['accuracy'] as num?)?.toDouble();

      if (lat != null && lng != null) {
        _peerLocations[message.senderId] = PeerLocation(
          peerId: message.senderId,
          peerName: message.senderName,
          latitude: lat,
          longitude: lng,
          accuracy: accuracy,
          timestamp: message.timestamp,
        );
        _peerLocationController.add(Map.from(_peerLocations));
      }
    } catch (e) {
      debugPrint('[LocationService] Error parsing location: $e');
    }
  }

  /// Calculate distance between two coordinates (Haversine).
  double calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  // --- Private methods ---

  Future<void> _shareLocation() async {
    if (_currentPosition == null) return;

    final message = _meshRouter.prepareMessage(
      type: MessageType.location,
      senderId: _meshService.currentUserId ?? 'unknown',
      senderName: 'User',
      payload: {
        'latitude': _currentPosition!.latitude,
        'longitude': _currentPosition!.longitude,
        'accuracy': _currentPosition!.accuracy,
        'altitude': _currentPosition!.altitude,
        'speed': _currentPosition!.speed,
        'heading': _currentPosition!.heading,
        'timestamp': _currentPosition!.timestamp.toIso8601String(),
      },
    );

    await _meshService.sendBroadcast(message);
  }

  LocationSettings _getLocationSettings() {
    return switch (_mode) {
      LocationMode.highAccuracy => const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 5,
        ),
      LocationMode.balanced => const LocationSettings(
          accuracy: LocationAccuracy.medium,
          distanceFilter: 15,
        ),
      LocationMode.batterySaver => const LocationSettings(
          accuracy: LocationAccuracy.low,
          distanceFilter: 50,
        ),
    };
  }

  /// Clean up resources.
  void dispose() {
    stopTracking();
    _locationController.close();
    _peerLocationController.close();
  }
}

/// Internal model for peer location data.
class PeerLocation {
  final String peerId;
  final String peerName;
  final double latitude;
  final double longitude;
  final double? accuracy;
  final DateTime timestamp;

  const PeerLocation({
    required this.peerId,
    required this.peerName,
    required this.latitude,
    required this.longitude,
    this.accuracy,
    required this.timestamp,
  });
}
