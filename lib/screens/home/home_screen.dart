import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/colors.dart';
import '../../widgets/common/glass_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _meshAnimController;

  @override
  void initState() {
    super.initState();
    _meshAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _meshAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            // App bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'DisasterNet',
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                        ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.safe,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.safe.withAlpha(128),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Mesh Network Active',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppColors.safe),
                            ),
                          ],
                        ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                      ],
                    ),
                    Row(
                      children: [
                        _HeaderIconButton(
                          icon: Icons.people_outline_rounded,
                          onTap: () {},
                        ),
                        const SizedBox(width: 8),
                        _HeaderIconButton(
                          icon: Icons.settings_rounded,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Mesh Visualization
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: GlassCard(
                  height: 180,
                  child: AnimatedBuilder(
                    animation: _meshAnimController,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: _MeshVisualizerPainter(
                          progress: _meshAnimController.value,
                        ),
                        size: Size.infinite,
                      );
                    },
                  ),
                ),
              ).animate().fadeIn(delay: 300.ms, duration: 600.ms).scale(begin: const Offset(0.95, 0.95)),
            ),

            // Status Cards Row
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: _StatusCard(
                        icon: Icons.people_rounded,
                        label: 'Nearby Peers',
                        value: '0',
                        color: AppColors.meshActive,
                        delay: 400,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatusCard(
                        icon: Icons.warning_amber_rounded,
                        label: 'Active Alerts',
                        value: '0',
                        color: AppColors.warning,
                        delay: 500,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatusCard(
                        icon: Icons.sos_rounded,
                        label: 'SOS Signals',
                        value: '0',
                        color: AppColors.emergency,
                        delay: 600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Quick Actions Title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.headlineSmall,
                ).animate().fadeIn(delay: 600.ms),
              ),
            ),

            // Quick Action Grid
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.4,
                ),
                delegate: SliverChildListDelegate([
                  _QuickActionCard(
                    icon: Icons.sos_rounded,
                    title: 'Send SOS',
                    subtitle: 'Emergency broadcast',
                    gradient: AppColors.emergencyGradient,
                    glowColor: AppColors.emergency,
                    delay: 700,
                    onTap: () {},
                  ),
                  _QuickActionCard(
                    icon: Icons.map_rounded,
                    title: 'Live Map',
                    subtitle: 'View locations',
                    gradient: AppColors.meshGradient,
                    glowColor: AppColors.accent,
                    delay: 800,
                    onTap: () {},
                  ),
                  _QuickActionCard(
                    icon: Icons.campaign_rounded,
                    title: 'Post Alert',
                    subtitle: 'Warn community',
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                    ),
                    glowColor: AppColors.warning,
                    delay: 900,
                    onTap: () {},
                  ),
                  _QuickActionCard(
                    icon: Icons.chat_rounded,
                    title: 'Mesh Chat',
                    subtitle: 'Message peers',
                    gradient: const LinearGradient(
                      colors: [Color(0xFF06B6D4), Color(0xFF0891B2)],
                    ),
                    glowColor: AppColors.meshActive,
                    delay: 1000,
                    onTap: () {},
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.glassWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Icon(icon, size: 20, color: AppColors.textSecondary),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final int delay;

  const _StatusCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: delay), duration: 400.ms).slideY(begin: 0.1);
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final LinearGradient gradient;
  final Color glowColor;
  final int delay;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.glowColor,
    required this.delay,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: glowColor.withAlpha(51),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(51),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withAlpha(179),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: delay), duration: 400.ms).scale(begin: const Offset(0.9, 0.9));
  }
}

/// Custom painter that draws an animated mesh network visualization
class _MeshVisualizerPainter extends CustomPainter {
  final double progress;

  _MeshVisualizerPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final nodes = <Offset>[];
    final rng = Random(42);

    // Generate node positions
    for (int i = 0; i < 12; i++) {
      final baseX = rng.nextDouble() * size.width;
      final baseY = rng.nextDouble() * size.height;
      final offsetX = sin(progress * 2 * pi + i) * 8;
      final offsetY = cos(progress * 2 * pi + i * 0.7) * 6;
      nodes.add(Offset(baseX + offsetX, baseY + offsetY));
    }

    // Draw connections
    final linePaint = Paint()
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < nodes.length; i++) {
      for (int j = i + 1; j < nodes.length; j++) {
        final dist = (nodes[i] - nodes[j]).distance;
        if (dist < size.width * 0.45) {
          final alpha = ((1.0 - dist / (size.width * 0.45)) * 0.3).clamp(0.0, 1.0);
          linePaint.color = AppColors.meshActive.withAlpha((alpha * 255).toInt());
          canvas.drawLine(nodes[i], nodes[j], linePaint);
        }
      }
    }

    // Draw nodes
    for (int i = 0; i < nodes.length; i++) {
      // Glow
      final glowPaint = Paint()
        ..color = (i == 0 ? AppColors.accent : AppColors.meshActive).withAlpha(51)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(nodes[i], 8, glowPaint);

      // Core dot
      final dotPaint = Paint()
        ..color = i == 0 ? AppColors.accent : AppColors.meshActive;
      canvas.drawCircle(nodes[i], 4, dotPaint);

      // Inner highlight
      final highlightPaint = Paint()..color = Colors.white.withAlpha(128);
      canvas.drawCircle(nodes[i], 1.5, highlightPaint);
    }

    // Draw "You" label on first node
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'You',
        style: TextStyle(
          color: AppColors.accent.withAlpha(204),
          fontSize: 9,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, nodes[0] + const Offset(-8, 10));
  }

  @override
  bool shouldRepaint(covariant _MeshVisualizerPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
