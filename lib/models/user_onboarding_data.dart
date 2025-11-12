class UserOnboardingData {
  // Passo 1: Informações Pessoais
  String? name;
  double? weight; // Peso
  double? height; // Altura
  DateTime? dateOfBirth; // Data de Nascimento
  String? gender; // Gênero
  
  // Passo 2: Objetivos
  String? goal; // Objetivo principal
  String? level; // Nível de treino
  
  // Passo 3: Equipamentos
  String? trainingLocation; // Local de treino (Em casa/Academia)
  List<String> equipment = []; // Lista de equipamentos selecionados

  UserOnboardingData({
    this.name,
    this.weight,
    this.height,
    this.dateOfBirth,
    this.gender,
    this.goal,
    this.level,
    this.trainingLocation,
    this.equipment = const [],
  });

  // Método auxiliar para converter dados para o formato JSON para o Supabase
  Map<String, dynamic> toJson(String userId) {
    return {
      'user_id': userId,
      'name': name,
      'weight': weight,
      'height': height,
      'date_of_birth': dateOfBirth?.toIso8601String().split('T').first,
      'gender': gender,
      'goal': goal,
      'level': level,
      'training_location': trainingLocation,
      'equipment': equipment,
      'onboarding_complete': true,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }
}