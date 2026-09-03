import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/exercise_models.dart';

/// Frosted-glass rounded panel, mirrors `.script` / `.glass-strong` blocks.
class GlassPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double radius;
  final Gradient? gradient;

  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
    this.radius = 18,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            gradient: gradient ??
                LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.glassStrong, AppColors.glass],
                ),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Small rounded pill, mirrors `.premium` / `.cyclebadge`.
class PillBadge extends StatelessWidget {
  final String text;
  final Gradient gradient;
  final Color textColor;
  const PillBadge({
    super.key,
    required this.text,
    required this.gradient,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(20)),
      child: Text(
        text,
        style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: textColor),
      ),
    );
  }
}

/// Small circular icon button, mirrors `.iconbtn`.
class IconCircleButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  const IconCircleButton({super.key, required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.glassStrong,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: child,
      ),
    );
  }
}

/// Step tracker row with connecting lines, mirrors `.tracker`.
class StepTracker extends StatelessWidget {
  final List<ExerciseStep> steps;
  final int current;
  final AppLang lang;
  const StepTracker({super.key, required this.steps, required this.current, required this.lang});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(steps.length, (i) {
        final active = i == current;
        final done = i < current;
        return Expanded(
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  if (i != 0)
                    Positioned(
                      right: MediaQuery.of(context).size.width / (2 * steps.length),
                      child: Container(height: 2, width: 999, color: AppColors.glassBorder),
                    ),
                  Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: active ? AppColors.accentGradient : null,
                      color: active ? null : (done ? Colors.white : AppColors.glass),
                      border: Border.all(
                        color: done ? AppColors.accent : AppColors.glassBorder,
                        width: 2,
                      ),
                      boxShadow: active
                          ? [BoxShadow(color: AppColors.glow, blurRadius: 14)]
                          : null,
                    ),
                    child: Text(
                      done ? '✓' : '${i + 1}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: active ? Colors.white : (done ? AppColors.accent : AppColors.inkSoft),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                steps[i].labelFor(lang),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 8.5,
                  color: active ? AppColors.ink : AppColors.inkSoft,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

/// Thin animated progress bar with glow effect.
class TimerBar extends StatelessWidget {
  final double progress; // 0..1
  const TimerBar({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    final clamped = progress.clamp(0.0, 1.0).toDouble();
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Container(
        height: 5,
        color: AppColors.glass,
        alignment: Alignment.centerLeft,
        child: Stack(
          children: [
            FractionallySizedBox(
              widthFactor: clamped,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.accentGradient,
                ),
              ),
            ),
            // Glow dot at the leading edge
            if (clamped > 0.01)
              Positioned(
                left: (clamped * (MediaQuery.of(context).size.width - 36)).clamp(0.0, 9999.0).toDouble() - 4,
                top: -2,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.accent2,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.glow.withValues(alpha: 0.7),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

String fmtDuration(Duration d) {
  final s = d.inSeconds.clamp(0, 999999);
  final m = s ~/ 60;
  final sec = s % 60;
  return '$m:${sec.toString().padLeft(2, '0')}';
}

/// Elapsed / total row under the timer bar, mirrors `.timerow`.
class TimeRow extends StatelessWidget {
  final Duration stepElapsed;
  final Duration stepTotal;
  final Duration sessionTotal;
  const TimeRow({
    super.key,
    required this.stepElapsed,
    required this.stepTotal,
    required this.sessionTotal,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('${fmtDuration(stepElapsed)} / ${fmtDuration(stepTotal)}',
              style: const TextStyle(fontSize: 9.5, color: AppColors.inkSoft)),
          Text('Total ${fmtDuration(sessionTotal)}',
              style: const TextStyle(fontSize: 9.5, color: AppColors.inkSoft)),
        ],
      ),
    );
  }
}

/// Pulsing green "live" dot next to the narrator label.
class LiveDot extends StatefulWidget {
  const LiveDot({super.key});
  @override
  State<LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<LiveDot> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
  AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 1.0, end: 0.3).animate(_c),
      child: Container(
        width: 6,
        height: 6,
        decoration: const BoxDecoration(
          color: AppColors.green,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: AppColors.green, blurRadius: 6)],
        ),
      ),
    );
  }
}

/// The narration text panel with a typewriter reveal + blinking cursor,
/// mirrors `.script`.
class ScriptPanel extends StatelessWidget {
  final String visibleText;
  final bool typingDone;
  const ScriptPanel({super.key, required this.visibleText, required this.typingDone});

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      radius: 18,
      child: SizedBox(
        height: 88,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                LiveDot(),
                SizedBox(width: 6),
                Text(
                  'AI THERAPIST — VOICE GUIDED',
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 0.06,
                    color: AppColors.accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Expanded(
              child: SingleChildScrollView(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 12.5, height: 1.55, color: AppColors.ink),
                    children: [
                      TextSpan(text: visibleText),
                      if (!typingDone)
                        const TextSpan(
                          text: ' ▌',
                          style: TextStyle(color: AppColors.accent),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom control row: Previous / Play-Pause / Next, mirrors `.controls`.
class PlayerControls extends StatelessWidget {
  final bool playing;
  final bool canGoPrev;
  final bool isLastStep;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onPlayPause;

  const PlayerControls({
    super.key,
    required this.playing,
    required this.canGoPrev,
    required this.isLastStep,
    required this.onPrev,
    required this.onNext,
    required this.onPlayPause,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _FlatButton(label: 'Previous', enabled: canGoPrev, onTap: onPrev)),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: onPlayPause,
          child: Container(
            width: 54,
            height: 54,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.white, Color(0xFFF0F4FA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.glassBorder),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  blurRadius: 22,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: const Color(0x40406496),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(playing ? Icons.pause_rounded : Icons.play_arrow_rounded, color: AppColors.accent, size: 24),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _FlatButton(
            label: isLastStep ? 'Finish' : 'Next',
            enabled: true,
            primary: true,
            onTap: onNext,
          ),
        ),
      ],
    );
  }
}

class _FlatButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final bool primary;
  final VoidCallback onTap;
  const _FlatButton({
    required this.label,
    required this.enabled,
    required this.onTap,
    this.primary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.35,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: primary ? AppColors.accentGradient : null,
            color: primary ? null : AppColors.glassStrong,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.glassBorder),
            boxShadow: primary
                ? [const BoxShadow(color: Color(0x663E8FDE), blurRadius: 20, offset: Offset(0, 10))]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: primary ? Colors.white : AppColors.ink,
            ),
          ),
        ),
      ),
    );
  }
}

/// Language dropdown menu, mirrors `.langmenu`.
class LanguageMenu extends StatelessWidget {
  final AppLang current;
  final ValueChanged<AppLang> onSelect;
  const LanguageMenu({super.key, required this.current, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      elevation: 10,
      child: Container(
        padding: const EdgeInsets.all(6),
        constraints: const BoxConstraints(minWidth: 150),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppLang.values.map((l) {
            final active = l == current;
            return InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => onSelect(l),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: active ? AppColors.accent : null,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  l.menuLabel,
                  style: TextStyle(
                    fontSize: 12,
                    color: active ? Colors.white : AppColors.ink,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
