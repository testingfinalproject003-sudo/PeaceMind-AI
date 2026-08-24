# PeaceMind — Guided Relaxation (Flutter)

A 4-screen guided relaxation app: **Body Scan**, **Grounding (5-4-3-2-1)**,
**Box Breathing (4-4-4-4)**, and **Mind Walking**. All four share the same
visual language as the original `pmr_body_scan_final.html`: the soft sky
gradient, frosted-glass panels, step tracker, timer bar, animated stage,
typewriter narration script, voice narration, language picker, and the
confetti "session complete" summary.

## What's exact vs. new

- **Body Scan** — the narration text (all 5 languages: English, Urdu, Roman
  Urdu, Chinese, Punjabi), step durations, step order, joint positions, and
  the completion stats/chart are copied verbatim from your HTML file. The
  actual body photo from the HTML is bundled as `assets/images/body_scan.jpg`
  and rendered with the same scanning-beam + glowing joints animation.
- **Grounding, Box Breathing, Mind Walking** — new screens built in the same
  visual system, with original English narration scripts I wrote to fit each
  technique. They currently ship with English narration only (the language
  switcher is wired up and will work instantly once more translations are
  added to their `lib/data/*_data.dart` files — just follow the pattern in
  `body_scan_data.dart`).

## Project structure

```
lib/
  main.dart                        # app entry, home screen route
  theme/app_theme.dart             # colors/gradients matching the CSS vars
  models/exercise_models.dart      # ExerciseStep / ExerciseInfo / CompletionConfig
  data/
    body_scan_data.dart            # body scan steps + completion (verbatim)
    grounding_data.dart            # grounding steps + completion
    box_breathing_data.dart        # box breathing steps + completion
    mind_walking_data.dart         # mind walking steps + completion
    exercises.dart                 # wires each data set to its stage widget
  widgets/
    glass_widgets.dart             # tracker, timer bar, script panel, controls, lang menu
    completion_overlay.dart        # trophy/confetti/stats/chart summary screen
    stage/
      body_scan_stage.dart         # real photo + scanning beam + joints
      grounding_stage.dart         # 5 senses ring
      box_breathing_stage.dart     # square breathing pacer
      mind_walking_stage.dart      # winding footpath + walker
  screens/
    home_screen.dart               # list of the 4 exercises
    exercise_player_screen.dart    # generic player driving any ExerciseInfo
assets/images/body_scan.jpg        # extracted from the original HTML
```

## Running it

This folder only contains the Dart source + assets (no native
`android/`/`ios/` scaffolding). To run it:

```bash
flutter create --project-name peacemind .
flutter pub get
flutter run
```

`flutter create .` will generate the native platform folders without
touching your existing `lib/`, `pubspec.yaml`, or `assets/`. If it prompts
about overwriting `pubspec.yaml`, choose "no" (yours already has the right
dependencies).

## Notes

- Narration uses the `flutter_tts` plugin. On first run per platform you may
  need to grant microphone/speech permissions are **not** required — TTS
  playback only needs no special permission on Android/iOS, but make sure a
  TTS voice pack for the selected language is installed on the test device
  (especially for Urdu/Punjabi) or it will silently fall back to the closest
  available voice.
- All animations (scanning beam, pulsing joints, breathing square, confetti,
  step timer) are done with Flutter's own `AnimationController`s — no extra
  animation packages required.
