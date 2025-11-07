class ShopItem {
  final String id;
  final String nome;
  final String descricao;
  final String tipo; // 'Arma', 'Cura', 'Munição', 'Material', 'Equipamento'
  final int preco;
  final int patenteMinima; // 0 a 20
  final int espaco; // Espaço que ocupa no inventário
  final String iconCode; // Código do ícone (ex: "0xe800" para Icons.codePoint)

  // Propriedades específicas por tipo
  final bool isAmaldicoado;
  final String? formulaDano;
  final String? formulaCura;
  final int? quantidade;
  final String? efeitoEspecial;
  final String? tipoMunicao; // 'prata', 'explosiva', 'perfurante', 'anti-zumbi', 'flecha'

  ShopItem({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.tipo,
    required this.preco,
    required this.patenteMinima,
    required this.espaco,
    required this.iconCode,
    this.isAmaldicoado = false,
    this.formulaDano,
    this.formulaCura,
    this.quantidade,
    this.efeitoEspecial,
    this.tipoMunicao,
  });

  factory ShopItem.fromMap(Map<String, dynamic> map) {
    return ShopItem(
      id: map['id'] ?? '',
      nome: map['nome'] ?? '',
      descricao: map['descricao'] ?? '',
      tipo: map['tipo'] ?? 'Equipamento',
      preco: map['preco'] ?? 0,
      patenteMinima: map['patenteMinima'] ?? 0,
      espaco: map['espaco'] ?? 1,
      iconCode: map['iconCode'] ?? '0xe567',
      isAmaldicoado: map['isAmaldicoado'] ?? false,
      formulaDano: map['formulaDano'],
      formulaCura: map['formulaCura'],
      quantidade: map['quantidade'],
      efeitoEspecial: map['efeitoEspecial'],
      tipoMunicao: map['tipoMunicao'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'tipo': tipo,
      'preco': preco,
      'patenteMinima': patenteMinima,
      'espaco': espaco,
      'iconCode': iconCode,
      'isAmaldicoado': isAmaldicoado,
      'formulaDano': formulaDano,
      'formulaCura': formulaCura,
      'quantidade': quantidade,
      'efeitoEspecial': efeitoEspecial,
      'tipoMunicao': tipoMunicao,
    };
  }

  ShopItem copyWith({
    String? id,
    String? nome,
    String? descricao,
    String? tipo,
    int? preco,
    int? patenteMinima,
    int? espaco,
    String? iconCode,
    bool? isAmaldicoado,
    String? formulaDano,
    String? formulaCura,
    int? quantidade,
    String? efeitoEspecial,
    String? tipoMunicao,
  }) {
    return ShopItem(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      tipo: tipo ?? this.tipo,
      preco: preco ?? this.preco,
      patenteMinima: patenteMinima ?? this.patenteMinima,
      espaco: espaco ?? this.espaco,
      iconCode: iconCode ?? this.iconCode,
      isAmaldicoado: isAmaldicoado ?? this.isAmaldicoado,
      formulaDano: formulaDano ?? this.formulaDano,
      formulaCura: formulaCura ?? this.formulaCura,
      quantidade: quantidade ?? this.quantidade,
      efeitoEspecial: efeitoEspecial ?? this.efeitoEspecial,
      tipoMunicao: tipoMunicao ?? this.tipoMunicao,
    );
  }
}

class Shop {
  final String id;
  final String nome;
  final String tipo; // 'Armeiro', 'Curas', 'Materiais', 'Geral', 'Personalizada'
  final String descricao;
  final List<ShopItem> items;
  final DateTime createdAt;
  final String createdBy; // ID do mestre

  Shop({
    required this.id,
    required this.nome,
    required this.tipo,
    required this.descricao,
    required this.items,
    required this.createdAt,
    required this.createdBy,
  });

  factory Shop.fromMap(Map<String, dynamic> map) {
    final List<ShopItem> items = [];
    if (map['items'] != null) {
      for (var itemMap in map['items']) {
        items.add(ShopItem.fromMap(itemMap));
      }
    }

    return Shop(
      id: map['id'] ?? '',
      nome: map['nome'] ?? '',
      tipo: map['tipo'] ?? 'Geral',
      descricao: map['descricao'] ?? '',
      items: items,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      createdBy: map['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'tipo': tipo,
      'descricao': descricao,
      'items': items.map((item) => item.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
    };
  }

  Shop copyWith({
    String? id,
    String? nome,
    String? tipo,
    String? descricao,
    List<ShopItem>? items,
    DateTime? createdAt,
    String? createdBy,
  }) {
    return Shop(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      tipo: tipo ?? this.tipo,
      descricao: descricao ?? this.descricao,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}

class CartItem {
  final ShopItem item;
  final int quantidade;

  CartItem({
    required this.item,
    required this.quantidade,
  });

  int get precoTotal => item.preco * quantidade;
  int get espacoTotal => item.espaco * quantidade;
}
