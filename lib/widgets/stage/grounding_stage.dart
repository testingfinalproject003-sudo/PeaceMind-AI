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

const _kSenseNumbers = {
  'sight': '5',
  'sound': '4',
  'touch': '3',
  'smell': '2',
  'taste': '1',
};

const _kSenseWords = {
  'sight': 'SEE',
  'sound': 'HEAR',
  'touch': 'TOUCH',
  'smell': 'SMELL',
  'taste': 'TASTE',
};

/// Soft pastel colors only — light blue, lavender, white family.
/// No dark/black colors.
const _kSenseColors = {
  'sight': Color(0xFF8B83C7), // lavender
  'sound': Color(0xFF8CAFE8), // soft blue
  'touch': Color(0xFF9CCFE6), // soft aqua-blue
  'smell': Color(0xFFB7A8E8), // light lavender
  'taste': Color(0xFFB3C3EF), // periwinkle
};

/// Main tone Color(0xFFCFE7FF): soft light blue → white-blue → lavender-white.
/// No dark background.
const _kStageGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFFCFE7FF), Color(0xFFE3F0FF), Color(0xFFF2EDFB)],
  stops: [0.0, 0.55, 1.0],
);

/// Very subtle light motes.
const _kMoteColors = [
  Colors.white,
  Color(0xFFCFE7FF),
  Color(0xFFE4D9F8),
  Color(0xFFE8F3FF),
];

/// Soft readable text tones — light blue / lavender only, no black.
const _kNumberInk = Color(0xFF5E86B0); // soft steel blue
const _kLabelInk = Color(0xFF8FA9C9); // muted sky blue
const _kSoftAccent = Color(0xFF8296CC); // soft lavender-blue

class GroundingStage extends StatefulWidget {
  final List<String> activeNodes;
  final bool playing;

  const GroundingStage({
    super.key,
    required this.activeNodes,
    required this.playing,
  });

  @override
  State<GroundingStage> createState() => _GroundingStageState();
}

class _GroundingStageState extends State<GroundingStage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ambient = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 7),
  );

  @override
  void initState() {
    super.initState();
    if (widget.playing) _ambient.repeat();
  }

  @override
  void didUpdateWidget(covariant GroundingStage old) {
    super.didUpdateWidget(old);

    if (widget.playing && !_ambient.isAnimating) {
      _ambient.repeat();
    } else if (!widget.playing && _ambient.isAnimating) {
      _ambient.stop();
    }
  }

  @override
  void dispose() {
    _ambient.dispose();
    super.dispose();
  }

  List<String> get _activeSenses =>
      kSenseIcons.keys.where((k) => widget.activeNodes.contains(k)).toList();

  @override
  Widget build(BuildContext context) {
    final active = _activeSenses;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: const BoxDecoration(
          gradient: _kStageGradient,
          border: Border.fromBorderSide(
            BorderSide(color: Colors.white, width: 1.2),
          ),
        ),
        child: LayoutBuilder(
          builder: (context, c) {
            final w = c.maxWidth;
            final h = c.maxHeight;
            final stripH = (h * 0.15).clamp(30.0, 48.0);
            final pill = stripH * 0.82;
            final heroW = w * 0.92;
            final heroH = h * 0.90 - stripH;

            return Stack(
              fit: StackFit.expand,
              children: [
                // Soft ambient light.
                AnimatedBuilder(
                  animation: _ambient,
                  builder: (_, _) {
                    final breathe = 0.5 + 0.5 * sin(_ambient.value * 2 * pi);

                    return DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: const Alignment(0, -0.15),
                          radius: 0.95,
                          colors: [
                            Colors.white.withValues(
                              alpha: 0.20 + 0.05 * breathe,
                            ),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.72],
                        ),
                      ),
                    );
                  },
                ),

                // Soft white top sheen.
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.white70, Colors.transparent],
                      stops: [0.0, 0.35],
                    ),
                  ),
                ),

                // Ambient motes.
                AnimatedBuilder(
                  animation: _ambient,
                  builder: (_, _) =>
                      Stack(children: _buildMotes(w, h, _ambient.value)),
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(
                    w * 0.04,
                    h * 0.045,
                    w * 0.04,
                    h * 0.035,
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: Center(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 600),
                            switchInCurve: Curves.easeOutCubic,
                            switchOutCurve: Curves.easeInCubic,
                            transitionBuilder: (child, anim) {
                              return FadeTransition(
                                opacity: anim,
                                child: ScaleTransition(
                                  scale: Tween<double>(
                                    begin: 0.88,
                                    end: 1.0,
                                  ).animate(anim),
                                  child: child,
                                ),
                              );
                            },
                            child: _buildHero(active, heroW, heroH),
                          ),
                        ),
                      ),
                      SizedBox(height: h * 0.02),
                      _buildStrip(active, pill),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHero(List<String> active, double availW, double availH) {
    final Widget content;
    final double ratio;

    if (active.isEmpty) {
      content = _SettleOrb(ambient: _ambient);
      ratio = min(availW / 170, availH / 150);
    } else {
      const gap = 26.0;
      final naturalW = active.length * 124.0 + (active.length - 1) * gap;

      const naturalH = 214.0;

      ratio = min(availW / naturalW, availH / naturalH);

      content = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < active.length; i++) ...[
            if (i > 0) const SizedBox(width: gap),
            _SenseHeroCard(sense: active[i], ambient: _ambient),
          ],
        ],
      );
    }

    final scaled = ratio > 1.0
        ? Transform.scale(scale: min(ratio, 1.3), child: content)
        : content;

    return FittedBox(
      key: ValueKey('grounding-hero-${active.join('|')}'),
      fit: BoxFit.scaleDown,
      child: scaled,
    );
  }

  Widget _buildStrip(List<String> active, double pill) {
    final keys = kSenseIcons.keys.toList();

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: SizedBox(
        height: pill,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < keys.length; i++) ...[
              if (i > 0) SizedBox(width: pill * 0.5),
              _SensePill(
                sense: keys[i],
                active: active.contains(keys[i]),
                size: pill,
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _buildMotes(double w, double h, double t) {
    return List.generate(8, (i) {
      final seed = i * 83.7;

      final x =
          w * (0.5 + 0.36 * sin(seed * 1.7)) + sin(t * 2 * pi * 0.5 + seed) * 9;

      final y =
          h * (0.5 + 0.34 * cos(seed * 0.9)) +
          cos(t * 2 * pi * 0.4 + seed * 2.2) * 7;

      final twinkle = 0.5 + 0.5 * sin(seed + t * 2 * pi * 0.8);

      final size = 2.2 + 2.2 * twinkle;
      final alpha = 0.10 + 0.18 * twinkle;
      final color = _kMoteColors[i % _kMoteColors.length];

      return Positioned(
        left: x - size / 2,
        top: y - size / 2,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: alpha),
          ),
        ),
      );
    });
  }
}

