import '../model/exercise_models.dart';
import '../models/exercise_models.dart';

/// Mind Walking (mindful walking meditation). English narration only for
/// now — the language switcher still works, it falls back to English for
/// this exercise until more translations are added.
final List<ExerciseStep> mindWalkingSteps = [
  ExerciseStep(
    label: {AppLang.en: 'Stand & Notice'},
    text: {
      AppLang.en:
      'Welcome. Find a quiet stretch of space, indoors or out, where you can take a few slow steps back and forth. Begin standing still. Feel your feet rooted into the ground beneath you, your weight evenly balanced. Take a slow breath in... and out. There is nowhere to rush to — this walk has no destination except this present moment.',
    },
    duration: const Duration(milliseconds: 20000),
  ),
  ExerciseStep(
    label: {AppLang.en: 'First Steps'},
    text: {
      AppLang.en:
      'Begin walking, slower than usual. With each step, notice the lifting of your heel, the shifting of your weight, the gentle placement of your foot back on the ground. Feel the ground rising to meet you. If your mind wanders to your to-do list or the past, gently guide it back to the simple sensation of walking, one step at a time.',
    },
    duration: const Duration(milliseconds: 28000),
  ),
  ExerciseStep(
    label: {AppLang.en: 'Whole-Body Awareness'},
    text: {
      AppLang.en:
      'Now widen your awareness. Notice the gentle swing of your arms, the rhythm of your breath matching your steps, the air moving past your skin. Notice any sounds around you without needing to name them. With every step, imagine you are placing a little more calm into the ground beneath you, leaving tension behind with each footprint.',
    },
    duration: const Duration(milliseconds: 30000),
  ),
  ExerciseStep(
    label: {AppLang.en: 'Completion'},
    text: {
      AppLang.en:
      'Beautifully done. Come to a gentle stop and stand still once more. Feel the difference in your body — more grounded, more present, more here. Take one final breath in... and out. Carry this unhurried, attentive pace with you as you continue through your day.',
    },
    duration: const Duration(milliseconds: 16000),
  ),
];

final mindWalkingCompletion = CompletionConfig(
  title: 'Mindfully Walked',
  subtitleBuilder: (n) => 'You walked $n mindful steps, fully present in your body.\nA calmer pace, carried forward.',
  unitLabel: 'STEPS WALKED',
  unitCount: 14,
  chartTitle: 'Presence Through the Walk',
  chartRows: const [
    CompletionStat('Feet', 89),
    CompletionStat('Breath', 84),
    CompletionStat('Body', 81),
    CompletionStat('Senses', 77),
    CompletionStat('Mind', 73),
  ],
);
