import 'dart:math';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Node keys used by grounding_data.dart step definitions.
const kSenseIcons = {
  'sight': Icons.visibility_rounded,
  'sound': Icons.hearing_rounded,
  'touch': Icons.back_hand_rounded,
  'smell': Icons.air_rounded,
  'taste': Icons.restaurant_rounded,
};

const kSenseLabels = {
  'sight': '5 · See',
  'sound': '4 · Hear',
  'touch': '3 · Touch',
  'smell': '2 · Smell',
  'taste': '1 · Taste',
};

class GroundingStage extends StatefulWidget {
  final List<String> activeNodes;
  final bool playing;
  const GroundingStage({super.key, required this.activeNodes, required this.playing});

  @override
  State<GroundingStage> createState() => _GroundingStageState();
}

class _GroundingStageState extends State<GroundingStage> with TickerProviderStateMixin {
  late final AnimationController _pulse =
  AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))..repeat(reverse: true);
  late final AnimationController _drift =
  AnimationController(vsync: this, duration: const Duration(seconds: 24))..repeat();

  @override
  void dispose() {
    _pulse.dispose();
    _drift.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keys = kSenseIcons.keys.toList();
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        color: AppColors.stageBg,
        child: LayoutBuilder(builder: (context, c) {
          final size = min(c.maxWidth, c.maxHeight);
          final radius = size * 0.34;
          final center = Offset(c.maxWidth / 2, c.maxHeight / 2);
          return Stack(
            fit: StackFit.expand,
            children: [
              // slow rotating soft glow backdrop
              AnimatedBuilder(
                animation: _drift,
                builder: (_, _) => Transform.rotate(
                  angle: _drift.value * 2 * pi,
                  child: Container(
                    alignment: Alignment.center,
                    child: Container(
                      width: size * 0.7,
                      height: size * 0.7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [AppColors.accent.withValues(alpha: 0.18), Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // center anchor
              Positioned(
                left: center.dx - 26,
                top: center.dy - 26,
                child: Container(
                  width: 52,
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.08),
                    border: Border.all(color: AppColors.glassBorder.withValues(alpha: 0.5)),
                  ),
                  child: const Icon(Icons.self_improvement_rounded, color: Color(0xFFDCEFFF), size: 26),
                ),
              ),
              ...List.generate(keys.length, (i) {
                final angle = -pi / 2 + i * (2 * pi / keys.length);
                final pos = Offset(center.dx + radius * cos(angle), center.dy + radius * sin(angle));
                final active = widget.activeNodes.contains(keys[i]);
                return Positioned(
                  left: pos.dx - 30,
                  top: pos.dy - 34,
                  child: AnimatedBuilder(
                    animation: _pulse,
                    builder: (_, _) {
                      final scale = active ? (1 + _pulse.value * 0.12) : 1.0;
                      return Transform.scale(
                        scale: scale,
                        child: Column(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: active ? AppColors.accentGradient : null,
                                color: active ? null : Colors.white.withValues(alpha: 0.06),
                                border: Border.all(
                                    color: active ? Colors.transparent : AppColors.glassBorder.withValues(alpha: 0.4)),
                                boxShadow: active
                                    ? [BoxShadow(color: AppColors.glow.withValues(alpha: 0.7), blurRadius: 18)]
                                    : null,
                              ),
                              child: Icon(kSenseIcons[keys[i]], color: Colors.white, size: 20),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              kSenseLabels[keys[i]]!,
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                                color: active ? const Color(0xFFDCEFFF) : const Color(0x99DCEFFF),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              }),
            ],
          );
        }),
      ),
    );
  }
}