class _SenseHeroCard extends StatelessWidget {
  final String sense;
  final Animation<double> ambient;

  const _SenseHeroCard({required this.sense, required this.ambient});

  @override
  Widget build(BuildContext context) {
    final color = _kSenseColors[sense]!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _kSenseNumbers[sense]!,
          style: const TextStyle(
            fontSize: 62,
            height: 1.0,
            fontWeight: FontWeight.w800,
            color: _kNumberInk,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          _kSenseWords[sense]!,
          style: const TextStyle(
            fontSize: 13,
            letterSpacing: 3.5,
            fontWeight: FontWeight.w700,
            color: _kLabelInk,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: 118,
          height: 118,
          child: switch (sense) {
            'sight' => _SeeVisual(color: color, ambient: ambient),
            'sound' => _HearVisual(color: color, ambient: ambient),
            'touch' => _TouchVisual(color: color, ambient: ambient),
            'smell' => _SmellVisual(color: color, ambient: ambient),
            _ => _TasteVisual(color: color, ambient: ambient),
          },
        ),
      ],
    );
  }
}

class _GlassIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _GlassIcon({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 62,
      height: 62,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.78),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1.4),
      ),
      child: Icon(icon, color: color, size: 29),
    );
  }
}

class _SeeVisual extends StatelessWidget {
  final Color color;
  final Animation<double> ambient;

  const _SeeVisual({required this.color, required this.ambient});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ambient,
      builder: (_, _) {
        final t = ambient.value;
        final breathe = 0.5 + 0.5 * sin(t * 2 * pi);

        return Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: Container(
                width: 104 + 12 * breathe,
                height: 104 + 12 * breathe,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      color.withValues(alpha: 0.14 + 0.08 * breathe),
                      color.withValues(alpha: 0.03),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                ),
              ),
            ),
            _twinkle(const Alignment(-0.85, -0.75), 0.0, t),
            _twinkle(const Alignment(0.9, -0.55), 1.4, t),
            _twinkle(const Alignment(0.75, 0.85), 2.8, t),
            _twinkle(const Alignment(-0.95, 0.55), 4.1, t),
            Center(
              child: _GlassIcon(icon: kSenseIcons['sight']!, color: color),
            ),
          ],
        );
      },
    );
  }

  Widget _twinkle(Alignment alignment, double phase, double t) {
    final tw = 0.5 + 0.5 * sin(t * 2 * pi * 1.4 + phase);

    final size = 3.5 + 2.5 * tw;

    return Align(
      alignment: alignment,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.35 + 0.55 * tw),
        ),
      ),
    );
  }
}

class _HearVisual extends StatelessWidget {
  final Color color;
  final Animation<double> ambient;

