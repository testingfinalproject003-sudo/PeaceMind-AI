import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../theme/app_theme.dart';
import '../models/exercise_models.dart';
import '../providers/garden_provider.dart';
import 'glass_widgets.dart';

class CompletionOverlay extends StatefulWidget {
  final CompletionConfig config;
  final Duration totalTime;
  final int cycles;
  final int previousCycles;
  final VoidCallback onClose;
  final VoidCallback onRestart;

  const CompletionOverlay({
    super.key,
    required this.config,
    required this.totalTime,
    required this.cycles,
    this.previousCycles = 0,
    required this.onClose,
    required this.onRestart,
  });

  @override
  State<CompletionOverlay> createState() => _CompletionOverlayState();
}

class _CompletionOverlayState extends State<CompletionOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _entrance = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 700))
    ..forward();
  late final AnimationController _bars = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1400))
    ..forward();
  late final AnimationController _rings = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1600))
    ..forward();
  late final AnimationController _pulse = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2000))
    ..repeat(reverse: true);
  late final List<_ConfettiPiece> _pieces =
      List.generate(36, (i) => _ConfettiPiece(i));

  @override
  void dispose() {
    _entrance.dispose();
    _bars.dispose();
    _rings.dispose();
    _pulse.dispose();
    super.dispose();
  }

  int get calmPct => min(95, 55 + widget.cycles * 15);
  int get focusPct => min(98, 60 + widget.cycles * 12);
  int get prevCalmPct =>
      widget.previousCycles > 0 ? min(95, 55 + widget.previousCycles * 15) : 0;
  int get prevFocusPct =>
      widget.previousCycles > 0 ? min(98, 60 + widget.previousCycles * 12) : 0;

  static const _motivations = [
    'You showed up for yourself today — that takes real strength.',
    'Every breath you took was a choice to be present.',
    'This calm is yours. Carry it forward.',
    'You are building a habit that changes lives.',
    'Small moments of stillness create big shifts.',
    'Your mind and body thank you for this pause.',
    'Consistency is the foundation of inner peace.',
  ];

  String get _motivation =>
      _motivations[widget.cycles % _motivations.length];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _entrance,
      builder: (context, _) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.skyTop,
                AppColors.skyMid,
                AppColors.skyBot,
                AppColors.accent.withValues(alpha: 0.08 * _entrance.value),
              ],
            ),
          ),
          child: LayoutBuilder(builder: (context, constraints) {
            final size = Size(constraints.maxWidth, constraints.maxHeight);
            return Stack(
              children: [
                ..._pieces.map((p) => _ConfettiWidget(piece: p, areaSize: size)),
                SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                    child: Column(
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 10),
                        _buildMotivationQuote(),
                        const SizedBox(height: 12),
                        _buildStatCards(),
                        const SizedBox(height: 10),
                        if (widget.previousCycles > 0) ...[
                          _buildCycleComparison(),
                          const SizedBox(height: 10),
                        ],
                        _buildScoreRings(),
                        const SizedBox(height: 10),
                        _buildTreeProgress(),
                        const SizedBox(height: 10),
                        _buildAnalysisChart(),
                        const SizedBox(height: 14),
                        _buildButtons(),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        );
      },
    );
  }

  // ── Header ──
  Widget _buildHeader() {
    return ScaleTransition(
      scale: CurvedAnimation(parent: _entrance, curve: Curves.elasticOut),
      child: Column(
        children: [
          Container(
            width: 78,
            height: 78,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: AppColors.goldGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0x55FFAA3C),
                  blurRadius: 30 + 10 * _pulse.value,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: const Text('🏆', style: TextStyle(fontSize: 36)),
          ),
          const SizedBox(height: 10),
          Text(
            widget.config.title,
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.ink),
          ),
          const SizedBox(height: 3),
          Text(
            widget.config.subtitleBuilder(widget.config.unitCount),
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 12.5, color: AppColors.inkSoft, height: 1.4),
          ),
        ],
      ),
    );
  }

  // ── Motivational quote ──
  Widget _buildMotivationQuote() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accent.withValues(alpha: 0.10),
            AppColors.accent2.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.format_quote_rounded,
              color: AppColors.accent, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _motivation,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.ink,
                fontWeight: FontWeight.w600,
                height: 1.4,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Stat cards row ──
  Widget _buildStatCards() {
    return Row(
      children: [
        _StatCard(
            value: fmtDuration(widget.totalTime),
            label: 'TOTAL TIME',
            icon: Icons.timer_outlined),
        const SizedBox(width: 8),
        _StatCard(
            value: '${widget.cycles}',
            label: 'CYCLES DONE',
            icon: Icons.autorenew_rounded),
        const SizedBox(width: 8),
        _StatCard(
            value: '${widget.config.unitCount}',
            label: widget.config.unitLabel,
            icon: Icons.insights_rounded),
      ],
    );
  }

  // ── Cycle comparison (previous vs current) ──
  Widget _buildCycleComparison() {
    final improved = widget.cycles > widget.previousCycles;
    return GlassPanel(
      radius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          // Previous
          Expanded(
            child: _MiniCompare(
              label: 'Previous',
              cycles: widget.previousCycles,
              calm: prevCalmPct,
              focus: prevFocusPct,
            ),
          ),
          // Arrow
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Column(
              children: [
                Icon(
                  improved
                      ? Icons.trending_up_rounded
                      : Icons.compare_arrows_rounded,
                  color:
                      improved ? AppColors.green : AppColors.inkSoft,
                  size: 20,
                ),
                if (improved)
                  const Text(
                    'Better!',
                    style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        color: AppColors.green),
                  ),
              ],
            ),
          ),
          // Current
          Expanded(
            child: _MiniCompare(
              label: 'Current',
              cycles: widget.cycles,
              calm: calmPct,
              focus: focusPct,
              isCurrent: true,
            ),
          ),
        ],
      ),
    );
  }

  // ── Dual score rings ──
  Widget _buildScoreRings() {
    return Row(
      children: [
        _ScoreRing(
            percent: calmPct,
            label: 'Calm',
            animCtrl: _rings,
            color: AppColors.accent),
        const SizedBox(width: 8),
        _ScoreRing(
            percent: focusPct,
            label: 'Focus',
            animCtrl: _rings,
            color: AppColors.green),
        const SizedBox(width: 8),
        Expanded(
          child: GlassPanel(
            radius: 14,
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.spa_rounded,
                    size: 14, color: AppColors.accent),
                const SizedBox(height: 4),
                Text(
                  'Wellness scores based on your breathing cycles & session duration.',
                  style: const TextStyle(
                      fontSize: 10, color: AppColors.inkSoft, height: 1.4),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Tree growth progress ──
  Widget _buildTreeProgress() {
    return GlassPanel(
      radius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF3ECF7A), Color(0xFF2A9D5C)]),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: AppColors.green.withValues(alpha: 0.25),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Lottie.asset(
              'assets/animations/garden_tree_growing.json',
              width: 30,
              height: 30,
              fit: BoxFit.contain,
              repeat: true,
              errorBuilder: (context, error, stackTrace) =>
                  const Text('🌱', style: TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Garden Progress',
                      style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink),
                    ),
                    const Spacer(),
                    Consumer<GardenProvider>(
                      builder: (_, g, _) => Text(
                        '${g.treeCount}/${GardenProvider.totalSlots}',
                        style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.green),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Consumer<GardenProvider>(
                  builder: (_, g, _) {
                    final frac =
                        g.treeCount / GardenProvider.totalSlots;
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Container(
                        height: 8,
                        color: const Color(0x80FFFFFF),
                        child: AnimatedBuilder(
                          animation: _bars,
                          builder: (_, _) =>
                              FractionallySizedBox(
                            widthFactor: frac * _bars.value,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient:
                                    const LinearGradient(
                                  colors: [
                                    Color(0xFF3ECF7A),
                                    Color(0xFF2A9D5C)
                                  ],
                                ),
                                borderRadius:
                                    BorderRadius.circular(5),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Analysis chart ──
  Widget _buildAnalysisChart() {
    return GlassPanel(
      radius: 18,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    AppColors.accent.withValues(alpha: 0.15),
                    AppColors.accent2.withValues(alpha: 0.08),
                  ]),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.bar_chart_rounded,
                    size: 14, color: AppColors.accent),
              ),
              const SizedBox(width: 8),
              Text(widget.config.chartTitle,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink)),
            ],
          ),
          const SizedBox(height: 10),
          ...widget.config.chartRows.map((row) => Padding(
                padding: const EdgeInsets.only(bottom: 7),
                child: Row(
                  children: [
                    SizedBox(
                      width: 70,
                      child: Text(row.label,
                          style: const TextStyle(
                              fontSize: 9.5, color: AppColors.inkSoft)),
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          height: 12,
                          color: const Color(0x88FFFFFF),
                          alignment: Alignment.centerLeft,
                          child: AnimatedBuilder(
                            animation: _bars,
                            builder: (_, _) =>
                                FractionallySizedBox(
                              widthFactor:
                                  (row.percent / 100) * _bars.value,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: AppColors.accentGradient,
                                  borderRadius:
                                      BorderRadius.circular(6),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 34,
                      child: Text('${row.percent}%',
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                              fontSize: 9.5,
                              color: AppColors.ink,
                              fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  // ── Buttons ──
  Widget _buildButtons() {
    return Row(
      children: [
        Expanded(child: _OverlayButton(
            label: 'Back to Garden', onTap: widget.onClose)),
        const SizedBox(width: 10),
        Expanded(
          child: _OverlayButton(
              label: 'Start New Cycle',
              primary: true,
              onTap: widget.onRestart),
        ),
      ],
    );
  }
}

// ── Stat card ──
class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  const _StatCard(
      {required this.value, required this.label, required this.icon});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GlassPanel(
        radius: 16,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          children: [
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child:
                  Icon(icon, size: 14, color: AppColors.accent),
            ),
            const SizedBox(height: 5),
            Text(value,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.accent)),
            const SizedBox(height: 2),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 8, color: AppColors.inkSoft)),
          ],
        ),
      ),
    );
  }
}

// ── Animated score ring ──
class _ScoreRing extends StatelessWidget {
  final int percent;
  final String label;
  final AnimationController animCtrl;
  final Color color;
  const _ScoreRing({
    required this.percent,
    required this.label,
    required this.animCtrl,
    required this.color,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 58,
          height: 58,
          child: AnimatedBuilder(
            animation: animCtrl,
            builder: (_, _) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(58, 58),
                    painter: _RingPainter(
                        (percent / 100) * animCtrl.value, color),
                  ),
                  Container(
                    width: 46,
                    height: 46,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle),
                    child: Text(
                        '${(percent * animCtrl.value).round()}%',
                        style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink,
                            fontSize: 13)),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 3),
        Text(label,
            style: const TextStyle(
                fontSize: 9,
                color: AppColors.inkSoft,
                fontWeight: FontWeight.w600)),
      ],
    );
  }
}

// ── Ring painter with custom color ──
class _RingPainter extends CustomPainter {
  final double frac;
  final Color color;
  _RingPainter(this.frac, this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;
    final track = Paint()
      ..color = const Color(0x66FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.38;
    canvas.drawCircle(center, radius * 0.68, track);
    final fg = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.38
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius * 0.68),
        -pi / 2,
        2 * pi * frac,
        false,
        fg);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.frac != frac || oldDelegate.color != color;
}

// ── Mini compare column (previous vs current) ──
class _MiniCompare extends StatelessWidget {
  final String label;
  final int cycles;
  final int calm;
  final int focus;
  final bool isCurrent;
  const _MiniCompare({
    required this.label,
    required this.cycles,
    required this.calm,
    required this.focus,
    this.isCurrent = false,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      decoration: BoxDecoration(
        color: isCurrent
            ? AppColors.accent.withValues(alpha: 0.06)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color:
                      isCurrent ? AppColors.accent : AppColors.inkSoft)),
          const SizedBox(height: 3),
          Text('$cycles cycles',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color:
                      isCurrent ? AppColors.accent : AppColors.ink)),
          const SizedBox(height: 2),
          Text('Calm $calm%  ·  Focus $focus%',
              style: const TextStyle(
                  fontSize: 8, color: AppColors.inkSoft)),
        ],
      ),
    );
  }
}

// ── Overlay button ──
class _OverlayButton extends StatelessWidget {
  final String label;
  final bool primary;
  final VoidCallback onTap;
  const _OverlayButton(
      {required this.label, required this.onTap, this.primary = false});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: primary ? AppColors.accentGradient : null,
          color: primary ? null : AppColors.glassStrong,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.glassBorder),
          boxShadow: primary
              ? [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.25),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
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

// ── Confetti ──
class _ConfettiPiece {
  final double left;
  final Color color;
  final double durationMs;
  final double delayMs;
  _ConfettiPiece(int seed)
      : left = Random(seed * 977).nextDouble(),
        color = AppColors
            .confettiColors[Random(seed * 131).nextInt(AppColors.confettiColors.length)],
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

class _ConfettiWidgetState extends State<_ConfettiWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: widget.piece.durationMs.round()));
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
      builder: (_, _) {
        final t = _c.value;
        return Positioned(
          left: widget.piece.left * w,
          top: -10 + t * (h + 10),
          child: Opacity(
            opacity: (1 - t).clamp(0, 1),
            child: Transform.rotate(
              angle: t * 2 * pi,
              child:
                  Container(width: 7, height: 12, color: widget.piece.color),
            ),
          ),
        );
      },
    );
  }
}
