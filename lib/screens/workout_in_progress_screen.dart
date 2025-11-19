import 'package:flutter/material.dart';
import 'dart:async';
import '../services/workout_service.dart';
import '../services/progress_service.dart';
import '../services/auth_service.dart';

// Cores baseadas no code.html e no padrão
const Color primaryColor = Color(0xFF007AFF); // Azul padrão do projeto
const Color backgroundDark = Color(0xFF1A1A1A);
const Color cardDark = Color(0xFF212121);
const Color textDark = Color(0xFFFFFFFF);
const Color subtextDark = Color(0xFFB0B0B0); // Cinza para subtexto

class WorkoutInProgressScreen extends StatefulWidget {
  final String workoutId;
  const WorkoutInProgressScreen({super.key, required this.workoutId});

  @override
  State<WorkoutInProgressScreen> createState() =>
      _WorkoutInProgressScreenState();
}

class _WorkoutInProgressScreenState extends State<WorkoutInProgressScreen> {
  // Cronômetro
  bool _isPaused = true;
  int _elapsedSeconds = 0;
  Timer? _timer;
  
  List<Map<String, dynamic>> _exercises = [];
  String _workoutName = '';
  bool _isLoading = true;
  
  // Progress tracking
  String? _progressId;
  final ProgressService _progressService = ProgressService();
  
  // Calcula o progresso com base nos exercícios completados
  double get _overallProgress {
    if (_exercises.isEmpty) return 0.0;
    final completed = _exercises.where((e) => e['isCompleted'] == true).length;
    return completed / _exercises.length;
  }
  
  // Formata tempo do cronômetro
  int get _minutes => _elapsedSeconds ~/ 60;
  int get _seconds => _elapsedSeconds % 60;

  @override
  void initState() {
    super.initState();
    _loadWorkoutData();
    _startWorkout();
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
  
  /// Inicia o treino e registra no banco
  Future<void> _startWorkout() async {
    try {
      final userId = AuthService.currentUser?['user_id'] as String?;
      if (userId == null) return;
      
      _progressId = await _progressService.startWorkoutProgress(
        userId: userId,
        workoutId: widget.workoutId,
      );
      
      // Inicia o cronômetro automaticamente
      _startTimer();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao iniciar treino')),
        );
      }
    }
  }
  
  /// Inicia/resume o cronômetro
  void _startTimer() {
    // Cancela timer anterior se existir (evita múltiplos timers rodando)
    _timer?.cancel();
    
    setState(() {
      _isPaused = false;
    });
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _elapsedSeconds++;
        });
      }
    });
  }
  
  /// Pausa o cronômetro
  void _pauseTimer() {
    _timer?.cancel();
    _timer = null;
    
    setState(() {
      _isPaused = true;
    });
  }
  
  /// Toggle entre play e pause
  void _togglePause() {
    if (_isPaused) {
      _startTimer();
    } else {
      _pauseTimer();
    }
  }

  void _loadWorkoutData() async {
    final WorkoutService workoutService = WorkoutService();
    final workoutData = await workoutService.fetchWorkoutById(widget.workoutId);

    if (mounted && workoutData != null) {
      setState(() {
        _workoutName = workoutData['name'] ?? 'Treino';
        final exercisesJson =
            workoutData['workout_exercises'] as List<dynamic>? ?? [];
        _exercises = exercisesJson.map((item) {
          // Acessa o objeto 'exercises' que vem do join
          final Map<String, dynamic>? exerciseDetails = item['exercises'] as Map<String, dynamic>?;
          
          return {
            'name': exerciseDetails?['name'] ?? 'Nome Desconhecido',
            'details': '${item['sets'] ?? 3} séries x ${item['reps'] ?? 10} repetições',
            'isCompleted': false,
          };
        }).toList();

        _isLoading = false;
      });
    } else if (mounted) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Erro ao carregar treino.')));
    }
  }

  /// Finaliza o treino e salva no banco
  Future<void> _finishWorkout() async {
    if (_progressId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro: Treino não foi iniciado corretamente.')),
      );
      return;
    }

    try {
      // Para o cronômetro definitivamente
      _timer?.cancel();
      _timer = null;
      
      // Salva o progresso no banco
      await _progressService.completeWorkoutProgress(
        progressId: _progressId!,
        durationSeconds: _elapsedSeconds,
        notes: 'Treino concluído com ${(_overallProgress * 100).toInt()}% dos exercícios completados',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Treino concluído com sucesso!'),
            backgroundColor: primaryColor,
          ),
        );
        Navigator.of(context).pop(); // Volta para a Home
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao salvar progresso do treino.')),
        );
      }
    }
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
        title: Text(
          _workoutName,
          style: const TextStyle(color: textDark, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: textDark),
            onPressed: () {
              /* TODO: Opções do treino */
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 24,
                    ),
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
            child: Text(
              ':',
              style: TextStyle(
                color: textDark,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
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
            style: const TextStyle(
              color: textDark,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
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
              const Text(
                'Progresso Geral',
                style: TextStyle(color: textDark, fontSize: 16),
              ),
              Text(
                '${(_overallProgress * 100).toInt()}%',
                style: TextStyle(color: subtextDark),
              ),
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
              color: primaryColor.withValues(alpha: 100),
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                title: Text(
                  exercise['name'],
                  style: const TextStyle(
                    color: textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
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
            style: TextStyle(
              color: backgroundDark,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
