import 'dart:math';
import 'package:uuid/uuid.dart';
import '../../models/shop.dart';
import '../../models/shop_generator_config.dart';
import 'item_templates.dart';

/// Gerador randômico de lojas
class RandomShopGenerator {
  final Random _random = Random();
  final Uuid _uuid = const Uuid();

  /// Gera uma loja completa baseada na configuração
  Shop generateShop(ShopGeneratorConfig config) {
    if (!config.isValid) {
      throw ArgumentError('Configuração inválida: nenhum item será gerado');
    }

    // Gera informações básicas da loja
    final String nome = config.nomePersonalizado ?? _generateShopName(config.tipoLoja);
    final String descricao = config.descricaoPersonalizada ?? _generateShopDescription(config.tipoLoja);
    final String? dono = config.donoPersonalizado ?? ShopOwnerNameGenerator.generate();

    // Gera itens
    final List<ShopItem> itens = _generateItems(config);

    return Shop(
      id: _uuid.v4(),
      nome: nome,
      descricao: descricao,
      tipo: config.tipoLoja,
      nomeDono: dono,
      itens: itens,
    );
  }

  /// Gera todos os itens da loja
  List<ShopItem> _generateItems(ShopGeneratorConfig config) {
    final List<ShopItem> itens = <ShopItem>[];

    // Armas comuns
    if (config.armasComuns > 0) {
      itens.addAll(_generateItemsFromTemplates(
        List.from(ItemTemplateDatabase.getArmasComuns()),
        config.armasComuns,
        config,
      ));
    }

    // Armas amaldiçoadas
    if (config.armasAmaldicoadas > 0) {
      itens.addAll(_generateItemsFromTemplates(
        List.from(ItemTemplateDatabase.getArmasAmaldicoadas()),
        config.armasAmaldicoadas,
        config,
      ));
    }

    // Curas
    if (config.curas > 0) {
      itens.addAll(_generateItemsFromTemplates(
        List.from(ItemTemplateDatabase.getCurasComuns()),
        config.curas,
        config,
      ));
    }

    // Curas amaldiçoadas
    if (config.curasAmaldicoadas > 0) {
      itens.addAll(_generateItemsFromTemplates(
        List.from(ItemTemplateDatabase.getCurasAmaldicoadas()),
        config.curasAmaldicoadas,
        config,
      ));
    }

    // Comidas
    if (config.comidas > 0) {
      itens.addAll(_generateItemsFromTemplates(
        List.from(ItemTemplateDatabase.comidas),
        config.comidas,
        config,
      ));
    }

    // Utilidades
    if (config.utilidades > 0) {
      itens.addAll(_generateItemsFromTemplates(
        List.from(ItemTemplateDatabase.utilidades),
        config.utilidades,
        config,
      ));
    }

    // Munições
    if (config.municoes > 0) {
      itens.addAll(_generateItemsFromTemplates(
        List.from(ItemTemplateDatabase.municoes),
        config.municoes,
        config,
      ));
    }

    // Equipamentos
    if (config.equipamentos > 0) {
      itens.addAll(_generateItemsFromTemplates(
        List.from(ItemTemplateDatabase.equipamentos),
        config.equipamentos,
        config,
      ));
    }

    // Embaralha para misturar os tipos (cria nova lista mutável)
    final itensEmbaralhados = List<ShopItem>.from(itens);
    itensEmbaralhados.shuffle(_random);

    return itensEmbaralhados;
  }

