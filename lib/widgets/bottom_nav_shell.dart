import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../config/colors.dart';

/// Premium glassmorphism bottom navigation shell with animated SOS button.
class BottomNavShell extends StatelessWidget {
  final Widget child;

  const BottomNavShell({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/map')) return 1;
    if (location.startsWith('/sos')) return 2;
    if (location.startsWith('/alerts')) return 3;
    if (location.startsWith('/chat')) return 4;
    return 0;
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
      case 1:
        context.go('/map');
      case 2:
        context.go('/sos');
      case 3:
        context.go('/alerts');
      case 4:
        context.go('/chat');
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(context);

    return Scaffold(
      body: child,
      extendBody: true,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
              color: AppColors.glassBorder,
              width: 0.5,
            ),
          ),
        ),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              color: AppColors.surface.withAlpha(217),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _NavItem(
                        icon: Icons.dashboard_rounded,
                        label: 'Home',
                        isSelected: selectedIndex == 0,
                        onTap: () => _onItemTapped(context, 0),
                      ),
                      _NavItem(
                        icon: Icons.map_rounded,
                        label: 'Map',
                        isSelected: selectedIndex == 1,
                        onTap: () => _onItemTapped(context, 1),
                      ),
                      _SOSNavItem(
                        isSelected: selectedIndex == 2,
                        onTap: () => _onItemTapped(context, 2),
                      ),
                      _NavItem(
                        icon: Icons.warning_amber_rounded,
                        label: 'Alerts',
                        isSelected: selectedIndex == 3,
                        onTap: () => _onItemTapped(context, 3),
                      ),
                      _NavItem(
                        icon: Icons.chat_bubble_outline_rounded,
                        label: 'Chat',
                        isSelected: selectedIndex == 4,
                        onTap: () => _onItemTapped(context, 4),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accent.withAlpha(38)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? AppColors.accent : AppColors.textTertiary,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppColors.accent : AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SOSNavItem extends StatefulWidget {
  final bool isSelected;
  final VoidCallback onTap;

  const _SOSNavItem({
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_SOSNavItem> createState() => _SOSNavItemState();
}

class _SOSNavItemState extends State<_SOSNavItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _pulseAnimation,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.emergencyGradient,
            boxShadow: [
              BoxShadow(
                color: AppColors.emergency.withAlpha(102),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(
            Icons.sos_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }
}
