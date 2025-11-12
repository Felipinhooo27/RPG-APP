import 'dart:math';
import 'package:uuid/uuid.dart';
import '../../models/character.dart';
import '../../models/item.dart';
import 'item_templates.dart';
import 'nex_progression.dart';

/// Gerador de itens iniciais para personagens
///
/// Gera kits de equipamento baseados em:
/// - Classe (Combatente, Especialista, Ocultista)
/// - Origem (influencia tipo de equipamento)
/// - NEX (quantidade e qualidade dos itens)
class ItemGenerator {
  final Random _random = Random();
  final Uuid _uuid = const Uuid();

  /// Gera kit de itens iniciais para um personagem
  ///
  /// [characterId] - ID do personagem
  /// [classe] - Classe do personagem
  /// [origem] - Origem do personagem
  /// [nex] - NEX do personagem (5-99)
  /// [useRandom] - Se true, adiciona variedade aleatória. Se false, usa itens padrão.
  List<Item> generateStartingKit({
    required String characterId,
    required CharacterClass classe,
    required Origem origem,
    required int nex,
    bool useRandom = true,
  }) {
    final items = <Item>[];
    final tier = NexProgression.getTierFromNex(nex);
    final itemCount = NexProgression.getRecommendedItemCount(nex);

    // Filtra templates disponíveis para o NEX
    final availableTemplates = ItemTemplateDatabase.getCommonItemsByNex(nex);

    // Set para rastrear itens já gerados (anti-duplicação)
    final generatedItemNames = <String>{};

    switch (classe) {
      case CharacterClass.combatente:
        items.addAll(_generateCombatenteKit(
          characterId,
          origem,
          tier,
          itemCount,
          availableTemplates,
          useRandom,
          nex,
          generatedItemNames,
        ));
        break;

      case CharacterClass.especialista:
        items.addAll(_generateEspecialistaKit(
          characterId,
          origem,
          tier,
          itemCount,
          availableTemplates,
          useRandom,
          nex,
          generatedItemNames,
        ));
        break;

      case CharacterClass.ocultista:
        items.addAll(_generateOcultistaKit(
          characterId,
          origem,
          tier,
          itemCount,
          availableTemplates,
          useRandom,
          nex,
          generatedItemNames,
        ));
        break;
    }

    return items;
  }

  /// Calcula máximo de armas baseado no NEX
  /// - NEX 5-15: Máximo 1 arma
  /// - NEX 20-50: Máximo 2 armas
  /// - NEX 55+: Máximo 3 armas
  int _getMaxWeaponsForNex(int nex) {
    if (nex <= 15) return 1;
    if (nex <= 50) return 2;
    return 3;
  }

  /// Gera kit para Combatente
  /// Foco: Armas de combate + Armadura/Proteção + Curas
  List<Item> _generateCombatenteKit(
    String characterId,
    Origem origem,
    int tier,
    int itemCount,
    List<ItemTemplate> availableTemplates,
    bool useRandom,
    int nex,
    Set<String> generatedItemNames,
  ) {
    final items = <Item>[];
    final maxWeapons = _getMaxWeaponsForNex(nex);
    int weaponCount = 0;

    // 1. Arma primária (obrigatório)
    final primaryWeapon = _selectPrimaryWeapon(
      origem,
      availableTemplates,
      useRandom,
      nex,
      generatedItemNames,
      preferRanged: _isRangedOrigem(origem),
    );
    if (primaryWeapon != null) {
      final item = _createItemFromTemplate(primaryWeapon, characterId);
      items.add(item);
      generatedItemNames.add(primaryWeapon.nome);
      weaponCount++;
    }

    // 2. Arma secundária (se permitido pelo NEX)
    if (weaponCount < maxWeapons && items.length < itemCount) {
      final secondaryWeapon = _selectSecondaryWeapon(
        origem,
        availableTemplates,
        useRandom,
        nex,
        generatedItemNames,
      );
      if (secondaryWeapon != null) {
        final item = _createItemFromTemplate(secondaryWeapon, characterId);
        items.add(item);
        generatedItemNames.add(secondaryWeapon.nome);
        weaponCount++;
      }
    }

    // 3. Arma terciária (apenas para NEX 55+, se permitido)
    if (weaponCount < maxWeapons && items.length < itemCount) {
      final tertiaryWeapon = _selectSecondaryWeapon(
        origem,
        availableTemplates,
        useRandom,
        nex,
        generatedItemNames,
      );
      if (tertiaryWeapon != null) {
        final item = _createItemFromTemplate(tertiaryWeapon, characterId);
        items.add(item);
        generatedItemNames.add(tertiaryWeapon.nome);
        weaponCount++;
      }
    }

    // 4. Armadura/Proteção (tier 2+)
    if (tier >= 2 && items.length < itemCount) {
      final armor = _selectArmor(availableTemplates, useRandom, generatedItemNames);
      if (armor != null) {
        items.add(_createItemFromTemplate(armor, characterId));
        generatedItemNames.add(armor.nome);
      }
    }

    // 5. Itens de cura (sempre 1-2)
    final healingCount = tier >= 4 ? 2 : 1;
    for (int i = 0; i < healingCount && items.length < itemCount; i++) {
      final healing = _selectHealing(availableTemplates, useRandom, generatedItemNames);
      if (healing != null) {
        items.add(_createItemFromTemplate(healing, characterId));
        generatedItemNames.add(healing.nome);
      }
    }

    // 6. Utilidades (preenche até o limite)
    while (items.length < itemCount) {
      final utility = _selectUtility(availableTemplates, useRandom, generatedItemNames);
      if (utility != null) {
        items.add(_createItemFromTemplate(utility, characterId));
        generatedItemNames.add(utility.nome);
      } else {
        break; // Sem mais utilidades disponíveis
      }
    }

    return items;
  }

