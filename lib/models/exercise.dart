import 'package:flutter/material.dart';

String _toTitleCase(String text) {
  if (text.isEmpty) return text;
  // Converte de MAIÚSCULAS (DB) para a primeira letra maiúscula (UI)
  return text
      .toLowerCase()
      .split('_')
      .map((word) {
        if (word.isEmpty) return '';
        return word[0].toUpperCase() + word.substring(1);
      })
      .join(' ');
}

// Função auxiliar para mapear o nível de dificuldade para uma cor visual
Color _getLevelColor(String level) {
  switch (level.toLowerCase()) {
    case 'iniciante':
      return const Color(0xFF007AFF);
    case 'intermediário':
      return Colors.yellow.shade700;
    case 'avançado':
      return Colors.red;
    default:
      return Colors.grey;
  }
}

class Exercise {
  final String id;
  final String name;
  final String description;
  final String muscleGroup;
  final String subgroup;
  final String videoUrl;
  final String level;

  final Color levelColor;

  Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.muscleGroup,
    required this.subgroup,
    required this.videoUrl,
    required this.level,
  }) : levelColor = _getLevelColor(level);

  // Converte a linha do Supabase (JSON) para o objeto Dart
  factory Exercise.fromJson(Map<String, dynamic> json) {
    // Nota: Os nomes das chaves (keys) correspondem às colunas em inglês da DB.
    return Exercise(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Exercício Sem Nome',
      description: json['description'] as String? ?? 'Sem descrição.',
      muscleGroup: _toTitleCase(json['muscle_group'] as String? ?? 'Geral'),
      subgroup: _toTitleCase(json['subgroup'] as String? ?? 'Geral'),
      videoUrl:
          json['video_url'] as String? ?? 'https://via.placeholder.com/60',
      level: json['level'] as String? ?? 'Iniciante',
    );
  }

  // Mapeia o modelo para o formato que a UI de listagem espera
  Map<String, dynamic> toMapForDisplay() {
    return {
      'id': id,
      'name': name,
      'level': level,
      'group': muscleGroup,
      'subgroup': subgroup,
      'image': videoUrl,
      'level_color': levelColor,
    };
  }
}
