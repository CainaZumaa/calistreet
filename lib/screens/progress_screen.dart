import 'package:calistreet/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'profile_screen.dart';

// Cores no padrão do seu app
const Color primaryColor = Color(0xFF007AFF); // Azul - Primária para acentuação e gráfico (anteriormente Verde)
const Color secondaryColor = Color(0xFFFF6F00); // Laranja - Mantido para Conquistas
const Color backgroundDark = Color(0xFF000000); // Fundo Preto
const Color cardDark = Color(0xFF1A1A1A); // Fundo do Card (Preto mais claro para contraste)
const Color textDark = Color(0xFFFFFFFF);
const Color subtextDark = Color(0xFF888888); // Cinza para subtexto
const Color borderDark = Color(0xFF2C2C2C); // Borda

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final int _selectedIndex = 1;

  // Dados simulados para o resumo da semana
  final Map<String, double> _weeklyData = {
    'DOM': 40, 
    'SEG': 100, 
    'TER': 30,  
    'QUA': 80,
    'QUI': 40,
    'SEX': 80,
    'SAB': 90,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundDark,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: backgroundDark,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Seu Progresso',
          style: TextStyle(
            color: textDark,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildWeeklySummaryCard(),
            const SizedBox(height: 16),
            _buildActionButtons(),
            const SizedBox(height: 16),
            _buildLatestAchievements(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildWeeklySummaryCard() {
    final double maxBarHeight = _weeklyData.values.reduce((a, b) => a > b ? a : b);
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderDark, width: 1),
      ),
      child: Column(
        children: [
          const Text(
            'Resumo da Semana',
            style: TextStyle(
              color: textDark,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          
          // 1. Métricas Principais
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetric('12', 'Treinos', primaryColor),
              _buildMetric('10h 30m', 'Tempo Total', primaryColor),
              _buildMetric('5,280', 'Calorias', primaryColor),
            ],
          ),
          
          // 2. Gráfico de Barras
          const SizedBox(height: 24),
          SizedBox(
            height: 140,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _weeklyData.entries.map((entry) {
                // Normaliza a altura da barra em relação ao valor máximo
                final double normalizedHeight = entry.value / maxBarHeight;
                
                return _buildBar(
                  heightRatio: normalizedHeight,
                  label: entry.key,
                  isActive: entry.key == 'QUA',
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: subtextDark,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildBar({
    required double heightRatio,
    required String label,
    bool isActive = false,
  }) {
    // Define a cor da barra (ativa ou inativa)
    final barColor = isActive ? primaryColor : primaryColor.withOpacity(0.3);
    // Altura máxima do gráfico é 100% da altura do SizedBox pai
    final double barHeight = 100 * heightRatio; 

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 14, // Largura fixa para cada barra
          height: barHeight,
          decoration: BoxDecoration(
            color: barColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(3),
              topRight: Radius.circular(3),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: isActive ? textDark : subtextDark,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Botão Histórico de Treinos
        _buildActionButton(
          title: 'Histórico de Treinos',
          subtitle: 'Veja todos os seus treinos',
          icon: Icons.history,
          iconColor: primaryColor,
          onTap: () { /* TODO: Navegar para Histórico */ },
        ),
        const SizedBox(height: 16),
        // Botão Compartilhar Conquistas
        _buildActionButton(
          title: 'Compartilhar Conquistas',
          subtitle: 'Mostre seu progresso',
          icon: Icons.share,
          iconColor: secondaryColor,
          onTap: () { /* TODO: Implementar compartilhamento */ },
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderDark, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 24),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: textDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(color: subtextDark, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
            Icon(Icons.chevron_right, color: subtextDark),
          ],
        ),
      ),
    );
  }

  Widget _buildLatestAchievements() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 16.0, left: 4),
          child: Text(
            'Últimas Conquistas',
            style: TextStyle(
              color: textDark,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        GridView.count(
          crossAxisCount: 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 0.8, // Para acomodar o ícone e o texto
          children: [
            _buildAchievementCard('Primeiro Treino!', Icons.military_tech, secondaryColor),
            _buildAchievementCard('10 Horas de Treino', Icons.timer, secondaryColor),
            _buildAchievementCard('Mestre das Flexões', Icons.fitness_center, secondaryColor),
          ],
        ),
      ],
    );
  }

  Widget _buildAchievementCard(String title, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderDark, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 40),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: textDark,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: backgroundDark,
        border: Border(top: BorderSide(color: borderDark, width: 1)),
      ),
      child: BottomNavigationBar(
        backgroundColor: backgroundDark,
        selectedItemColor: primaryColor,
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
            icon: Icon(Icons.trending_up), // Ícone de Progresso
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
        // Já está na tela de progresso
        break;
      case 2:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tela de Desafios em desenvolvimento.'),
            backgroundColor: primaryColor,
          ),
        );
        break;
      case 3:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        );
        break;
    }
  }
}