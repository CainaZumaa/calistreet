import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/exercise.dart';
import 'auth_service.dart';

class ExerciseService {
  // Cliente com Service Role Key para ler a tabela de exercícios
  final SupabaseClient _publicClient = AuthService.client;

  // Busca todos os exercícios da tabela 'exercises'
  Future<List<Exercise>> fetchAllExercises() async {
    try {
      final List<dynamic> response = await _publicClient
          .from('exercises')
          .select('*')
          .order('name', ascending: true);

      // Mapeia a resposta JSON para a lista de modelos Dart
      return response.map((data) => Exercise.fromJson(data as Map<String, dynamic>)).toList();
      
    } catch (e) {
      print('Erro ao buscar exercícios: $e');
      return []; // Retorna lista vazia em caso de falha
    }
  }
}