import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/colors.dart';
import '../../config/constants.dart';
import '../../models/enums.dart';
import '../../widgets/common/glass_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final String _userName = 'Survivor';
  LocationMode _locationMode = LocationMode.balanced;
  bool _autoShareLocation = true;
  bool _sosAlarmSound = true;
  bool _vibration = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
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
                      'Settings',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms),
            ),

            // Profile Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppColors.meshGradient,
                        ),
                        child: Center(
                          child: Text(
                            _userName[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _userName,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tap to edit profile',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded,
                          color: AppColors.textTertiary),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
            ),

            // Network Settings
            _sectionHeader(context, 'Network', 300),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GlassCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _SettingsTile(
                        icon: Icons.bluetooth,
                        iconColor: AppColors.info,
                        title: 'Bluetooth Mesh',
                        subtitle: 'Bridgefy SDK',
                        trailing: _StatusDot(isActive: true),
                      ),
                      const Divider(height: 1, indent: 56),
                      _SettingsTile(
                        icon: Icons.wifi,
                        iconColor: AppColors.meshActive,
                        title: 'Nearby Connections',
                        subtitle: 'Android WiFi P2P',
                        trailing: _StatusDot(isActive: true),
                      ),
                      const Divider(height: 1, indent: 56),
                      _SettingsTile(
                        icon: Icons.hub_rounded,
                        iconColor: AppColors.accent,
                        title: 'Message Relay',
                        subtitle: 'TTL: ${AppConstants.defaultTTL} hops',
                        trailing: _StatusDot(isActive: true),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
            ),

            // Location Settings
            _sectionHeader(context, 'Location', 500),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GlassCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _SettingsTile(
                        icon: Icons.share_location_rounded,
                        iconColor: AppColors.safe,
                        title: 'Auto Share Location',
                        trailing: Switch(
                          value: _autoShareLocation,
                          activeTrackColor: AppColors.safe,
                          onChanged: (v) =>
                              setState(() => _autoShareLocation = v),
                        ),
                      ),
                      const Divider(height: 1, indent: 56),
                      _SettingsTile(
                        icon: Icons.speed_rounded,
                        iconColor: AppColors.warning,
                        title: 'Location Mode',
                        subtitle: _locationMode.description,
                        onTap: () => _showLocationModePicker(),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 600.ms, duration: 400.ms),
            ),

            // SOS Settings
            _sectionHeader(context, 'Emergency', 700),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GlassCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _SettingsTile(
                        icon: Icons.volume_up_rounded,
                        iconColor: AppColors.emergency,
                        title: 'SOS Alarm Sound',
                        trailing: Switch(
                          value: _sosAlarmSound,
                          activeTrackColor: AppColors.emergency,
                          onChanged: (v) =>
                              setState(() => _sosAlarmSound = v),
                        ),
                      ),
                      const Divider(height: 1, indent: 56),
                      _SettingsTile(
                        icon: Icons.vibration_rounded,
                        iconColor: AppColors.warning,
                        title: 'Vibration',
                        trailing: Switch(
                          value: _vibration,
                          activeTrackColor: AppColors.warning,
                          onChanged: (v) =>
                              setState(() => _vibration = v),
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 800.ms, duration: 400.ms),
            ),

            // About
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        '${AppConstants.appName} v${AppConstants.appVersion}',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Offline-first emergency communication',
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _sectionHeader(BuildContext context, String title, int delay) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
        child: Text(
          title.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                letterSpacing: 1.5,
                color: AppColors.textTertiary,
              ),
        ),
      ).animate().fadeIn(delay: Duration(milliseconds: delay), duration: 400.ms),
    );
  }

  void _showLocationModePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Location Mode',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            ...LocationMode.values.map((mode) => ListTile(
                  onTap: () {
                    setState(() => _locationMode = mode);
                    Navigator.pop(context);
                  },
                  title: Text(mode.label),
                  subtitle: Text(mode.description),
                  leading: Icon(
                    _locationMode == mode
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: _locationMode == mode
                        ? AppColors.accent
                        : AppColors.textTertiary,
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconColor.withAlpha(26),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: iconColor),
      ),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      subtitle: subtitle != null
          ? Text(subtitle!,
              style: const TextStyle(fontSize: 12, color: AppColors.textTertiary))
          : null,
      trailing: trailing ??
          const Icon(Icons.chevron_right_rounded,
              color: AppColors.textTertiary, size: 20),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    );
  }
}

class _StatusDot extends StatelessWidget {
  final bool isActive;

  const _StatusDot({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? AppColors.safe : AppColors.textTertiary,
        boxShadow: isActive
            ? [BoxShadow(color: AppColors.safe.withAlpha(128), blurRadius: 6)]
            : null,
      ),
    );
  }
}
