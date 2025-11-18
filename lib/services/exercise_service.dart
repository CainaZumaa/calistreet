import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/exercise.dart';
import 'auth_service.dart';
import '../utils/logger.dart';

class ExerciseService {
  // Cliente com Service Role Key para ler a tabela de exercícios
  final SupabaseClient _publicClient = AuthService.client;

  // Busca todos os exercícios da tabela 'exercises'
  Future<List<Exercise>> fetchAllExercises() async {
    try {
      Logger.debug('ExerciseService', 'Buscando todos os exercícios');
      final List<dynamic> response = await _publicClient
          .from('exercises')
          .select('*')
          .order('name', ascending: true);

      final exercises = response
          .map((data) => Exercise.fromJson(data as Map<String, dynamic>))
          .toList();
      Logger.info(
        'ExerciseService',
        'Exercícios carregados com sucesso',
        extra: {'count': exercises.length},
      );
      return exercises;
    } catch (e, stackTrace) {
      Logger.error(
        'ExerciseService',
        'Erro ao buscar exercícios',
        error: e,
        stackTrace: stackTrace,
      );
      return []; // Retorna lista vazia em caso de falha
    }
  }
}
