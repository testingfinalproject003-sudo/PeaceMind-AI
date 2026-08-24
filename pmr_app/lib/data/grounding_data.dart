import '../models/exercise_models.dart';

/// Grounding (5-4-3-2-1 senses technique). English narration only for now —
/// the language switcher still works, it falls back to English for this
/// exercise until more translations are added.
final List<ExerciseStep> groundingSteps = [
  ExerciseStep(
    label: {AppLang.en: 'Settle & Breathe'},
    text: {
      AppLang.en:
          'Welcome. Find a comfortable position, feet flat on the ground, back supported. Take a slow breath in through your nose for four counts... one, two, three, four... and release it gently through your mouth. This is the 5-4-3-2-1 technique — a simple way to bring your mind back to the present moment by noticing the world around you. There is nothing to fix, nothing to force. Just notice. Let\'s begin together, one more breath in... and out.',
    },
    duration: const Duration(milliseconds: 22000),
    activeNodes: const [],
  ),
  ExerciseStep(
    label: {AppLang.en: 'See & Hear'},
    text: {
      AppLang.en:
          'Look slowly around you and silently name five things you can see. Notice their shapes, their colors, the way light falls on them. Take your time with each one. Now bring your attention to sound. Name four things you can hear right now — near or far, loud or quiet. You don\'t need to judge them, just notice them arriving and passing. Let each sound remind you that you are here, right now, safe in this moment.',
    },
    duration: const Duration(milliseconds: 30000),
    activeNodes: const ['sight', 'sound'],
  ),
  ExerciseStep(
    label: {AppLang.en: 'Touch, Smell & Taste'},
    text: {
      AppLang.en:
          'Now notice three things you can touch or feel — the texture of your clothing, the surface beneath your hands, the temperature of the air on your skin. Next, notice two things you can smell, even if it\'s simply the neutral scent of the room. Finally, notice one thing you can taste — a lingering flavor, or simply the inside of your mouth. With each sense you name, you are anchoring yourself more fully into this present moment.',
    },
    duration: const Duration(milliseconds: 30000),
    activeNodes: const ['touch', 'smell', 'taste'],
  ),
  ExerciseStep(
    label: {AppLang.en: 'Completion'},
    text: {
      AppLang.en:
          'Beautifully done. Take one more slow breath in... and out. Notice how much more present and settled you feel, connected to the room around you instead of your racing thoughts. Whenever your mind starts to spin, you can return to this simple practice — five things you see, four you hear, three you touch, two you smell, one you taste. Carry this steadiness with you.',
    },
    duration: const Duration(milliseconds: 16000),
    activeNodes: const [],
  ),
];

final groundingCompletion = CompletionConfig(
  title: 'Grounded & Present',
  subtitleBuilder: (n) => 'You reconnected with the present moment through $n senses.\nWell done — you are here, and you are safe.',
  unitLabel: 'SENSES ENGAGED',
  unitCount: 5,
  chartTitle: 'Awareness by Sense',
  chartRows: const [
    CompletionStat('Sight', 90),
    CompletionStat('Sound', 85),
    CompletionStat('Touch', 82),
    CompletionStat('Smell', 74),
    CompletionStat('Taste', 70),
  ],
);
