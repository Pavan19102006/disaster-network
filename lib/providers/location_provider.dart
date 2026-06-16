import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../models/enums.dart';
import '../services/location/location_service.dart';

/// Provider for location state management.
final locationProvider =
    StateNotifierProvider<LocationNotifier, LocationState>((ref) {
  return LocationNotifier();
});

class LocationState {
  final Position? currentPosition;
  final bool isTracking;
  final bool isSharing;
  final LocationMode mode;
  final bool hasPermission;

  const LocationState({
    this.currentPosition,
    this.isTracking = false,
    this.isSharing = false,
    this.mode = LocationMode.balanced,
    this.hasPermission = false,
  });

  LocationState copyWith({
    Position? currentPosition,
    bool? isTracking,
    bool? isSharing,
    LocationMode? mode,
    bool? hasPermission,
  }) {
    return LocationState(
      currentPosition: currentPosition ?? this.currentPosition,
      isTracking: isTracking ?? this.isTracking,
      isSharing: isSharing ?? this.isSharing,
      mode: mode ?? this.mode,
      hasPermission: hasPermission ?? this.hasPermission,
    );
  }
}

class LocationNotifier extends StateNotifier<LocationState> {
  LocationNotifier() : super(const LocationState()) {
    _initialize();
  }

  final _locationService = LocationService.instance;
  StreamSubscription<Position>? _subscription;

  Future<void> _initialize() async {
    final hasPerms = await _locationService.checkPermissions();
    state = state.copyWith(hasPermission: hasPerms);

    if (hasPerms) {
      await startTracking();
    }
  }

  Future<void> startTracking({LocationMode? mode}) async {
    if (mode != null) {
      state = state.copyWith(mode: mode);
    }

    await _locationService.startTracking(mode: state.mode);

    _subscription?.cancel();
    _subscription = _locationService.onLocationChanged.listen((position) {
      state = state.copyWith(
        currentPosition: position,
        isTracking: true,
      );
    });

    state = state.copyWith(isTracking: true);
  }

  Future<void> startSharing() async {
    await _locationService.startSharing();
    state = state.copyWith(isSharing: true);
  }

  void stopSharing() {
    _locationService.stopSharing();
    state = state.copyWith(isSharing: false);
  }

  void setMode(LocationMode mode) {
    state = state.copyWith(mode: mode);
    if (state.isTracking) {
      startTracking(mode: mode);
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
