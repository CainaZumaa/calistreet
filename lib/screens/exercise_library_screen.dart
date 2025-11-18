import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../services/exercise_service.dart';
import '../../models/exercise.dart';

// Cores baseadas no padrão:
const Color primaryColor = Color(0xFF007AFF); // Azul - Primária para acentuação
const Color backgroundDark = Color(
  0xFF000000,
); // Fundo Escuro do design (quase preto)
const Color surfaceDark = Color(0xFF1C1C1E); // Fundo dos filtros/busca
const Color cardDark = Color(0xFF1A1A1A); // Fundo dos cards na lista
const Color textDark = Color(0xFFFFFFFF);
const Color subtextDark = Color(0xFFA3B99D); // Subtexto do design Progresso
const Color borderDark = Color(0xFF404040); // Borda

class ExerciseLibraryScreen extends StatefulWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  State<ExerciseLibraryScreen> createState() => _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends State<ExerciseLibraryScreen> {
  String _selectedGroup = 'Superior';
  String _selectedSubGroup = 'Ombro';
  String _searchQuery = '';

  List<Exercise> _allExercises = [];
  bool _isLoading = true;

  final List<String> _groupFilters = ['Superior', 'Core', 'Inferior'];
  final Map<String, List<String>> _subGroupFilters = {
    'Superior': ['Ombro', 'Peito', 'Costas', 'Biceps', 'Tríceps'],
    'Core': ['Abdomen', 'Lombar'],
    'Inferior': ['Quadriceps', 'Panturrilha', 'Posterior'],
  };

  @override
  void initState() {
    super.initState();
    _fetchExercises();
  }

  void _fetchExercises() async {
    setState(() {
      _isLoading = true;
    });

    final ExerciseService service = ExerciseService();
    final List<Exercise> exercises = await service.fetchAllExercises();

    setState(() {
      _allExercises = exercises;
      _isLoading = false;

      // Se houver dados, garante que o filtro inicial seja válido
      if (exercises.isNotEmpty &&
          _subGroupFilters[_selectedGroup]?.isEmpty == true) {
        // Atualiza os subgrupos disponíveis com base nos dados reais, se necessário.
        // Por enquanto, mantemos a estrutura de filtro anterior para UI.
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Lógica de filtragem
    final filteredExercises = _allExercises.where((ex) {
      bool matchesGroup = ex.muscleGroup == _selectedGroup;
      bool matchesSubGroup = ex.subgroup == _selectedSubGroup;
      bool matchesSearch = ex.name.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );

      return matchesGroup && matchesSubGroup && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: backgroundDark,
      body: Column(
        children: [
          // Header e Barra de Busca
          _buildHeaderAndSearch(),

          // Botões Segmentados (Superior/Core/Inferior)
          _buildGroupFilters(),

          // Chips (Ombros/Peito/Costas, etc.)
          _buildSubGroupChips(),

          // Lista de Exercícios
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: primaryColor),
                  )
                : ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    children: filteredExercises.map((exercise) {
                      return _buildExerciseListItem(exercise.toMapForDisplay());
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS DE CONSTRUÇÃO ---

  Widget _buildHeaderAndSearch() {
    return Container(
      color: backgroundDark,
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Column(
        children: [
          // App Bar (Título e Voltar)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: textDark,
                    size: 24,
                  ),
                  onPressed: () => Navigator.of(
                    context,
                  ).pop(), // Volta para CreateWorkoutScreen
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'Exercícios',
                      style: const TextStyle(
                        color: textDark,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 48), // Espaço para centralizar
              ],
            ),
          ),

          // Barra de Busca
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              style: const TextStyle(color: textDark),
              decoration: InputDecoration(
                hintText: 'Procurar exercícios',
                hintStyle: TextStyle(color: subtextDark),
                prefixIcon: Icon(Icons.search, color: subtextDark),
                filled: true,
                fillColor: surfaceDark, // Fundo escuro do design
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: backgroundDark,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: surfaceDark, // Fundo escuro do design
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: _groupFilters.map((group) {
            bool isSelected = _selectedGroup == group;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedGroup = group;
                      _selectedSubGroup =
                          _subGroupFilters[group]!.first; // Reset subgrupo
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? primaryColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        group,
                        style: TextStyle(
                          color: isSelected ? textDark : subtextDark,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSubGroupChips() {
    final List<String> currentSubGroups =
        _subGroupFilters[_selectedGroup] ?? [];

    return Container(
      color: backgroundDark,
      height: 60,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: currentSubGroups.map((subGroup) {
          bool isSelected = _selectedSubGroup == subGroup;

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedSubGroup = subGroup;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: isSelected ? primaryColor.withAlpha(50) : surfaceDark,
                  borderRadius: BorderRadius.circular(25),
                  border: isSelected
                      ? Border.all(color: primaryColor, width: 2)
                      : null,
                ),
                child: Center(
                  child: Text(
                    subGroup,
                    style: TextStyle(
                      color: isSelected ? primaryColor : textDark,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildExerciseListItem(Map<String, dynamic> exercise) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderDark, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // Imagem (Placeholder)
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage(exercise['image']),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Nome e Nível
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise['name'],
                    style: const TextStyle(
                      color: textDark,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              exercise['level_color'] as Color, // Cor do nível
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        exercise['level'],
                        style: TextStyle(color: subtextDark, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // Botão Favorito/Adicionar
          IconButton(
            icon: const Icon(Icons.star_border, color: textDark),
            onPressed: () {
              // TODO: Implementar lógica de Favorito ou Adicionar ao Treino
              Navigator.of(
                context,
              ).pop(exercise); // Retorna o exercício selecionado
            },
          ),
        ],
      ),
    );
  }
}
