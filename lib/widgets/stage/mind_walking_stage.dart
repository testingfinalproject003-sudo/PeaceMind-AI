import 'dart:math';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class MindWalkingStage extends StatelessWidget {
  final double progress; // 0..1 through the current step
  final bool playing;
  const MindWalkingStage({super.key, required this.progress, required this.playing});

  static const _steps = 14;

  Offset _pointAt(double t, Size size) {
    final x = 0.08 * size.width + t * 0.84 * size.width;
    final y = size.height * 0.55 + sin(t * pi * 2.4) * size.height * 0.22;
    return Offset(x, y);
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        color: AppColors.stageBg,
        child: LayoutBuilder(builder: (context, c) {
          final size = Size(c.maxWidth, c.maxHeight);
          final walkerT = progress.clamp(0.0, 1.0);
          return Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(
                size: size,
                painter: _PathPainter(pointAt: (t) => _pointAt(t, size)),
              ),
              ...List.generate(_steps, (i) {
                final t = i / (_steps - 1);
                final lit = t <= walkerT + 0.001;
                final p = _pointAt(t, size);
                return AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  left: p.dx - 5,
                  top: p.dy - 5,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 400),
                    opacity: lit ? 1 : 0.18,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: lit ? AppColors.accent2 : Colors.white24,
                        boxShadow: lit
                            ? [BoxShadow(color: AppColors.glow.withOpacity(0.7), blurRadius: 10)]
                            : null,
                      ),
                    ),
                  ),
                );
              }),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                left: _pointAt(walkerT, size).dx - 16,
                top: _pointAt(walkerT, size).dy - 34,
                child: Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.accentGradient,
                    boxShadow: [BoxShadow(color: AppColors.glow.withOpacity(0.8), blurRadius: 16)],
                  ),
                  child: const Icon(Icons.directions_walk_rounded, color: Colors.white, size: 20),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _PathPainter extends CustomPainter {
  final Offset Function(double t) pointAt;
  _PathPainter({required this.pointAt});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.12)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final path = Path();
    const n = 60;
    for (int i = 0; i <= n; i++) {
      final t = i / n;
      final p = pointAt(t);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _PathPainter oldDelegate) => false;
}
