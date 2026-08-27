import 'package:flutter/widgets.dart';

/// Supported narration / UI languages, matching the original app.
enum AppLang { en, ur, urRoman, zh, pa }

extension AppLangCode on AppLang {
  /// Key used inside the translation maps.
  String get key {
    switch (this) {
      case AppLang.en:
        return 'en';
      case AppLang.ur:
        return 'ur';
      case AppLang.urRoman:
        return 'ur_roman';
      case AppLang.zh:
        return 'zh';
      case AppLang.pa:
        return 'pa';
    }
  }

  /// BCP-47 tag used for text-to-speech.
  String get ttsLocale {
    switch (this) {
      case AppLang.en:
        return 'en-US';
      case AppLang.ur:
        return 'ur-PK';
      case AppLang.urRoman:
        return 'en-US';
      case AppLang.zh:
        return 'zh-CN';
      case AppLang.pa:
        return 'pa-IN';
    }
  }

  /// Label shown in the language picker menu.
  String get menuLabel {
    switch (this) {
      case AppLang.en:
        return 'English';
      case AppLang.ur:
        return 'اردو';
      case AppLang.urRoman:
        return 'Roman Urdu';
      case AppLang.zh:
        return '中文 Chinese';
      case AppLang.pa:
        return 'ਪੰਜਾਬੀ Punjabi';
    }
  }
}

/// One step (stage) of a guided exercise: a tracker label, a narration
/// script per language, a duration, and which "hot" nodes are active
/// during it (used by the body-scan stage; ignored by other stages).
class ExerciseStep {
  final Map<AppLang, String> label;
  final Map<AppLang, String> text;
  final Duration duration;
  final List<String> activeNodes;
  /// True while this step should show the "eyes closed" overlay.
  final bool eyesClosed;

  const ExerciseStep({
    required this.label,
    required this.text,
    required this.duration,
    this.activeNodes = const [],
    this.eyesClosed = false,
  });

  String labelFor(AppLang lang) => label[lang] ?? label[AppLang.en] ?? '';
  String textFor(AppLang lang) => text[lang] ?? text[AppLang.en] ?? '';
}

/// One row in the post-session "released by ___" bar chart.
class CompletionStat {
  final String label;
  final int percent;
  const CompletionStat(this.label, this.percent);
}

/// Static copy shown on the completion / victory overlay.
class CompletionConfig {
  final String title;
  final String Function(int unitCount) subtitleBuilder;
  final String unitLabel; // e.g. "MUSCLES SCANNED", "SENSES GROUNDED"
  final int unitCount;
  final String chartTitle;
  final List<CompletionStat> chartRows;

  const CompletionConfig({
    required this.title,
    required this.subtitleBuilder,
    required this.unitLabel,
    required this.unitCount,
    required this.chartTitle,
    required this.chartRows,
  });
}

/// A full guided exercise: brand copy + steps + which visual "stage"
/// widget renders behind the narration.
class ExerciseInfo {
  final String id;
  final String brandTitle;
  final IconData navIcon;
  final List<ExerciseStep> steps;
  final CompletionConfig completion;
  /// Builds the animated visual for the stage area.
  /// [stepIndex] is the current step, [progress] is 0..1 through it.
  final Widget Function(
      BuildContext context,
      int stepIndex,
      double progress,
      bool playing,
      ) stageBuilder;
  final String homeCardBlurb;
  final Color homeCardAccent;

  const ExerciseInfo({
    required this.id,
    required this.brandTitle,
    required this.navIcon,
    required this.steps,
    required this.completion,
    required this.stageBuilder,
    required this.homeCardBlurb,
    required this.homeCardAccent,
  });
}
