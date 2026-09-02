import 'dart:math' as math;

import 'package:flutter/material.dart';

class AudioCallOrb extends StatefulWidget {
  const AudioCallOrb({
    super.key,
    required this.size,
    required this.isActive,
    required this.isListening,
  });

  final double size;
  final bool isActive;
  final bool isListening;

  @override
  State<AudioCallOrb> createState() => _AudioCallOrbState();
}

class _AudioCallOrbState extends State<AudioCallOrb>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulse;
  late final Animation<double> _float;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    _pulse = Tween<double>(begin: 0.9, end: 1.08).chain(
      CurveTween(curve: Curves.easeInOutCubic),
    ).animate(_controller);

    _float = Tween<double>(begin: 0.0, end: 1.0).chain(
      CurveTween(curve: Curves.easeInOutSine),
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final pulseValue = _pulse.value;
        final floatOffset = math.sin(_float.value * math.pi * 2) * 10;

        return Transform.translate(
          offset: Offset(0, floatOffset),
          child: Transform.rotate(
            angle: _controller.value * math.pi * 2,
            child: Stack(
              alignment: Alignment.center,
              children: [
                _ring(
                  size: widget.size * 1.45,
                  color: const Color(0xFFB39DDB).withValues(alpha: 0.25),
                  thickness: 2,
                  delay: 0.0,
                ),
                _ring(
                  size: widget.size * 1.8,
                  color: const Color(0xFF9575CD).withValues(alpha: 0.18),
                  thickness: 2,
                  delay: 0.5,
                ),
                _ring(
                  size: widget.size * 2.12,
                  color: const Color(0xFF7E57C2).withValues(alpha: 0.12),
                  thickness: 2,
                  delay: 1.0,
                ),
                Transform.scale(
                  scale: widget.isListening ? pulseValue : 1.0,
                  child: Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFB39DDB),
                          Color(0xFF9575CD),
                          Color(0xFF7E57C2),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFB39DDB).withValues(alpha: 0.45),
                          blurRadius: 32,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        widget.isActive ? Icons.mic_rounded : Icons.phone_in_talk_rounded,
                        size: widget.size * 0.28,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _ring({
    required double size,
    required Color color,
    required double thickness,
    required double delay,
  }) {
    final phase = (_controller.value + delay) % 1.0;
    final alphaMultiplier = 1.0 - (phase * 0.65);

    return Transform.scale(
      scale: 0.9 + (phase * 0.25),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: color.withValues(alpha: alphaMultiplier),
            width: thickness,
          ),
        ),
      ),
    );
  }
}
