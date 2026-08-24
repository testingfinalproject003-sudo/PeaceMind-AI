import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/exercise_models.dart';
import 'glass_widgets.dart';

class CompletionOverlay extends StatefulWidget {
  final CompletionConfig config;
  final Duration totalTime;
  final int cycles;
  final VoidCallback onClose;
  final VoidCallback onRestart;

  const CompletionOverlay({
    super.key,
    required this.config,
    required this.totalTime,
    required this.cycles,
    required this.onClose,
    required this.onRestart,
  });

  @override
  State<CompletionOverlay> createState() => _CompletionOverlayState();
}

class _CompletionOverlayState extends State<CompletionOverlay> with TickerProviderStateMixin {
  late final AnimationController _entrance =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 600))..forward();
  late final AnimationController _bars =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..forward();
  late final List<_ConfettiPiece> _pieces = List.generate(36, (i) => _ConfettiPiece(i));

  @override
  void dispose() {
    _entrance.dispose();
    _bars.dispose();
    super.dispose();
  }

  int get calmPct => min(95, 55 + widget.cycles * 15);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.skyGradient),
      child: LayoutBuilder(builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        return Stack(
          children: [
            ..._pieces.map((p) => _ConfettiWidget(piece: p, areaSize: size)),
            SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 28, 22, 20),
              child: Column(
                children: [
                  ScaleTransition(
                    scale: CurvedAnimation(parent: _entrance, curve: Curves.elasticOut),
                    child: Container(
                      width: 74,
                      height: 74,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        gradient: AppColors.goldGradient,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Color(0x73FFAA3C), blurRadius: 26, offset: Offset(0, 12))],
                      ),
                      child: const Text('🏆', style: TextStyle(fontSize: 34)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(widget.config.title,
                      style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.ink)),
                  const SizedBox(height: 4),
                  Text(
                    widget.config.subtitleBuilder(widget.config.unitCount),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12.5, color: AppColors.inkSoft, height: 1.4),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      _StatCard(value: fmtDuration(widget.totalTime), label: 'TOTAL TIME'),
                      const SizedBox(width: 10),
                      _StatCard(value: '${widget.cycles}', label: 'CYCLES DONE'),
                      const SizedBox(width: 10),
                      _StatCard(value: '${widget.config.unitCount}', label: widget.config.unitLabel),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _CalmRing(percent: calmPct),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Estimated calm score based on completed breathing cycles',
                          style: TextStyle(fontSize: 11.5, color: AppColors.inkSoft),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GlassPanel(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.config.chartTitle,
                            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.ink)),
                        const SizedBox(height: 10),
                        ...widget.config.chartRows.map((row) => Padding(
                              padding: const EdgeInsets.only(bottom: 7),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 70,
                                    child: Text(row.label,
                                        style: const TextStyle(fontSize: 9.5, color: AppColors.inkSoft)),
                                  ),
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: Container(
                                        height: 10,
                                        color: const Color(0x99FFFFFF),
                                        alignment: Alignment.centerLeft,
                                        child: AnimatedBuilder(
                                          animation: _bars,
                                          builder: (_, __) => FractionallySizedBox(
                                            widthFactor: (row.percent / 100) * _bars.value,
                                            child: Container(
                                                decoration:
                                                    const BoxDecoration(gradient: AppColors.accentGradient)),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 32,
                                    child: Text('${row.percent}%',
                                        textAlign: TextAlign.right,
                                        style: const TextStyle(
                                            fontSize: 9.5, color: AppColors.ink, fontWeight: FontWeight.w700)),
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: _OverlayButton(label: 'Close', onTap: widget.onClose),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _OverlayButton(label: 'Start New Cycle', primary: true, onTap: widget.onRestart),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
        );
      }),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  const _StatCard({required this.value, required this.label});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GlassPanel(
        radius: 16,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          children: [
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.accent)),
            const SizedBox(height: 2),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 9, color: AppColors.inkSoft)),
          ],
        ),
      ),
    );
  }
}

class _CalmRing extends StatelessWidget {
  final int percent;
  const _CalmRing({required this.percent});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      height: 64,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(64, 64),
            painter: _RingPainter(percent / 100),
          ),
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: Text('$percent%',
                style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.ink, fontSize: 15)),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double frac;
  _RingPainter(this.frac);
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;
    final track = Paint()
      ..color = const Color(0x80FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius;
    canvas.drawCircle(center, radius / 2, track);
    final fg = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius
      ..strokeCap = StrokeCap.butt;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius / 2), -pi / 2, 2 * pi * frac, false, fg);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) => oldDelegate.frac != frac;
}

class _OverlayButton extends StatelessWidget {
  final String label;
  final bool primary;
  final VoidCallback onTap;
  const _OverlayButton({required this.label, required this.onTap, this.primary = false});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: primary ? AppColors.accentGradient : null,
          color: primary ? null : AppColors.glassStrong,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: primary ? Colors.white : AppColors.ink)),
      ),
    );
  }
}

class _ConfettiPiece {
  final double left;
  final Color color;
  final double durationMs;
  final double delayMs;
  _ConfettiPiece(int seed)
      : left = Random(seed * 977).nextDouble(),
        color = AppColors.confettiColors[Random(seed * 131).nextInt(AppColors.confettiColors.length)],
        durationMs = 1800 + Random(seed * 53).nextDouble() * 1400,
        delayMs = Random(seed * 17).nextDouble() * 600;
}

class _ConfettiWidget extends StatefulWidget {
  final _ConfettiPiece piece;
  final Size areaSize;
  const _ConfettiWidget({required this.piece, required this.areaSize});
  @override
  State<_ConfettiWidget> createState() => _ConfettiWidgetState();
}

class _ConfettiWidgetState extends State<_ConfettiWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: Duration(milliseconds: widget.piece.durationMs.round()));
    Future.delayed(Duration(milliseconds: widget.piece.delayMs.round()), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = widget.areaSize.height;
    final w = widget.areaSize.width;
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        final t = _c.value;
        return Positioned(
          left: widget.piece.left * w,
          top: -10 + t * (h + 10),
          child: Opacity(
            opacity: (1 - t).clamp(0, 1),
            child: Transform.rotate(
              angle: t * 2 * pi,
              child: Container(width: 7, height: 12, color: widget.piece.color),
            ),
          ),
        );
      },
    );
  }
}
