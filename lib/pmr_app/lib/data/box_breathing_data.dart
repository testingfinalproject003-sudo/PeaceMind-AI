import '../models/exercise_models.dart';

/// Box Breathing (4-4-4-4 pattern). English narration only for now — the
/// language switcher still works, it falls back to English for this
/// exercise until more translations are added.
final List<ExerciseStep> boxBreathingSteps = [
  ExerciseStep(
    label: {AppLang.en: 'Prepare'},
    text: {
      AppLang.en:
          'Welcome to box breathing, a technique used by athletes and even Navy SEALs to calm the nervous system in moments of stress. Sit comfortably with your back straight, shoulders relaxed, hands resting gently in your lap. We will breathe in a square pattern — inhale for four counts, hold for four, exhale for four, hold for four. Let\'s take one easy breath together to settle in before we begin the pattern.',
    },
    duration: const Duration(milliseconds: 20000),
  ),
  ExerciseStep(
    label: {AppLang.en: 'Find the Rhythm'},
    text: {
      AppLang.en:
          'Now begin the box. Inhale slowly through your nose... two, three, four. Hold gently at the top... two, three, four. Exhale slowly through your mouth... two, three, four. Hold at the bottom, empty and still... two, three, four. Follow the glowing dot as it traces each side of the square — let it set your pace rather than your thoughts.',
    },
    duration: const Duration(milliseconds: 32000),
  ),
  ExerciseStep(
    label: {AppLang.en: 'Continue the Box'},
    text: {
      AppLang.en:
          'Keep following the pattern — inhale, hold, exhale, hold, each for four steady counts. With every lap around the square, notice your heart rate settling, your mind growing quieter. If a thought pulls your attention away, that\'s completely normal — simply return to the rhythm of the square. You are training your body to find calm on command.',
    },
    duration: const Duration(milliseconds: 32000),
  ),
  ExerciseStep(
    label: {AppLang.en: 'Completion'},
    text: {
      AppLang.en:
          'Wonderful work. Let your breath return to its natural rhythm, no longer counted, just easy and free. Notice the steadiness you\'ve built — a tool you can use anywhere, anytime you need to find your center. When you\'re ready, gently open your eyes and carry this calm forward.',
    },
    duration: const Duration(milliseconds: 16000),
  ),
];

final boxBreathingCompletion = CompletionConfig(
  title: 'Breath Steadied',
  subtitleBuilder: (n) => 'You completed $n calming breath phases in rhythm.\nYour nervous system thanks you.',
  unitLabel: 'PHASES PACED',
  unitCount: 4,
  chartTitle: 'Calm by Breath Phase',
  chartRows: const [
    CompletionStat('Inhale', 86),
    CompletionStat('Hold', 80),
    CompletionStat('Exhale', 91),
    CompletionStat('Hold', 79),
  ],
);
