import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Joint hotspot positions as fractions of the stage size, copied verbatim
/// from the original `.joint` left/top percentages.
const Map<String, Offset> kBodyJoints = {
  'n-neck': Offset(0.50, 0.18),
  'n-lsh': Offset(0.36, 0.235),
  'n-rsh': Offset(0.64, 0.235),
  'n-chest': Offset(0.50, 0.29),
  'n-lelbow': Offset(0.32, 0.357),
  'n-relbow': Offset(0.68, 0.357),
  'n-hip': Offset(0.50, 0.455),
  'n-lknee': Offset(0.42, 0.653),
  'n-rknee': Offset(0.58, 0.653),
  'n-lfoot': Offset(0.44, 0.845),
  'n-rfoot': Offset(0.56, 0.845),
};

class BodyScanStage extends StatefulWidget {
  final List<String> activeNodes;
  final bool eyesClosed;
  final bool playing;
  const BodyScanStage({
    super.key,
    required this.activeNodes,
    required this.eyesClosed,
    required this.playing,
  });

  @override
  State<BodyScanStage> createState() => _BodyScanStageState();
}

class _BodyScanStageState extends State<BodyScanStage> with SingleTickerProviderStateMixin {
  late final AnimationController _beam =
  AnimationController(vsync: this, duration: const Duration(milliseconds: 3600))..repeat(reverse: true);

  @override
  void didUpdateWidget(covariant BodyScanStage old) {
    super.didUpdateWidget(old);
    if (widget.playing && !_beam.isAnimating) {
      _beam.repeat(reverse: true);
    } else if (!widget.playing && _beam.isAnimating) {
      _beam.stop();
    }
  }

  @override
  void dispose() {
    _beam.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        color: AppColors.stageBg,
        child: LayoutBuilder(builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;
          return Stack(
            fit: StackFit.expand,
            children: [
              Center(
                child: Image.asset(
                  'assets/images/body_scan.jpg',
                  fit: BoxFit.contain,
                  height: h,
                  width: w,
                ),
              ),
              // scanning beam
              AnimatedBuilder(
                animation: _beam,
                builder: (_, __) {
                  final t = Curves.easeInOut.transform(_beam.value);
                  final top = 0.01 * h + t * (0.92 * h);
                  return Positioned(
                    left: 0,
                    right: 0,
                    top: top,
                    child: Container(
                      height: 90,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0x0066C6FF),
                            Color(0x6666C6FF),
                            Color(0x6666C6FF),
                            Color(0x0066C6FF),
                          ],
                          stops: [0.0, 0.45, 0.55, 1.0],
                        ),
                      ),
                    ),
                  );
                },
              ),
              // joint hotspots
              ...kBodyJoints.entries.map((entry) {
                final active = widget.activeNodes.contains(entry.key);
                return AnimatedPositioned(
                  duration: const Duration(milliseconds: 400),
                  left: entry.value.dx * w - 13,
                  top: entry.value.dy * h - 13,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 600),
                    opacity: active ? 1 : 0,
                    child: _PulsingJoint(active: active),
                  ),
                );
              }),
              // eyes closed overlay
              AnimatedOpacity(
                duration: const Duration(milliseconds: 800),
                opacity: widget.eyesClosed ? 1 : 0,
                child: IgnorePointer(
                  child: Container(
                    color: const Color(0x8C050912),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: const Text(
                      'Close your eyes and simply listen ✦',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFFDCEFFF),
                        letterSpacing: 0.05,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: _VoiceBars(playing: widget.playing),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _PulsingJoint extends StatefulWidget {
  final bool active;
  const _PulsingJoint({required this.active});
  @override
  State<_PulsingJoint> createState() => _PulsingJointState();
}

class _PulsingJointState extends State<_PulsingJoint> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
  AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        final scale = widget.active ? (1 + _c.value * 0.35) : 1.0;
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 26,
            height: 26,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Color(0xF2FF5C5C), Color(0x59FF5C5C), Color(0x00FF5C5C)],
                stops: [0.0, 0.55, 0.75],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _VoiceBars extends StatefulWidget {
  final bool playing;
  const _VoiceBars({required this.playing});
  @override
  State<_VoiceBars> createState() => _VoiceBarsState();
}

class _VoiceBarsState extends State<_VoiceBars> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
  AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat();
  static const _heights = [6.0, 14.0, 9.0, 16.0, 8.0];
  static const _delays = [0.0, 0.15, 0.3, 0.45, 0.6];

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: widget.playing ? 0.9 : 0.35,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(5, (i) {
          return AnimatedBuilder(
            animation: _c,
            builder: (_, __) {
              double phase = ((_c.value + _delays[i]) % 1.0);
              double scale = widget.playing ? (0.4 + 0.6 * (0.5 - 0.5 * (1 - 2 * phase).abs()) * 2).clamp(0.4, 1.0) : 0.3;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                width: 3,
                height: _heights[i] * scale,
                decoration: BoxDecoration(
                  color: AppColors.accent2,
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
