import 'dart:math';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class BoxBreathingStage extends StatefulWidget {
  final bool playing;
  const BoxBreathingStage({super.key, required this.playing});

  @override
  State<BoxBreathingStage> createState() => _BoxBreathingStageState();
}

class _BoxBreathingStageState extends State<BoxBreathingStage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 16),
  )..repeat();

  @override
  void didUpdateWidget(covariant BoxBreathingStage old) {
    super.didUpdateWidget(old);
    if (widget.playing && !_c.isAnimating) {
      _c.repeat();
    } else if (!widget.playing && _c.isAnimating) {
      _c.stop();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  static const _phaseLabels = ['Inhale', 'Hold', 'Exhale', 'Hold'];

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        color: AppColors.stageBg,
        child: LayoutBuilder(builder: (context, c) {
          final side =
              (c.maxWidth < c.maxHeight ? c.maxWidth : c.maxHeight) * 0.6;
          final center = Offset(c.maxWidth / 2, c.maxHeight / 2);
          final half = side / 2;
          return AnimatedBuilder(
            animation: _c,
            builder: (_, _) {
              final t = _c.value;
              final phaseIndex = (t * 4).floor().clamp(0, 3);
              final phaseT = (t * 4) - phaseIndex;

              double breath;
              switch (phaseIndex) {
                case 0:
                  breath = 0.55 + 0.45 * phaseT;
                  break;
                case 1:
                  breath = 1.0;
                  break;
                case 2:
                  breath = 1.0 - 0.45 * phaseT;
                  break;
                default:
                  breath = 0.55;
              }

              final perim = t * 4;
              Offset dot;
              if (perim < 1) {
                dot = Offset(
                    center.dx - half + perim * side, center.dy - half);
              } else if (perim < 2) {
                dot = Offset(center.dx + half,
                    center.dy - half + (perim - 1) * side);
              } else if (perim < 3) {
                dot = Offset(
                    center.dx + half - (perim - 2) * side, center.dy + half);
              } else {
                dot = Offset(center.dx - half,
                    center.dy + half - (perim - 3) * side);
              }

              return Stack(
                fit: StackFit.expand,
                children: [
                  // ── Ambient particles ──
                  ..._buildParticles(center, side, t),

                  // ── Outer glow ring ──
                  Center(
                    child: Container(
                      width: side * 0.85 * breath,
                      height: side * 0.85 * breath,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.glow
                              .withValues(alpha: 0.15 + 0.15 * breath),
                          width: 2,
                        ),
                      ),
                    ),
                  ),

                  // ── Breathing circle (radial gradient) ──
                  Center(
                    child: Container(
                      width: side * 0.7 * breath,
                      height: side * 0.7 * breath,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.accent2.withValues(alpha: 0.40),
                            AppColors.accent.withValues(alpha: 0.15),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.6, 1.0],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.glow
                                .withValues(alpha: 0.25 * breath),
                            blurRadius: 40 * breath,
                            spreadRadius: 10 * breath,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Square path (rounded corners, subtle glow) ──
                  Positioned(
                    left: center.dx - half,
                    top: center.dy - half,
                    width: side,
                    height: side,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color:
                              AppColors.glassBorder.withValues(alpha: 0.45),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.glow.withValues(alpha: 0.08),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Corner dots ──
                  ..._buildCornerDots(center, half),

                  // ── Phase label ──
                  Positioned(
                    top: center.dy - 10,
                    left: 0,
                    right: 0,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        _phaseLabels[phaseIndex],
                        key: ValueKey(phaseIndex),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFFDCEFFF),
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),

                  // ── Moving glow dot with trail ──
                  ..._buildDotTrail(dot),
                  Positioned(
                    left: dot.dx - 10,
                    top: dot.dy - 10,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.glow,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.glow.withValues(alpha: 0.9),
                            blurRadius: 18,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        }),
      ),
    );
  }

  /// Floating ambient particles that drift slowly around the center.
  List<Widget> _buildParticles(Offset center, double side, double t) {
    const count = 8;
    return List.generate(count, (i) {
      final seed = i * 137.5;
      final angle = seed + t * 2 * pi * 0.3;
      final radius = side * 0.55 + sin(seed + t * pi) * 20;
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);
      final size = 2.5 + sin(seed * 2 + t * pi * 2) * 1.5;
      final opacity = 0.15 + 0.15 * sin(seed + t * pi * 2);
      return Positioned(
        left: x - size / 2,
        top: y - size / 2,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.glow.withValues(alpha: opacity),
          ),
        ),
      );
    });
  }

  /// Small dots at each corner of the square path.
  List<Widget> _buildCornerDots(Offset center, double half) {
    final corners = [
      Offset(center.dx - half, center.dy - half),
      Offset(center.dx + half, center.dy - half),
      Offset(center.dx + half, center.dy + half),
      Offset(center.dx - half, center.dy + half),
    ];
    return corners.map((c) {
      return Positioned(
        left: c.dx - 3,
        top: c.dy - 3,
        child: Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.glassBorder.withValues(alpha: 0.6),
          ),
        ),
      );
    }).toList();
  }

  /// Trail dots behind the moving glow dot for a comet effect.
  List<Widget> _buildDotTrail(Offset dot) {
    return List.generate(3, (i) {
      // simplified trail: just smaller, more transparent dots near main dot
      final dx = dot.dx - (i + 1) * 4 * (dot.dx > 100 ? 1 : -1);
      final dy = dot.dy - (i + 1) * 2;
      return Positioned(
        left: dx - 4,
        top: dy - 4,
        child: Container(
          width: 8 - i * 2.0,
          height: 8 - i * 2.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.glow.withValues(alpha: 0.3 - i * 0.08),
          ),
        ),
      );
    });
  }
}
