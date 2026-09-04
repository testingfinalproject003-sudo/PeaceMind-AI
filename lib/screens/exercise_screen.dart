import 'package:flutter/material.dart';

import '../data/exercises.dart';
import 'exercise_player_screen.dart';

class ExerciseScreen extends StatelessWidget {
  const ExerciseScreen({super.key});

  static const Color background = Color(0xFFF3F6E8);
  static const Color darkBlue = Color(0xFF202952);
  static const Color darkText = Color(0xFF303450);
  static const Color greyText = Color(0xFF777B94);

  static final List<_ExerciseData> _exercises = [
    _ExerciseData(
      title: 'Box Breathing',
      subtitle: '3 cycles • Calm your mind',
      asset: 'assets/images/box_breathing_cover.png',
      fallbackIcon: Icons.self_improvement_rounded,
      color: const Color(0xFFECE8FA),
      exerciseInfo: boxBreathingExercise,
    ),
    _ExerciseData(
      title: 'Grounding 5-4-3-2-1',
      subtitle: 'Reconnect with senses',
      asset: 'assets/images/grounding_cover.png',
      fallbackIcon: Icons.spa_rounded,
      color: const Color(0xFFE5F3EC),
      exerciseInfo: groundingExercise,
    ),
    _ExerciseData(
      title: 'Mindful Walking',
      subtitle: 'Walk with awareness',
      asset: 'assets/images/mindful_walking_cover.png',
      fallbackIcon: Icons.directions_walk_rounded,
      color: const Color(0xFFFDECE3),
      exerciseInfo: mindWalkingExercise,
    ),
    _ExerciseData(
      title: 'Body Scan',
      subtitle: 'Release tension slowly',
      asset: 'assets/images/body_scan_cover.png',
      fallbackIcon: Icons.accessibility_new_rounded,
      color: const Color(0xFFE8EEF7),
      exerciseInfo: bodyScanExercise,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildExerciseGrid(context),
                    const SizedBox(height: 24),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'More exercises coming soon 🌱',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: greyText,
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseGrid(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _exercises.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.78,
      ),
      itemBuilder: (context, index) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 400 + index * 120),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 30 * (1 - value)),
              child: Opacity(opacity: value, child: child),
            );
          },
          child: _buildExerciseTile(context, _exercises[index]),
        );
      },
    );
  }

  Widget _buildExerciseTile(BuildContext context, _ExerciseData data) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ExercisePlayerScreen(exercise: data.exerciseInfo),
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .06),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: data.color.withValues(alpha: .40),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Full image cover
            Image.asset(
              data.asset,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: data.color,
                  alignment: Alignment.center,
                  child: Icon(
                    data.fallbackIcon,
                    color: darkBlue,
                    size: 40,
                  ),
                );
              },
            ),
            // Gradient overlay at bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0),
                      Colors.black.withValues(alpha: 0.65),
                    ],
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(12, 24, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      data.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Play icon overlay
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFF202952),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.white.withValues(alpha: .85),
                ),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: background,
                size: 17,
              ),
            ),
          ),
          const SizedBox(width: 13),
          const Expanded(
            child: Text(
              'Exercise',
              style: TextStyle(
                color: darkText,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseData {
  final String title;
  final String subtitle;
  final String asset;
  final IconData fallbackIcon;
  final Color color;
  final dynamic exerciseInfo;

  _ExerciseData({
    required this.title,
    required this.subtitle,
    required this.asset,
    required this.fallbackIcon,
    required this.color,
    required this.exerciseInfo,
  });
}