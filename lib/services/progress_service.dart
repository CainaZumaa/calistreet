import 'package:calistreet/models/progress.dart';
import 'package:calistreet/services/auth_service.dart';
import 'package:calistreet/utils/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/achievement.dart';

class ProgressService {
  final SupabaseClient _client = AuthService.createServiceRoleClient();
  final Uuid _uuid = const Uuid();

  Future<List<Progress>> getProgressForUser(String userId) async {
    try {
      final response = await _client
          .from('progress')
          .select('*')
          .eq('user_id', userId)
          .order('start_date', ascending: false);

      final List<Progress> progressList = (response as List)
          .map((data) => Progress.fromJson(data as Map<String, dynamic>))
          .toList();
      return progressList;
    } catch (e) {
      // Handle or rethrow the exception as needed
      Logger.error(
        'ProgressService',
        'Erro ao buscar progresso do usuário',
        error: e,
      );
      rethrow;
    }
  }

  Future<void> addProgress(Progress progress) async {
    try {
      await _client.from('progress').insert(progress.toJson());
    } catch (e) {
      // Handle or rethrow the exception as needed
      Logger.error('ProgressService', 'Erro ao adicionar progresso', error: e);
      rethrow;
    }
  }

  /// Busca progresso dos últimos 7 dias para exibir no gráfico semanal
  Future<List<Progress>> getLast7DaysProgress(String userId) async {
    try {
      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));

      final response = await _client
          .from('progress')
          .select('*')
          .eq('user_id', userId)
          .gte('start_date', sevenDaysAgo.toIso8601String())
          .order('start_date', ascending: true);

