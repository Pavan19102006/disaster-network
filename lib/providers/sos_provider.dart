import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/enums.dart';
import '../models/sos_signal.dart';
import '../services/sos/sos_service.dart';

/// Provider for SOS state management.
final sosProvider =
    StateNotifierProvider<SOSNotifier, SOSState>((ref) {
  return SOSNotifier();
});

class SOSState {
  final bool isBroadcasting;
  final SOSSignal? activeSignal;
  final Map<String, SOSSignal> receivedSignals;

  const SOSState({
    this.isBroadcasting = false,
    this.activeSignal,
    this.receivedSignals = const {},
  });

  SOSState copyWith({
    bool? isBroadcasting,
    SOSSignal? activeSignal,
    Map<String, SOSSignal>? receivedSignals,
  }) {
    return SOSState(
      isBroadcasting: isBroadcasting ?? this.isBroadcasting,
      activeSignal: activeSignal ?? this.activeSignal,
      receivedSignals: receivedSignals ?? this.receivedSignals,
    );
  }
}

class SOSNotifier extends StateNotifier<SOSState> {
  SOSNotifier() : super(const SOSState()) {
    _listenToSOS();
  }

  final _sosService = SOSService.instance;
  final List<StreamSubscription> _subscriptions = [];

  void _listenToSOS() {
    _subscriptions.add(
      _sosService.onStatusChanged.listen((status) {
        state = state.copyWith(
          isBroadcasting: status == SOSStatus.broadcasting,
          activeSignal: _sosService.activeSignal,
        );
      }),
    );

    _subscriptions.add(
      _sosService.onSOSReceived.listen((signal) {
        final newSignals =
            Map<String, SOSSignal>.from(state.receivedSignals);
        newSignals[signal.id] = signal;
        state = state.copyWith(receivedSignals: newSignals);
      }),
    );
  }

  Future<void> startSOS({
    required EmergencyType type,
    required double latitude,
    required double longitude,
    String? description,
  }) async {
    await _sosService.startSOS(
      type: type,
      latitude: latitude,
      longitude: longitude,
      description: description,
    );
  }

  void stopSOS() {
    _sosService.stopSOS();
    state = state.copyWith(
      isBroadcasting: false,
      activeSignal: null,
    );
  }

  Future<void> acknowledgeSOS(String sosId) async {
    await _sosService.acknowledgeSOS(sosId);
  }

  @override
  void dispose() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    super.dispose();
  }
}
