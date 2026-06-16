import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/colors.dart';
import '../../widgets/common/glass_card.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _beaconController;

  @override
  void initState() {
    super.initState();
    _beaconController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _beaconController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          // Map placeholder with grid pattern
          Positioned.fill(
            child: CustomPaint(
              painter: _GridMapPainter(),
            ),
          ),

          // Your location beacon
          Center(
            child: AnimatedBuilder(
              animation: _beaconController,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Pulse ring
                    Container(
                      width: 60 + (_beaconController.value * 40),
                      height: 60 + (_beaconController.value * 40),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.accent.withAlpha(
                              ((1 - _beaconController.value) * 100).toInt()),
                          width: 2,
                        ),
                      ),
                    ),
                    // Accuracy circle
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.accent.withAlpha(26),
                      ),
                    ),
                    // Center dot
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.accent,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withAlpha(128),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // Demo peer markers
          Positioned(
            left: 80,
            top: 200,
            child: _PeerMarker(name: 'User A', distance: '120m'),
          ),
          Positioned(
            right: 60,
            top: 280,
            child: _PeerMarker(name: 'User B', distance: '340m'),
          ),
          Positioned(
            left: 120,
            bottom: 300,
            child: _PeerMarker(name: 'User C', distance: '580m', isSOS: true),
          ),

          // Header overlay
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: GlassCard(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      borderRadius: 14,
                      child: Row(
                        children: [
                          Icon(Icons.map_rounded,
                              color: AppColors.info, size: 22),
                          const SizedBox(width: 10),
                          Text(
                            'Mesh Network Map',
                            style:
                                Theme.of(context).textTheme.titleMedium,
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.safe.withAlpha(26),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.safe,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  '3 nearby',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.safe,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2),
            ),
          ),

          // Bottom info card
          Positioned(
            left: 20,
            right: 20,
            bottom: 110,
            child: GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.my_location_rounded,
                          color: AppColors.accent, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Your Location',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'GPS: Waiting for satellite fix...',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Accuracy: -- m  |  Sharing: Active',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.safe),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 400.ms, duration: 400.ms).slideY(begin: 0.2),
          ),
        ],
      ),
    );
  }
}

class _PeerMarker extends StatelessWidget {
  final String name;
  final String distance;
  final bool isSOS;

  const _PeerMarker({
    required this.name,
    required this.distance,
    this.isSOS = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight.withAlpha(230),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSOS ? AppColors.emergency.withAlpha(128) : AppColors.glassBorder,
            ),
          ),
          child: Column(
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isSOS ? AppColors.emergency : AppColors.textPrimary,
                ),
              ),
              Text(
                distance,
                style: const TextStyle(
                  fontSize: 9,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSOS ? AppColors.emergency : AppColors.meshActive,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: (isSOS ? AppColors.emergency : AppColors.meshActive)
                    .withAlpha(128),
                blurRadius: 8,
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0, 0));
  }
}

class _GridMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.glassBorder
      ..strokeWidth = 0.5;

    // Horizontal lines
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    // Vertical lines
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
