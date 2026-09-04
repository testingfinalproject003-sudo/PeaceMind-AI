import 'dart:async';

import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../models/exercise_models.dart';
import '../widgets/glass_widgets.dart';
import '../widgets/completion_overlay.dart';
import '../providers/routine_provider.dart';
import '../providers/daily_routine_provider.dart';
import '../providers/garden_provider.dart';

class ExercisePlayerScreen extends StatefulWidget {
  final ExerciseInfo exercise;
  const ExercisePlayerScreen({super.key, required this.exercise});

  @override
  State<ExercisePlayerScreen> createState() => _ExercisePlayerScreenState();
}

class _ExercisePlayerScreenState extends State<ExercisePlayerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _stepCtrl;
  final Stopwatch _sessionStopwatch = Stopwatch();
  final FlutterTts _tts = FlutterTts();

  int _current = 0;
  int _cycles = 1;
  int _previousCycles = 0;
  bool _playing = true;
  bool _muted = false;
  bool _showLangMenu = false;
  bool _showOverlay = false;
  AppLang _lang = AppLang.en;
  Duration _sessionElapsed = Duration.zero;
  bool _sessionCompleted = false;

  /// History sirf pehli completion par save hoti hai —
  /// "Start New Cycle" par duplicate entry nahi banti.
  bool _historySaved = false;

  // --- voice/script sync state ---
  int _revealChars = 0;
  bool _speechDone = false;

  /// Generation token — incremented on every action that invalidates
  /// pending TTS callbacks (step change, mute, pause, lang change, etc.).
  /// Stale callbacks whose captured generation doesn't match are ignored.
  int _stepGeneration = 0;

  /// Prevents _advanceAfterStep from firing twice for the same step.
  bool _stepAdvanced = false;

  /// Per-language narration pace. Google's Urdu voices speak faster
  /// than the English voice at the same rate value, so Urdu uses a
  /// slightly slower setting — calm, but not unnaturally slow.
  static const _ttsRate = {
    AppLang.en: 0.45,
    AppLang.ur: 0.42,
    AppLang.urRoman: 0.45,
    AppLang.pa: 0.45,
  };

  /// Best Urdu voice found on this device (cached after first lookup).
  Map<String, String>? _urduVoice;
  bool _urduVoiceChecked = false;

  List<ExerciseStep> get _steps => widget.exercise.steps;
  ExerciseStep get _step => _steps[_current];

  @override
  void initState() {
    super.initState();
    // AnimationController: visual progress indicator ONLY.
    // It does NOT drive step advancement — TTS completion does.
    _stepCtrl = AnimationController(vsync: this, duration: _step.duration)
      ..addListener(() => setState(() {}));

    _tts.setProgressHandler((text, start, end, word) {
      if (!mounted) return;
      setState(() => _revealChars = end);
    });

    _tts.setCompletionHandler(() {
      if (!mounted) return;
      setState(() {
        _revealChars = _step.textFor(_lang).length;
        _speechDone = true;
      });
      // TTS completed → advance to next step (if this generation is current).
      _tryAdvance();
    });

    _tts.setCancelHandler(() {
      // TTS was stopped externally. If this is the current generation
      // and speech hasn't been marked done, use fallback timer so the
      // step doesn't get stuck.
      if (!mounted) return;
      if (!_speechDone) {
        _speechDone = true;
        _startFallbackTimer();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _beginStep());
    _sessionStopwatch.start();
    _tickTotal();
  }

  Future<void> _tickTotal() async {
    while (mounted) {
      await Future.delayed(const Duration(milliseconds: 250));
      if (!mounted) return;
      setState(() => _sessionElapsed = _sessionStopwatch.elapsed);
    }
  }

  // ── Step lifecycle ───────────────────────────────────────────────────

  /// Begin narration for the current step. Resets text-reveal state,
  /// invalidates stale TTS callbacks, and starts TTS (or fallback
  /// timer when muted / TTS unavailable).
  void _beginStep() {
    _stepGeneration++;
    _stepAdvanced = false;
    setState(() {
      _revealChars = 0;
      _speechDone = false;
    });
    if (_muted || !_playing) {
      // No TTS — use configured step duration as fallback timing.
      _startFallbackTimer();
      return;
    }
    _speak();
  }

  /// Attempt to advance to the next step. Guarded against duplicate
  /// calls from overlapping TTS completion + fallback timer.
  void _tryAdvance() {
    if (!mounted || !_playing || _sessionCompleted) return;
    if (_stepAdvanced) return;
    _stepAdvanced = true;
    _advanceAfterStep();
  }

  void _advanceAfterStep() {
    if (_current < _steps.length - 1) {
      _goToStep(_current + 1);
    } else {
      _finishSession();
    }
  }

  /// Fallback timer: advances the step after [_step.duration] if TTS
  /// completion never fires (engine failure, muted, or voice missing).
  /// This is NOT a sync buffer — it's a safety net for when the TTS
  /// engine provides no completion signal at all.
  void _startFallbackTimer() {
    final gen = _stepGeneration;
    Future.delayed(_step.duration, () {
      if (!mounted || gen != _stepGeneration) return;
      if (_stepAdvanced || _sessionCompleted || !_playing) return;
      setState(() => _speechDone = true);
      _tryAdvance();
    });
  }

  /// Urdu voice-quality tuning (Android only).
  ///
  /// Google's TTS engine ships two kinds of Urdu voices: an offline
  /// one that sounds robotic, and a far more natural online "network"
  /// voice that flutter_tts does not select by default. This looks up
  /// the available voices once, prefers a Pakistani (ur-PK) network
  /// voice, and re-applies it before every Urdu step (setLanguage
  /// resets the active voice each time). Every failure path is silent:
  /// devices, engines, or platforms without voice lists simply keep
  /// the voice chosen by setLanguage. No timing logic lives here —
  /// step advancement stays driven by the TTS completion handler.
  Future<void> _tuneUrduVoice() async {
    if (_lang != AppLang.ur) return;
    if (defaultTargetPlatform != TargetPlatform.android) return;
    if (_urduVoice != null) {
      try {
        await _tts.setVoice(_urduVoice!);
      } catch (_) {}
      return;
    }
    if (_urduVoiceChecked) return; // no better voice found earlier
    _urduVoiceChecked = true;
    try {
      final voices = await _tts.getVoices; // getter in flutter_tts 4.x
      if (voices is! List) return;
      Map<String, String>? best;
      var bestScore = -1;
      for (final v in voices) {
        if (v is! Map) continue;
        final localeTag = '${v['locale']}';
        final locale = localeTag.toLowerCase();
        if (!locale.startsWith('ur')) continue;
        final name = '${v['name']}';
        final lower = name.toLowerCase();
        var score = 0;
        if (locale.contains('pk')) score += 2; // Pakistani pronunciation
        if (lower.contains('network') || v['network'] == true) {
          score += 3; // online voices sound far more natural
        }
        if (!lower.contains('local')) score += 1;
        if (score > bestScore) {
          bestScore = score;
          best = {'name': name, 'locale': localeTag};
        }
      }
      if (best != null) {
        _urduVoice = best;
        await _tts.setVoice(best);
      }
    } catch (_) {
      // Voice listing unsupported here — default voice stays active.
    }
  }

  /// Start TTS narration for the current step.
  /// On engine failure, falls back to the configured step duration.
  /// Does NOT increment _stepGeneration — the caller (_beginStep)
  /// has already set the generation for this narration cycle.
  Future<void> _speak() async {
    final gen = _stepGeneration;
    setState(() {
      _revealChars = 0;
      _speechDone = false;
    });
    if (_muted || !_playing) {
      _startFallbackTimer();
      return;
    }
    try {
      await _tts.stop();
      // Guard: a newer step/speak was started while awaiting stop.
      if (!mounted || gen != _stepGeneration) return;
      await _tts.setLanguage(_lang.ttsLocale);
      if (!mounted || gen != _stepGeneration) return;
      // Prefer the device's most natural Urdu voice before speaking.
      await _tuneUrduVoice();
      if (!mounted || gen != _stepGeneration) return;
      // Natural speech rate — let actual TTS duration control step timing.
      // Urdu voices speak faster at the same value, so they use a slightly
      // calmer rate for guided-meditation pacing.
      await _tts.setSpeechRate(_ttsRate[_lang] ?? 0.45);
      await _tts.setPitch(1.0);
      final result = await _tts.speak(_step.textFor(_lang));
      if (!mounted || gen != _stepGeneration) return;
      // speak() failed (voice/engine missing) — use fallback timer
      // so the step doesn't get stuck.
      if (result != 1) {
        setState(() => _speechDone = true);
        _startFallbackTimer();
      }
    } catch (_) {
      if (!mounted || gen != _stepGeneration) return;
      setState(() => _speechDone = true);
      _startFallbackTimer();
    }
  }

  void _goToStep(int index) {
    // Invalidate any pending TTS callbacks from the previous step.
    _stepGeneration++;
    _stepAdvanced = false;
    setState(() {
      _current = index;
    });
    _stepCtrl.duration = _step.duration;
    _stepCtrl.value = 0;
    if (_playing) _stepCtrl.forward();
    _beginStep();
  }

  void _onPrev() {
    if (_current > 0) _goToStep(_current - 1);
  }

  void _onNext() {
    if (_current < _steps.length - 1) {
      _goToStep(_current + 1);
    } else {
      _finishSession();
    }
  }

  void _onPlayPause() {
    setState(() => _playing = !_playing);
    if (_playing) {
      _stepCtrl.forward();
      _sessionStopwatch.start();
      // Resume: restart narration with fresh generation.
      _beginStep();
    } else {
      _stepCtrl.stop();
      _sessionStopwatch.stop();
      // Pause: invalidate stale TTS callbacks and stop speech.
      _stepGeneration++;
      _tts.stop();
    }
  }

  void _onMute() {
    setState(() => _muted = !_muted);
    if (_muted) {
      // Mute: stop TTS. No completion callback will fire for this step.
      // Fall back to configured step duration for advancement.
      _stepGeneration++;
      _tts.stop();
      _startFallbackTimer();
    } else {
      // Unmute: restart narration with fresh generation.
      _beginStep();
    }
  }

  void _onSelectLang(AppLang lang) {
    setState(() {
      _lang = lang;
      _showLangMenu = false;
    });
    // Language change: stop old narration, start new cleanly.
    _beginStep();
  }

  void _finishSession() {
    if (_sessionCompleted) return;
    _sessionCompleted = true;
    // Invalidate any pending TTS callbacks.
    _stepGeneration++;
    _stepCtrl.stop();
    _sessionStopwatch.stop();
    _tts.stop();
    
    // Mark exercise as complete in routine provider (sirf ek dafa)
    if (mounted && !_historySaved) {
      _historySaved = true;
      final routineProvider = context.read<RoutineProvider>();
      routineProvider.completeExercise(
        exerciseId: widget.exercise.id,
        exerciseTitle: widget.exercise.brandTitle,
        duration: _sessionElapsed,
        cycles: _cycles,
      );

      // Rule 5: also notify DailyRoutineProvider so the daily task
      // is marked complete in the auto-generated 5-task set.
      final dailyTaskId = DailyRoutineProvider.exerciseIdToTaskId(widget.exercise.id);
      if (dailyTaskId != null) {
        context.read<DailyRoutineProvider>().markTaskComplete(dailyTaskId);
      }

      // Grow tree in garden on exercise completion
      context.read<GardenProvider>().growTree();
    }
    
    setState(() => _showOverlay = true);
  }

  void _onRestart() async {
    // Full reset: TTS state, progress, pending advance, generation token,
    // session timer, step index.
    _stepGeneration++;
    setState(() {
      _previousCycles = _cycles;
      _cycles++;
      _showOverlay = false;
      _current = 0;
      _sessionCompleted = false;
      _stepAdvanced = false;
      _revealChars = 0;
      _speechDone = false;
    });
    await _tts.stop();
    if (!mounted) return;
    _sessionStopwatch.reset();
    _sessionStopwatch.start();
    _stepCtrl.duration = _step.duration;
    _stepCtrl.value = 0;
    _playing = true;
    _stepCtrl.forward();
    _beginStep();
  }

  void _onClose() {
    // Pass exercise title back to HomeScreen so it can show the
    // Yappy celebration card. Null means exercise was not completed.
    Navigator.of(context).pop(
      _historySaved ? widget.exercise.brandTitle : null,
    );
  }

  @override
  void dispose() {
    _stepCtrl.dispose();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fullText = _step.textFor(_lang);
    final progressReveal = _revealChars.clamp(0, fullText.length);
    final fallbackReveal = (fullText.length * _stepCtrl.value).round().clamp(0, fullText.length);
    final revealCount = (!_muted && progressReveal > 0) ? progressReveal : fallbackReveal;
    final visibleText = fullText.substring(0, revealCount);
    final typingDone = revealCount >= fullText.length;
    // Visual step progress driven by AnimationController.
    // Configured _step.duration is a visual estimate — actual narration
    // duration is controlled by TTS completion.
    final stepElapsed = Duration(
      milliseconds: (_step.duration.inMilliseconds * _stepCtrl.value).round(),
    );

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.skyGradient),
        child: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
                child: Column(
                  children: [
                    _buildTopBar(),
                    const SizedBox(height: 8),
                    StepTracker(steps: _steps, current: _current, lang: _lang),
                    const SizedBox(height: 8),
                    TimerBar(progress: _stepCtrl.value),
                    TimeRow(
                      stepElapsed: stepElapsed,
                      stepTotal: _step.duration,
                      sessionTotal: _sessionElapsed,
                    ),
                    const SizedBox(height: 2),
                    Expanded(
                      child: widget.exercise.stageBuilder(
                        context,
                        _current,
                        _stepCtrl.value,
                        _playing,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ScriptPanel(visibleText: visibleText, typingDone: typingDone),
                    const SizedBox(height: 12),
                    PlayerControls(
                      playing: _playing,
                      canGoPrev: _current > 0,
                      isLastStep: _current == _steps.length - 1,
                      onPrev: _onPrev,
                      onNext: _onNext,
                      onPlayPause: _onPlayPause,
                    ),
                  ],
                ),
              ),
              if (_showOverlay)
                Positioned.fill(
                  child: CompletionOverlay(
                    config: widget.exercise.completion,
                    totalTime: _sessionElapsed,
                    cycles: _cycles,
                    previousCycles: _previousCycles,
                    onClose: _onClose,
                    onRestart: _onRestart,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppColors.ink),
          onPressed: () => Navigator.pop(context),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              widget.exercise.brandTitle.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.08,
                color: AppColors.inkSoft,
              ),
            ),
          ),
        ),
        PillBadge(
          text: 'Cycle $_cycles',
          gradient: const LinearGradient(colors: [AppColors.greenBadgeStart, AppColors.greenBadgeEnd]),
          textColor: AppColors.greenBadgeText,
        ),
        const SizedBox(width: 6),
        IconCircleButton(
          onTap: _onMute,
          child: Icon(_muted ? Icons.volume_off_rounded : Icons.volume_up_rounded, size: 15, color: AppColors.ink),
        ),
        const SizedBox(width: 6),
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconCircleButton(
              onTap: () => setState(() => _showLangMenu = !_showLangMenu),
              child: const Icon(Icons.language_rounded, size: 15, color: AppColors.ink),
            ),
            if (_showLangMenu)
              Positioned(
                top: 34,
                right: 0,
                child: LanguageMenu(current: _lang, onSelect: _onSelectLang),
              ),
          ],
        ),
      ],
    );
  }
}
