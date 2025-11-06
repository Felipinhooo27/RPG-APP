class Item {
  final String id;
  final String nome;
  final String descricao;
  final int quantidade;
  final String tipo; // 'Arma', 'Equipamento', 'Consumível'

  // Propriedades de Dano (para Armas)
  final String? formulaDano; // ex: "1d8+2", "2d6"
  final int? multiplicadorCritico; // ex: 2 para x2, 3 para x3
  final String? efeitoCritico;

  Item({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.quantidade,
    required this.tipo,
    this.formulaDano,
    this.multiplicadorCritico,
    this.efeitoCritico,
  });

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
      formulaDano: map['formulaDano'],
      multiplicadorCritico: map['multiplicadorCritico'],
      efeitoCritico: map['efeitoCritico'],
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
      'formulaDano': formulaDano,
      'multiplicadorCritico': multiplicadorCritico,
      'efeitoCritico': efeitoCritico,
    };
  }

  // Método copyWith para criar cópias com alterações
  Item copyWith({
    String? id,
    String? nome,
    String? descricao,
    int? quantidade,
    String? tipo,
    String? formulaDano,
    int? multiplicadorCritico,
    String? efeitoCritico,
  }) {
    return Item(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      quantidade: quantidade ?? this.quantidade,
      tipo: tipo ?? this.tipo,
      formulaDano: formulaDano ?? this.formulaDano,
      multiplicadorCritico: multiplicadorCritico ?? this.multiplicadorCritico,
      efeitoCritico: efeitoCritico ?? this.efeitoCritico,
    );
  }

  // Verifica se o item é uma arma (tem fórmula de dano)
  bool get isWeapon => formulaDano != null && formulaDano!.isNotEmpty;
}
