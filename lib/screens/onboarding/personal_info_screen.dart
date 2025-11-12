import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart'; // Importe para ícones do Material Symbols
import 'goal_selection_screen.dart';
import '../../models/user_onboarding_data.dart';

// Cores baseadas no code2.html:
const Color primaryColor = Color(0xFF46EC13); // Verde Neon
const Color backgroundDark = Color(0xFF000000); // Fundo Preto
const Color surfaceDark = Color(0xFF1C1C1E); // Input Background
const Color textDark = Color(0xFFFFFFFF); // Texto Principal
const Color subtleTextDark = Color(0xFFA3B99D); // Texto Subtil
const Color borderDark = Color(0xFF2E2E30); // Borda

class PersonalInfoScreen extends StatefulWidget {
  final UserOnboardingData onboardingData;
  
  const PersonalInfoScreen({super.key, required this.onboardingData});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  // Variáveis para simular o estado
  late final TextEditingController _pesoController;
  late final TextEditingController _alturaController;
  DateTime? _selectedDate;
  late String _generoSelecionado;

  @override
  void initState() {
    super.initState();
    // Inicializa os controllers com dados existentes ou padrão '0'
    _pesoController = TextEditingController(text: (widget.onboardingData.weight ?? 0).toString());
    _alturaController = TextEditingController(text: (widget.onboardingData.height ?? 0).toString());
    _selectedDate = widget.onboardingData.dateOfBirth;
    _generoSelecionado = widget.onboardingData.gender ?? 'Feminino';
  }

  @override
  void dispose() {
    _pesoController.dispose();
    _alturaController.dispose();
    super.dispose();
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
                    _buildInputs(),
                    const SizedBox(height: 24),
                    _buildGenderSelector(),
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
          'Sobre você',
          style: TextStyle(
            color: textDark,
            fontSize: 32,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Para criar um plano personalizado, precisamos de alguns detalhes.',
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
        // Passo 2 (Pendente, cor de Fundo Surface)
        Expanded(
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: surfaceDark,
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

  Widget _buildInputs() {
    return Column(
      children: [
        // Peso e Altura
        Row(
          children: [
            Expanded(child: _buildInputCard('Peso', 'kg', _pesoController)),
            const SizedBox(width: 16),
            Expanded(child: _buildInputCard('Altura', 'cm', _alturaController)),
          ],
        ),
        const SizedBox(height: 16),
        // Data de Nascimento
        _buildDateInput(),
      ],
    );
  }

  Widget _buildInputCard(String label, String suffix, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            label,
            style: const TextStyle(
              color: textDark,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: surfaceDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderDark, width: 1),
          ),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: textDark, fontSize: 16),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: '0',
                      hintStyle: TextStyle(color: subtleTextDark.withOpacity(0.5)),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Text(
                  suffix,
                  style: const TextStyle(color: subtleTextDark),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Função para abrir o DatePicker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900), // Limite inferior razoável
      lastDate: DateTime.now(),  // Não permite datas futuras
      builder: (context, child) {
        return Theme(
          // Aplica o tema escuro ao Date Picker para combinar com o app
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: primaryColor, // Cor principal (verde)
              onPrimary: backgroundDark,
              surface: surfaceDark,
              onSurface: textDark,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: primaryColor),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Widget _buildDateInput() {
    // Formata a data para exibição (DD / MM / AAAA)
    final String dateDisplay = _selectedDate != null
        ? '${_selectedDate!.day.toString().padLeft(2, '0')} / ${_selectedDate!.month.toString().padLeft(2, '0')} / ${_selectedDate!.year}'
        : 'DD / MM / AAAA';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 8.0),
          child: Text(
            'Data de Nascimento',
            style: TextStyle(
              color: textDark,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        GestureDetector(
          onTap: () => _selectDate(context), // <--- CHAMADA AGORA ESTÁ INTERATIVA
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: surfaceDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderDark, width: 1),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    dateDisplay,
                    style: TextStyle(
                      color: _selectedDate != null ? textDark : subtleTextDark,
                      fontSize: 16,
                    ),
                  ),
                ),
                const Icon(
                  Symbols.calendar_today,
                  color: subtleTextDark,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 8.0),
          child: Text(
            'Gênero',
            style: TextStyle(
              color: textDark,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildGenderButton('Masculino'),
            const SizedBox(width: 8),
            _buildGenderButton('Feminino'),
            const SizedBox(width: 8),
            _buildGenderButton('Não informar'),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderButton(String label) {
    bool isSelected = _generoSelecionado == label;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _generoSelecionado = label;
          });
        },
        child: Container(
          height: 56,
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
    final double? weight = double.tryParse(_pesoController.text);
    final double? height = double.tryParse(_alturaController.text);

    if (weight == null || height == null || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, preencha Peso, Altura e Data de Nascimento.'),
          backgroundColor: Color(0xFFE53935), // Cor de erro (vermelho)
        ),
      );
      return;
    }

    // 1. Atualiza o DTO com os dados coletados
    widget.onboardingData.weight = weight;
    widget.onboardingData.height = height;
    widget.onboardingData.dateOfBirth = _selectedDate;
    widget.onboardingData.gender = _generoSelecionado;

    // 2. Navega para a próxima tela, passando o DTO atualizado
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GoalSelectionScreen(
          onboardingData: widget.onboardingData, // Passa o DTO
        ),
      ),
    );
  }
}