  /// Gera kit para Especialista
  /// Foco: Versátil - 1 arma + Utilidades + Curas + Equipamentos
  List<Item> _generateEspecialistaKit(
    String characterId,
    Origem origem,
    int tier,
    int itemCount,
    List<ItemTemplate> availableTemplates,
    bool useRandom,
    int nex,
    Set<String> generatedItemNames,
  ) {
    final items = <Item>[];
    final maxWeapons = _getMaxWeaponsForNex(nex);
    int weaponCount = 0;

    // 1. Arma versátil (obrigatório)
    final weapon = _selectPrimaryWeapon(
      origem,
      availableTemplates,
      useRandom,
      nex,
      generatedItemNames,
      preferRanged: true, // Especialistas preferem armas de fogo
    );
    if (weapon != null) {
      items.add(_createItemFromTemplate(weapon, characterId));
      generatedItemNames.add(weapon.nome);
      weaponCount++;
    }

    // 2. Arma secundária opcional (se NEX permitir)
    if (weaponCount < maxWeapons && items.length < itemCount && tier >= 3) {
      final secondWeapon = _selectSecondaryWeapon(
        origem,
        availableTemplates,
        useRandom,
        nex,
        generatedItemNames,
      );
      if (secondWeapon != null) {
        items.add(_createItemFromTemplate(secondWeapon, characterId));
        generatedItemNames.add(secondWeapon.nome);
        weaponCount++;
      }
    }

    // 3. Itens de cura (sempre 1-2)
    final healingCount = tier >= 3 ? 2 : 1;
    for (int i = 0; i < healingCount && items.length < itemCount; i++) {
      final healing = _selectHealing(availableTemplates, useRandom, generatedItemNames);
      if (healing != null) {
        items.add(_createItemFromTemplate(healing, characterId));
        generatedItemNames.add(healing.nome);
      }
    }

    // 4. Equipamentos especializados (tier 2+)
    if (tier >= 2) {
      final equipmentCount = (itemCount * 0.3).ceil(); // 30% do kit
      for (int i = 0; i < equipmentCount && items.length < itemCount; i++) {
        final equipment = _selectEquipment(availableTemplates, useRandom, generatedItemNames);
        if (equipment != null) {
          items.add(_createItemFromTemplate(equipment, characterId));
          generatedItemNames.add(equipment.nome);
        }
      }
    }

    // 5. Utilidades (preenche resto)
    while (items.length < itemCount) {
      final utility = _selectUtility(availableTemplates, useRandom, generatedItemNames);
      if (utility != null) {
        items.add(_createItemFromTemplate(utility, characterId));
        generatedItemNames.add(utility.nome);
      } else {
        break;
      }
    }

    return items;
  }

