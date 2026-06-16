import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/colors.dart';
import '../../models/enums.dart';
import '../../widgets/common/glass_card.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  AlertCategory? _filterCategory;

  // Demo alerts data
  final List<_DemoAlert> _alerts = [
    _DemoAlert(
      category: AlertCategory.dangerZone,
      priority: AlertPriority.critical,
      title: 'Flooding on Highway 12',
      description: 'Water level rising rapidly. Avoid this route.',
      timeAgo: '5m ago',
      distance: '1.2 km',
      confirmations: 4,
    ),
    _DemoAlert(
      category: AlertCategory.shelter,
      priority: AlertPriority.high,
      title: 'Community Center Open',
      description: 'Food, water, and beds available for 200 people.',
      timeAgo: '18m ago',
      distance: '3.5 km',
      confirmations: 12,
    ),
    _DemoAlert(
      category: AlertCategory.supplies,
      priority: AlertPriority.medium,
      title: 'Water Distribution Point',
      description: 'Clean water available at City Park entrance.',
      timeAgo: '42m ago',
      distance: '2.1 km',
      confirmations: 8,
    ),
    _DemoAlert(
      category: AlertCategory.roadBlocked,
      priority: AlertPriority.high,
      title: 'Bridge Collapsed - Main St',
      description: 'Bridge is impassable. Use detour via Oak Ave.',
      timeAgo: '1h ago',
      distance: '800m',
      confirmations: 15,
    ),
    _DemoAlert(
      category: AlertCategory.medicalCamp,
      priority: AlertPriority.medium,
      title: 'Field Hospital Active',
      description: 'Medical team treating injuries at the school gym.',
      timeAgo: '2h ago',
      distance: '4.8 km',
      confirmations: 6,
    ),
  ];

  Color _priorityColor(AlertPriority priority) {
    switch (priority) {
      case AlertPriority.critical:
        return AppColors.emergency;
      case AlertPriority.high:
        return AppColors.warning;
      case AlertPriority.medium:
        return AppColors.info;
      case AlertPriority.low:
        return AppColors.textTertiary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredAlerts = _filterCategory == null
        ? _alerts
        : _alerts.where((a) => a.category == _filterCategory).toList();

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Community Alerts',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  GestureDetector(
                    onTap: () => _showCreateAlert(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: AppColors.meshGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add, color: Colors.white, size: 18),
                          SizedBox(width: 4),
                          Text(
                            'Post',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),

            // Category filter chips
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 0, 8),
              child: SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _FilterChip(
                      label: 'All',
                      isSelected: _filterCategory == null,
                      onTap: () =>
                          setState(() => _filterCategory = null),
                    ),
                    ...AlertCategory.values.map((cat) => Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: _FilterChip(
                            label: '${cat.emoji} ${cat.label}',
                            isSelected: _filterCategory == cat,
                            onTap: () =>
                                setState(() => _filterCategory = cat),
                          ),
                        )),
                    const SizedBox(width: 20),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

            // Alerts List
            Expanded(
              child: filteredAlerts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.info_outline,
                              size: 48, color: AppColors.textTertiary),
                          const SizedBox(height: 12),
                          Text(
                            'No alerts in this category',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                      itemCount: filteredAlerts.length,
                      itemBuilder: (context, index) {
                        final alert = filteredAlerts[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: GlassCard(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      alert.category.emoji,
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        alert.title,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _priorityColor(alert.priority)
                                            .withAlpha(26),
                                        borderRadius:
                                            BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        alert.priority.name.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color:
                                              _priorityColor(alert.priority),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  alert.description,
                                  style:
                                      Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Icon(Icons.access_time,
                                        size: 14,
                                        color: AppColors.textTertiary),
                                    const SizedBox(width: 4),
                                    Text(
                                      alert.timeAgo,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall,
                                    ),
                                    const SizedBox(width: 16),
                                    Icon(Icons.location_on_outlined,
                                        size: 14,
                                        color: AppColors.textTertiary),
                                    const SizedBox(width: 4),
                                    Text(
                                      alert.distance,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall,
                                    ),
                                    const Spacer(),
                                    Icon(Icons.verified_outlined,
                                        size: 14, color: AppColors.safe),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${alert.confirmations} confirmed',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(color: AppColors.safe),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ).animate().fadeIn(
                              delay: Duration(milliseconds: 300 + index * 100),
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

  void _showCreateAlert(BuildContext context) {
    // Placeholder - will be implemented with full form
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Create Alert coming soon')),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accent.withAlpha(26)
              : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.accent.withAlpha(128) : AppColors.glassBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? AppColors.accent : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _DemoAlert {
  final AlertCategory category;
  final AlertPriority priority;
  final String title;
  final String description;
  final String timeAgo;
  final String distance;
  final int confirmations;

  const _DemoAlert({
    required this.category,
    required this.priority,
    required this.title,
    required this.description,
    required this.timeAgo,
    required this.distance,
    required this.confirmations,
  });
}
