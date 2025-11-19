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
}
