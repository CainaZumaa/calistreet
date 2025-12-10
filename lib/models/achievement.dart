import 'package:flutter/material.dart';

class Achievement {
  final String id;
  final String name;
  final String description;
  final String iconName;
  final String targetExerciseId;
  final int thresholdCount;
  final bool isUnlocked; // Se o usuário já desbloqueou
  final int? currentValue;
  final int? targetValue;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
    required this.targetExerciseId,
    required this.thresholdCount,
    this.isUnlocked = false,
    this.currentValue,
    this.targetValue,
  });

  factory Achievement.fromJson(Map<String, dynamic> json, {required bool isUnlocked}) {
    return Achievement(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Conquista',
      description: json['description'] as String? ?? '',
      iconName: json['icon_name'] as String? ?? 'emoji_events',
      targetExerciseId: json['target_exercise_id'] as String? ?? '',
      thresholdCount: json['threshold_count'] as int? ?? 0,
      isUnlocked: isUnlocked,
      currentValue: json['current_value'] as int?,
      targetValue: json['target_value'] as int?,
    );
  }
  
}
extension AchievementCopy on Achievement {
  Achievement copyWith({
    String? id,
    String? name,
    String? description,
    String? iconName,
    String? targetExerciseId,
    int? thresholdCount,
    bool? isUnlocked,
    int? currentValue,
    int? targetValue,
  }) {
    return Achievement(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      targetExerciseId: targetExerciseId ?? this.targetExerciseId,
      thresholdCount: thresholdCount ?? this.thresholdCount,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      currentValue: currentValue ?? this.currentValue,
      targetValue: targetValue ?? this.targetValue,
    );
  }
}