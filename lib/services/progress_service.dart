import 'package:calistreet/models/progress.dart';
import 'package:calistreet/services/auth_service.dart';
import 'package:calistreet/utils/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProgressService {
  final SupabaseClient _client = AuthService.client;

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
      Logger.error(
        'ProgressService',
        'Erro ao adicionar progresso',
        error: e,
      );
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
      final endOfWeek = startOfWeek.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));

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
    try {
      final response = await _client
          .from('progress')
          .insert({
            'user_id': userId,
            'workout_id': workoutId,
            'start_date': DateTime.now().toIso8601String(),
            'status': 'IN_PROGRESS',
          })
          .select('id')
          .single();

      final progressId = response['id'] as String;
      
      Logger.info(
        'ProgressService',
        'Progresso iniciado com sucesso',
        extra: {'progress_id': progressId, 'workout_id': workoutId},
      );
      
      return progressId;
    } catch (e) {
      Logger.error(
        'ProgressService',
        'Erro ao iniciar progresso',
        error: e,
      );
      rethrow;
    }
  }

  /// Finaliza um progresso de treino (atualiza para COMPLETED)
  Future<void> completeWorkoutProgress({
    required String progressId,
    required int durationSeconds,
    String? notes,
  }) async {
    try {
      await _client
          .from('progress')
          .update({
            'end_date': DateTime.now().toIso8601String(),
            'duration_seconds': durationSeconds,
            'status': 'COMPLETED',
            if (notes != null) 'notes': notes,
          })
          .eq('id', progressId);

      Logger.info(
        'ProgressService',
        'Progresso concluído com sucesso',
        extra: {'progress_id': progressId, 'duration': durationSeconds},
      );
    } catch (e) {
      Logger.error(
        'ProgressService',
        'Erro ao concluir progresso',
        error: e,
      );
      rethrow;
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
      Logger.error(
        'ProgressService',
        'Erro ao cancelar progresso',
        error: e,
      );
      rethrow;
    }
  }
}
