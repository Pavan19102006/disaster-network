import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../config/constants.dart';
import '../../models/enums.dart';
import '../../models/mesh_message.dart';
import '../../models/community_alert.dart';
import '../mesh/mesh_service.dart';
import '../mesh/mesh_router.dart';

/// Community alert management service.
///
/// Handles creating, receiving, and syncing community alerts
/// through the mesh network with deduplication and expiry management.
class AlertService {
  static final AlertService _instance = AlertService._();
  static AlertService get instance => _instance;
  AlertService._();

  final _meshService = MeshService.instance;
  final _meshRouter = MeshRouter.instance;

  final Map<String, CommunityAlert> _alerts = {};
  Timer? _expiryTimer;

  // Stream controllers
  final _alertsController =
      StreamController<List<CommunityAlert>>.broadcast();
  final _newAlertController = StreamController<CommunityAlert>.broadcast();

  // Public streams
  Stream<List<CommunityAlert>> get onAlertsChanged =>
      _alertsController.stream;
  Stream<CommunityAlert> get onNewAlert => _newAlertController.stream;

  // State
  List<CommunityAlert> get alerts {
    final list = _alerts.values.where((a) => !a.isExpired).toList();
    list.sort((a, b) {
      // Sort by priority first, then by creation time
      final priorityCompare =
          a.priority.index.compareTo(b.priority.index);
      if (priorityCompare != 0) return priorityCompare;
      return b.createdAt.compareTo(a.createdAt);
    });
    return list;
  }

  int get activeAlertCount =>
      _alerts.values.where((a) => !a.isExpired).length;

  /// Initialize the alert service and start expiry timer.
  void initialize() {
    // Periodically clean expired alerts
    _expiryTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _cleanExpiredAlerts(),
    );
  }

  /// Create and broadcast a new community alert.
  Future<CommunityAlert> createAlert({
    required AlertCategory category,
    required AlertPriority priority,
    required String title,
    required String description,
    required double latitude,
    required double longitude,
    Duration? expiresIn,
    String? creatorName,
  }) async {
    final alert = CommunityAlert(
      id: const Uuid().v4(),
      creatorId: _meshService.currentUserId ?? 'unknown',
      creatorName: creatorName ?? 'User',
      category: category,
      priority: priority,
      title: title,
      description: description,
      latitude: latitude,
      longitude: longitude,
      createdAt: DateTime.now(),
      expiresAt: DateTime.now()
          .add(expiresIn ?? AppConstants.alertDefaultExpiry),
    );

    // Store locally
    _alerts[alert.id] = alert;
    _alertsController.add(alerts);
    _newAlertController.add(alert);

    // Broadcast to mesh
    final message = _meshRouter.prepareMessage(
      type: MessageType.alert,
      senderId: alert.creatorId,
      senderName: alert.creatorName,
      payload: alert.toJson(),
      ttl: priority == AlertPriority.critical
          ? AppConstants.sosMaxHops
          : AppConstants.defaultTTL,
    );

    await _meshService.sendBroadcast(message);
    debugPrint('[AlertService] Created alert: ${alert.title}');

    return alert;
  }

  /// Handle incoming alert from mesh network.
  void handleIncomingMessage(MeshMessage message) {
    if (message.type != MessageType.alert) return;

    try {
      final alert = CommunityAlert.fromJson(message.payload);

      // Skip if already have this alert or it's expired
      if (_alerts.containsKey(alert.id) || alert.isExpired) return;

      // Skip our own alerts
      if (alert.creatorId == _meshService.currentUserId) return;

      _alerts[alert.id] = alert;
      _alertsController.add(alerts);
      _newAlertController.add(alert);

      debugPrint(
          '[AlertService] Received alert: ${alert.title} (${alert.category.label})');
    } catch (e) {
      debugPrint('[AlertService] Error parsing alert: $e');
    }
  }

  /// Remove expired alerts.
  void _cleanExpiredAlerts() {
    final before = _alerts.length;
    _alerts.removeWhere((_, alert) => alert.isExpired);
    final removed = before - _alerts.length;
    if (removed > 0) {
      _alertsController.add(alerts);
      debugPrint('[AlertService] Cleaned $removed expired alerts');
    }
  }

  /// Clean up resources.
  void dispose() {
    _expiryTimer?.cancel();
    _alertsController.close();
    _newAlertController.close();
  }
}
