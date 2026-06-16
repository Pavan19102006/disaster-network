import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

/// Handles runtime permission requests for Bluetooth, WiFi, and Location.
class PermissionHelper {
  PermissionHelper._();

  /// Request all permissions needed for mesh networking.
  static Future<bool> requestMeshPermissions() async {
    final permissions = <Permission>[
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise,
      Permission.location,
      Permission.locationWhenInUse,
    ];

    // Android-specific permissions
    if (Platform.isAndroid) {
      permissions.addAll([
        Permission.nearbyWifiDevices,
      ]);
    }

    final statuses = await permissions.request();

    final allGranted = statuses.values.every(
      (status) => status.isGranted || status.isLimited,
    );

    if (!allGranted) {
      debugPrint('[Permissions] Some permissions denied:');
      for (final entry in statuses.entries) {
        if (!entry.value.isGranted) {
          debugPrint('  ${entry.key}: ${entry.value}');
        }
      }
    }

    return allGranted;
  }

  /// Request location permission only.
  static Future<bool> requestLocationPermission() async {
    final status = await Permission.locationWhenInUse.request();
    return status.isGranted;
  }

  /// Check if Bluetooth is available and enabled.
  static Future<bool> isBluetoothAvailable() async {
    final status = await Permission.bluetooth.status;
    return status.isGranted;
  }

  /// Check if location services are enabled.
  static Future<bool> isLocationEnabled() async {
    final status = await Permission.location.status;
    return status.isGranted;
  }
}
