import 'package:calistreet/models/progress.dart';
import 'package:calistreet/services/auth_service.dart';
import 'package:calistreet/utils/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

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
    final sessionId = _uuid.v4();
    try {
      await _client.from('progress').insert({
        'id': sessionId,
        'user_id': userId,
        'workout_id': workoutId,
        'start_date': DateTime.now().toIso8601String(),
        'status': 'EM_ANDAMENTO',
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
      await _client.from('progress')
          .update({
            'end_date': now,
            'duration_seconds': durationSeconds,
            'status': 'CONCLUIDO',
            if (notes != null) 'notes': notes,
          })
          .eq('id', progressId);
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
      Logger.error(
        'ProgressService',
        'Erro ao cancelar progresso',
        error: e,
      );
      rethrow;
    }
  }

  // Função para contar treinos concluídos pelo usuário
  Future<int> countCompletedWorkouts(String userId) async {
    try {
      final serviceClient = AuthService.createServiceRoleClient();

      final response = await serviceClient.from('progress')
          .select('id')
          .eq('user_id', userId)
          .eq('status', 'CONCLUIDO');

      if (response is List) {
        return response.length;
      }
      return 0;
    } catch (e) {
      print('ProgressService Erro ao contar treinos: $e');
      return 0;
    }
  }

  // Função para buscar a duração total (em segundos) de todos os treinos concluídos
Future<int> fetchTotalDuration(String userId) async {
  try {
    final serviceClient = AuthService.createServiceRoleClient();
    
    final List<dynamic> response = (await serviceClient.from('progress')
        .select('sum(duration_seconds)')
        .eq('user_id', userId)
        .eq('status', 'CONCLUIDO')
        .single()) as List;
        
    final Map<String, dynamic> aggregate = response.first as Map<String, dynamic>;
    
    final int totalSeconds = aggregate['sum'] as int? ?? 0;
    
    return totalSeconds;
    
  } catch (e) {
    print('ProgressService Erro ao buscar duração total: $e');
    return 0;
  }
}
}
