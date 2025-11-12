import 'dart:convert';

/// Enumeração de Classes (Ordem Paranormal)
enum CharacterClass {
  combatente,
  especialista,
  ocultista,
}

/// Enumeração de Origens (Ordem Paranormal)
enum Origem {
  academico,
  agente,
  artista,
  atleta,
  chef,
  criminoso,
  cultista,
  desgarrado,
  engenheiro,
  executivo,
  investigador,
  lutador,
  mercenario,
  militar,
  operario,
  policial,
  religioso,
  servidor,
  trambiqueiro,
  universitario,
  veterano,
  vitima,
}

/// Enumeração de Sexo
enum Sexo {
  masculino,
  feminino,
  naoBinario,
}

/// Model de Personagem seguindo as regras de Ordem Paranormal
///
/// REGRAS:
/// - Atributos: 0-5 (max 3 inicial, 4 pontos para distribuir)
/// - PV = base da classe + Vigor
/// - PE = base da classe + Presença
/// - SAN = base da classe
/// - NEX: 5%, 10%, 20%, 35%, 40%, 50%, 65%, 70%, 80%, 95%, 99%
/// - Deslocamento padrão: 9m
class Character {
  final String id;
  final String userId; // 'player_001' ou 'master_001'

  // Informações básicas
  String nome;
  CharacterClass classe;
  Origem origem;
  String? trilha;
  String? patente;
  int nex; // 5-99%
  Sexo? sexo; // masculino, feminino ou não-binário

  // Atributos (0-5)
  int forca;
  int agilidade;
  int vigor;
  int intelecto;
  int presenca;

  // Recursos
  int pvMax;
  int pvAtual;
  int peMax;
  int peAtual;
  int sanMax;
  int sanAtual;

  // Combate
  int defesa;
  int bloqueio;
  int deslocamento; // metros
  int iniciativaBase;

  // Finanças
  int creditos;

  // Perícias (IDs)
  List<String> periciasTreinadas;

  // Inventário (IDs de itens)
  List<String> inventarioIds;

  // Poderes (IDs)
  List<String> poderesIds;

  // Notas pessoais
  String? notas;
  String? historia;

  // Metadata
  DateTime criadoEm;
  DateTime atualizadoEm;
  String? activeShopId;

  Character({
    required this.id,
    required this.userId,
    required this.nome,
    required this.classe,
    required this.origem,
    this.trilha,
    this.patente,
    required this.nex,
    this.sexo,
    required this.forca,
    required this.agilidade,
    required this.vigor,
    required this.intelecto,
    required this.presenca,
    required this.pvMax,
    required this.pvAtual,
    required this.peMax,
    required this.peAtual,
    required this.sanMax,
    required this.sanAtual,
    required this.defesa,
    required this.bloqueio,
    required this.deslocamento,
    required this.iniciativaBase,
    this.creditos = 0,
    List<String>? periciasTreinadas,
    List<String>? inventarioIds,
    List<String>? poderesIds,
    this.notas,
    this.historia,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
    this.activeShopId,
  })  : periciasTreinadas = periciasTreinadas ?? [],
        inventarioIds = inventarioIds ?? [],
        poderesIds = poderesIds ?? [],
        criadoEm = criadoEm ?? DateTime.now(),
        atualizadoEm = atualizadoEm ?? DateTime.now();

  // Getters calculados
  int get modificadorForca => forca;
  int get modificadorAgilidade => agilidade;
  int get modificadorVigor => vigor;
  int get modificadorIntelecto => intelecto;
  int get modificadorPresenca => presenca;

  double get pvPercentual => pvMax > 0 ? (pvAtual / pvMax) : 0;
  double get pePercentual => peMax > 0 ? (peAtual / peMax) : 0;
  double get sanPercentual => sanMax > 0 ? (sanAtual / sanMax) : 0;

  bool get isLowHealth => pvPercentual <= 0.25;
  bool get isLowSanity => sanPercentual <= 0.25;

  int get iniciativa => iniciativaBase + agilidade;

  // Cálculos de Combate (Sistema Ordem Paranormal)
  /// Peso máximo que o personagem pode carregar (Força x 10)
  int get pesoMaximo => forca * 10;

  /// Defesa base calculada (10 + Agilidade)
  /// Nota: Bônus de armadura deve ser adicionado externamente
  int get defesaCalculada => 10 + agilidade;

  /// Bloqueio calculado (Força + Vigor)
  int get bloqueioCalculado => forca + vigor;

  /// Deslocamento calculado em metros (Agilidade x 3)
  /// Nota: Penalidades de armadura devem ser aplicadas externamente
  int get deslocamentoCalculado => agilidade * 3;

  // Validações (Ordem Paranormal)
  static const int MIN_ATTRIBUTE = -1;
  static const int MAX_ATTRIBUTE_INITIAL = 3;
  static const int MAX_ATTRIBUTE_EVER = 5;
  static const int DESLOCAMENTO_PADRAO = 9;

  bool isAttributeValid(int value) {
    return value >= MIN_ATTRIBUTE && value <= MAX_ATTRIBUTE_EVER;
  }

