import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/auth_service.dart';
import 'create_workout_screen.dart';
import 'profile_screen.dart';
import 'progress_screen.dart';
import 'workout_in_progress_screen.dart';
import 'my_workouts_screen.dart';
import 'package:intl/intl.dart';
import '../services/workout_service.dart';
import '../utils/logger.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String _welcomeMessage = 'Olá, Usuário!';
  Map<String, dynamic>? _userProfile;
  Map<String, dynamic>? _todaysWorkout;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadTodaysWorkout();
  }

  void _loadUserData() async {
    final userData = AuthService.currentUser;
    if (userData != null) {
      final userId = userData['user_id'] as String;

      // 1. Buscar dados do perfil
      final profile = await AuthService.fetchUserProfile(userId);

      setState(() {
        _isLoading = false;
        _userProfile = profile;

        // 2. Mensagem de boas-vindas com o Nome
        if (profile != null && profile.containsKey('name')) {
          _welcomeMessage = 'Olá, ${profile['name'].toString().split(' ')[0]}!';
        }
      });
    } else {
      setState(() {
        _isLoading = false;
        _welcomeMessage = 'Olá, Usuário!';
      });
    }
  }

  // Determina o treino do dia
  void _loadTodaysWorkout() async {
    final userId = AuthService.currentUser?['user_id'];
    if (userId == null) return;

    // 1. Obtém o dia atual em formato de 3 letras (ex: 'seg', 'ter', 'sáb')
    // É CRUCIAL USAR 'pt_BR' para corresponder aos dados salvos no banco.
    final currentDayName = DateFormat('EEE', 'pt_BR').format(DateTime.now());
    final String dayAbbr = currentDayName.substring(
      0,
      3,
    ); // Obtém as 3 primeiras letras

    // 2. Formata para o padrão (Ex: 'Seg', 'Ter')
    final String finalDayFilter =
        dayAbbr.substring(0, 1).toUpperCase() + dayAbbr.substring(1);

    Logger.debug(
      'HomeScreen',
      'Buscando treinos do dia',
      extra: {'user_id': userId, 'day': finalDayFilter},
    );

    final WorkoutService service = WorkoutService();

    // Busca o treino agendado para o dia de hoje
    // A função retorna List<Map<...>>
    final List<Map<String, dynamic>> workouts = await service
        .fetchUserWorkoutsByDay(userId as String, finalDayFilter);

    setState(() {
      // Atribui o primeiro treino encontrado à variável de estado, ou null se a lista estiver vazia.
      _todaysWorkout = workouts.isNotEmpty ? workouts.first : null;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Resetar para Home quando volta de outra tela
    if (ModalRoute.of(context)?.isCurrent == true) {
      setState(() {
        _selectedIndex = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        backgroundColor: const Color(0xFF000000),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {},
        ),
        title: Text(
          _welcomeMessage,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF007AFF)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTodayWorkoutCard(),
                  const SizedBox(height: 16),
                  _buildCustomWorkoutCard(),
                  const SizedBox(height: 16),
                  _buildMyWorkoutsCard(),
                ],
              ),
            ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildTodayWorkoutCard() {
    if (_todaysWorkout == null) {
      return const SizedBox.shrink(); // Não mostra card se não houver treino agendado
    }

    final String workoutName = _todaysWorkout!['name'] ?? 'Treino Agendado';
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF1E1E1E),
      ),
      child: Stack(
        children: [
          // Imagem/Ilustração (Placeholder Simples)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Container(
                height: 100,
                color: Colors.blueGrey.shade900,
                child: const Center(
                  child: Icon(
                    Icons.directions_run,
                    color: Colors.white54,
                    size: 48,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF1A1A1A),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workoutName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Agendado para hoje. Mantenha o foco!',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Duração: Estimada',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Navega para a tela de treino em andamento
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  const WorkoutInProgressScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF007AFF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Começar',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyWorkoutsCard() {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const MyWorkoutsScreen()),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Meus Treinos',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Visualize, edite e organize suas rotinas.',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                color: Color(0xFF007AFF),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.list_alt, color: Colors.white, size: 24),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomWorkoutCard() {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const CreateWorkoutScreen()),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Monte seu Treino',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Crie um plano personalizado.',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                color: Color(0xFF007AFF),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 24),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        border: Border(top: BorderSide(color: Color(0xFF2C2C2C), width: 1)),
      ),
      child: BottomNavigationBar(
        backgroundColor: const Color(0xFF000000),
        selectedItemColor: const Color(0xFF007AFF),
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
        // Já está na tela home - não fazer nada
        break;
      case 1:
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => const ProgressScreen()));
        break;
      case 2:
        // TODO: Navegar para Desafios
        break;
      case 3:
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => const ProfileScreen()));
        break;
    }
  }

  void _handleLogout() async {
    try {
      AuthService.clearCurrentUser();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao fazer logout: $e'),
          backgroundColor: const Color(0xFF2C2C2C),
        ),
      );
    }
  }
}
