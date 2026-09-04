import 'package:flutter/material.dart';

/// Lightweight pulsing skeleton block — spinner-free loading placeholder.
/// No external package: simple opacity pulse on a rounded container.
class SkeletonBlock extends StatefulWidget {
  const SkeletonBlock({
    super.key,
    this.width = double.infinity,
    this.height = 14,
    this.radius = 8,
    this.color,
  });

  final double? width;
  final double height;
  final double radius;
  final Color? color;

  @override
  State<SkeletonBlock> createState() => _SkeletonBlockState();
}

class _SkeletonBlockState extends State<SkeletonBlock>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = widget.color ??
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08);
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) => Opacity(
        opacity: 0.45 + 0.55 * _pulse.value,
        child: child,
      ),
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: base,
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      ),
    );
  }
}
