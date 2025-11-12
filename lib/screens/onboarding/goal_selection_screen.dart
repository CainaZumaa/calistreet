import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'equipment_selection_screen.dart';
import '../../models/user_onboarding_data.dart';

// REUTILIZAÇÃO DAS CORES DO personal_info_screen.dart
const Color primaryColor = Color(0xFF46EC13); // Verde Neon
const Color backgroundDark = Color(0xFF000000); // Fundo Preto (texto no botão)
const Color surfaceDark = Color(0xFF1C1C1E); // Input Background
const Color textDark = Color(0xFFFFFFFF); // Texto Principal
const Color subtleTextDark = Color(0xFFA3B99D); // Texto Subtil
const Color borderDark = Color(0xFF2E2E30); // Borda

class GoalSelectionScreen extends StatefulWidget {
  final UserOnboardingData onboardingData;

  const GoalSelectionScreen({super.key, required this.onboardingData});

  @override
  State<GoalSelectionScreen> createState() => _GoalSelectionScreenState();
}

class _GoalSelectionScreenState extends State<GoalSelectionScreen> {
  final List<String> _goals = [
    'Ganhar massa muscular', 
    'Perder peso', 
    'Melhorar resistência'
  ];
  final List<String> _levels = [
    'Iniciante',
    'Intermediário',
    'Avançado',
  ];

  String? _selectedGoal;
  String _selectedLevel = 'Intermediário';

  @override
  void initState() {
    super.initState();
    // Define o valor inicial do dropdown
    _selectedGoal = _goals.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            // Header (Ícone de Voltar)
            _buildHeader(),
            
            // Conteúdo Principal
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitle(),
                    const SizedBox(height: 16),
                    _buildProgressBar(),
                    const SizedBox(height: 24),
                    _buildGoalDropdown(),
                    const SizedBox(height: 32),
                    _buildLevelSelector(),
                  ],
                ),
              ),
            ),

            // Botão Avançar
            _buildNextButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 24, top: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: textDark, size: 20),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Qual seu objetivo?',
          style: TextStyle(
            color: textDark,
            fontSize: 32,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Isso nos ajudará a criar um plano de treino personalizado para você.',
          style: TextStyle(
            color: subtleTextDark,
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    return Row(
      children: [
        // Passo 1 (Completo, cor Primária)
        Expanded(
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Passo 2 (Completo, cor Primária)
        Expanded(
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Passo 3 (Pendente, cor de Fundo Surface)
        Expanded(
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: surfaceDark,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGoalDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 8.0),
          child: Text(
            'Seu principal objetivo',
            style: TextStyle(
              color: textDark,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: surfaceDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderDark, width: 1),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedGoal,
              isExpanded: true,
              dropdownColor: surfaceDark,
              style: const TextStyle(color: textDark, fontSize: 16),
              icon: const Icon(Icons.expand_more, color: subtleTextDark),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedGoal = newValue;
                });
              },
              items: _goals.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLevelSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 8.0),
          child: Text(
            'Seu nível de treino',
            style: TextStyle(
              color: textDark,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Column(
          children: _levels.map((level) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: _buildLevelButton(level),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLevelButton(String label) {
    bool isSelected = _selectedLevel == label;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLevel = label;
        });
      },
      child: Container(
        height: 56,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : surfaceDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? primaryColor : borderDark,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? backgroundDark : textDark, // Texto preto no botão selecionado
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SizedBox(
        height: 56,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _handleNext,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                'Avançar',
                style: TextStyle(
                  color: backgroundDark,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward, color: backgroundDark, size: 24),
            ],
          ),
        ),
      ),
    );
  }
  void _handleNext() {
    // 1. Atualiza o DTO com os dados coletados
    widget.onboardingData.goal = _selectedGoal;
    widget.onboardingData.level = _selectedLevel;

    // 2. Navega para a última tela, passando o DTO atualizado
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EquipmentSelectionScreen(
          onboardingData: widget.onboardingData, // Passa o DTO
        ),
      ),
    );
  }
}