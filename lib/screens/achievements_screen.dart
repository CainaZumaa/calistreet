import 'package:flutter/material.dart';
import 'package:calistreet/models/achievement.dart';
import 'package:calistreet/services/auth_service.dart';
import 'package:calistreet/services/progress_service.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  final ProgressService _progressService = ProgressService();
  List<Achievement> _achievements = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    final user = AuthService.currentUser;

    if (user == null || user['user_id'] == null) {
      debugPrint("Nenhum usuário encontrado no AuthService.currentUser");
      setState(() => _loading = false);
      return;
    }

    final userId = user['user_id'];

    try {
      // Busca todas as conquistas do usuário (com progresso atual)
      final list = await _progressService.getUserAchievements(userId);

      // Atualiza o estado da tela
      setState(() {
        _achievements = list;
        _loading = false;
      });

      // Verifica se alguma conquista atingiu o objetivo e precisa ser desbloqueada
      await _unlockAchievements(userId);
    } catch (e) {
      debugPrint('Erro ao carregar conquistas: $e');
      setState(() => _loading = false);
    }
  }

  Future<void> _unlockAchievements(String userId) async {
    // Atualiza as conquistas no banco
    await _progressService.checkAchievements(userId);

    // Recarrega do banco as conquistas com isUnlocked atualizado
    final updatedList = await _progressService.getUserAchievements(userId);

    setState(() {
      _achievements = updatedList;
    });
  }

  IconData _mapIcon(String iconName) {
    switch (iconName) {
      case "pushup":
        return Icons.fitness_center;
      case "run":
        return Icons.directions_run;
      case "abs":
        return Icons.accessibility_new;
      case "trophy":
        return Icons.emoji_events;
      default:
        return Icons.emoji_events;
    }
  }

  double _calculateProgress(Achievement a) {
    if (a.isUnlocked) return 1.0;

    final int? target = a.targetValue ?? a.thresholdCount;
    if (target == null || target == 0) return 0.0;

    final int current = a.currentValue ?? 0;
    double progress = current / target;
    return progress.clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Conquistas"),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.amber))
          : _achievements.isEmpty
              ? const Center(
                  child: Text(
                    "Nenhuma conquista encontrada.",
                    style: TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _achievements.length,
                  itemBuilder: (context, index) {
                    final a = _achievements[index];

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: a.isUnlocked
                            ? Colors.green.withOpacity(0.18)
                            : Colors.grey.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: a.isUnlocked
                              ? Colors.greenAccent.withOpacity(0.6)
                              : Colors.white12,
                          width: 1.2,
                        ),
                      ),
                      child: ListTile(
                        leading: Icon(
                          _mapIcon(a.iconName),
                          color: a.isUnlocked ? Colors.amber : Colors.grey,
                          size: 40,
                        ),
                        title: Text(
                          a.name,
                          style: TextStyle(
                            color: a.isUnlocked ? Colors.white : Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              a.description,
                              style: TextStyle(
                                color:
                                    a.isUnlocked ? Colors.white70 : Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                            if (!a.isUnlocked)
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 8, right: 12),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: LinearProgressIndicator(
                                    value: _calculateProgress(a),
                                    backgroundColor: Colors.white12,
                                    minHeight: 6,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        trailing: a.isUnlocked
                            ? const Icon(Icons.check_circle,
                                color: Colors.greenAccent, size: 32)
                            : const Icon(Icons.lock,
                                color: Colors.grey, size: 28),
                      ),
                    );
                  },
                ),
    );
  }
}
