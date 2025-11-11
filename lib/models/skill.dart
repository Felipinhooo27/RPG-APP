import 'dart:convert';

/// Níveis de treinamento de perícia (Ordem Paranormal)
enum SkillLevel {
  untrained, // Destreinado
  trained, // Treinado
  expert, // Veterano
  master, // Expert
}

/// Atributo associado à perícia
enum SkillAttribute {
  forca,
  agilidade,
  vigor,
  intelecto,
  presenca,
}

/// Categorias de perícias
enum SkillCategory {
  investigation, // Investigação
  combat, // Combate
  survival, // Sobrevivência
  social, // Social
  knowledge, // Conhecimento
}

/// Model de Perícia (Skill)
///
/// Cada perícia tem:
/// - Nome
/// - Atributo relacionado
/// - Nível de treinamento
/// - Categoria
/// - Bônus calculado (atributo + nível)
class Skill {
  final String id;
  final String characterId;

  String nome;
  SkillAttribute atributo;
  SkillLevel nivel;
  SkillCategory categoria;

  // Metadata
  DateTime criadoEm;
  DateTime atualizadoEm;

  Skill({
    required this.id,
    required this.characterId,
    required this.nome,
    required this.atributo,
    this.nivel = SkillLevel.untrained,
    required this.categoria,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
  })  : criadoEm = criadoEm ?? DateTime.now(),
        atualizadoEm = atualizadoEm ?? DateTime.now();

  // Bônus por nível
  int get nivelBonus {
    switch (nivel) {
      case SkillLevel.untrained:
        return 0;
      case SkillLevel.trained:
        return 5;
      case SkillLevel.expert:
        return 10;
      case SkillLevel.master:
        return 15;
    }
  }

  // Serialização JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'characterId': characterId,
      'nome': nome,
      'atributo': atributo.name,
      'nivel': nivel.name,
      'categoria': categoria.name,
      'criadoEm': criadoEm.toIso8601String(),
      'atualizadoEm': atualizadoEm.toIso8601String(),
    };
  }

  factory Skill.fromJson(Map<String, dynamic> json) {
    return Skill(
      id: json['id'] as String,
      characterId: json['characterId'] as String,
      nome: json['nome'] as String,
      atributo: SkillAttribute.values.firstWhere(
        (e) => e.name == json['atributo'],
        orElse: () => SkillAttribute.intelecto,
      ),
      nivel: SkillLevel.values.firstWhere(
        (e) => e.name == json['nivel'],
        orElse: () => SkillLevel.untrained,
      ),
      categoria: SkillCategory.values.firstWhere(
        (e) => e.name == json['categoria'],
        orElse: () => SkillCategory.knowledge,
      ),
      criadoEm: DateTime.parse(json['criadoEm'] as String),
      atualizadoEm: DateTime.parse(json['atualizadoEm'] as String),
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory Skill.fromJsonString(String jsonString) {
    return Skill.fromJson(jsonDecode(jsonString));
  }

  // Copiar com modificações
  Skill copyWith({
    String? id,
    String? characterId,
    String? nome,
    SkillAttribute? atributo,
    SkillLevel? nivel,
    SkillCategory? categoria,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
  }) {
    return Skill(
      id: id ?? this.id,
      characterId: characterId ?? this.characterId,
      nome: nome ?? this.nome,
      atributo: atributo ?? this.atributo,
      nivel: nivel ?? this.nivel,
      categoria: categoria ?? this.categoria,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? DateTime.now(),
    );
  }

  // Lista de perícias padrão de Ordem Paranormal
  static List<String> getPadrao() {
    return [
      'Acrobacia',
      'Adestramento',
      'Artes',
      'Atletismo',
      'Atualidades',
      'Ciências',
      'Crime',
      'Diplomacia',
      'Enganação',
      'Fortitude',
      'Furtividade',
      'Iniciativa',
      'Intimidação',
      'Intuição',
      'Investigação',
      'Luta',
      'Medicina',
      'Ocultismo',
      'Percepção',
      'Pilotagem',
      'Pontaria',
      'Profissão',
      'Reflexos',
      'Religião',
      'Sobrevivência',
      'Tática',
      'Tecnologia',
      'Vontade',
    ];
  }
}
