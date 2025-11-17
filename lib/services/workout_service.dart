import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/workout_exercise_item.dart';
import 'auth_service.dart';

class WorkoutService {
  final SupabaseClient _serviceClient = AuthService.createServiceRoleClient();

  Future<void> saveNewWorkout({
    required String workoutName,
    required List<WorkoutExerciseItem> items,
    required List<String> scheduleDays,
  }) async {
    // 1. Obtenção do User ID
    final currentUserId = AuthService.currentUser?['user_id'];
    
    if (currentUserId == null) {
      throw Exception('Usuário não autenticado. Faça login e tente novamente.');
    }
    
    if (items.isEmpty) {
      throw Exception('O treino deve conter pelo menos um exercício.');
    }
    
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

      // 2. PREPARAR ITENS PARA INSERÇÃO EM LOTE na tabela 'workout_exercises'
      final List<Map<String, dynamic>> itemsToInsert = items
          .asMap()
          .entries
          .map((entry) => entry.value.toJson(newWorkoutId!, entry.key + 1))
          .toList();

      // 3. INSERIR EM LOTE NA TABELA 'workout_exercises'
      await _serviceClient
          .from('workout_exercises')
          .insert(itemsToInsert);
      
    } catch (e) {
      // 4. TRATAMENTO DE ERRO COM REVERSÃO (ROLLBACK)
      if (newWorkoutId != null) {
        await _serviceClient.from('workouts').delete().eq('id', newWorkoutId);
      }
      throw Exception('Falha na persistência do treino: ${e.toString()}');
    }
  }

  Future<List<Map<String, dynamic>>> fetchUserWorkouts(String userId) async {
    try {final serviceClient = AuthService.createServiceRoleClient();
      
      final List<dynamic> response = await serviceClient
          .from('workouts')
          .select('id, name')
          .limit(10);

      // Converte a lista de dynamic para List<Map<String, dynamic>>
      return response.cast<Map<String, dynamic>>();

    } catch (e) {
      print('Erro ao buscar treinos: $e');
      return [];
    }
  }

  // Função para buscar um treino específico pelo ID
  Future<Map<String, dynamic>?> fetchWorkoutById(String workoutId) async {
    try {
      final serviceClient = AuthService.createServiceRoleClient();

      final response = await serviceClient
          .from('workouts')
          .select('*, workout_exercises:workout_exercises(*)')
          .eq('id', workoutId)
          .single();

      // O Supabase retorna o JSON do treino, incluindo a lista de exercícios aninhada.
      return response as Map<String, dynamic>?;

    } catch (e) {
      print('Erro ao buscar treino: $e');
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
        .update({
          'name': workoutName,
          'schedule_days': scheduleDays,
        })
        .eq('id', workoutId);
        
    // 2. EXCLUIR ITENS ANTIGOS e INSERIR NOVOS
    await _serviceClient.from('workout_exercises').delete().eq('workout_id', workoutId);
        
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
  Future<List<Map<String, dynamic>>> fetchUserWorkoutsByDay(String userId, String currentDay) async {
    try {
      final serviceClient = AuthService.createServiceRoleClient(); 

      final List<dynamic> response = await serviceClient
          .from('workouts')
          .select('id, name, created_by_id, schedule_days') 
          .eq('created_by_id', userId) 
          .contains('schedule_days', [currentDay])
          .order('id', ascending: false);

      return response.cast<Map<String, dynamic>>();

    } catch (e) {
      print('Erro ao buscar treinos por dia: $e');
      return []; 
    }
  }
}