import 'dart:math';
import 'package:uuid/uuid.dart';
import '../models/shop_item.dart';

class ShopGenerator {
  final Random _random = Random();
  final Uuid _uuid = const Uuid();

  // Gerador de lojas automáticas
  Shop generateShop({
    required String tipo,
    required String createdBy,
    int itemCount = 20,
  }) {
    final shopName = _getShopName(tipo);
    final items = <ShopItem>[];

    switch (tipo) {
      case 'Armeiro':
        items.addAll(_generateWeapons(itemCount));
        break;
      case 'Curas':
        items.addAll(_generateHeals(itemCount));
        break;
      case 'Materiais':
        items.addAll(_generateMaterials(itemCount));
        break;
      case 'Munições':
        items.addAll(_generateAmmunition(itemCount));
        break;
      case 'Geral':
        items.addAll(_generateMixedItems(itemCount));
        break;
    }

    return Shop(
      id: _uuid.v4(),
      nome: shopName,
      tipo: tipo,
      descricao: _getShopDescription(tipo),
      items: items,
      createdAt: DateTime.now(),
      createdBy: createdBy,
    );
  }

  String _getShopName(String tipo) {
    final names = {
      'Armeiro': [
        'Arsenal do Combatente',
        'Forja das Sombras',
        'Armas e Cia',
        'Lâminas Mortais'
      ],
      'Curas': [
        'Farmácia Paranormal',
        'Cruz Verde do Outro Lado',
        'Remédios Ocultos',
        'Poções e Antídotos'
      ],
      'Materiais': [
        'Ferragens do Construtor',
        'Suprimentos Táticos',
        'Material de Campo',
        'Loja do Sobrevivente'
      ],
      'Munições': [
        'Munições Especiais',
        'Balística Avançada',
        'Projéteis Paranormais',
        'Arsenal de Munição'
      ],
      'Geral': [
        'Loja Geral',
        'Mercado Central',
        'Empório do Agente',
        'Bazar Paranormal'
      ],
    };

    final list = names[tipo] ?? ['Loja'];
    return list[_random.nextInt(list.length)];
  }

  String _getShopDescription(String tipo) {
    final descriptions = {
      'Armeiro':
          'Especializada em armas de todos os tipos para combate paranormal',
      'Curas': 'Itens de cura e recuperação para agentes em campo',
      'Materiais': 'Materiais de construção e equipamentos táticos',
      'Munições': 'Munições especiais e projéteis paranormais',
      'Geral': 'Variedade de itens para todas as necessidades',
    };

    return descriptions[tipo] ?? 'Loja de itens diversos';
  }

  // Gerador de armas
  List<ShopItem> _generateWeapons(int count) {
    final items = <ShopItem>[];
    final weaponTypes = [
      {'nome': 'Pistola 9mm', 'dano': '1d8', 'preco': 500, 'patente': 0},
      {'nome': 'Revólver .38', 'dano': '1d8+1', 'preco': 600, 'patente': 0},
      {'nome': 'Espingarda', 'dano': '2d6', 'preco': 1200, 'patente': 5},
      {'nome': 'Rifle de Assalto', 'dano': '2d8', 'preco': 2500, 'patente': 10},
      {'nome': 'Faca de Combate', 'dano': '1d6', 'preco': 200, 'patente': 0},
      {'nome': 'Machado', 'dano': '1d10', 'preco': 400, 'patente': 0},
      {'nome': 'Katana', 'dano': '1d10+2', 'preco': 1500, 'patente': 5},
      {'nome': 'Escopeta', 'dano': '3d6', 'preco': 1800, 'patente': 8},
    ];

    for (int i = 0; i < count; i++) {
      final weapon =
          weaponTypes[_random.nextInt(weaponTypes.length)] as Map<String, dynamic>;
      final isAmaldicoado = _random.nextDouble() < 0.1; // 10% chance

      items.add(ShopItem(
        id: _uuid.v4(),
        nome: isAmaldicoado
            ? '${weapon['nome']} Amaldiçoada'
            : weapon['nome'] as String,
        descricao: isAmaldicoado
            ? 'Arma poderosa mas com maldição. Use com cuidado.'
            : 'Arma padrão de combate',
        tipo: 'Arma',
        preco: (weapon['preco'] as int) * (isAmaldicoado ? 2 : 1),
        patenteMinima: weapon['patente'] as int,
        espaco: 2,
        iconCode: '0xe3ad', // Icons.gavel
        formulaDano: weapon['dano'] as String,
        isAmaldicoado: isAmaldicoado,
        efeitoEspecial: isAmaldicoado
            ? 'Ao errar, perde ${_random.nextInt(5) + 1}d4 de sanidade'
            : null,
      ));
    }

    return items;
  }

