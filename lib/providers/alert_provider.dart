import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/community_alert.dart';
import '../models/enums.dart';
import '../services/alerts/alert_service.dart';

/// Provider for community alerts state management.
final alertsProvider =
    StateNotifierProvider<AlertsNotifier, AlertsState>((ref) {
  return AlertsNotifier();
});

class AlertsState {
  final List<CommunityAlert> alerts;
  final int activeCount;

  const AlertsState({
    this.alerts = const [],
    this.activeCount = 0,
  });

  AlertsState copyWith({
    List<CommunityAlert>? alerts,
    int? activeCount,
  }) {
    return AlertsState(
      alerts: alerts ?? this.alerts,
      activeCount: activeCount ?? this.activeCount,
    );
  }
}

class AlertsNotifier extends StateNotifier<AlertsState> {
  AlertsNotifier() : super(const AlertsState()) {
    _listenToAlerts();
  }

  final _alertService = AlertService.instance;
  final List<StreamSubscription> _subscriptions = [];

  void _listenToAlerts() {
    _alertService.initialize();

    _subscriptions.add(
      _alertService.onAlertsChanged.listen((alerts) {
        state = AlertsState(
          alerts: alerts,
          activeCount: alerts.length,
        );
      }),
    );
  }

  Future<void> createAlert({
    required AlertCategory category,
    required AlertPriority priority,
    required String title,
    required String description,
    required double latitude,
    required double longitude,
  }) async {
    await _alertService.createAlert(
      category: category,
      priority: priority,
      title: title,
      description: description,
      latitude: latitude,
      longitude: longitude,
    );
  }

  @override
  void dispose() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    super.dispose();
  }
}
