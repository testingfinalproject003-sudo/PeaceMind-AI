// lib/widgets/exercise_popup.dart
import 'package:flutter/material.dart';
import 'package:peace_mind_ai/models/exercise_models.dart';
import '../theme/app_theme.dart';
import '../data/exercise_registry.dart';
import '../screens/exercise_player_screen.dart';

class ExercisePopup extends StatelessWidget {
  final String exerciseId;
  final VoidCallback onCancel;

  const ExercisePopup({
    super.key,
    required this.exerciseId,
    required this.onCancel,
  });

  static Future<void> show({
    required BuildContext context,
    required String exerciseId,
    VoidCallback? onCancel,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ExercisePopup(
        exerciseId: exerciseId,
        onCancel: () {
          Navigator.pop(context);
          if (onCancel != null) onCancel();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final exercise = getExerciseById(exerciseId);

    if (exercise == null) {
      return const SizedBox.shrink();
    }

    final firstStep = exercise.steps.isNotEmpty ? exercise.steps.first : null;
    final description = firstStep?.textFor(AppLang.en) ?? 
        'A guided exercise to help you feel better.';

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.glassStrong,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.glassBorder,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.ink.withValues(alpha: 0.15),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                exercise.navIcon,
                color: AppColors.accent,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Try ${exercise.brandTitle}',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: AppColors.inkSoft,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCancel,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.inkSoft,
                      side: BorderSide(color: AppColors.inkSoft.withValues(alpha: 0.3)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Not now'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ExercisePlayerScreen(exercise: exercise),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: const Text('Try it'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}