import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../theme/app_theme.dart';
import '../models/exercise_models.dart';
import '../widgets/glass_widgets.dart';
import '../widgets/completion_overlay.dart';

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
  bool _playing = true;
  bool _muted = false;
  bool _showLangMenu = false;
  bool _showOverlay = false;
  AppLang _lang = AppLang.en;
  Duration _sessionElapsed = Duration.zero;

  // --- voice/script sync state ---
  // Characters revealed so far, driven by the TTS engine's own word-timing
  // callback (setProgressHandler) rather than a guessed fixed duration.
  // Stays 0 on platforms/voices that don't report progress, in which case
  // we fall back to the old proportional-by-duration reveal.
  int _revealChars = 0;
  bool _speechDone = false;
  bool _pendingAdvance = false;

  List<ExerciseStep> get _steps => widget.exercise.steps;
  ExerciseStep get _step => _steps[_current];

  @override
  void initState() {
    super.initState();
    _stepCtrl = AnimationController(vsync: this, duration: _step.duration)
      ..addStatusListener(_onStepAnimStatus)
      ..addListener(() => setState(() {}));
    _sessionStopwatch.start();

    // Reveal the script in step with the words the engine is actually
    // speaking (fires per-word on Android/iOS with character offsets).
    _tts.setProgressHandler((text, start, end, word) {
      if (!mounted) return;
      setState(() => _revealChars = end);
    });

    // Only truly advance to the next step once the voice has actually
    // finished the sentence — never cut narration off mid-word.
    _tts.setCompletionHandler(() {
      if (!mounted) return;
      setState(() {
        _revealChars = _step.textFor(_lang).length;
        _speechDone = true;
      });
      if (_pendingAdvance) {
        _pendingAdvance = false;
        _advanceAfterStep();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _stepCtrl.forward();
      _speak();
    });
    // Periodically refresh the session-total label.
    _tickTotal();
  }

  Future<void> _tickTotal() async {
    while (mounted) {
      await Future.delayed(const Duration(milliseconds: 250));
      if (!mounted) return;
      setState(() => _sessionElapsed = _sessionStopwatch.elapsed);
    }
  }

  void _onStepAnimStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && _playing) {
      // The timer bar reaching the end is only a rough estimate of how
      // long the sentence takes to say. If the voice is muted (no TTS to
      // wait for) or has already finished speaking, advance right away.
      // Otherwise wait for the completion handler to tell us the voice is
      // actually done, so narration is never cut off mid-sentence.
      if (_muted || _speechDone) {
        _advanceAfterStep();
      } else {
        _pendingAdvance = true;
      }
    }
  }

  void _advanceAfterStep() {
    if (!mounted || !_playing) return;
    if (_current < _steps.length - 1) {
      _goToStep(_current + 1);
    } else {
      _finishSession();
    }
  }

  Future<void> _speak() async {
    setState(() {
      _revealChars = 0;
      _speechDone = false;
      _pendingAdvance = false;
    });
    if (_muted || !_playing) return;
    await _tts.stop();
    await _tts.setLanguage(_lang.ttsLocale);
    await _tts.setSpeechRate(0.42);
    await _tts.setPitch(1.0);
    await _tts.speak(_step.textFor(_lang));
  }

  void _goToStep(int index) {
    setState(() {
      _current = index;
    });
    _stepCtrl.duration = _step.duration;
    _stepCtrl.value = 0;
    if (_playing) {
      _stepCtrl.forward();
      _speak();
    }
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
      _speak();
    } else {
      _stepCtrl.stop();
      _sessionStopwatch.stop();
      _tts.stop();
    }
  }

  void _onMute() {
    setState(() => _muted = !_muted);
    if (_muted) {
      _tts.stop();
    } else {
      _speak();
    }
  }

  void _onSelectLang(AppLang lang) {
    setState(() {
      _lang = lang;
      _showLangMenu = false;
    });
    _speak();
  }

  void _finishSession() {
    _stepCtrl.stop();
    _sessionStopwatch.stop();
    _tts.stop();
    setState(() => _showOverlay = true);
  }

  void _onRestart() {
    setState(() {
      _cycles++;
      _showOverlay = false;
      _current = 0;
    });
    _sessionStopwatch.reset();
    _sessionStopwatch.start();
    _stepCtrl.duration = _step.duration;
    _stepCtrl.value = 0;
    _playing = true;
    _stepCtrl.forward();
    _speak();
  }

  void _onClose() {
    setState(() => _showOverlay = false);
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
    // Prefer the TTS engine's own word-progress offsets so the text on
    // screen tracks what's actually being said. If the platform/voice
    // never reports progress (some web/desktop voices don't), _revealChars
    // stays 0 and we fall back to the old estimated-duration reveal so the
    // script still animates instead of sitting blank.
    final progressReveal = _revealChars.clamp(0, fullText.length);
    final fallbackReveal = (fullText.length * _stepCtrl.value).round().clamp(0, fullText.length);
    final revealCount = (!_muted && progressReveal > 0) ? progressReveal : fallbackReveal;
    final visibleText = fullText.substring(0, revealCount);
    final typingDone = revealCount >= fullText.length;
    final stepElapsed = _step.duration * _stepCtrl.value;

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
        const PillBadge(
          text: '✦ Premium',
          gradient: LinearGradient(colors: [AppColors.goldBadgeStart, AppColors.goldBadgeEnd]),
          textColor: AppColors.goldBadgeText,
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