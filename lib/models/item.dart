class Item {
  final String id;
  final String nome;
  final String descricao;
  final int quantidade;
  final String tipo; // 'Arma', 'Equipamento', 'Consumível', 'Cura', 'Munição'
  final String categoria; // Categoria para agrupamento (mesma coisa que tipo basicamente)

  // Propriedades de Dano (para Armas)
  final String? formulaDano; // ex: "1d8+2", "2d6"
  final int? multiplicadorCritico; // ex: 2 para x2, 3 para x3
  final String? efeitoCritico;

  // Propriedades de Cura
  final String? formulaCura; // ex: "2d4+2"

  // Propriedades adicionais
  final int espaco; // Espaço que ocupa no inventário
  final int preco; // Preço em créditos
  final String? iconCode; // Código do ícone customizável
  final bool isAmaldicoado;
  final String? efeitoEspecial;

  Item({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.quantidade,
    required this.tipo,
    String? categoria,
    this.formulaDano,
    this.multiplicadorCritico,
    this.efeitoCritico,
    this.formulaCura,
    this.espaco = 1,
    this.preco = 0,
    this.iconCode,
    this.isAmaldicoado = false,
    this.efeitoEspecial,
  }) : categoria = categoria ?? tipo;

  // Construtor para criar um item vazio
  factory Item.empty() {
    return Item(
      id: '',
      nome: '',
      descricao: '',
      quantidade: 1,
      tipo: 'Equipamento',
    );
  }

  // Converter de Map (Firestore) para Item
  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'] ?? '',
      nome: map['nome'] ?? '',
      descricao: map['descricao'] ?? '',
      quantidade: map['quantidade'] ?? 1,
      tipo: map['tipo'] ?? 'Equipamento',
      categoria: map['categoria'],
      formulaDano: map['formulaDano'],
      multiplicadorCritico: map['multiplicadorCritico'],
      efeitoCritico: map['efeitoCritico'],
      formulaCura: map['formulaCura'],
      espaco: map['espaco'] ?? 1,
      preco: map['preco'] ?? 0,
      iconCode: map['iconCode'],
      isAmaldicoado: map['isAmaldicoado'] ?? false,
      efeitoEspecial: map['efeitoEspecial'],
    );
  }

  // Converter de Item para Map (Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'quantidade': quantidade,
      'tipo': tipo,
      'categoria': categoria,
      'formulaDano': formulaDano,
      'multiplicadorCritico': multiplicadorCritico,
      'efeitoCritico': efeitoCritico,
      'formulaCura': formulaCura,
      'espaco': espaco,
      'preco': preco,
      'iconCode': iconCode,
      'isAmaldicoado': isAmaldicoado,
      'efeitoEspecial': efeitoEspecial,
    };
  }

  // Método copyWith para criar cópias com alterações
  Item copyWith({
    String? id,
    String? nome,
    String? descricao,
    int? quantidade,
    String? tipo,
    String? categoria,
    String? formulaDano,
    int? multiplicadorCritico,
    String? efeitoCritico,
    String? formulaCura,
    int? espaco,
    int? preco,
    String? iconCode,
    bool? isAmaldicoado,
    String? efeitoEspecial,
  }) {
    return Item(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      quantidade: quantidade ?? this.quantidade,
      tipo: tipo ?? this.tipo,
      categoria: categoria ?? this.categoria,
      formulaDano: formulaDano ?? this.formulaDano,
      multiplicadorCritico: multiplicadorCritico ?? this.multiplicadorCritico,
      efeitoCritico: efeitoCritico ?? this.efeitoCritico,
      formulaCura: formulaCura ?? this.formulaCura,
      espaco: espaco ?? this.espaco,
      preco: preco ?? this.preco,
      iconCode: iconCode ?? this.iconCode,
      isAmaldicoado: isAmaldicoado ?? this.isAmaldicoado,
      efeitoEspecial: efeitoEspecial ?? this.efeitoEspecial,
    );
  }

  // Verifica se o item é uma arma (tem fórmula de dano)
  bool get isWeapon => formulaDano != null && formulaDano!.isNotEmpty;

  // Verifica se o item é uma cura (tem fórmula de cura)
  bool get isHeal => formulaCura != null && formulaCura!.isNotEmpty;
}