  /// Gera itens de uma lista de templates (sem duplicatas quando possível)
  List<ShopItem> _generateItemsFromTemplates(
    List<ItemTemplate> templates,
    int quantidade,
    ShopGeneratorConfig config,
  ) {
    final List<ShopItem> itens = [];

    // Filtra templates baseado nos critérios
    final templatesValidos = templates.where((template) {
      // Verifica raridade
      final raridadeOk = template.raridade.index >= config.raridadeMinima.index &&
          template.raridade.index <= config.raridadeMaxima.index;

      // Verifica patente
      final patenteOk = template.patenteMinima >= config.patenteMinima &&
          template.patenteMinima <= config.patenteMaxima;

      return raridadeOk && patenteOk;
    }).toList();

    if (templatesValidos.isEmpty) {
      // Se não há templates válidos, retorna vazio
      return itens;
    }

    // Embaralha templates para variedade
    templatesValidos.shuffle(_random);

    // Se a quantidade solicitada é menor ou igual aos templates disponíveis,
    // não haverá duplicatas
    if (quantidade <= templatesValidos.length) {
      // Pega apenas os primeiros N templates (todos diferentes)
      for (int i = 0; i < quantidade; i++) {
        final item = _createShopItemFromTemplate(templatesValidos[i]);
        itens.add(item);
      }
    } else {
      // Se a quantidade é maior que templates disponíveis,
      // primeiro adiciona todos os templates únicos
      for (final template in templatesValidos) {
        final item = _createShopItemFromTemplate(template);
        itens.add(item);
      }

      // Depois preenche o restante com itens aleatórios (pode haver duplicatas)
      final restante = quantidade - templatesValidos.length;
      for (int i = 0; i < restante; i++) {
        final template = templatesValidos[_random.nextInt(templatesValidos.length)];
        final item = _createShopItemFromTemplate(template);
        itens.add(item);
      }
    }

    return itens;
  }

  /// Cria um ShopItem a partir de um template
  ShopItem _createShopItemFromTemplate(ItemTemplate template) {
    // Calcula preço final (base * multiplicador de raridade)
    final precoFinal = (template.precoBase * template.raridade.precoMultiplicador).round();

    return ShopItem(
      id: _uuid.v4(),
      nome: template.nome,
      descricao: template.descricao,
      tipo: template.tipo,
      preco: precoFinal,
      espacoUnitario: template.espacoUnitario,
      patenteMinima: template.patenteMinima,
      formulaDano: template.formulaDano,
      multiplicadorCritico: template.multiplicadorCritico,
      efeitoCritico: template.efeitoCritico,
      isAmaldicoado: template.isAmaldicoado,
      efeitoMaldicao: template.efeitoMaldicao,
      formulaCura: template.formulaCura,
      efeitoAdicional: template.efeitoAdicional,
      raridade: template.raridade,
      buffTipo: template.buffTipo,
      buffDescricao: template.buffDescricao,
      buffDuracao: template.buffDuracao,
      buffTurnos: template.buffTurnos,
      buffValor: template.buffValor,
    );
  }

  /// Gera nome de loja baseado no tipo
  String _generateShopName(ShopType tipo) {
    switch (tipo) {
      case ShopType.taberna:
        return _pickRandom([
          'Taberna do Viajante',
          'O Refúgio',
          'Taverna da Meia-Noite',
          'O Cálice Dourado',
          'Estalagem do Descanso',
          'Bar do Fim do Mundo',
          'O Último Gole',
          'Taberna da Encruzilhada',
        ]);

      case ShopType.armaria:
        return _pickRandom([
          'Armaria Tática',
          'Arsenal do Caçador',
          'Defesa Total',
          'Armaria Fortaleza',
          'O Gatilho',
          'Munições & Cia',
          'Armaria Segurança Máxima',
          'Arsenal Tático',
          'A Mira Certa',
          'Defesa Armada',
        ]);

      case ShopType.farmacia:
        return _pickRandom([
          'Farmácia da Cura',
          'Drogaria Saúde Total',
          'Farmácia Vida Nova',
          'Remédios & Poções',
          'Farmácia do Bem-Estar',
          'A Cura',
          'Farmácia Esperança',
          'Drogaria Salvação',
        ]);

      case ShopType.mercador:
        return _pickRandom([
          'Mercado do João',
          'Empório Tudo Tem',
          'Mercadinho da Esquina',
          'Armazém Geral',
          'Loja de Conveniência 24h',
          'Mercado Central',
          'O Sortimento',
          'Empório Variedades',
        ]);

      case ShopType.forjaria:
        return _pickRandom([
          'Forja do Destino',
          'Armaduras & Escudos',
          'A Bigorna',
          'Forjaria Mestre Ferreiro',
          'O Martelo',
          'Forja da Ordem',
          'Equipamentos Táticos Elite',
          'A Armadura Perfeita',
        ]);
    }
  }

