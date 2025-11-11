import 'dart:convert';

/// Elementos do Outro Lado (Ordem Paranormal)
enum ElementoOutroLado {
  conhecimento,
  energia,
  morte,
  sangue,
  medo,
}

/// Model de Poder/Ritual
///
/// Representa poderes paranormais e rituais do sistema Ordem Paranormal
class Power {
  final String id;
  final String characterId;

  String nome;
  String descricao;
  ElementoOutroLado elemento;

  int custoPE; // Custo em Pontos de Esforço
  int nivelMinimo; // NEX mínimo para usar

  // Detalhes do poder
  String? efeitos;
  String? duracao;
  String? alcance;
  int? circulo; // Para rituais (1º, 2º, 3º, 4º círculo)

  // Metadata
  DateTime criadoEm;
  DateTime atualizadoEm;

  Power({
    required this.id,
    required this.characterId,
    required this.nome,
    required this.descricao,
    required this.elemento,
    required this.custoPE,
    this.nivelMinimo = 5,
    this.efeitos,
    this.duracao,
    this.alcance,
    this.circulo,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
  })  : criadoEm = criadoEm ?? DateTime.now(),
        atualizadoEm = atualizadoEm ?? DateTime.now();

  // Getter para verificar se é ritual
  bool get isRitual => circulo != null;

  // Serialização JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'characterId': characterId,
      'nome': nome,
      'descricao': descricao,
      'elemento': elemento.name,
      'custoPE': custoPE,
      'nivelMinimo': nivelMinimo,
      'efeitos': efeitos,
      'duracao': duracao,
      'alcance': alcance,
      'circulo': circulo,
      'criadoEm': criadoEm.toIso8601String(),
      'atualizadoEm': atualizadoEm.toIso8601String(),
    };
  }

  factory Power.fromJson(Map<String, dynamic> json) {
    return Power(
      id: json['id'] as String,
      characterId: json['characterId'] as String,
      nome: json['nome'] as String,
      descricao: json['descricao'] as String,
      elemento: ElementoOutroLado.values.firstWhere(
        (e) => e.name == json['elemento'],
        orElse: () => ElementoOutroLado.conhecimento,
      ),
      custoPE: json['custoPE'] as int,
      nivelMinimo: json['nivelMinimo'] as int? ?? 5,
      efeitos: json['efeitos'] as String?,
      duracao: json['duracao'] as String?,
      alcance: json['alcance'] as String?,
      circulo: json['circulo'] as int?,
      criadoEm: DateTime.parse(json['criadoEm'] as String),
      atualizadoEm: DateTime.parse(json['atualizadoEm'] as String),
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory Power.fromJsonString(String jsonString) {
    return Power.fromJson(jsonDecode(jsonString));
  }

  // Copiar com modificações
  Power copyWith({
    String? id,
    String? characterId,
    String? nome,
    String? descricao,
    ElementoOutroLado? elemento,
    int? custoPE,
    int? nivelMinimo,
    String? efeitos,
    String? duracao,
    String? alcance,
    int? circulo,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
  }) {
    return Power(
      id: id ?? this.id,
      characterId: characterId ?? this.characterId,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      elemento: elemento ?? this.elemento,
      custoPE: custoPE ?? this.custoPE,
      nivelMinimo: nivelMinimo ?? this.nivelMinimo,
      efeitos: efeitos ?? this.efeitos,
      duracao: duracao ?? this.duracao,
      alcance: alcance ?? this.alcance,
      circulo: circulo ?? this.circulo,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? DateTime.now(),
    );
  }
}
