import 'dart:convert';
import 'item.dart';

/// Tipos de loja
enum ShopType {
  taberna, // Tudo
  armaria, // Armas e munição
  farmacia, // Poções e cura
  mercador, // Variados
  forjaria, // Equipamentos
}

/// Item de loja (diferente do Item de inventário)
class ShopItem {
  final String id;
  String nome;
  String descricao;
  ItemType tipo;

  int preco; // Créditos
  int espacoUnitario; // Espaço que ocupa
  int patenteMinima; // Patente mínima para comprar (0-5)

  // Campos específicos para ARMA
  String? formulaDano;
  int? multiplicadorCritico;
  String? efeitoCritico;
  bool isAmaldicoado;
  String? efeitoMaldicao;

  // Campos específicos para CURA
  String? formulaCura;
  String? efeitoAdicional;

  ShopItem({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.tipo,
    required this.preco,
    required this.espacoUnitario,
    this.patenteMinima = 0,
    this.formulaDano,
    this.multiplicadorCritico,
    this.efeitoCritico,
    this.isAmaldicoado = false,
    this.efeitoMaldicao,
    this.formulaCura,
    this.efeitoAdicional,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'tipo': tipo.name,
      'preco': preco,
      'espacoUnitario': espacoUnitario,
      'patenteMinima': patenteMinima,
      'formulaDano': formulaDano,
      'multiplicadorCritico': multiplicadorCritico,
      'efeitoCritico': efeitoCritico,
      'isAmaldicoado': isAmaldicoado,
      'efeitoMaldicao': efeitoMaldicao,
      'formulaCura': formulaCura,
      'efeitoAdicional': efeitoAdicional,
    };
  }

  factory ShopItem.fromJson(Map<String, dynamic> json) {
    return ShopItem(
      id: json['id'] as String,
      nome: json['nome'] as String,
      descricao: json['descricao'] as String,
      tipo: ItemType.values.firstWhere(
        (e) => e.name == json['tipo'],
        orElse: () => ItemType.equipamento,
      ),
      preco: json['preco'] as int,
      espacoUnitario: json['espacoUnitario'] as int,
      patenteMinima: json['patenteMinima'] as int? ?? 0,
      formulaDano: json['formulaDano'] as String?,
      multiplicadorCritico: json['multiplicadorCritico'] as int?,
      efeitoCritico: json['efeitoCritico'] as String?,
      isAmaldicoado: json['isAmaldicoado'] as bool? ?? false,
      efeitoMaldicao: json['efeitoMaldicao'] as String?,
      formulaCura: json['formulaCura'] as String?,
      efeitoAdicional: json['efeitoAdicional'] as String?,
    );
  }

  ShopItem copyWith({
    String? id,
    String? nome,
    String? descricao,
    ItemType? tipo,
    int? preco,
    int? espacoUnitario,
    int? patenteMinima,
    String? formulaDano,
    int? multiplicadorCritico,
    String? efeitoCritico,
    bool? isAmaldicoado,
    String? efeitoMaldicao,
    String? formulaCura,
    String? efeitoAdicional,
  }) {
    return ShopItem(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      tipo: tipo ?? this.tipo,
      preco: preco ?? this.preco,
      espacoUnitario: espacoUnitario ?? this.espacoUnitario,
      patenteMinima: patenteMinima ?? this.patenteMinima,
      formulaDano: formulaDano ?? this.formulaDano,
      multiplicadorCritico: multiplicadorCritico ?? this.multiplicadorCritico,
      efeitoCritico: efeitoCritico ?? this.efeitoCritico,
      isAmaldicoado: isAmaldicoado ?? this.isAmaldicoado,
      efeitoMaldicao: efeitoMaldicao ?? this.efeitoMaldicao,
      formulaCura: formulaCura ?? this.formulaCura,
      efeitoAdicional: efeitoAdicional ?? this.efeitoAdicional,
    );
  }
}

/// Model de Loja
class Shop {
  final String id;
  String nome;
  String descricao;
  ShopType tipo;

  List<ShopItem> itens;

  // Metadata
  DateTime criadoEm;
  DateTime atualizadoEm;

  Shop({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.tipo,
    List<ShopItem>? itens,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
  })  : itens = itens ?? [],
        criadoEm = criadoEm ?? DateTime.now(),
        atualizadoEm = atualizadoEm ?? DateTime.now();

  // Serialização JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'tipo': tipo.name,
      'itens': itens.map((item) => item.toJson()).toList(),
      'criadoEm': criadoEm.toIso8601String(),
      'atualizadoEm': atualizadoEm.toIso8601String(),
    };
  }

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      id: json['id'] as String,
      nome: json['nome'] as String,
      descricao: json['descricao'] as String,
      tipo: ShopType.values.firstWhere(
        (e) => e.name == json['tipo'],
        orElse: () => ShopType.mercador,
      ),
      itens: (json['itens'] as List<dynamic>?)
              ?.map((item) => ShopItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      criadoEm: DateTime.parse(json['criadoEm'] as String),
      atualizadoEm: DateTime.parse(json['atualizadoEm'] as String),
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory Shop.fromJsonString(String jsonString) {
    return Shop.fromJson(jsonDecode(jsonString));
  }

  // Copiar com modificações
  Shop copyWith({
    String? id,
    String? nome,
    String? descricao,
    ShopType? tipo,
    List<ShopItem>? itens,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
  }) {
    return Shop(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      tipo: tipo ?? this.tipo,
      itens: itens ?? this.itens,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? DateTime.now(),
    );
  }
}

/// Formato de export/import para WhatsApp
class ShopExport {
  final String version;
  final String type;
  final Shop shop;
  final DateTime exportDate;

  ShopExport({
    this.version = '1.0',
    this.type = 'shop',
    required this.shop,
    DateTime? exportDate,
  }) : exportDate = exportDate ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'type': type,
      'data': shop.toJson(),
      'exportDate': exportDate.toIso8601String(),
    };
  }

  factory ShopExport.fromJson(Map<String, dynamic> json) {
    return ShopExport(
      version: json['version'] as String? ?? '1.0',
      type: json['type'] as String? ?? 'shop',
      shop: Shop.fromJson(json['data'] as Map<String, dynamic>),
      exportDate: DateTime.parse(json['exportDate'] as String),
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory ShopExport.fromJsonString(String jsonString) {
    return ShopExport.fromJson(jsonDecode(jsonString));
  }
}