  const _HearVisual({required this.color, required this.ambient});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ambient,
      builder: (_, _) {
        final t = ambient.value;

        return Stack(
          fit: StackFit.expand,
          children: [
            ...List.generate(3, (i) => _ring(i, t)),
            Center(
              child: _GlassIcon(icon: kSenseIcons['sound']!, color: color),
            ),
          ],
        );
      },
    );
  }

  Widget _ring(int i, double t) {
    final p = (t * 1.5 + i / 3) % 1.0;

    final r = 0.34 + 0.62 * Curves.easeOutCubic.transform(p);

    return Center(
      child: Container(
        width: 118 * r,
        height: 118 * r,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: color.withValues(alpha: (1 - p) * 0.5),
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

class _TouchVisual extends StatelessWidget {
  final Color color;
  final Animation<double> ambient;

  const _TouchVisual({required this.color, required this.ambient});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ambient,
      builder: (_, _) {
        final t = ambient.value;

        final press = pow(max(0.0, sin(t * 2 * pi)), 2).toDouble();

        return Stack(
          fit: StackFit.expand,
          children: [
            ...List.generate(2, (i) => _ripple(i, t)),
            Center(
              child: Transform.scale(
                scale: 1 - 0.055 * press,
                child: _GlassIcon(icon: kSenseIcons['touch']!, color: color),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _ripple(int i, double t) {
    final p = (t * 1.1 + i / 2) % 1.0;

    final r = 0.30 + 0.66 * Curves.easeOutCubic.transform(p);

    return Center(
      child: Container(
        width: 118 * r,
        height: 118 * r,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: color.withValues(alpha: (1 - p) * 0.38),
            width: 2.2,
          ),
        ),
      ),
    );
  }
}

class _SmellVisual extends StatelessWidget {
  final Color color;
  final Animation<double> ambient;

  const _SmellVisual({required this.color, required this.ambient});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ambient,
      builder: (_, _) {
        final t = ambient.value;

        return Stack(
          fit: StackFit.expand,
          children: [
            ...List.generate(6, (j) => _mote(j, t)),
            Center(
              child: _GlassIcon(icon: kSenseIcons['smell']!, color: color),
            ),
          ],
        );
      },
    );
  }

  Widget _mote(int j, double t) {
    final p = (t * 1.15 + j / 6) % 1.0;

    final dy = 18 - p * 88;

    final dx = sin(p * 2 * pi + j * 1.9) * 16 * sin(p * pi);

    final opacity = sin(p * pi) * 0.5;

    final size = 2.6 + 2.0 * (0.5 + 0.5 * sin(j * 2.3));

    return Positioned(
      left: 59 + dx - size / 2,
      top: 59 + dy - size / 2,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: opacity),
        ),
      ),
    );
  }
}

class _TasteVisual extends StatelessWidget {
  final Color color;
  final Animation<double> ambient;

  const _TasteVisual({required this.color, required this.ambient});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ambient,
      builder: (_, _) {
        final t = ambient.value;

        final pulse = 0.5 + 0.5 * sin(t * 2 * pi * 0.9);

        return Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: Container(
                width: 86 + 24 * pulse,
                height: 86 + 24 * pulse,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      color.withValues(alpha: 0.12 + 0.10 * pulse),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.85],
                  ),
                ),
              ),
            ),
            Center(
              child: Container(
                width: 112 + 6 * pulse,
                height: 112 + 6 * pulse,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color.withValues(alpha: 0.16 + 0.18 * pulse),
                    width: 1.2,
                  ),
                ),
              ),
            ),
            Center(
              child: _GlassIcon(icon: kSenseIcons['taste']!, color: color),
            ),
          ],
        );
      },
    );
  }
}

class _SettleOrb extends StatelessWidget {
  final Animation<double> ambient;

  const _SettleOrb({required this.ambient});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: ambient,
          builder: (_, _) {
            final breathe = 0.5 + 0.5 * sin(ambient.value * 2 * pi);

            return Container(
              width: 92 + 10 * breathe,
              height: 92 + 10 * breathe,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white,
                    Colors.white.withValues(alpha: 0.70),
                    Color(0xFFEDE7FF),
                  ],
                  stops: const [0.0, 0.62, 1.0],
                ),
                border: Border.all(color: Colors.white, width: 1.4),
              ),
              child: Icon(
                Icons.self_improvement_rounded,
                color: _kSoftAccent,
                size: 40 + 3 * breathe,
              ),
            );
          },
        ),
        const SizedBox(height: 14),
        const Text(
          '5 · 4 · 3 · 2 · 1',
          style: TextStyle(
            fontSize: 13,
            letterSpacing: 3,
            fontWeight: FontWeight.w700,
            color: _kLabelInk,
          ),
        ),
      ],
    );
  }
}

class _SensePill extends StatelessWidget {
  final String sense;
  final bool active;
  final double size;

  const _SensePill({
    required this.sense,
    required this.active,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final color = _kSenseColors[sense]!;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOut,
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: active
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color.lerp(color, Colors.white, 0.35)!, color],
              )
            : null,
        color: active ? null : Colors.white.withValues(alpha: 0.55),
        border: Border.all(
          color: active
              ? Colors.white
              : AppColors.glassBorder.withValues(alpha: 0.75),
          width: active ? 1.6 : 1.0,
        ),
      ),
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 420),
        style: TextStyle(
          fontSize: size * 0.42,
          height: 1.0,
          fontWeight: active ? FontWeight.w800 : FontWeight.w600,
          color: active ? Colors.white : _kLabelInk,
        ),
        child: Text(_kSenseNumbers[sense]!),
      ),
    );
  }
}
