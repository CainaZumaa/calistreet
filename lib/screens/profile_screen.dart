import 'package:calistreet/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/achievement.dart';
import '../services/auth_service.dart';
import '../services/progress_service.dart';
import 'progress_screen.dart';
import 'package:calistreet/screens/achievements_screen.dart';


// Definindo cores comuns para consistência
const Color backgroundDark = Color(0xFF000000);
const Color primaryBlue = Color(0xFF007AFF);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

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

class _ProfileScreenState extends State<ProfileScreen> {
  final int _selectedIndex = 3;
  Map<String, dynamic>? _userProfile;
  bool _isLoading = true;
  int _completedWorkoutsCount = 0;
  String _totalDurationFormatted = '0h 0m';
  List<Achievement> _achievements = [];

  @override
  void initState() {
    super.initState();
    _loadProfileData();
    _loadWorkoutStats();
    _loadAchievements();
  }

  void _loadProfileData() async {
    final userData = AuthService.currentUser;
    if (userData != null) {
      final userId = userData['user_id'] as String;

      final profile = await AuthService.fetchUserProfile(userId);

      setState(() {
        _isLoading = false;
        _userProfile = profile;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _loadWorkoutStats() async {
    final userId = AuthService.currentUser?['user_id'];
    if (userId == null) {
        setState(() { _isLoading = false; });
        return;
    }
    
    final ProgressService progressService = ProgressService();
    final int count = await progressService.countCompletedWorkouts(userId as String);
    final int durationSeconds = await progressService.fetchTotalDuration(userId as String);

    setState(() {
      _completedWorkoutsCount = count;
      _totalDurationFormatted = formatSecondsToHoursMinutes(durationSeconds);
      _isLoading = false;
    });
  }

  // Função placeholder para alterar foto
  void _changeProfilePicture() {
    // TODO: Implementar lógica de seleção de imagem (image_picker) e upload para Supabase Storage
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidade de mudar foto em desenvolvimento.'),
        backgroundColor: primaryBlue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: backgroundDark,
        body: Center(child: CircularProgressIndicator(color: primaryBlue)),
      );
    }

    // Fallback: usar o nome do email se o perfil não for encontrado
    final String defaultEmail =
        AuthService.currentUser?['email'] ?? 'usuario@exemplo.com';
    final String defaultUserName = defaultEmail.split('@')[0];

    // Tenta usar o nome real da tabela user_profiles (ou nome do login como fallback)
    final String displayName =
        _userProfile?['name'] ??
        AuthService.currentUser?['name'] ??
        defaultUserName;
    final String displayUsername = defaultUserName
        .toLowerCase(); // Usar o nome do email como username

    return Scaffold(
      backgroundColor: backgroundDark,
      appBar: AppBar(
        backgroundColor: backgroundDark,
        title: const Text(
          'Perfil',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProfileHeader(displayName, displayUsername),
            const SizedBox(height: 24),
            _buildStatsSection(),
            const SizedBox(height: 24),
            _buildAchievementsSection(),
            const SizedBox(height: 24),
            _buildEditProfileButton(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildProfileHeader(String displayName, String username) {
    return Column(
      children: [
        GestureDetector(
          onTap: _changeProfilePicture,
          child: Stack(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [primaryBlue, Color(0xFF0051D5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(Icons.person, size: 60, color: Colors.white),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: primaryBlue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          displayName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '@$username',
          style: const TextStyle(color: Colors.grey, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Text(
          'Membro desde 2025',
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    final int calories = _userProfile?['calories_burned'] ?? 2500;

    return Row(
      children: [
        Expanded(child: _buildStatCard(_completedWorkoutsCount.toString(), 'Treinos')),        const SizedBox(width: 12),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard(calories.toString(), 'Calorias')),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard(_totalDurationFormatted, 'Tempo')),
      ],
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildAchievementsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Conquistas',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            IconButton(
              icon: const Icon(Icons.arrow_forward_ios, color: Colors.white70),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AchievementsScreen()),
                );
              },
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Caso não tenha conquistas
        if (_achievements.isEmpty)
          const Text(
            'Nenhuma conquista desbloqueada ainda.',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),

        // Mostra até 4 conquistas
        if (_achievements.isNotEmpty)
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _achievements.length.clamp(0, 4),
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final a = _achievements[index];

                return _buildAchievementBadge(
                  a.name,
                  _getAchievementIcon(a.iconName),
                  a.isUnlocked ? primaryBlue : Colors.grey,
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildAchievementBadge(String title, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 60,
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildEditProfileButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Editar Perfil',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      decoration: const BoxDecoration(
        color: backgroundDark,
        border: Border(top: BorderSide(color: Color(0xFF1A1A1A), width: 1)),
      ),
      child: BottomNavigationBar(
        backgroundColor: backgroundDark,
        selectedItemColor: primaryBlue,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index != _selectedIndex) {
            _navigateToScreen(index);
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: 'Progresso',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.trophy),
            label: 'Desafios',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }

  void _navigateToScreen(int index) {
    switch (index) {
      case 0:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
        break;
      case 1:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const ProgressScreen()),
        );
        break;
      case 2:
        // TODO: Navegar para Desafios
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tela de Desafios em desenvolvimento.'),
            backgroundColor: primaryBlue,
          ),
        );
        break;
      case 3:
        // Já está na tela de perfil
        break;
    }
  }

  void _loadAchievements() async {
    final userId = AuthService.currentUser?['user_id'];

    if (userId == null) return;

    final ProgressService progress = ProgressService();
    final list = await progress.getUserAchievements(userId);

    setState(() {
      _achievements = list;
    });
  }

  IconData _getAchievementIcon(String iconName) {
    switch (iconName) {
      case 'beginner': return Icons.eco;
      case 'intermediate': return Icons.person;
      case 'advanced': return Icons.fitness_center;
      case 'expert': return FontAwesomeIcons.trophy;
      default: return Icons.emoji_events;
    }
  }
}
