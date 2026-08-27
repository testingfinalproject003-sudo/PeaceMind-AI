import 'package:flutter/material.dart';
import '../model/exercise_models.dart';
import '../theme/app_theme.dart';
import '../models/exercise_models.dart';
import '../data/exercises.dart';
import '../widgets/glass_widgets.dart';
import 'exercise_player_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.skyGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PEACEMIND',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.1,
                    color: AppColors.inkSoft,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Guided Relaxation',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.ink),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Choose an exercise to begin your session.',
                  style: TextStyle(fontSize: 13, color: AppColors.inkSoft),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.separated(
                    itemCount: allExercises.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, i) => _ExerciseCard(exercise: allExercises[i]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final ExerciseInfo exercise;
  const _ExerciseCard({required this.exercise});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ExercisePlayerScreen(exercise: exercise)),
      ),
      child: GlassPanel(
        radius: 20,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: exercise.homeCardAccent.withOpacity(0.15),
              ),
              child: Icon(exercise.navIcon, color: exercise.homeCardAccent, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.brandTitle.replaceFirst('PeaceMind · ', ''),
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.ink),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    exercise.homeCardBlurb,
                    style: const TextStyle(fontSize: 11.5, color: AppColors.inkSoft, height: 1.3),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.inkSoft),
          ],
        ),
      ),
    );
  }
}