  // Serialização JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'nome': nome,
      'classe': classe.name,
      'origem': origem.name,
      'trilha': trilha,
      'patente': patente,
      'nex': nex,
      'sexo': sexo?.name,
      'forca': forca,
      'agilidade': agilidade,
      'vigor': vigor,
      'intelecto': intelecto,
      'presenca': presenca,
      'pvMax': pvMax,
      'pvAtual': pvAtual,
      'peMax': peMax,
      'peAtual': peAtual,
      'sanMax': sanMax,
      'sanAtual': sanAtual,
      'defesa': defesa,
      'bloqueio': bloqueio,
      'deslocamento': deslocamento,
      'iniciativaBase': iniciativaBase,
      'creditos': creditos,
      'periciasTreinadas': periciasTreinadas,
      'inventarioIds': inventarioIds,
      'poderesIds': poderesIds,
      'notas': notas,
      'historia': historia,
      'criadoEm': criadoEm.toIso8601String(),
      'atualizadoEm': atualizadoEm.toIso8601String(),
      'activeShopId': activeShopId,
    };
  }

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: json['id'] as String,
      userId: json['userId'] as String,
      nome: json['nome'] as String,
      classe: CharacterClass.values.firstWhere(
        (e) => e.name == json['classe'],
        orElse: () => CharacterClass.combatente,
      ),
      origem: Origem.values.firstWhere(
        (e) => e.name == json['origem'],
        orElse: () => Origem.academico,
      ),
      trilha: json['trilha'] as String?,
      patente: json['patente'] as String?,
      nex: json['nex'] as int,
      sexo: json['sexo'] != null
          ? Sexo.values.firstWhere(
              (e) => e.name == json['sexo'],
              orElse: () => Sexo.naoBinario,
            )
          : null,
      forca: json['forca'] as int,
      agilidade: json['agilidade'] as int,
      vigor: json['vigor'] as int,
      intelecto: json['intelecto'] as int,
      presenca: json['presenca'] as int,
      pvMax: json['pvMax'] as int,
      pvAtual: json['pvAtual'] as int,
      peMax: json['peMax'] as int,
      peAtual: json['peAtual'] as int,
      sanMax: json['sanMax'] as int,
      sanAtual: json['sanAtual'] as int,
      defesa: json['defesa'] as int,
      bloqueio: json['bloqueio'] as int,
      deslocamento: json['deslocamento'] as int,
      iniciativaBase: json['iniciativaBase'] as int,
      creditos: json['creditos'] as int? ?? 0,
      periciasTreinadas: (json['periciasTreinadas'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      inventarioIds: (json['inventarioIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      poderesIds: (json['poderesIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      notas: json['notas'] as String?,
      historia: json['historia'] as String?,
      criadoEm: DateTime.parse(json['criadoEm'] as String),
      atualizadoEm: DateTime.parse(json['atualizadoEm'] as String),
      activeShopId: json['activeShopId'] as String?,
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory Character.fromJsonString(String jsonString) {
    return Character.fromJson(jsonDecode(jsonString));
  }

  // Copiar com modificações
  Character copyWith({
    String? id,
    String? userId,
    String? nome,
    CharacterClass? classe,
    Origem? origem,
    String? trilha,
    String? patente,
    int? nex,
    Sexo? sexo,
    int? forca,
    int? agilidade,
    int? vigor,
    int? intelecto,
    int? presenca,
    int? pvMax,
    int? pvAtual,
    int? peMax,
    int? peAtual,
    int? sanMax,
    int? sanAtual,
    int? defesa,
    int? bloqueio,
    int? deslocamento,
    int? iniciativaBase,
    int? creditos,
    List<String>? periciasTreinadas,
    List<String>? inventarioIds,
    List<String>? poderesIds,
    String? notas,
    String? historia,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
    String? activeShopId,
  }) {
    return Character(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      nome: nome ?? this.nome,
      classe: classe ?? this.classe,
      origem: origem ?? this.origem,
      trilha: trilha ?? this.trilha,
      patente: patente ?? this.patente,
      nex: nex ?? this.nex,
      sexo: sexo ?? this.sexo,
      forca: forca ?? this.forca,
      agilidade: agilidade ?? this.agilidade,
      vigor: vigor ?? this.vigor,
      intelecto: intelecto ?? this.intelecto,
      presenca: presenca ?? this.presenca,
      pvMax: pvMax ?? this.pvMax,
      pvAtual: pvAtual ?? this.pvAtual,
      peMax: peMax ?? this.peMax,
      peAtual: peAtual ?? this.peAtual,
      sanMax: sanMax ?? this.sanMax,
      sanAtual: sanAtual ?? this.sanAtual,
      defesa: defesa ?? this.defesa,
      bloqueio: bloqueio ?? this.bloqueio,
      deslocamento: deslocamento ?? this.deslocamento,
      iniciativaBase: iniciativaBase ?? this.iniciativaBase,
      creditos: creditos ?? this.creditos,
      periciasTreinadas: periciasTreinadas ?? this.periciasTreinadas,
      inventarioIds: inventarioIds ?? this.inventarioIds,
      poderesIds: poderesIds ?? this.poderesIds,
      notas: notas ?? this.notas,
      historia: historia ?? this.historia,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? DateTime.now(),
      activeShopId: activeShopId ?? this.activeShopId,
    );
  }
}