      final List<Progress> progressList = (response as List)
          .map((data) => Progress.fromJson(data as Map<String, dynamic>))
          .toList();
      return progressList;
    } catch (e) {
      Logger.error(
        'ProgressService',
        'Erro ao buscar progresso dos últimos 7 dias',
        error: e,
      );
      rethrow;
    }
  }

  /// Busca progresso da semana atual (segunda a domingo)
  Future<List<Progress>> getCurrentWeekProgress(String userId) async {
    try {
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final endOfWeek = startOfWeek.add(
        const Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
      );

      final response = await _client
          .from('progress')
          .select('*')
          .eq('user_id', userId)
          .gte('start_date', startOfWeek.toIso8601String())
          .lte('start_date', endOfWeek.toIso8601String())
          .order('start_date', ascending: true);

      final List<Progress> progressList = (response as List)
          .map((data) => Progress.fromJson(data as Map<String, dynamic>))
          .toList();
      return progressList;
    } catch (e) {
      Logger.error(
        'ProgressService',
        'Erro ao buscar progresso da semana atual',
        error: e,
      );
      rethrow;
    }
  }

  /// Inicia um novo progresso de treino (status IN_PROGRESS)
  Future<String> startWorkoutProgress({
    required String userId,
    required String workoutId,
  }) async {
    final sessionId = _uuid.v4();
    try {
      await _client.from('progress').insert({
        'id': sessionId,
        'user_id': userId,
        'workout_id': workoutId,
        'start_date': DateTime.now().toIso8601String(),
        'status': 'IN_PROGRESS',
      });
      return sessionId; // Retorna o ID da sessão criada
    } catch (e) {
      throw Exception('Falha ao iniciar a sessão de treino: ${e.toString()}');
    }
  }

  /// Finaliza um progresso de treino (atualiza para COMPLETED)
  Future<void> completeWorkoutProgress({
    required String progressId,
    required int durationSeconds,
    String? notes,
  }) async {
    try {
      final now = DateTime.now().toIso8601String();

      // 1. Atualiza o progresso da sessão para COMPLETED
      await _client.from('progress').update({
        'end_date': now,
        'duration_seconds': durationSeconds,
        'status': 'COMPLETED',
        if (notes != null) 'notes': notes,
      }).eq('id', progressId);

      // 2. Busca o progress para pegar o workout_id
      final progressData = await _client
          .from('progress')
          .select('workout_id')
          .eq('id', progressId)
          .single();

      final workoutId = progressData['workout_id'] as String;

      // 3. Busca todos os exercícios do treino
      final workoutExercises = await _client
          .from('workout_exercises')
          .select('*')
          .eq('workout_id', workoutId);

      // 4. Insere os exercícios na tabela progress_exercises
      for (final we in workoutExercises) {
        await _client.from('progress_exercises').insert({
          'progress_id': progressId,
          'exercise_id': we['exercise_id'],
          'sets_completed': we['sets'],
          'repetitions_completed': we['sets'] * we['repetitions'],
        });
      }

    } catch (e) {
      throw Exception('Falha ao concluir a sessão de treino: ${e.toString()}');
    }
  }

  /// Cancela um progresso de treino (atualiza para SKIPPED)
  Future<void> cancelWorkoutProgress({
    required String progressId,
    String? notes,
  }) async {
    try {
      await _client
          .from('progress')
          .update({
            'end_date': DateTime.now().toIso8601String(),
            'status': 'SKIPPED',
            if (notes != null) 'notes': notes,
          })
          .eq('id', progressId);

      Logger.info(
        'ProgressService',
        'Progresso cancelado',
        extra: {'progress_id': progressId},
      );
    } catch (e) {
      Logger.error('ProgressService', 'Erro ao cancelar progresso', error: e);
      rethrow;
    }
  }

  // Função para contar treinos concluídos pelo usuário
  Future<int> countCompletedWorkouts(String userId) async {
    try {
      final serviceClient = AuthService.createServiceRoleClient();

      final response = await serviceClient
          .from('progress')
          .select('id')
          .eq('user_id', userId)
          .eq('status', 'COMPLETED');

      return response.length;
    } catch (e) {
      print('ProgressService Erro ao contar treinos: $e');
      return 0;
    }
  }

  // Função para buscar a duração total (em segundos) de todos os treinos concluídos
  Future<int> fetchTotalDuration(String userId) async {
    final List<Progress> allProgress = await getAllUserProgress(userId);
    
    int totalSeconds = allProgress
        .where((p) => p.status == ProgressStatus.completed && p.durationSeconds != null)
        .fold(0, (sum, p) => sum + p.durationSeconds!);
    
    return totalSeconds;
  }

  // NOVO: Busca o histórico de sessões concluídas para exibição
  Future<List<Map<String, dynamic>>> getWorkoutHistory(String userId) async {
    try {
      final serviceClient = AuthService.createServiceRoleClient(); 

      // Busca sessões CONCLUIDAS na tabela 'progress'
      // Faz JOIN com a tabela 'workouts' para obter o nome do treino.
      final List<dynamic> response = await serviceClient.from('progress')
          .select('*, workouts(name)') // Pega o nome do treino aninhado
          .eq('user_id', userId)
          .order('start_date', ascending: false) // Mais recente primeiro
          .limit(20); // Limita para agilidade

      // Mapeia a resposta e extrai o nome do treino
      return response.map((data) {
        final workoutName = (data['workouts'] as Map<String, dynamic>?)?['name'] ?? 'Treino Excluído';
        
        return {
          'id': data['id'],
          'workout_name': workoutName,
          'date': DateTime.parse(data['start_date'] as String), // Converte para DateTime
          'duration': data['duration_seconds'],
          'status': data['status'],
        };
      }).toList();
      
    } catch (e) {
      print('ProgressService Erro ao buscar histórico: $e');
      return []; 
    }
  }

  Future<List<String>> checkAchievements(String userId) async {
    final supabase = AuthService.createServiceRoleClient();

    final achievementsResponse = await supabase
        .from('achievements')
        .select('*');

    final unlockedIds = <String>[];

    for (final json in achievementsResponse) {
      final achievement = Achievement.fromJson(json, isUnlocked: false);

      final rpc = await supabase.rpc('sum_user_reps', params: {
        'user_id_param': userId,
        'exercise_id_param': achievement.targetExerciseId,
      });

      final int totalReps = ((rpc?['total'] ?? 0) as num).toInt();

      if (totalReps >= achievement.thresholdCount) {
        final alreadyUnlocked = await supabase
            .from('user_achievements')
            .select()
            .eq('user_id', userId)
            .eq('achievement_id', achievement.id)
            .maybeSingle();

        if (alreadyUnlocked == null) {
          await supabase.from('user_achievements').insert({
            'user_id': userId,
            'achievement_id': achievement.id,
          });
        }

        unlockedIds.add(achievement.id);
      }
    }

    return unlockedIds;
  }

  Future<List<Achievement>> getUserAchievements(String userId) async {
    final supabase = AuthService.createServiceRoleClient();

    final achievementRows = await supabase.from('achievements').select('*');

    final unlockedRows = await supabase
        .from('user_achievements')
        .select('achievement_id')
        .eq('user_id', userId);

    final unlockedIds = unlockedRows.map((e) => e['achievement_id']).toSet();

    // Paraleliza as RPCs
    final futures = achievementRows.map((json) async {
      final achId = json['id'] as String;
      final exerciseId = json['target_exercise_id'] as String?;

      int totalReps = 0;
      if (exerciseId != null) {
        try {
          final rpc = await supabase.rpc(
            'sum_user_reps',
            params: {
              'user_id_param': userId,
              'exercise_id_param': exerciseId,
            },
          );
          totalReps = (rpc as int?) ?? 0;
        } catch (e) {
          totalReps = 0;
          debugPrint('Erro na RPC sum_user_reps para $achId: $e');
        }
      }

      return Achievement.fromJson(
        json,
        isUnlocked: unlockedIds.contains(achId) || totalReps >= (json['threshold_count'] as int? ?? 0),
      ).copyWith(
        currentValue: totalReps,
        targetValue: json['threshold_count'] as int? ?? 0,
      );
    });

    return await Future.wait(futures);
  }

  Future<List<Progress>> getAllUserProgress(String userId) async {
    final supabase = AuthService.createServiceRoleClient();

    try {
      final List<Map<String, dynamic>> data = await supabase
          .from('progress')
          .select()
          .eq('user_id', userId);

      return data.map((json) => Progress.fromJson(json)).toList();
    } catch (e) {
      print('Erro ao buscar todos os progressos: $e');
      return [];
    }
  }
}
