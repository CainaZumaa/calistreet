import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/workout_exercise_item.dart';
import 'auth_service.dart';
import '../utils/logger.dart';
import '../utils/error_handler.dart';

class WorkoutService {
  final SupabaseClient _serviceClient = AuthService.createServiceRoleClient();

  Future<void> saveNewWorkout({
    required String workoutName,
    required List<WorkoutExerciseItem> items,
    required List<String> scheduleDays,
  }) async {
    final currentUserId = AuthService.currentUser?['user_id'];

    if (currentUserId == null) {
      Logger.warning(
        'WorkoutService',
        'Tentativa de salvar treino sem autenticação',
      );
      throw Exception('Usuário não autenticado. Faça login e tente novamente.');
    }

    if (items.isEmpty) {
      Logger.warning(
        'WorkoutService',
        'Tentativa de salvar treino sem exercícios',
      );
      throw Exception('O treino deve conter pelo menos um exercício.');
    }

    Logger.info(
      'WorkoutService',
      'Salvando novo treino',
      extra: {
        'workout_name': workoutName,
        'user_id': currentUserId,
        'exercises_count': items.length,
        'schedule_days': scheduleDays,
      },
    );

    String? newWorkoutId;

    try {
      // 1. INSERIR NA TABELA 'workouts'
      final List<Map<String, dynamic>> workoutResponse = await _serviceClient
          .from('workouts')
          .insert({
            'name': workoutName,
            'created_by_id': currentUserId,
            'is_template': false,
            'schedule_days': scheduleDays,
          })
          .select('id');

      if (workoutResponse.isEmpty) {
        throw Exception('Falha ao criar registro principal do treino.');
      }

      newWorkoutId = workoutResponse.first['id'] as String;
      Logger.debug(
        'WorkoutService',
        'Treino criado',
        extra: {'workout_id': newWorkoutId},
      );

      // 2. PREPARAR ITENS PARA INSERÇÃO EM LOTE na tabela 'workout_exercises'
      final List<Map<String, dynamic>> itemsToInsert = items
          .asMap()
          .entries
          .map((entry) => entry.value.toJson(newWorkoutId!, entry.key + 1))
          .toList();

      // 3. INSERIR EM LOTE NA TABELA 'workout_exercises'
      await _serviceClient.from('workout_exercises').insert(itemsToInsert);

      Logger.info(
        'WorkoutService',
        'Treino salvo com sucesso',
        extra: {'workout_id': newWorkoutId},
      );
    } catch (e, stackTrace) {
      // 4. TRATAMENTO DE ERRO COM REVERSÃO (ROLLBACK)
      Logger.error(
        'WorkoutService',
        'Erro ao salvar treino - executando rollback',
        error: e,
        stackTrace: stackTrace,
        extra: {'workout_id': newWorkoutId, 'workout_name': workoutName},
      );

      if (newWorkoutId != null) {
        try {
          await _serviceClient.from('workouts').delete().eq('id', newWorkoutId);
          Logger.info(
            'WorkoutService',
            'Rollback executado com sucesso',
            extra: {'workout_id': newWorkoutId},
          );
        } catch (rollbackError) {
          Logger.error(
            'WorkoutService',
            'Erro ao executar rollback',
            error: rollbackError,
            extra: {'workout_id': newWorkoutId},
          );
        }
      }
      throw Exception(
        ErrorHandler.handleError(
          e,
          stackTrace: stackTrace,
          context: 'saveNewWorkout',
        ),
      );
    }
  }

  Future<List<Map<String, dynamic>>> fetchUserWorkouts(String userId) async {
    try {
      Logger.debug(
        'WorkoutService',
        'Buscando treinos do usuário',
        extra: {'user_id': userId},
      );
      final serviceClient = AuthService.createServiceRoleClient();

      final List<dynamic> response = await serviceClient
          .from('workouts')
          .select('id, name')
          .limit(10);

      final workouts = response.cast<Map<String, dynamic>>();
      Logger.info(
        'WorkoutService',
        'Treinos carregados com sucesso',
        extra: {'user_id': userId, 'count': workouts.length},
      );
      return workouts;
    } catch (e, stackTrace) {
      Logger.error(
        'WorkoutService',
        'Erro ao buscar treinos do usuário',
        error: e,
        stackTrace: stackTrace,
        extra: {'user_id': userId},
      );
      return [];
    }
  }

  // Função para buscar um treino específico pelo ID
  Future<Map<String, dynamic>?> fetchWorkoutById(String workoutId) async {
    try {
      Logger.debug(
        'WorkoutService',
        'Buscando treino por ID',
        extra: {'workout_id': workoutId},
      );
      final serviceClient = AuthService.createServiceRoleClient();

      final response = await serviceClient
          .from('workouts')
          .select('*, workout_exercises:workout_exercises(*)')
          .eq('id', workoutId)
          .single();

      Logger.info(
        'WorkoutService',
        'Treino encontrado',
        extra: {'workout_id': workoutId},
      );
      return response as Map<String, dynamic>?;
    } catch (e, stackTrace) {
      Logger.warning(
        'WorkoutService',
        'Erro ao buscar treino por ID',
        error: e,
        stackTrace: stackTrace,
        extra: {'workout_id': workoutId},
      );
      return null;
    }
  }

  // Função para atualizar um treino existente
  Future<void> updateWorkout({
    required String workoutId,
    required String workoutName,
    required List<WorkoutExerciseItem> items,
    required List<String> scheduleDays,
  }) async {
    if (items.isEmpty) {
      throw Exception('O treino deve conter pelo menos um exercício.');
    }

    // 1. ATUALIZAR TABELA 'workouts'
    await _serviceClient
        .from('workouts')
        .update({'name': workoutName, 'schedule_days': scheduleDays})
        .eq('id', workoutId);

    // 2. EXCLUIR ITENS ANTIGOS e INSERIR NOVOS
    await _serviceClient
        .from('workout_exercises')
        .delete()
        .eq('workout_id', workoutId);

    // 3. PREPARAR E INSERIR NOVOS ITENS EM LOTE
    final List<Map<String, dynamic>> itemsToInsert = items
        .asMap()
        .entries
        .map((entry) => entry.value.toJson(workoutId, entry.key + 1))
        .toList();

    await _serviceClient.from('workout_exercises').insert(itemsToInsert);

    // Se falhar em qualquer inserção, a exceção será lançada e capturada no método chamador.
  }

  // Função para buscar treinos agendados para um dia específico
  Future<List<Map<String, dynamic>>> fetchUserWorkoutsByDay(
    String userId,
    String currentDay,
  ) async {
    try {
      Logger.debug(
        'WorkoutService',
        'Buscando treinos por dia',
        extra: {'user_id': userId, 'day': currentDay},
      );
      final serviceClient = AuthService.createServiceRoleClient();

      final List<dynamic> response = await serviceClient
          .from('workouts')
          .select('id, name, created_by_id, schedule_days')
          .eq('created_by_id', userId)
          .contains('schedule_days', [currentDay])
          .order('id', ascending: false);

      final workouts = response.cast<Map<String, dynamic>>();
      Logger.info(
        'WorkoutService',
        'Treinos por dia carregados',
        extra: {'user_id': userId, 'day': currentDay, 'count': workouts.length},
      );
      return workouts;
    } catch (e, stackTrace) {
      Logger.error(
        'WorkoutService',
        'Erro ao buscar treinos por dia',
        error: e,
        stackTrace: stackTrace,
        extra: {'user_id': userId, 'day': currentDay},
      );
      return [];
    }
  }
}
