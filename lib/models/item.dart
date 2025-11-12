import 'dart:convert';
import 'item_rarity.dart';
import 'buff_type.dart';
import 'buff_duration.dart';

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
  String? categoria; // Categoria customizada (ex: "Armadura Pesada", "Espada", etc)

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

  // Campos específicos para EQUIPAMENTO (Armadura)
  int? defesaBonus; // Bônus de defesa para armaduras

  // Novos campos - Sistema de Raridade e Buffs
  ItemRarity raridade;
  BuffType? buffTipo;
  String? buffDescricao;
  BuffDuration? buffDuracao;
  int? buffTurnos; // Quantidade de turnos (se buffDuracao == turnos)
  int? buffValor; // Magnitude do buff (ex: +2 defesa, +5 velocidade)

  // Metadata
  DateTime criadoEm;
  DateTime atualizadoEm;

  Item({
    required this.id,
    required this.characterId,
    required this.nome,
    required this.descricao,
    required this.tipo,
    this.categoria,
    this.quantidade = 1,
    this.espaco = 1,
    this.formulaDano,
    this.multiplicadorCritico,
    this.efeitoCritico,
    this.isAmaldicoado = false,
    this.efeitoMaldicao,
    this.formulaCura,
    this.efeitoAdicional,
    this.defesaBonus,
    this.raridade = ItemRarity.comum,
    this.buffTipo,
    this.buffDescricao,
    this.buffDuracao,
    this.buffTurnos,
    this.buffValor,
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
      'categoria': categoria,
      'quantidade': quantidade,
      'espaco': espaco,
      'formulaDano': formulaDano,
      'multiplicadorCritico': multiplicadorCritico,
      'efeitoCritico': efeitoCritico,
      'isAmaldicoado': isAmaldicoado,
      'efeitoMaldicao': efeitoMaldicao,
      'formulaCura': formulaCura,
      'efeitoAdicional': efeitoAdicional,
      'defesaBonus': defesaBonus,
      'raridade': raridade.name,
      'buffTipo': buffTipo?.name,
      'buffDescricao': buffDescricao,
      'buffDuracao': buffDuracao?.name,
      'buffTurnos': buffTurnos,
      'buffValor': buffValor,
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
      categoria: json['categoria'] as String?,
      quantidade: json['quantidade'] as int? ?? 1,
      espaco: json['espaco'] as int? ?? 1,
      formulaDano: json['formulaDano'] as String?,
      multiplicadorCritico: json['multiplicadorCritico'] as int?,
      efeitoCritico: json['efeitoCritico'] as String?,
      isAmaldicoado: json['isAmaldicoado'] as bool? ?? false,
      efeitoMaldicao: json['efeitoMaldicao'] as String?,
      formulaCura: json['formulaCura'] as String?,
      efeitoAdicional: json['efeitoAdicional'] as String?,
      defesaBonus: json['defesaBonus'] as int?,
      raridade: json['raridade'] != null
          ? ItemRarity.fromString(json['raridade'] as String)
          : ItemRarity.comum,
      buffTipo: json['buffTipo'] != null
          ? BuffType.fromString(json['buffTipo'] as String)
          : null,
      buffDescricao: json['buffDescricao'] as String?,
      buffDuracao: json['buffDuracao'] != null
          ? BuffDuration.fromString(json['buffDuracao'] as String)
          : null,
      buffTurnos: json['buffTurnos'] as int?,
      buffValor: json['buffValor'] as int?,
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
    String? categoria,
    int? quantidade,
    int? espaco,
    String? formulaDano,
    int? multiplicadorCritico,
    String? efeitoCritico,
    bool? isAmaldicoado,
    String? efeitoMaldicao,
    String? formulaCura,
    String? efeitoAdicional,
    int? defesaBonus,
    ItemRarity? raridade,
    BuffType? buffTipo,
    String? buffDescricao,
    BuffDuration? buffDuracao,
    int? buffTurnos,
    int? buffValor,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
  }) {
    return Item(
      id: id ?? this.id,
      characterId: characterId ?? this.characterId,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      tipo: tipo ?? this.tipo,
      categoria: categoria ?? this.categoria,
      quantidade: quantidade ?? this.quantidade,
      espaco: espaco ?? this.espaco,
      formulaDano: formulaDano ?? this.formulaDano,
      multiplicadorCritico: multiplicadorCritico ?? this.multiplicadorCritico,
      efeitoCritico: efeitoCritico ?? this.efeitoCritico,
      isAmaldicoado: isAmaldicoado ?? this.isAmaldicoado,
      efeitoMaldicao: efeitoMaldicao ?? this.efeitoMaldicao,
      formulaCura: formulaCura ?? this.formulaCura,
      efeitoAdicional: efeitoAdicional ?? this.efeitoAdicional,
      defesaBonus: defesaBonus ?? this.defesaBonus,
      raridade: raridade ?? this.raridade,
      buffTipo: buffTipo ?? this.buffTipo,
      buffDescricao: buffDescricao ?? this.buffDescricao,
      buffDuracao: buffDuracao ?? this.buffDuracao,
      buffTurnos: buffTurnos ?? this.buffTurnos,
      buffValor: buffValor ?? this.buffValor,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? DateTime.now(),
    );
  }
}
