import 'item.dart';

class Character {
  final String id;
  final String nome;
  final String patente;
  final int nex;
  final String origem;
  final String classe;
  final String trilha;
  final String createdBy; // ID do usuário que criou (para Modo Jogador)

  // Status
  final int pvAtual;
  final int pvMax;
  final int peAtual;
  final int peMax;
  final int psAtual;
  final int psMax;
  final int creditos;

  // Atributos
  final int forca;
  final int agilidade;
  final int vigor;
  final int inteligencia;
  final int presenca;

  // Combate
  final int iniciativaBase;

  // Poderes Paranormais
  final List<String> poderes;

  // Inventário
  final List<Item> inventario;

  Character({
    required this.id,
    required this.nome,
    required this.patente,
    required this.nex,
    required this.origem,
    required this.classe,
    required this.trilha,
    required this.createdBy,
    required this.pvAtual,
    required this.pvMax,
    required this.peAtual,
    required this.peMax,
    required this.psAtual,
    required this.psMax,
    required this.creditos,
    required this.forca,
    required this.agilidade,
    required this.vigor,
    required this.inteligencia,
    required this.presenca,
    required this.iniciativaBase,
    required this.poderes,
    required this.inventario,
  });

  // Construtor para criar um personagem vazio
  factory Character.empty(String userId) {
    return Character(
      id: '',
      nome: '',
      patente: '',
      nex: 0,
      origem: '',
      classe: '',
      trilha: '',
      createdBy: userId,
      pvAtual: 0,
      pvMax: 0,
      peAtual: 0,
      peMax: 0,
      psAtual: 0,
      psMax: 0,
      creditos: 0,
      forca: 0,
      agilidade: 0,
      vigor: 0,
      inteligencia: 0,
      presenca: 0,
      iniciativaBase: 0,
      poderes: [],
      inventario: [],
    );
  }

  // Converter de Map (Firestore) para Character
  factory Character.fromMap(Map<String, dynamic> map) {
    final List<Item> items = [];
    if (map['inventario'] != null) {
      for (var itemMap in map['inventario']) {
        items.add(Item.fromMap(itemMap));
      }
    }

    final List<String> poderes = [];
    if (map['poderes'] != null) {
      for (var poder in map['poderes']) {
        poderes.add(poder.toString());
      }
    }

    return Character(
      id: map['id'] ?? '',
      nome: map['nome'] ?? '',
      patente: map['patente'] ?? '',
      nex: map['nex'] ?? 0,
      origem: map['origem'] ?? '',
      classe: map['classe'] ?? '',
      trilha: map['trilha'] ?? '',
      createdBy: map['createdBy'] ?? '',
      pvAtual: map['status']?['pv_atual'] ?? 0,
      pvMax: map['status']?['pv_max'] ?? 0,
      peAtual: map['status']?['pe_atual'] ?? 0,
      peMax: map['status']?['pe_max'] ?? 0,
      psAtual: map['status']?['ps_atual'] ?? 0,
      psMax: map['status']?['ps_max'] ?? 0,
      creditos: map['status']?['creditos'] ?? 0,
      forca: map['atributos']?['for'] ?? 0,
      agilidade: map['atributos']?['agi'] ?? 0,
      vigor: map['atributos']?['vig'] ?? 0,
      inteligencia: map['atributos']?['int'] ?? 0,
      presenca: map['atributos']?['pre'] ?? 0,
      iniciativaBase: map['combate']?['iniciativa_base'] ?? 0,
      poderes: poderes,
      inventario: items,
    );
  }

  // Converter de Character para Map (Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'patente': patente,
      'nex': nex,
      'origem': origem,
      'classe': classe,
      'trilha': trilha,
      'createdBy': createdBy,
      'status': {
        'pv_atual': pvAtual,
        'pv_max': pvMax,
        'pe_atual': peAtual,
        'pe_max': peMax,
        'ps_atual': psAtual,
        'ps_max': psMax,
        'creditos': creditos,
      },
      'atributos': {
        'for': forca,
        'agi': agilidade,
        'vig': vigor,
        'int': inteligencia,
        'pre': presenca,
      },
      'combate': {
        'iniciativa_base': iniciativaBase,
      },
      'poderes': poderes,
      'inventario': inventario.map((item) => item.toMap()).toList(),
    };
  }

  // Método copyWith para criar cópias com alterações
  Character copyWith({
    String? id,
    String? nome,
    String? patente,
    int? nex,
    String? origem,
    String? classe,
    String? trilha,
    String? createdBy,
    int? pvAtual,
    int? pvMax,
    int? peAtual,
    int? peMax,
    int? psAtual,
    int? psMax,
    int? creditos,
    int? forca,
    int? agilidade,
    int? vigor,
    int? inteligencia,
    int? presenca,
    int? iniciativaBase,
    List<String>? poderes,
    List<Item>? inventario,
  }) {
    return Character(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      patente: patente ?? this.patente,
      nex: nex ?? this.nex,
      origem: origem ?? this.origem,
      classe: classe ?? this.classe,
      trilha: trilha ?? this.trilha,
      createdBy: createdBy ?? this.createdBy,
      pvAtual: pvAtual ?? this.pvAtual,
      pvMax: pvMax ?? this.pvMax,
      peAtual: peAtual ?? this.peAtual,
      peMax: peMax ?? this.peMax,
      psAtual: psAtual ?? this.psAtual,
      psMax: psMax ?? this.psMax,
      creditos: creditos ?? this.creditos,
      forca: forca ?? this.forca,
      agilidade: agilidade ?? this.agilidade,
      vigor: vigor ?? this.vigor,
      inteligencia: inteligencia ?? this.inteligencia,
      presenca: presenca ?? this.presenca,
      iniciativaBase: iniciativaBase ?? this.iniciativaBase,
      poderes: poderes ?? this.poderes,
      inventario: inventario ?? this.inventario,
    );
  }
}
