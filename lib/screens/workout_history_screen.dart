import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/progress_service.dart';
import '../../services/auth_service.dart';
// NOTE: Você precisará de um modelo 'Progress' com os campos da tabela 'progress'
// Ex: id, workout_id, start_date, end_date, duration_seconds, status

// Cores baseadas no padrão
const Color primaryColor = Color(0xFF007AFF);
const Color errorColor = Color(0xFFE53935); 
const Color backgroundDark = Color(0xFF000000); 
const Color cardDark = Color(0xFF1A1A1A); 
const Color textDark = Color(0xFFFFFFFF);
const Color subtextDark = Color(0xFF888888); 

class WorkoutHistoryScreen extends StatefulWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  State<WorkoutHistoryScreen> createState() => _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends State<WorkoutHistoryScreen> {
  List<Map<String, dynamic>> _history = []; 
  bool _isLoading = true;
  final ProgressService _progressService = ProgressService();

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final userId = AuthService.currentUser?['user_id'];
    
    if (userId == null) {
      setState(() { _isLoading = false; });
      return;
    }
    
    setState(() { _isLoading = true; });

    final List<Map<String, dynamic>> history = (await _progressService.getWorkoutHistory(userId as String))
    .where((session) => (session['status'] as String).toUpperCase() == 'COMPLETED')
    .toList();

    setState(() {
      _history = history; // Popula a lista com dados reais
      _isLoading = false;
    });
  }

  String getStatusText(String status) {
  switch (status.toUpperCase()) {
    case 'COMPLETED':
    case 'CONCLUIDO':
      return 'COMPLETED';
    case 'IN_PROGRESS':
    case 'EM_ANDAMENTO':
      return 'IN_PROGRESS';
    case 'SKIPPED':
    case 'CANCELADO':
      return 'SKIPPED';
    default:
      return status;
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundDark,
      appBar: AppBar(
        backgroundColor: backgroundDark,
        elevation: 0,
        title: const Text('Histórico de Treinos', style: TextStyle(color: textDark, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : _history.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _history.length,
                  itemBuilder: (context, index) {
                    return _buildHistoryCard(_history[index]);
                  },
                ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> session) {
    final String duration = formatSecondsToHoursMinutes(session['duration'] as int? ?? 0);
    final String date = DateFormat('dd/MM/yy').format(session['date'] as DateTime);
    final String status = getStatusText(session['status'] as String);
    Color statusColor = status == 'COMPLETED' ? primaryColor : errorColor;
    
    return Card(
      color: cardDark,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(
          status == 'COMPLETED' ? Icons.check_circle : Icons.cancel,
          color: statusColor,
        ),
        title: Text(
          session['workout_name'] as String,
          style: const TextStyle(color: textDark, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '$date | Duração: $duration',
          style: TextStyle(color: subtextDark),
        ),
        trailing: Text(
          status,
          style: TextStyle(color: statusColor, fontWeight: FontWeight.w600),
        ),
        onTap: () {
          // TODO: Implementar navegação para a tela de detalhes do histórico
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, color: subtextDark, size: 60),
          const SizedBox(height: 16),
          Text('Nenhuma sessão de treino encontrada.', style: TextStyle(color: textDark, fontSize: 18)),
          const SizedBox(height: 8),
          Text('Conclua seu primeiro treino para ver seu histórico!', style: TextStyle(color: subtextDark)),
        ],
      ),
    );
  }

  // NOTE: A função formatSecondsToHoursMinutes deve estar definida globalmente ou no utilitário.
  String formatSecondsToHoursMinutes(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m';
    } else {
      return '< 1m';
    }
  }
}