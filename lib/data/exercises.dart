import 'package:flutter/material.dart';
import '../model/exercise_models.dart';
import '../theme/app_theme.dart';
import '../models/exercise_models.dart';
import '../widgets/stage/body_scan_stage.dart';
import '../widgets/stage/grounding_stage.dart';
import '../widgets/stage/box_breathing_stage.dart';
import '../widgets/stage/mind_walking_stage.dart';
import 'body_scan_data.dart';
import 'grounding_data.dart';
import 'box_breathing_data.dart';
import 'mind_walking_data.dart';

final ExerciseInfo bodyScanExercise = ExerciseInfo(
  id: 'body_scan',
  brandTitle: 'PeaceMind · Body Scan',
  navIcon: Icons.accessibility_new_rounded,
  steps: bodyScanSteps,
  completion: bodyScanCompletion,
  homeCardBlurb: 'A progressive muscle relaxation journey down through every part of your body.',
  homeCardAccent: AppColors.accent,
  stageBuilder: (context, stepIndex, progress, playing) => BodyScanStage(
    activeNodes: bodyScanSteps[stepIndex].activeNodes,
    eyesClosed: bodyScanSteps[stepIndex].eyesClosed,
    playing: playing,
  ),
);

final ExerciseInfo groundingExercise = ExerciseInfo(
  id: 'grounding',
  brandTitle: 'PeaceMind · Grounding',
  navIcon: Icons.spa_rounded,
  steps: groundingSteps,
  completion: groundingCompletion,
  homeCardBlurb: 'The 5-4-3-2-1 technique to anchor your mind back into the present moment.',
  homeCardAccent: AppColors.green,
  stageBuilder: (context, stepIndex, progress, playing) => GroundingStage(
    activeNodes: groundingSteps[stepIndex].activeNodes,
    playing: playing,
  ),
);

final ExerciseInfo boxBreathingExercise = ExerciseInfo(
  id: 'box_breathing',
  brandTitle: 'PeaceMind · Box Breathing',
  navIcon: Icons.crop_square_rounded,
  steps: boxBreathingSteps,
  completion: boxBreathingCompletion,
  homeCardBlurb: 'A steady 4-4-4-4 breathing pattern used to calm the nervous system fast.',
  homeCardAccent: AppColors.gold,
  stageBuilder: (context, stepIndex, progress, playing) => BoxBreathingStage(playing: playing),
);

final ExerciseInfo mindWalkingExercise = ExerciseInfo(
  id: 'mind_walking',
  brandTitle: 'PeaceMind · Mind Walking',
  navIcon: Icons.directions_walk_rounded,
  steps: mindWalkingSteps,
  completion: mindWalkingCompletion,
  homeCardBlurb: 'A slow, attentive walking meditation that grounds you step by step.',
  homeCardAccent: AppColors.accent2,
  stageBuilder: (context, stepIndex, progress, playing) => MindWalkingStage(
    progress: progress,
    playing: playing,
  ),
);

final List<ExerciseInfo> allExercises = [
  bodyScanExercise,
  groundingExercise,
  boxBreathingExercise,
  mindWalkingExercise,
];