  /// Gera kit para Ocultista
  /// Foco: Componentes rituais + Grimórios + Curas + Mínimo de armas
  List<Item> _generateOcultistaKit(
    String characterId,
    Origem origem,
    int tier,
    int itemCount,
    List<ItemTemplate> availableTemplates,
    bool useRandom,
    int nex,
    Set<String> generatedItemNames,
  ) {
    final items = <Item>[];

    // 1. Arma leve de defesa (opcional, tier 1-2 sempre tem, respeitando limite NEX)
    final maxWeapons = _getMaxWeaponsForNex(nex);
    if (maxWeapons > 0 && (tier <= 2 || (useRandom && _random.nextDouble() < 0.5))) {
      final weapon = _selectLightWeapon(availableTemplates, useRandom, generatedItemNames);
      if (weapon != null) {
        items.add(_createItemFromTemplate(weapon, characterId));
        generatedItemNames.add(weapon.nome);
      }
    }

    // 2. Itens de cura paranormais (sempre 2-3)
    final healingCount = tier >= 4 ? 3 : 2;
    for (int i = 0; i < healingCount && items.length < itemCount; i++) {
      final healing = _selectHealing(availableTemplates, useRandom, generatedItemNames);
      if (healing != null) {
        items.add(_createItemFromTemplate(healing, characterId));
        generatedItemNames.add(healing.nome);
      }
    }

    // 3. Utilidades paranormais/rituais
    while (items.length < itemCount) {
      final utility = _selectUtility(availableTemplates, useRandom, generatedItemNames);
      if (utility != null) {
        items.add(_createItemFromTemplate(utility, characterId));
        generatedItemNames.add(utility.nome);
      } else {
        break;
      }
    }

    return items;
  }

  // ========== SELETORES DE TEMPLATES ==========

  ItemTemplate? _selectPrimaryWeapon(
    Origem origem,
    List<ItemTemplate> availableTemplates,
    bool useRandom,
    int nex,
    Set<String> generatedItemNames, {
    bool preferRanged = false,
  }) {
    // Para NEX 65+, 20% de chance de incluir armas amaldiçoadas
    final includeCursed = nex >= 65 && useRandom && _random.nextDouble() < 0.2;

    var weapons = availableTemplates
        .where((t) => t.tipo == ItemType.arma)
        .where((t) => includeCursed || !t.isAmaldicoado)
        .where((t) => !generatedItemNames.contains(t.nome))
        .toList();

    if (weapons.isEmpty) return null;

    if (useRandom) {
      // Filtra por origem se possível
      final filtered = _filterWeaponsByOrigem(weapons, origem);
      final pool = filtered.isNotEmpty ? filtered : weapons;
      return pool[_random.nextInt(pool.length)];
    } else {
      // Seleciona arma padrão
      if (preferRanged) {
        return weapons.firstWhere(
          (w) => w.nome.contains('Glock') || w.nome.contains('Pistola'),
          orElse: () => weapons.first,
        );
      } else {
        return weapons.firstWhere(
          (w) => w.nome.contains('Faca') || w.nome.contains('Taco'),
          orElse: () => weapons.first,
        );
      }
    }
  }

  ItemTemplate? _selectSecondaryWeapon(
    Origem origem,
    List<ItemTemplate> availableTemplates,
    bool useRandom,
    int nex,
    Set<String> generatedItemNames,
  ) {
    // Para NEX 65+, 15% de chance de incluir armas amaldiçoadas
    final includeCursed = nex >= 65 && useRandom && _random.nextDouble() < 0.15;

    var weapons = availableTemplates
        .where((t) => t.tipo == ItemType.arma)
        .where((t) => includeCursed || !t.isAmaldicoado)
        .where((t) => !generatedItemNames.contains(t.nome))
        .toList();

    if (weapons.isEmpty) return null;

    if (useRandom) {
      return weapons[_random.nextInt(weapons.length)];
    } else {
      return weapons.first;
    }
  }

  ItemTemplate? _selectLightWeapon(
    List<ItemTemplate> availableTemplates,
    bool useRandom,
    Set<String> generatedItemNames,
  ) {
    final lightWeapons = availableTemplates
        .where((t) =>
            t.tipo == ItemType.arma &&
            !t.isAmaldicoado &&
            t.espacoUnitario <= 1)
        .where((t) => !generatedItemNames.contains(t.nome))
        .toList();

    if (lightWeapons.isEmpty) return null;

    if (useRandom) {
      return lightWeapons[_random.nextInt(lightWeapons.length)];
    } else {
      return lightWeapons.first;
    }
  }

  ItemTemplate? _selectArmor(
    List<ItemTemplate> availableTemplates,
    bool useRandom,
    Set<String> generatedItemNames,
  ) {
    final armors = availableTemplates
        .where((t) => t.defesaBonus != null && t.defesaBonus! > 0)
        .where((t) => !generatedItemNames.contains(t.nome))
        .toList();

    if (armors.isEmpty) return null;

    if (useRandom) {
      return armors[_random.nextInt(armors.length)];
    } else {
      return armors.first;
    }
  }

