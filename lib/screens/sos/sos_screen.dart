import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/colors.dart';
import '../../models/enums.dart';

class SOSScreen extends StatefulWidget {
  const SOSScreen({super.key});

  @override
  State<SOSScreen> createState() => _SOSScreenState();
}

class _SOSScreenState extends State<SOSScreen> with TickerProviderStateMixin {
  bool _isBroadcasting = false;
  bool _isHolding = false;
  double _holdProgress = 0.0;
  EmergencyType _selectedType = EmergencyType.general;
  late AnimationController _pulseController;
  late AnimationController _rippleController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  void _startHold() {
    setState(() => _isHolding = true);
    _animateHold();
  }

  void _animateHold() async {
    const steps = 60;
    for (int i = 0; i <= steps; i++) {
      if (!_isHolding) return;
      await Future.delayed(const Duration(milliseconds: 50));
      if (!mounted) return;
      setState(() => _holdProgress = i / steps);
      if (i == steps) {
        _activateSOS();
      }
    }
  }

  void _cancelHold() {
    setState(() {
      _isHolding = false;
      _holdProgress = 0;
    });
  }

  void _activateSOS() {
    HapticFeedback.heavyImpact();
    setState(() {
      _isBroadcasting = true;
      _isHolding = false;
      _holdProgress = 0;
    });
  }

  void _deactivateSOS() {
    setState(() => _isBroadcasting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Icon(
                    Icons.sos_rounded,
                    color: _isBroadcasting
                        ? AppColors.emergency
                        : AppColors.textSecondary,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Emergency SOS',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),

            const SizedBox(height: 8),

            // Status banner
            if (_isBroadcasting)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.emergency.withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: AppColors.emergency.withAlpha(77)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.emergency,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.emergency.withAlpha(128),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'SOS Broadcasting Active',
                      style: TextStyle(
                        color: AppColors.emergency,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: _deactivateSOS,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.emergency.withAlpha(51),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'CANCEL',
                          style: TextStyle(
                            color: AppColors.emergencyLight,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(duration: 300.ms)
                  .shimmer(
                    duration: 2000.ms,
                    color: AppColors.emergency.withAlpha(26),
                  ),

            // Main SOS Button Area
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // SOS Button with ripple rings
                    SizedBox(
                      width: 240,
                      height: 240,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Ripple rings when broadcasting
                          if (_isBroadcasting)
                            ...List.generate(3, (index) {
                              return AnimatedBuilder(
                                animation: _rippleController,
                                builder: (context, child) {
                                  final delay = index * 0.33;
                                  final animValue =
                                      (_rippleController.value + delay) % 1.0;
                                  return Container(
                                    width: 160 + (animValue * 80),
                                    height: 160 + (animValue * 80),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.emergency.withAlpha(
                                            ((1 - animValue) * 100).toInt()),
                                        width: 2,
                                      ),
                                    ),
                                  );
                                },
                              );
                            }),

                          // Hold progress ring
                          if (_isHolding && !_isBroadcasting)
                            SizedBox(
                              width: 180,
                              height: 180,
                              child: CircularProgressIndicator(
                                value: _holdProgress,
                                strokeWidth: 4,
                                color: AppColors.emergency,
                                backgroundColor:
                                    AppColors.emergency.withAlpha(38),
                              ),
                            ),

                          // Main button
                          GestureDetector(
                            onLongPressStart: _isBroadcasting
                                ? null
                                : (_) => _startHold(),
                            onLongPressEnd: _isBroadcasting
                                ? null
                                : (_) => _cancelHold(),
                            child: ScaleTransition(
                              scale: _isBroadcasting
                                  ? _pulseAnim
                                  : AlwaysStoppedAnimation(
                                      _isHolding ? 0.95 : 1.0),
                              child: Container(
                                width: 160,
                                height: 160,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: AppColors.emergencyGradient,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.emergency
                                          .withAlpha(_isBroadcasting ? 153 : 77),
                                      blurRadius: _isBroadcasting ? 40 : 24,
                                      spreadRadius: _isBroadcasting ? 8 : 2,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.sos_rounded,
                                      color: Colors.white,
                                      size: 48,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _isBroadcasting
                                          ? 'ACTIVE'
                                          : 'HOLD 3s',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    Text(
                      _isBroadcasting
                          ? 'Broadcasting ${_selectedType.emoji} ${_selectedType.label}'
                          : 'Press and hold to send SOS',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: _isBroadcasting
                                ? AppColors.emergency
                                : AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ),

            // Emergency Type Selector
            if (!_isBroadcasting)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Emergency Type',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: EmergencyType.values.map((type) {
                        final isSelected = type == _selectedType;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedType = type),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.emergency.withAlpha(26)
                                  : AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.emergency.withAlpha(128)
                                    : AppColors.glassBorder,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(type.emoji, style: const TextStyle(fontSize: 16)),
                                const SizedBox(width: 6),
                                Text(
                                  type.label,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: isSelected
                                        ? AppColors.emergency
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 400.ms, duration: 400.ms).slideY(begin: 0.1),

            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }
}
