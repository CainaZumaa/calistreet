class WorkoutExerciseItem {
  final String exerciseId;
  final String exerciseName;
  int sets;
  int repetitions;
  final String imageUrl;
  
  WorkoutExerciseItem({
    required this.exerciseId,
    required this.exerciseName,
    required this.imageUrl,
    this.sets = 3,
    this.repetitions = 10,
  });

  // Converte para o formato que a DB (tabela workout_exercises) espera
  Map<String, dynamic> toJson(String workoutId, int order) {
    return {
      'workout_id': workoutId,
      'exercise_id': exerciseId,
      'sequence_order': order,
      'sets': sets,
      'repetitions': repetitions,
    };
  }
}