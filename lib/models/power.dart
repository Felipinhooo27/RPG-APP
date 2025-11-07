class Ability {
  final String id;
  final String nome;
  final String descricao;
  final int custo; // Custo em PE
  final String? formulaDano; // Fórmula de dano/cura (ex: "2d6+3")
  final String tipo; // 'dano', 'cura', 'utilidade'
  final String? efeitoAdicional; // Descrição de efeitos adicionais

  Ability({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.custo,
    this.formulaDano,
    required this.tipo,
    this.efeitoAdicional,
  });

  factory Ability.fromMap(Map<String, dynamic> map) {
    return Ability(
      id: map['id'] ?? '',
      nome: map['nome'] ?? '',
      descricao: map['descricao'] ?? '',
      custo: map['custo'] ?? 0,
      formulaDano: map['formulaDano'],
      tipo: map['tipo'] ?? 'utilidade',
      efeitoAdicional: map['efeitoAdicional'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'custo': custo,
      'formulaDano': formulaDano,
      'tipo': tipo,
      'efeitoAdicional': efeitoAdicional,
    };
  }

  Ability copyWith({
    String? id,
    String? nome,
    String? descricao,
    int? custo,
    String? formulaDano,
    String? tipo,
    String? efeitoAdicional,
  }) {
    return Ability(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      custo: custo ?? this.custo,
      formulaDano: formulaDano ?? this.formulaDano,
      tipo: tipo ?? this.tipo,
      efeitoAdicional: efeitoAdicional ?? this.efeitoAdicional,
    );
  }
}

class Power {
  final String id;
  final String nome;
  final String descricao;
  final String elemento; // 'Conhecimento', 'Energia', 'Morte', 'Sangue', 'Medo'
  final List<Ability> habilidades;

  Power({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.elemento,
    required this.habilidades,
  });

  factory Power.fromMap(Map<String, dynamic> map) {
    final List<Ability> habilidades = [];
    if (map['habilidades'] != null) {
      for (var abilityMap in map['habilidades']) {
        habilidades.add(Ability.fromMap(abilityMap));
      }
    }

    return Power(
      id: map['id'] ?? '',
      nome: map['nome'] ?? '',
      descricao: map['descricao'] ?? '',
      elemento: map['elemento'] ?? 'Conhecimento',
      habilidades: habilidades,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'elemento': elemento,
      'habilidades': habilidades.map((ability) => ability.toMap()).toList(),
    };
  }

  Power copyWith({
    String? id,
    String? nome,
    String? descricao,
    String? elemento,
    List<Ability>? habilidades,
  }) {
    return Power(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      elemento: elemento ?? this.elemento,
      habilidades: habilidades ?? this.habilidades,
    );
  }
}
