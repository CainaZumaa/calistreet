import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/auth_service.dart';
import 'progress_screen.dart';

// Definindo cores comuns para consistência 
const Color primaryGreen = Color(0xFF4CAF50);
const Color backgroundDark = Color(0xFF000000);
const Color primaryBlue = Color(0xFF007AFF);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedIndex = 3;
  Map<String, dynamic>? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
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
    final String defaultEmail = AuthService.currentUser?['email'] ?? 'usuario@exemplo.com';
    final String defaultUserName = defaultEmail.split('@')[0];
    
    // Tenta usar o nome real da tabela user_profiles (ou nome do login como fallback)
    final String displayName = _userProfile?['name'] ?? AuthService.currentUser?['name'] ?? defaultUserName;
    final String displayUsername = defaultUserName.toLowerCase(); // Usar o nome do email como username

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
                    colors: [primaryGreen, Color(0xFF2E7D32)],
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
                    color: primaryGreen,
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
          'Membro desde 2024',
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    final int workouts = _userProfile?['workouts_completed'] ?? 150;
    final int calories = _userProfile?['calories_burned'] ?? 2500;
    final String time = _userProfile?['total_time'] ?? '30h';
    
    return Row(
      children: [
        Expanded(child: _buildStatCard(workouts.toString(), 'Treinos')),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard(calories.toString(), 'Calorias')),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard(time, 'Tempo')),
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
          Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Conquistas',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 80,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildAchievementBadge(
                'Iniciante',
                Icons.eco,
                primaryGreen,
              ),
              const SizedBox(width: 16),
              _buildAchievementBadge(
                'Intermediário',
                Icons.person,
                Colors.grey,
              ),
              const SizedBox(width: 16),
              _buildAchievementBadge(
                'Avançado',
                Icons.fitness_center,
                Colors.grey,
              ),
              const SizedBox(width: 16),
              _buildAchievementBadge(
                'Expert',
                FontAwesomeIcons.trophy,
                Colors.grey,
              ),
            ],
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
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 12)),
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
          backgroundColor: primaryGreen,
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
          setState(() {
            _selectedIndex = index;
          });
          _navigateToScreen(index);
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
        // Volta para Home e reseta o índice
        Navigator.of(context).pop();
        break;
      case 1:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const ProgressScreen()),
        );
        break;
      case 2:
        // TODO: Navegar para Desafios
        break;
      case 3:
        // Já está na tela de perfil
        break;
    }
  }
}