  /// Gera descrição de loja baseada no tipo
  String _generateShopDescription(ShopType tipo) {
    switch (tipo) {
      case ShopType.taberna:
        return _pickRandom([
          'Um estabelecimento acolhedor que oferece comida, bebida e descanso para viajantes.',
          'Taberna movimentada frequentada por aventureiros e comerciantes.',
          'Local de encontro popular onde histórias são compartilhadas ao redor da lareira.',
          'Estabelecimento rústico com boa comida e bebidas de qualidade.',
        ]);

      case ShopType.armaria:
        return _pickRandom([
          'Loja especializada em armamentos e equipamento tático de qualidade.',
          'Arsenal completo para profissionais de segurança e agentes de campo.',
          'Fornecedor confiável de armas, munições e equipamentos táticos.',
          'Armaria com amplo estoque de armas modernas e clássicas.',
        ]);

      case ShopType.farmacia:
        return _pickRandom([
          'Estabelecimento médico com ampla variedade de medicamentos e suprimentos de saúde.',
          'Farmácia bem equipada com produtos farmacêuticos e kits de primeiros socorros.',
          'Local especializado em tratamentos e curas para diversas condições.',
          'Drogaria completa com medicamentos controlados e de venda livre.',
        ]);

      case ShopType.mercador:
        return _pickRandom([
          'Loja de conveniência com grande variedade de produtos do dia a dia.',
          'Mercado bem sortido que vende de tudo um pouco.',
          'Empório tradicional com produtos variados e bom atendimento.',
          'Loja versátil que atende todas as necessidades básicas.',
        ]);

      case ShopType.forjaria:
        return _pickRandom([
          'Oficina especializada em armaduras, escudos e equipamentos de proteção.',
          'Forjaria que produz equipamentos de alta qualidade para combatentes.',
          'Estabelecimento que fornece proteção e equipamentos táticos premium.',
          'Forja tradicional com equipamentos modernos e tecnologia de ponta.',
        ]);
    }
  }

  /// Seleciona elemento aleatório de uma lista
  T _pickRandom<T>(List<T> lista) {
    return lista[_random.nextInt(lista.length)];
  }

  /// Gera múltiplas lojas de uma vez
  List<Shop> generateMultipleShops(ShopGeneratorConfig config, int quantidade) {
    final List<Shop> lojas = [];
    for (int i = 0; i < quantidade; i++) {
      lojas.add(generateShop(config));
    }
    return lojas;
  }

  /// Gera uma loja com preset específico
  Shop generateFromPreset(String presetName) {
    ShopGeneratorConfig config;

    switch (presetName.toLowerCase()) {
      case 'loja_bairro':
        config = ShopGeneratorConfig.presetLojaDeBairro();
        break;
      case 'armaria_basica':
        config = ShopGeneratorConfig.presetArmariaBasica();
        break;
      case 'quartel_ordem':
        config = ShopGeneratorConfig.presetQuartelDaOrdem();
        break;
      case 'farmacia':
        config = ShopGeneratorConfig.presetFarmacia();
        break;
      case 'enfermaria_ordem':
        config = ShopGeneratorConfig.presetEnfermariaDaOrdem();
        break;
      case 'mercado_completo':
        config = ShopGeneratorConfig.presetMercadoCompleto();
        break;
      case 'armaria_tatica':
        config = ShopGeneratorConfig.presetArmariaTatica();
        break;
      default:
        throw ArgumentError('Preset desconhecido: $presetName');
    }

    return generateShop(config);
  }
}
