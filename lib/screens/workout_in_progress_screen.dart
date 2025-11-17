import 'package:flutter/material.dart';

// Cores baseadas no code.html e no padrão
const Color primaryColor = Color(0xFF39FF14); // Verde Neon
const Color backgroundDark = Color(0xFF1A1A1A);
const Color cardDark = Color(0xFF212121);
const Color textDark = Color(0xFFFFFFFF);
const Color subtextDark = Color(0xFFB0B0B0); // Cinza para subtexto

class WorkoutInProgressScreen extends StatefulWidget {
  const WorkoutInProgressScreen({super.key});

  @override
  State<WorkoutInProgressScreen> createState() => _WorkoutInProgressScreenState();
}

class _WorkoutInProgressScreenState extends State<WorkoutInProgressScreen> {
  // Simulação de estado do treino/cronômetro
  bool _isPaused = true;
  int _minutes = 1;
  int _seconds = 25;
  double _overallProgress = 1 / 3; // Simula 1 de 3 exercícios concluídos
  
  // Lista de Exercícios (Simulados)
  List<Map<String, dynamic>> _exercises = [
    {'name': 'Flexões', 'details': '3 séries x 10 repetições | 60s de descanso', 'isCompleted': true},
    {'name': 'Flexão Diamante', 'details': '3 séries x 8 repetições | 60s de descanso', 'isCompleted': false},
    {'name': 'Flexão Inclinada', 'details': '3 séries x 12 repetições | 60s de descanso', 'isCompleted': false},
  ];

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  void _finishWorkout() {
    // TODO: 1. Lógica de cálculo de calorias/tempo
    // TODO: 2. Enviar dados de conclusão para o Supabase
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Treino concluído com sucesso!'), backgroundColor: primaryColor),
    );
    Navigator.of(context).pop(); // Volta para a Home
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
        title: const Text('Treino de Peito - Iniciante', style: TextStyle(color: textDark, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: textDark),
            onPressed: () { /* TODO: Opções do treino */ },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                children: [
                  _buildTimerSection(),
                  const SizedBox(height: 24),
                  _buildProgressIndicator(),
                  const SizedBox(height: 32),
                  _buildPauseButton(),
                  const SizedBox(height: 32),
                  _buildExerciseChecklist(),
                ],
              ),
            ),
          ),
          _buildFinishWorkoutButton(),
        ],
      ),
    );
  }

  Widget _buildTimerSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTimerBox(_minutes.toString().padLeft(2, '0')),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text(':', style: TextStyle(color: textDark, fontSize: 32, fontWeight: FontWeight.bold)),
          ),
          _buildTimerBox(_seconds.toString().padLeft(2, '0')),
        ],
      ),
    );
  }

  Widget _buildTimerBox(String value) {
    return Expanded(
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: cardDark,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            value,
            style: const TextStyle(color: textDark, fontSize: 32, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Progresso Geral', style: TextStyle(color: textDark, fontSize: 16)),
              Text('${(_overallProgress * 100).toInt()}%', style: TextStyle(color: subtextDark)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _overallProgress,
              minHeight: 10,
              backgroundColor: cardDark,
              valueColor: const AlwaysStoppedAnimation<Color>(primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPauseButton() {
    return GestureDetector(
      onTap: _togglePause,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: primaryColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.4),
              blurRadius: 10,
            ),
          ],
        ),
        child: Icon(
          _isPaused ? Icons.play_arrow : Icons.pause,
          color: backgroundDark,
          size: 40,
        ),
      ),
    );
  }

  Widget _buildExerciseChecklist() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: _exercises.asMap().entries.map((entry) {
          int index = entry.key;
          Map<String, dynamic> exercise = entry.value;

          return Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Checkbox(
                  value: exercise['isCompleted'],
                  onChanged: (bool? newValue) {
                    setState(() {
                      _exercises[index]['isCompleted'] = newValue ?? false;
                    });
                  },
                  activeColor: primaryColor,
                  checkColor: backgroundDark,
                  side: const BorderSide(color: Color(0xFF404040), width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                title: Text(
                  exercise['name'],
                  style: const TextStyle(color: textDark, fontSize: 16, fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  exercise['details'],
                  style: TextStyle(color: subtextDark, fontSize: 13),
                ),
                onTap: () {
                  setState(() {
                    _exercises[index]['isCompleted'] = !exercise['isCompleted'];
                  });
                },
              ),
              if (index < _exercises.length - 1)
                const Divider(color: Color(0xFF404040), height: 1), // Divisor
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFinishWorkoutButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      color: backgroundDark,
      child: SizedBox(
        height: 56,
        child: ElevatedButton(
          onPressed: _finishWorkout,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Concluir Treino',
            style: TextStyle(color: backgroundDark, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}