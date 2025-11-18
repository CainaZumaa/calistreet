import 'package:flutter/material.dart';
import 'create_workout_screen.dart';
import '../../services/workout_service.dart';
import '../../services/auth_service.dart';

// Cores baseadas no padrão
const Color primaryColor = Color(0xFF007AFF);
const Color backgroundDark = Color(0xFF000000); 
const Color cardDark = Color(0xFF1A1A1A); 
const Color textDark = Color(0xFFFFFFFF);
const Color subtextDark = Color(0xFF888888); 
const Color borderDark = Color(0xFF2C2C2C); 
const Color errorColor = Color(0xFFE53935);

class MyWorkoutsScreen extends StatefulWidget {
  const MyWorkoutsScreen({super.key});

  @override
  State<MyWorkoutsScreen> createState() => _MyWorkoutsScreenState();
}

class _MyWorkoutsScreenState extends State<MyWorkoutsScreen> {
  List<Map<String, dynamic>> _userWorkouts = []; // Lista vazia, será populada
  bool _isLoading = true;
  final WorkoutService _workoutService = WorkoutService();

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
  }

  Future<void> _loadWorkouts() async {
    final userId = AuthService.currentUser?['user_id'];
    
    if (userId == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final List<Map<String, dynamic>> workouts = await _workoutService.fetchUserWorkouts(userId as String);

    setState(() {
      _userWorkouts = workouts;
      _isLoading = false;
    });
  }
  
  void _editWorkout(String workoutId) {
    // Navega para a tela de criação/edição, passando o ID
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreateWorkoutScreen(workoutId: workoutId), // <--- PASSANDO O ID
      ),
    ).then((_) => _loadWorkouts()); // Recarrega a lista ao voltar
  }

  void _deleteWorkout(String workoutId) {
    setState(() {
      _userWorkouts.removeWhere((w) => w['id'] == workoutId);
      // TODO: Implementar exclusão no Supabase
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Treino excluído com sucesso!'), backgroundColor: errorColor),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundDark,
      appBar: AppBar(
        backgroundColor: backgroundDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Meus Treinos', style: TextStyle(color: textDark, fontWeight: FontWeight.bold)),
        actions: [
          // Botão de Refresh
          IconButton(
            icon: const Icon(Icons.refresh, color: textDark),
            onPressed: _loadWorkouts,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : _userWorkouts.isEmpty
              ? _buildEmptyState()
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: _userWorkouts.map((workout) => _buildWorkoutCard(workout)).toList(),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.list_alt, color: subtextDark, size: 60),
          const SizedBox(height: 16),
          Text('Nenhum treino encontrado.', style: TextStyle(color: textDark, fontSize: 18)),
          const SizedBox(height: 8),
          Text('Crie seu primeiro treino personalizado!', style: TextStyle(color: subtextDark)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
               Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const CreateWorkoutScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Montar Novo Treino'),
          )
        ],
      ),
    );
  }

  Widget _buildWorkoutCard(Map<String, dynamic> workout) {
    final String levelDisplay = workout['level'] ?? 'Não definido'; 
    
    return Card(
      color: cardDark,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        leading: Icon(Icons.fitness_center, color: primaryColor),
        title: Text(
          workout['name'] as String,
          style: const TextStyle(color: textDark, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Nível: $levelDisplay',
          style: TextStyle(color: subtextDark),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Botão de Editar
            IconButton(
              icon: Icon(Icons.edit, color: primaryColor, size: 20),
              onPressed: () => _editWorkout(workout['id'] as String),
            ),
            // Botão de Excluir
            IconButton(
              icon: Icon(Icons.delete_outline, color: errorColor, size: 20),
              onPressed: () => _deleteWorkout(workout['id'] as String),
            ),
          ],
        ),
        onTap: () => _editWorkout(workout['id'] as String), 
      ),
    );
  }
}