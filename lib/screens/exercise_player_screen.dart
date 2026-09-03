import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../models/exercise_models.dart';
import '../widgets/glass_widgets.dart';
import '../widgets/completion_overlay.dart';
import '../widgets/garden_celebration_card.dart';
import '../providers/routine_provider.dart';
import '../providers/daily_routine_provider.dart';
import '../providers/garden_provider.dart';
import '../providers/auth_provider.dart';

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
      if (_pendingAdvance) {
        _pendingAdvance = false;
        _advanceAfterStep();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _stepCtrl.forward();
      _speak();
    });
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
      if (_muted || _speechDone) {
        _advanceAfterStep();
      } else {
        _pendingAdvance = true;
        // Safety: agar TTS complete na ho (device par voice missing)
        // to 8 second buffer ke baad advance — stage stuck nahi hota.
        Future.delayed(const Duration(seconds: 8), () {
          if (!mounted || !_pendingAdvance) return;
          _pendingAdvance = false;
          _speechDone = true;
          _advanceAfterStep();
        });
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
    try {
      await _tts.stop();
      await _tts.setLanguage(_lang.ttsLocale);
      // Dynamic speech rate: calculate so TTS finishes close to step duration.
      // ~150 words/min at rate 0.5 is baseline; adjust per step.
      final wordCount = _step.textFor(_lang).split(RegExp(r'\s+')).length;
      final durationSec = _step.duration.inMilliseconds / 1000.0;
      final targetRate = (wordCount / durationSec / 2.8).clamp(0.32, 0.58);
      await _tts.setSpeechRate(targetRate);
      await _tts.setPitch(1.0);
      final result = await _tts.speak(_step.textFor(_lang));
      // speak fail hua (voice/engine missing) — script timer ke sath
      // sync chalta rahe aur stage aage badhta rahe
      if (result != 1 && mounted) {
        setState(() => _speechDone = true);
      }
    } catch (_) {
      if (mounted) setState(() => _speechDone = true);
    }
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
    if (_sessionCompleted) return;
    _sessionCompleted = true;
    
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

    // Show garden celebration dialog
    if (mounted) {
      _showExerciseCelebration();
    }
  }

  Future<void> _showExerciseCelebration() async {
    final userName = context.read<AuthProvider>().userName;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (dialogContext) {
        return GardenCelebrationCard(
          userName: userName,
          taskTitle: widget.exercise.brandTitle,
          onContinue: () => Navigator.of(dialogContext).pop(),
        );
      },
    );
  }

  void _onRestart() {
    setState(() {
      _previousCycles = _cycles;
      _cycles++;
      _showOverlay = false;
      _current = 0;
      _sessionCompleted = false;
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
    // Back to home garden — result=true tells the caller (HomeScreen)
    // to play the yappy celebration song and show the newly grown tree.
    Navigator.of(context).pop(_historySaved);
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