  // Gerador de curas
  List<ShopItem> _generateHeals(int count) {
    final items = <ShopItem>[];
    final healTypes = [
      {
        'nome': 'Kit Médico Básico',
        'cura': '1d6+1',
        'preco': 100,
        'patente': 0
      },
      {
        'nome': 'Kit Médico Avançado',
        'cura': '2d6+2',
        'preco': 300,
        'patente': 3
      },
      {'nome': 'Primeiros Socorros', 'cura': '1d4', 'preco': 50, 'patente': 0},
      {
        'nome': 'Antídoto Paranormal',
        'cura': '2d4+3',
        'preco': 500,
        'patente': 5
      },
      {'nome': 'Poção de Vida', 'cura': '3d6', 'preco': 800, 'patente': 8},
      {
        'nome': 'Serum de Recuperação',
        'cura': '2d8+4',
        'preco': 1000,
        'patente': 10
      },
    ];

    for (int i = 0; i < count; i++) {
      final heal =
          healTypes[_random.nextInt(healTypes.length)] as Map<String, dynamic>;

      items.add(ShopItem(
        id: _uuid.v4(),
        nome: heal['nome'] as String,
        descricao: 'Item de cura e recuperação',
        tipo: 'Cura',
        preco: heal['preco'] as int,
        patenteMinima: heal['patente'] as int,
        espaco: 1,
        iconCode: '0xe3f9', // Icons.healing
        formulaCura: heal['cura'] as String,
        efeitoEspecial: 'Restaura PV instantaneamente',
      ));
    }

    return items;
  }

  // Gerador de materiais
  List<ShopItem> _generateMaterials(int count) {
    final items = <ShopItem>[];
    final materialTypes = [
      {'nome': 'Lanterna Tática', 'preco': 50, 'patente': 0},
      {'nome': 'Bateria', 'preco': 20, 'patente': 0},
      {'nome': 'Algemas', 'preco': 100, 'patente': 0},
      {'nome': 'Cadeado Reforçado', 'preco': 80, 'patente': 0},
      {'nome': 'Kit de Lockpick', 'preco': 300, 'patente': 5},
      {'nome': 'Cordas (10m)', 'preco': 40, 'patente': 0},
      {'nome': 'Rádio Comunicador', 'preco': 500, 'patente': 3},
      {'nome': 'Colete à Prova de Balas', 'preco': 2000, 'patente': 8},
    ];

    for (int i = 0; i < count; i++) {
      final material = materialTypes[_random.nextInt(materialTypes.length)]
          as Map<String, dynamic>;

      items.add(ShopItem(
        id: _uuid.v4(),
        nome: material['nome'] as String,
        descricao: 'Material útil para operações de campo',
        tipo: 'Material',
        preco: material['preco'] as int,
        patenteMinima: material['patente'] as int,
        espaco: 1,
        iconCode: '0xe14d', // Icons.build
        quantidade: _random.nextInt(5) + 1,
      ));
    }

    return items;
  }

  // Gerador de munições
  List<ShopItem> _generateAmmunition(int count) {
    final items = <ShopItem>[];
    final ammoTypes = [
      {
        'nome': 'Munição Padrão',
        'tipo': 'padrão',
        'preco': 50,
        'patente': 0
      },
      {
        'nome': 'Munição de Prata',
        'tipo': 'prata',
        'preco': 200,
        'patente': 3
      },
      {
        'nome': 'Munição Explosiva',
        'tipo': 'explosiva',
        'preco': 500,
        'patente': 8
      },
      {
        'nome': 'Munição Perfurante',
        'tipo': 'perfurante',
        'preco': 300,
        'patente': 5
      },
      {
        'nome': 'Munição Anti-Zumbi',
        'tipo': 'anti-zumbi',
        'preco': 400,
        'patente': 7
      },
      {'nome': 'Flechas', 'tipo': 'flecha', 'preco': 30, 'patente': 0},
      {
        'nome': 'Virotes de Besta',
        'tipo': 'virote',
        'preco': 40,
        'patente': 0
      },
    ];

    for (int i = 0; i < count; i++) {
      final ammo =
          ammoTypes[_random.nextInt(ammoTypes.length)] as Map<String, dynamic>;

      items.add(ShopItem(
        id: _uuid.v4(),
        nome: ammo['nome'] as String,
        descricao: 'Munição especial para combate',
        tipo: 'Munição',
        preco: ammo['preco'] as int,
        patenteMinima: ammo['patente'] as int,
        espaco: 1,
        iconCode: '0xe86f', // Icons.settings_input_component
        tipoMunicao: ammo['tipo'] as String,
        quantidade: _random.nextInt(20) + 10,
        efeitoEspecial: _getAmmoEffect(ammo['tipo'] as String),
      ));
    }

    return items;
  }

  String _getAmmoEffect(String tipo) {
    final effects = {
      'prata': 'Dano extra contra criaturas vulneráveis a prata',
      'explosiva': '+1d6 de dano explosivo',
      'perfurante': 'Ignora 5 pontos de armadura',
      'anti-zumbi': '+2d4 de dano contra mortos-vivos',
      'flecha': 'Silenciosa',
      'virote': 'Perfurante e silenciosa',
      'padrão': 'Munição comum',
    };

    return effects[tipo] ?? 'Efeito especial';
  }

