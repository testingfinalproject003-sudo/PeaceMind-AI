// lib/data/exercise_registry.dart
import 'package:flutter/material.dart';
import '../models/exercise_models.dart';
import '../widgets/stage/box_breathing_stage.dart';
import '../widgets/stage/grounding_stage.dart';
import '../widgets/stage/body_scan_stage.dart';
import '../widgets/stage/mind_walking_stage.dart';
import 'box_breathing_data.dart';
import 'grounding_data.dart';
import 'body_scan_data.dart';
import 'mind_walking_data.dart';

// ============ BOX BREATHING ============
final boxBreathingExercise = ExerciseInfo(
  id: 'box_breathing',
  brandTitle: 'Box Breathing',
  navIcon: Icons.air,
  steps: boxBreathingSteps,
  completion: boxBreathingCompletion,
  stageBuilder: (context, stepIndex, progress, playing) {
    return BoxBreathingStage(playing: playing);
  },
  homeCardBlurb: 'Calm your mind with 4-4-4-4 breathing',
  homeCardAccent: const Color(0xFFECE8FA),
);

// ============ GROUNDING ============
final groundingExercise = ExerciseInfo(
  id: 'grounding',
  brandTitle: 'Grounding 5-4-3-2-1',
  navIcon: Icons.spa_rounded,
  steps: groundingSteps,
  completion: groundingCompletion,
  stageBuilder: (context, stepIndex, progress, playing) {
    final step = groundingSteps[stepIndex];
    return GroundingStage(
      activeNodes: step.activeNodes,
      playing: playing,
    );
  },
  homeCardBlurb: 'Reconnect with your senses',
  homeCardAccent: const Color(0xFFE5F3EC),
);

// ============ BODY SCAN ============
final bodyScanExercise = ExerciseInfo(
  id: 'body_scan',
  brandTitle: 'Body Scan',
  navIcon: Icons.accessibility_new_rounded,
  steps: bodyScanSteps,
  completion: bodyScanCompletion,
  stageBuilder: (context, stepIndex, progress, playing) {
    final step = bodyScanSteps[stepIndex];
    return BodyScanStage(
      activeNodes: step.activeNodes,
      eyesClosed: step.eyesClosed,
      playing: playing,
    );
  },
  homeCardBlurb: 'Release tension slowly',
  homeCardAccent: const Color(0xFFE8EEF7),
);

// ============ MINDFUL WALKING ============
final mindWalkingExercise = ExerciseInfo(
  id: 'mindful_walking',
  brandTitle: 'Mindful Walking',
  navIcon: Icons.directions_walk_rounded,
  steps: mindWalkingSteps,
  completion: mindWalkingCompletion,
  stageBuilder: (context, stepIndex, progress, playing) {
    return MindWalkingStage(progress: progress, playing: playing);
  },
  homeCardBlurb: 'Walk with awareness',
  homeCardAccent: const Color(0xFFFDECE3),
);

// ============ REGISTRY ============
final Map<String, ExerciseInfo> exerciseMap = {
  'box_breathing': boxBreathingExercise,
  'grounding': groundingExercise,
  'body_scan': bodyScanExercise,
  'mindful_walking': mindWalkingExercise,
};

ExerciseInfo? getExerciseById(String id) {
  return exerciseMap[id];
}

List<ExerciseInfo> getAllExercises() {
  return exerciseMap.values.toList();
}