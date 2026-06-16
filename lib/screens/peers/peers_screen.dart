import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/colors.dart';
import '../../models/enums.dart';
import '../../widgets/common/glass_card.dart';

class PeersScreen extends StatelessWidget {
  const PeersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final peers = [
      _DemoPeer('User Alpha', PeerConnectionStatus.connected, TransportType.ble, -55, '120m', true),
      _DemoPeer('User Beta', PeerConnectionStatus.connected, TransportType.nearby, -68, '340m', false),
      _DemoPeer('User Charlie', PeerConnectionStatus.connected, TransportType.ble, -78, '580m', true),
      _DemoPeer('User Delta', PeerConnectionStatus.discovered, TransportType.ble, -88, '1.2km', false),
      _DemoPeer('User Echo', PeerConnectionStatus.disconnected, TransportType.ble, null, '--', false),
    ];

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.glassWhite,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.glassBorder),
                      ),
                      child: const Icon(Icons.arrow_back_rounded,
                          size: 20, color: AppColors.textSecondary),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Nearby Peers',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),

            // Stats row
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  _StatChip(
                    label: 'Connected',
                    value: '3',
                    color: AppColors.safe,
                  ),
                  const SizedBox(width: 8),
                  _StatChip(
                    label: 'Discovered',
                    value: '1',
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: 8),
                  _StatChip(
                    label: 'Lost',
                    value: '1',
                    color: AppColors.textTertiary,
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

            const SizedBox(height: 16),

            // Peer list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                itemCount: peers.length,
                itemBuilder: (context, index) {
                  final peer = peers[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GlassCard(
                      padding: const EdgeInsets.all(16),
                      borderColor: peer.status == PeerConnectionStatus.connected
                          ? AppColors.safe.withAlpha(38)
                          : null,
                      child: Row(
                        children: [
                          // Avatar
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _statusColor(peer.status).withAlpha(26),
                              border: Border.all(
                                color: _statusColor(peer.status).withAlpha(77),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                peer.name.split(' ').last[0],
                                style: TextStyle(
                                  color: _statusColor(peer.status),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          // Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      peer.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                    if (peer.hasLocation) ...[
                                      const SizedBox(width: 6),
                                      Icon(Icons.location_on,
                                          size: 14, color: AppColors.info),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    _TransportBadge(
                                        transport: peer.transport),
                                    const SizedBox(width: 8),
                                    Text(
                                      peer.distance,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall,
                                    ),
                                    if (peer.rssi != null) ...[
                                      const SizedBox(width: 8),
                                      _SignalBars(rssi: peer.rssi!),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Status indicator
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: _statusColor(peer.status).withAlpha(26),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              peer.status.name,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _statusColor(peer.status),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(
                        delay: Duration(milliseconds: 300 + index * 80),
                        duration: 400.ms,
                      ).slideX(begin: 0.05);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(PeerConnectionStatus status) {
    switch (status) {
      case PeerConnectionStatus.connected:
        return AppColors.safe;
      case PeerConnectionStatus.connecting:
        return AppColors.warning;
      case PeerConnectionStatus.discovered:
        return AppColors.info;
      case PeerConnectionStatus.disconnected:
        return AppColors.textTertiary;
    }
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
              ),
            ),
            const SizedBox(width: 8),
            Text(value,
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700, color: color)),
            const SizedBox(width: 4),
            Flexible(
              child: Text(label,
                  style: Theme.of(context).textTheme.labelSmall,
                  overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransportBadge extends StatelessWidget {
  final TransportType transport;

  const _TransportBadge({required this.transport});

  @override
  Widget build(BuildContext context) {
    final label = switch (transport) {
      TransportType.ble => 'BLE',
      TransportType.nearby => 'WiFi',
      TransportType.wifiDirect => 'WiFi',
      TransportType.multipeer => 'MPC',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.meshActive.withAlpha(26),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: AppColors.meshActive,
        ),
      ),
    );
  }
}

class _SignalBars extends StatelessWidget {
  final int rssi;

  const _SignalBars({required this.rssi});

  @override
  Widget build(BuildContext context) {
    final bars = rssi >= -50 ? 4 : rssi >= -65 ? 3 : rssi >= -80 ? 2 : 1;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(4, (i) {
        return Container(
          width: 3,
          height: 6 + (i * 3).toDouble(),
          margin: const EdgeInsets.only(right: 1),
          decoration: BoxDecoration(
            color: i < bars ? AppColors.safe : AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(1),
          ),
        );
      }),
    );
  }
}

class _DemoPeer {
  final String name;
  final PeerConnectionStatus status;
  final TransportType transport;
  final int? rssi;
  final String distance;
  final bool hasLocation;

  const _DemoPeer(
      this.name, this.status, this.transport, this.rssi, this.distance, this.hasLocation);
}
