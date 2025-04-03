import 'package:flutter/material.dart';
import 'package:flutter_app/models/project_model.dart';

class AppColors {
  // State Colors
  static const Color planned = Color(0xff098ee1);
  static const Color inProgress = Color(0xffffa300);
  static const Color finished = Color(0xff079e00);

  static final Color plannedLight = Color.alphaBlend(planned.withAlpha(51), Colors.white); // ~20% opacity
  static final Color inProgressLight = Color.alphaBlend(inProgress.withAlpha(51), Colors.white);
  static final Color finishedLight = Color.alphaBlend(finished.withAlpha(51), Colors.white);

  // Text colors that contrast well with each state
  static const Color onPlanned = Colors.white;
  static const Color onInProgress = Colors.black;
  static const Color onFinished = Colors.white;

  // Get color by project state
  static Color getColorByState(EProjectState state) {
    switch (state) {
      case EProjectState.planned:
        return planned;
      case EProjectState.inProgress:
        return inProgress;
      case EProjectState.finished:
        return finished;
    }
  }

  // Get contrasting text color by project state
  static Color getOnColorByState(EProjectState state) {
    switch (state) {
      case EProjectState.planned:
        return onPlanned;
      case EProjectState.inProgress:
        return onInProgress;
      case EProjectState.finished:
        return onFinished;
    }
  }

  static ProjectStateColors getColorsByState(EProjectState state) {
    switch (state) {
      case EProjectState.planned:
        return ProjectStateColors(
          main: planned,
          light: plannedLight,
          onColor: onPlanned,
        );
      case EProjectState.inProgress:
        return ProjectStateColors(
          main: inProgress,
          light: inProgressLight,
          onColor: onInProgress,
        );
      case EProjectState.finished:
        return ProjectStateColors(
          main: finished,
          light: finishedLight,
          onColor: onFinished,
        );
    }
  }
}

class ProjectStateColors {
  final Color main;
  final Color light;
  final Color onColor;

  const ProjectStateColors({
    required this.main,
    required this.light,
    required this.onColor,
  });
}