  ItemTemplate? _selectHealing(
    List<ItemTemplate> availableTemplates,
    bool useRandom,
    Set<String> generatedItemNames,
  ) {
    final healing = availableTemplates
        .where((t) => t.formulaCura != null && !t.isAmaldicoado)
        .where((t) => !generatedItemNames.contains(t.nome))
        .toList();

    if (healing.isEmpty) return null;

    if (useRandom) {
      return healing[_random.nextInt(healing.length)];
    } else {
      // Prioriza Kit Médico
      return healing.firstWhere(
        (h) => h.nome.contains('Kit') || h.nome.contains('Médico'),
        orElse: () => healing.first,
      );
    }
  }

  ItemTemplate? _selectUtility(
    List<ItemTemplate> availableTemplates,
    bool useRandom,
    Set<String> generatedItemNames,
  ) {
    // Utilities podem ser consumíveis ou equipamentos
    final utilities = availableTemplates
        .where((t) =>
            (t.tipo == ItemType.consumivel || t.tipo == ItemType.equipamento) &&
            !t.isAmaldicoado)
        .where((t) => !generatedItemNames.contains(t.nome))
        .toList();

    if (utilities.isEmpty) return null;

    if (useRandom) {
      return utilities[_random.nextInt(utilities.length)];
    } else {
      return utilities.first;
    }
  }

  ItemTemplate? _selectEquipment(
    List<ItemTemplate> availableTemplates,
    bool useRandom,
    Set<String> generatedItemNames,
  ) {
    final equipment = availableTemplates
        .where((t) => t.tipo == ItemType.equipamento && !t.isAmaldicoado)
        .where((t) => !generatedItemNames.contains(t.nome))
        .toList();

    if (equipment.isEmpty) return null;

    if (useRandom) {
      return equipment[_random.nextInt(equipment.length)];
    } else {
      return equipment.first;
    }
  }

  // ========== HELPERS ==========

  /// Filtra armas apropriadas para uma origem
  List<ItemTemplate> _filterWeaponsByOrigem(
    List<ItemTemplate> weapons,
    Origem origem,
  ) {
    // Origens militares/policiais preferem armas de fogo
    if ([
      Origem.militar,
      Origem.policial,
      Origem.agente,
      Origem.mercenario,
    ].contains(origem)) {
      final firearms = weapons
          .where((w) =>
              w.nome.contains('Pistola') ||
              w.nome.contains('Glock') ||
              w.nome.contains('Beretta') ||
              w.nome.contains('Rifle') ||
              w.nome.contains('Shotgun'))
          .toList();
      if (firearms.isNotEmpty) return firearms;
    }

    // Origens de combate corpo-a-corpo preferem armas brancas
    if ([Origem.lutador, Origem.atleta].contains(origem)) {
      final melee = weapons
          .where((w) =>
              w.nome.contains('Faca') ||
              w.nome.contains('Taco') ||
              w.nome.contains('Machado') ||
              w.nome.contains('Katana'))
          .toList();
      if (melee.isNotEmpty) return melee;
    }

    return weapons;
  }

  /// Verifica se a origem prefere armas de fogo
  bool _isRangedOrigem(Origem origem) {
    return [
      Origem.militar,
      Origem.policial,
      Origem.agente,
      Origem.mercenario,
      Origem.investigador,
    ].contains(origem);
  }

  /// Cria um Item a partir de um ItemTemplate
  Item _createItemFromTemplate(ItemTemplate template, String characterId) {
    return Item(
      id: _uuid.v4(),
      characterId: characterId,
      nome: template.nome,
      descricao: template.descricao,
      tipo: template.tipo,
      raridade: template.raridade,
      espaco: template.espacoUnitario,
      formulaDano: template.formulaDano,
      multiplicadorCritico: template.multiplicadorCritico,
      efeitoCritico: template.efeitoCritico,
      isAmaldicoado: template.isAmaldicoado,
      efeitoMaldicao: template.efeitoMaldicao,
      formulaCura: template.formulaCura,
      efeitoAdicional: template.efeitoAdicional,
      defesaBonus: template.defesaBonus,
      buffTipo: template.buffTipo,
      buffDescricao: template.buffDescricao,
      buffDuracao: template.buffDuracao,
      buffTurnos: template.buffTurnos,
      buffValor: template.buffValor,
    );
  }
}