  // Gerador de itens mistos
  List<ShopItem> _generateMixedItems(int count) {
    final items = <ShopItem>[];

    // Mix de todos os tipos
    final weaponCount = (count * 0.3).round();
    final healCount = (count * 0.25).round();
    final materialCount = (count * 0.25).round();
    final ammoCount = count - weaponCount - healCount - materialCount;

    items.addAll(_generateWeapons(weaponCount));
    items.addAll(_generateHeals(healCount));
    items.addAll(_generateMaterials(materialCount));
    items.addAll(_generateAmmunition(ammoCount));

    // Embaralhar
    items.shuffle(_random);

    return items;
  }

  // Gerar itens aleatórios para NPCs baseado no nível
  List<ShopItem> generateNPCItems(String npcType, int patente) {
    final items = <ShopItem>[];

    switch (npcType.toLowerCase()) {
      case 'civil':
        items.addAll(_generateCivilItems());
        break;
      case 'soldado':
        items.addAll(_generateSoldierItems(patente));
        break;
      case 'agente':
        items.addAll(_generateAgentItems(patente));
        break;
      default:
        items.addAll(_generateCommonItems());
    }

    return items;
  }

  List<ShopItem> _generateCivilItems() {
    return [
      ShopItem(
        id: _uuid.v4(),
        nome: 'Carteira',
        descricao: 'Carteira com documentos e dinheiro',
        tipo: 'Equipamento',
        preco: 50,
        patenteMinima: 0,
        espaco: 1,
        iconCode: '0xe8f6', // Icons.wallet
      ),
      ShopItem(
        id: _uuid.v4(),
        nome: 'Celular',
        descricao: 'Smartphone comum',
        tipo: 'Equipamento',
        preco: 500,
        patenteMinima: 0,
        espaco: 1,
        iconCode: '0xe32c', // Icons.phone_android
      ),
      ShopItem(
        id: _uuid.v4(),
        nome: 'Foto de Família',
        descricao: 'Lembrança pessoal',
        tipo: 'Equipamento',
        preco: 0,
        patenteMinima: 0,
        espaco: 0,
        iconCode: '0xe410', // Icons.photo
      ),
    ];
  }

  List<ShopItem> _generateSoldierItems(int patente) {
    final items = <ShopItem>[
      ShopItem(
        id: _uuid.v4(),
        nome: 'Pistola de Serviço',
        descricao: 'Arma padrão militar',
        tipo: 'Arma',
        preco: 800,
        patenteMinima: 0,
        espaco: 2,
        iconCode: '0xe3ad',
        formulaDano: '1d8+1',
      ),
      ShopItem(
        id: _uuid.v4(),
        nome: 'Munição Padrão',
        descricao: 'Caixa de munição',
        tipo: 'Munição',
        preco: 100,
        patenteMinima: 0,
        espaco: 1,
        iconCode: '0xe86f',
        quantidade: 30,
      ),
    ];

    // Chance de ter armas especiais em patentes mais altas
    if (patente >= 10 && _random.nextDouble() < 0.3) {
      items.add(ShopItem(
        id: _uuid.v4(),
        nome: 'Arma Amaldiçoada',
        descricao: 'Arma poderosa de origem desconhecida',
        tipo: 'Arma',
        preco: 5000,
        patenteMinima: 10,
        espaco: 2,
        iconCode: '0xe3ad',
        formulaDano: '2d10+2',
        isAmaldicoado: true,
        efeitoEspecial: 'Ao errar, perde 1d8 de sanidade',
      ));
    }

    return items;
  }

  List<ShopItem> _generateAgentItems(int patente) {
    final items = <ShopItem>[
      ShopItem(
        id: _uuid.v4(),
        nome: 'Kit de Investigação',
        descricao: 'Ferramentas para investigação',
        tipo: 'Equipamento',
        preco: 300,
        patenteMinima: 0,
        espaco: 2,
        iconCode: '0xe8b4', // Icons.search
      ),
      ShopItem(
        id: _uuid.v4(),
        nome: 'Pistola Paranormal',
        descricao: 'Arma modificada para combate paranormal',
        tipo: 'Arma',
        preco: 1500,
        patenteMinima: 5,
        espaco: 2,
        iconCode: '0xe3ad',
        formulaDano: '1d10+2',
      ),
    ];

    if (patente >= 15) {
      items.add(ShopItem(
        id: _uuid.v4(),
        nome: 'Artefato Paranormal',
        descricao: 'Item de poder paranormal',
        tipo: 'Equipamento',
        preco: 10000,
        patenteMinima: 15,
        espaco: 1,
        iconCode: '0xe51d', // Icons.auto_fix_high
        efeitoEspecial: 'Concede habilidades especiais',
      ));
    }

    return items;
  }

  List<ShopItem> _generateCommonItems() {
    return [
      ShopItem(
        id: _uuid.v4(),
        nome: 'Item Comum',
        descricao: 'Item sem valor especial',
        tipo: 'Equipamento',
        preco: 10,
        patenteMinima: 0,
        espaco: 1,
        iconCode: '0xe332', // Icons.shopping_bag
      ),
    ];
  }
}
