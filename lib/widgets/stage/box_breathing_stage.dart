import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class BoxBreathingStage extends StatefulWidget {
  final bool playing;
  const BoxBreathingStage({super.key, required this.playing});

  @override
  State<BoxBreathingStage> createState() => _BoxBreathingStageState();
}

class _BoxBreathingStageState extends State<BoxBreathingStage> with SingleTickerProviderStateMixin {
  // One full lap of the square = one 4-4-4-4 breathing cycle (16s).
  late final AnimationController _c =
  AnimationController(vsync: this, duration: const Duration(seconds: 16))..repeat();

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
          final side = (c.maxWidth < c.maxHeight ? c.maxWidth : c.maxHeight) * 0.6;
          final center = Offset(c.maxWidth / 2, c.maxHeight / 2);
          final half = side / 2;
          return AnimatedBuilder(
            animation: _c,
            builder: (_, _) {
              final t = _c.value; // 0..1 over the full lap
              final phaseIndex = (t * 4).floor().clamp(0, 3);
              final phaseT = (t * 4) - phaseIndex;
              // breathing circle scale: grows on Inhale (0), holds (1), shrinks on Exhale (2), holds (3)
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
              // dot position along the square perimeter
              final perim = t * 4;
              Offset dot;
              if (perim < 1) {
                dot = Offset(center.dx - half + perim * side, center.dy - half);
              } else if (perim < 2) {
                dot = Offset(center.dx + half, center.dy - half + (perim - 1) * side);
              } else if (perim < 3) {
                dot = Offset(center.dx + half - (perim - 2) * side, center.dy + half);
              } else {
                dot = Offset(center.dx - half, center.dy + half - (perim - 3) * side);
              }

              return Stack(
                fit: StackFit.expand,
                children: [
                  // breathing circle
                  Center(
                    child: Container(
                      width: side * 0.7 * breath,
                      height: side * 0.7 * breath,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [AppColors.accent2.withValues(alpha: 0.35), AppColors.accent.withValues(alpha: 0.05)],
                        ),
                      ),
                    ),
                  ),
                  // square path
                  Positioned(
                    left: center.dx - half,
                    top: center.dy - half,
                    width: side,
                    height: side,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.glassBorder.withValues(alpha: 0.55), width: 2),
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                  // phase label
                  Positioned(
                    top: center.dy - 10,
                    left: 0,
                    right: 0,
                    child: Text(
                      _phaseLabels[phaseIndex],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFFDCEFFF),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  // moving glow dot
                  Positioned(
                    left: dot.dx - 9,
                    top: dot.dy - 9,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.glow,
                        boxShadow: [BoxShadow(color: AppColors.glow.withValues(alpha: 0.8), blurRadius: 14)],
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
}
