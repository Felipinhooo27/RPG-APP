import 'shop.dart';
import 'item_rarity.dart';

/// Configuração para geração randômica de lojas
class ShopGeneratorConfig {
  // Informações básicas (opcionais - serão geradas se não fornecidas)
  final String? nomePersonalizado;
  final String? descricaoPersonalizada;
  final String? donoPersonalizado;

  // Tipo de loja
  final ShopType tipoLoja;

  // Quantidades de cada tipo de item
  final int armasComuns;
  final int armasAmaldicoadas;
  final int curas;
  final int curasAmaldicoadas;
  final int comidas;
  final int utilidades;
  final int municoes;
  final int equipamentos;

  // Filtros de raridade e patente
  final ItemRarity raridadeMinima;
  final ItemRarity raridadeMaxima;
  final int patenteMinima;
  final int patenteMaxima;

  const ShopGeneratorConfig({
    this.nomePersonalizado,
    this.descricaoPersonalizada,
    this.donoPersonalizado,
    this.tipoLoja = ShopType.mercador,
    this.armasComuns = 0,
    this.armasAmaldicoadas = 0,
    this.curas = 0,
    this.curasAmaldicoadas = 0,
    this.comidas = 0,
    this.utilidades = 0,
    this.municoes = 0,
    this.equipamentos = 0,
    this.raridadeMinima = ItemRarity.comum,
    this.raridadeMaxima = ItemRarity.lendario,
    this.patenteMinima = 0,
    this.patenteMaxima = 5,
  });

  /// Retorna total de itens a serem gerados
  int get totalItens =>
      armasComuns +
      armasAmaldicoadas +
      curas +
      curasAmaldicoadas +
      comidas +
      utilidades +
      municoes +
      equipamentos;

  /// Verifica se a configuração é válida
  bool get isValid => totalItens > 0;

  /// Presets prontos

  /// Loja de Bairro - Foco em comidas e utilidades
  static ShopGeneratorConfig presetLojaDeBairro() {
    return const ShopGeneratorConfig(
      tipoLoja: ShopType.mercador,
      comidas: 15,
      utilidades: 10,
      curas: 5,
      patenteMinima: 0,
      patenteMaxima: 1,
      raridadeMinima: ItemRarity.comum,
      raridadeMaxima: ItemRarity.incomum,
    );
  }

  /// Armaria Básica - Foco em armas comuns e munições
  static ShopGeneratorConfig presetArmariaBasica() {
    return const ShopGeneratorConfig(
      tipoLoja: ShopType.armaria,
      armasComuns: 12,
      municoes: 8,
      equipamentos: 5,
      patenteMinima: 0,
      patenteMaxima: 2,
      raridadeMinima: ItemRarity.comum,
      raridadeMaxima: ItemRarity.incomum,
    );
  }

  /// Quartel da Ordem - Foco em armas amaldiçoadas
  static ShopGeneratorConfig presetQuartelDaOrdem() {
    return const ShopGeneratorConfig(
      tipoLoja: ShopType.forjaria,
      armasAmaldicoadas: 10,
      armasComuns: 5,
      curasAmaldicoadas: 5,
      equipamentos: 5,
      patenteMinima: 2,
      patenteMaxima: 5,
      raridadeMinima: ItemRarity.raro,
      raridadeMaxima: ItemRarity.lendario,
    );
  }

  /// Farmácia - Foco em curas
  static ShopGeneratorConfig presetFarmacia() {
    return const ShopGeneratorConfig(
      tipoLoja: ShopType.farmacia,
      curas: 15,
      comidas: 5,
      utilidades: 3,
      patenteMinima: 0,
      patenteMaxima: 2,
      raridadeMinima: ItemRarity.comum,
      raridadeMaxima: ItemRarity.raro,
    );
  }

  /// Enfermaria da Ordem - Foco em curas amaldiçoadas
  static ShopGeneratorConfig presetEnfermariaDaOrdem() {
    return const ShopGeneratorConfig(
      tipoLoja: ShopType.farmacia,
      curasAmaldicoadas: 8,
      curas: 7,
      patenteMinima: 2,
      patenteMaxima: 5,
      raridadeMinima: ItemRarity.incomum,
      raridadeMaxima: ItemRarity.lendario,
    );
  }

  /// Mercado Completo - Mix de tudo
  static ShopGeneratorConfig presetMercadoCompleto() {
    return const ShopGeneratorConfig(
      tipoLoja: ShopType.taberna,
      armasComuns: 5,
      armasAmaldicoadas: 2,
      curas: 8,
      curasAmaldicoadas: 2,
      comidas: 10,
      utilidades: 8,
      municoes: 5,
      equipamentos: 5,
      patenteMinima: 0,
      patenteMaxima: 3,
      raridadeMinima: ItemRarity.comum,
      raridadeMaxima: ItemRarity.raro,
    );
  }

  /// Armaria Tática - Armas e equipamentos táticos
  static ShopGeneratorConfig presetArmariaTatica() {
    return const ShopGeneratorConfig(
      tipoLoja: ShopType.armaria,
      armasComuns: 15,
      municoes: 10,
      equipamentos: 10,
      utilidades: 5,
      patenteMinima: 1,
      patenteMaxima: 3,
      raridadeMinima: ItemRarity.comum,
      raridadeMaxima: ItemRarity.raro,
    );
  }

  ShopGeneratorConfig copyWith({
    String? nomePersonalizado,
    String? descricaoPersonalizada,
    String? donoPersonalizado,
    ShopType? tipoLoja,
    int? armasComuns,
    int? armasAmaldicoadas,
    int? curas,
    int? curasAmaldicoadas,
    int? comidas,
    int? utilidades,
    int? municoes,
    int? equipamentos,
    ItemRarity? raridadeMinima,
    ItemRarity? raridadeMaxima,
    int? patenteMinima,
    int? patenteMaxima,
  }) {
    return ShopGeneratorConfig(
      nomePersonalizado: nomePersonalizado ?? this.nomePersonalizado,
      descricaoPersonalizada: descricaoPersonalizada ?? this.descricaoPersonalizada,
      donoPersonalizado: donoPersonalizado ?? this.donoPersonalizado,
      tipoLoja: tipoLoja ?? this.tipoLoja,
      armasComuns: armasComuns ?? this.armasComuns,
      armasAmaldicoadas: armasAmaldicoadas ?? this.armasAmaldicoadas,
      curas: curas ?? this.curas,
      curasAmaldicoadas: curasAmaldicoadas ?? this.curasAmaldicoadas,
      comidas: comidas ?? this.comidas,
      utilidades: utilidades ?? this.utilidades,
      municoes: municoes ?? this.municoes,
      equipamentos: equipamentos ?? this.equipamentos,
      raridadeMinima: raridadeMinima ?? this.raridadeMinima,
      raridadeMaxima: raridadeMaxima ?? this.raridadeMaxima,
      patenteMinima: patenteMinima ?? this.patenteMinima,
      patenteMaxima: patenteMaxima ?? this.patenteMaxima,
    );
  }
}
