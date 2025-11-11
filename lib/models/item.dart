import 'dart:convert';

/// Tipos de itens no inventário
enum ItemType {
  arma,
  cura,
  municao,
  equipamento,
  consumivel,
}

/// Model de Item para inventário
///
/// Suporta:
/// - Armas com fórmula de dano (ex: "1d8+2") e crítico
/// - Itens de cura com fórmula (ex: "2d4+2")
/// - Municao, equipamentos e consumiveis
/// - Sistema de espaço (peso)
/// - Armas amaldicoadas
class Item {
  final String id;
  final String characterId; // Dono do item

  String nome;
  String descricao;
  ItemType tipo;

  int quantidade;
  int espaco; // Espaço unitário (peso)

  // Campos específicos para ARMA
  String? formulaDano; // ex: "1d8+2"
  int? multiplicadorCritico; // ex: 2 (x2)
  String? efeitoCritico; // Descrição do efeito crítico
  bool isAmaldicoado;
  String? efeitoMaldicao;

  // Campos específicos para CURA
  String? formulaCura; // ex: "2d4+2"
  String? efeitoAdicional; // Efeito extra da cura

  // Metadata
  DateTime criadoEm;
  DateTime atualizadoEm;

  Item({
    required this.id,
    required this.characterId,
    required this.nome,
    required this.descricao,
    required this.tipo,
    this.quantidade = 1,
    this.espaco = 1,
    this.formulaDano,
    this.multiplicadorCritico,
    this.efeitoCritico,
    this.isAmaldicoado = false,
    this.efeitoMaldicao,
    this.formulaCura,
    this.efeitoAdicional,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
  })  : criadoEm = criadoEm ?? DateTime.now(),
        atualizadoEm = atualizadoEm ?? DateTime.now();

  // Getter para espaço total
  int get espacoTotal => espaco * quantidade;

  // Validação de arma
  bool get isArma => tipo == ItemType.arma;
  bool get isCura => tipo == ItemType.cura;

  // Serialização JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'characterId': characterId,
      'nome': nome,
      'descricao': descricao,
      'tipo': tipo.name,
      'quantidade': quantidade,
      'espaco': espaco,
      'formulaDano': formulaDano,
      'multiplicadorCritico': multiplicadorCritico,
      'efeitoCritico': efeitoCritico,
      'isAmaldicoado': isAmaldicoado,
      'efeitoMaldicao': efeitoMaldicao,
      'formulaCura': formulaCura,
      'efeitoAdicional': efeitoAdicional,
      'criadoEm': criadoEm.toIso8601String(),
      'atualizadoEm': atualizadoEm.toIso8601String(),
    };
  }

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] as String,
      characterId: json['characterId'] as String,
      nome: json['nome'] as String,
      descricao: json['descricao'] as String,
      tipo: ItemType.values.firstWhere(
        (e) => e.name == json['tipo'],
        orElse: () => ItemType.equipamento,
      ),
      quantidade: json['quantidade'] as int? ?? 1,
      espaco: json['espaco'] as int? ?? 1,
      formulaDano: json['formulaDano'] as String?,
      multiplicadorCritico: json['multiplicadorCritico'] as int?,
      efeitoCritico: json['efeitoCritico'] as String?,
      isAmaldicoado: json['isAmaldicoado'] as bool? ?? false,
      efeitoMaldicao: json['efeitoMaldicao'] as String?,
      formulaCura: json['formulaCura'] as String?,
      efeitoAdicional: json['efeitoAdicional'] as String?,
      criadoEm: DateTime.parse(json['criadoEm'] as String),
      atualizadoEm: DateTime.parse(json['atualizadoEm'] as String),
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory Item.fromJsonString(String jsonString) {
    return Item.fromJson(jsonDecode(jsonString));
  }

  // Copiar com modificações
  Item copyWith({
    String? id,
    String? characterId,
    String? nome,
    String? descricao,
    ItemType? tipo,
    int? quantidade,
    int? espaco,
    String? formulaDano,
    int? multiplicadorCritico,
    String? efeitoCritico,
    bool? isAmaldicoado,
    String? efeitoMaldicao,
    String? formulaCura,
    String? efeitoAdicional,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
  }) {
    return Item(
      id: id ?? this.id,
      characterId: characterId ?? this.characterId,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      tipo: tipo ?? this.tipo,
      quantidade: quantidade ?? this.quantidade,
      espaco: espaco ?? this.espaco,
      formulaDano: formulaDano ?? this.formulaDano,
      multiplicadorCritico: multiplicadorCritico ?? this.multiplicadorCritico,
      efeitoCritico: efeitoCritico ?? this.efeitoCritico,
      isAmaldicoado: isAmaldicoado ?? this.isAmaldicoado,
      efeitoMaldicao: efeitoMaldicao ?? this.efeitoMaldicao,
      formulaCura: formulaCura ?? this.formulaCura,
      efeitoAdicional: efeitoAdicional ?? this.efeitoAdicional,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? DateTime.now(),
    );
  }
}
