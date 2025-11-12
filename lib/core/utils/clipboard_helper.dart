import 'dart:convert';
import 'package:flutter/services.dart';
import '../../models/character.dart';
import '../../models/item.dart';
import '../../models/power.dart';
import '../../models/shop.dart';
import '../database/item_repository.dart';
import '../database/power_repository.dart';

/// Helper para operações de clipboard (copiar/colar)
/// Usado para compartilhar personagens via WhatsApp
class ClipboardHelper {
  /// Copia texto para clipboard
  static Future<void> copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  /// Obtém texto do clipboard
  static Future<String?> getFromClipboard() async {
    final data = await Clipboard.getData('text/plain');
    return data?.text;
  }

  /// Exporta personagem para texto plano (fácil copiar/colar)
  static String exportCharacter(Character character) {
    final buffer = StringBuffer();

    buffer.writeln('═══ PERSONAGEM HEXATOMBE RPG ═══');
    buffer.writeln();
    buffer.writeln('INFORMAÇÕES BÁSICAS');
    buffer.writeln('━'.padRight(40, '━'));
    buffer.writeln('Nome: ${character.nome}');
    buffer.writeln('Classe: ${_getClasseNome(character.classe)}');
    buffer.writeln('Origem: ${_getOrigemNome(character.origem)}');
    if (character.trilha != null) buffer.writeln('Trilha: ${character.trilha}');
    if (character.patente != null) buffer.writeln('Patente: ${character.patente}');
    buffer.writeln('NEX: ${character.nex}%');
    buffer.writeln();

    buffer.writeln('ATRIBUTOS');
    buffer.writeln('━'.padRight(40, '━'));
    buffer.writeln('FOR: ${character.forca >= 0 ? '+' : ''}${character.forca}');
    buffer.writeln('AGI: ${character.agilidade >= 0 ? '+' : ''}${character.agilidade}');
    buffer.writeln('VIG: ${character.vigor >= 0 ? '+' : ''}${character.vigor}');
    buffer.writeln('INT: ${character.intelecto >= 0 ? '+' : ''}${character.intelecto}');
    buffer.writeln('PRE: ${character.presenca >= 0 ? '+' : ''}${character.presenca}');
    buffer.writeln();

    buffer.writeln('RECURSOS');
    buffer.writeln('━'.padRight(40, '━'));
    buffer.writeln('PV: ${character.pvAtual}/${character.pvMax}');
    buffer.writeln('PE: ${character.peAtual}/${character.peMax}');
    buffer.writeln('SAN: ${character.sanAtual}/${character.sanMax}');
    buffer.writeln('Créditos: \$${character.creditos}');
    buffer.writeln();

    buffer.writeln('COMBATE');
    buffer.writeln('━'.padRight(40, '━'));
    buffer.writeln('Defesa: ${character.defesa}');
    buffer.writeln('Bloqueio: ${character.bloqueio}');
    buffer.writeln('Deslocamento: ${character.deslocamento}m');
    buffer.writeln('Iniciativa: ${character.iniciativa >= 0 ? '+' : ''}${character.iniciativa}');
    buffer.writeln();

    if (character.periciasTreinadas.isNotEmpty) {
      buffer.writeln('PERÍCIAS TREINADAS (${character.periciasTreinadas.length})');
      buffer.writeln('━'.padRight(40, '━'));
      for (final pericia in character.periciasTreinadas) {
        buffer.writeln('• $pericia');
      }
      buffer.writeln();
    }

    if (character.inventarioIds.isNotEmpty) {
      buffer.writeln('INVENTÁRIO (${character.inventarioIds.length} itens)');
      buffer.writeln('━'.padRight(40, '━'));
      buffer.writeln('[IDs: ${character.inventarioIds.join(', ')}]');
      buffer.writeln();
    }

    if (character.poderesIds.isNotEmpty) {
      buffer.writeln('PODERES (${character.poderesIds.length})');
      buffer.writeln('━'.padRight(40, '━'));
      buffer.writeln('[IDs: ${character.poderesIds.join(', ')}]');
      buffer.writeln();
    }

    if (character.historia != null && character.historia!.isNotEmpty) {
      buffer.writeln('HISTÓRIA');
      buffer.writeln('━'.padRight(40, '━'));
      buffer.writeln(character.historia);
      buffer.writeln();
    }

    if (character.notas != null && character.notas!.isNotEmpty) {
      buffer.writeln('NOTAS');
      buffer.writeln('━'.padRight(40, '━'));
      buffer.writeln(character.notas);
      buffer.writeln();
    }

    buffer.writeln('═══════════════════════════════════════');
    buffer.writeln('Exportado em: ${DateTime.now().toString().split('.')[0]}');
    buffer.writeln('ID: ${character.id}');

    return buffer.toString();
  }

  static String _getClasseNome(CharacterClass classe) {
    switch (classe) {
      case CharacterClass.combatente:
        return 'Combatente';
      case CharacterClass.especialista:
        return 'Especialista';
      case CharacterClass.ocultista:
        return 'Ocultista';
    }
  }

  static String _getOrigemNome(Origem origem) {
    final nomes = {
      Origem.academico: 'Acadêmico',
      Origem.agente: 'Agente',
      Origem.artista: 'Artista',
      Origem.atleta: 'Atleta',
      Origem.chef: 'Chef',
      Origem.criminoso: 'Criminoso',
      Origem.cultista: 'Cultista',
      Origem.desgarrado: 'Desgarrado',
      Origem.engenheiro: 'Engenheiro',
      Origem.executivo: 'Executivo',
      Origem.investigador: 'Investigador',
      Origem.lutador: 'Lutador',
      Origem.mercenario: 'Mercenário',
      Origem.militar: 'Militar',
      Origem.operario: 'Operário',
      Origem.policial: 'Policial',
      Origem.religioso: 'Religioso',
      Origem.servidor: 'Servidor',
      Origem.trambiqueiro: 'Trambiqueiro',
      Origem.universitario: 'Universitário',
      Origem.veterano: 'Veterano',
      Origem.vitima: 'Vítima',
    };
    return nomes[origem] ?? origem.name;
  }

  /// Exporta um único personagem para JSON (formato de compartilhamento)
  /// VERSÃO 2.0: Inclui itens e poderes completos
  static Future<String> exportCharacterJson(Character character) async {
    // Busca itens e poderes reais do banco
    final itemRepository = ItemRepository();
    final powerRepository = PowerRepository();

    final items = await itemRepository.getByCharacterId(character.id);
    final powers = await powerRepository.getByCharacterId(character.id);

    final export = {
      'version': '2.0',  // Nova versão com itens e poderes
      'type': 'character',
      'exportDate': DateTime.now().toIso8601String(),
      'data': {
        'character': character.toJson(),
        'items': items.map((item) => item.toJson()).toList(),
        'powers': powers.map((power) => power.toJson()).toList(),
      },
    };

    return const JsonEncoder.withIndent('  ').convert(export);
  }

  /// Exporta uma única loja para JSON (formato de compartilhamento)
  /// VERSÃO 1.0: Inclui todos os itens da loja
  static String exportShopJson(Shop shop) {
    final export = ShopExport(shop: shop);
    return const JsonEncoder.withIndent('  ').convert(export.toJson());
  }

  /// Exporta múltiplos personagens para JSON
  static String exportCharacters(List<Character> characters) {
    final export = {
      'version': '1.0',
      'type': 'characters',
      'exportDate': DateTime.now().toIso8601String(),
      'count': characters.length,
      'data': characters.map((c) => c.toJson()).toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(export);
  }

  /// Importa personagem(ns) de JSON
  /// Suporta versão 1.0 (apenas personagem) e 2.0 (com itens e poderes)
  static ImportResult importFromJson(String jsonString) {
    try {
      final decoded = jsonDecode(jsonString);

      // Valida estrutura básica
      if (decoded is! Map<String, dynamic>) {
        return ImportResult.error('JSON inválido: não é um objeto');
      }

      final version = decoded['version'] as String?;
      final type = decoded['type'] as String?;

      if (type == 'character') {
        // Um único personagem
        final data = decoded['data'];
        if (data == null) {
          return ImportResult.error('Campo "data" não encontrado');
        }

        try {
          // Verifica se é versão 2.0 (com itens e poderes)
          if (version == '2.0' && data is Map<String, dynamic>) {
            // Versão 2.0: data contém character, items e powers
            final characterData = data['character'] as Map<String, dynamic>?;
            final itemsData = data['items'] as List?;
            final powersData = data['powers'] as List?;

            if (characterData == null) {
              return ImportResult.error('Campo "character" não encontrado na versão 2.0');
            }

            final character = Character.fromJson(characterData);

            // Parseia itens
            final items = itemsData
                ?.map((json) => Item.fromJson(json as Map<String, dynamic>))
                .toList() ?? [];

            // Parseia poderes
            final powers = powersData
                ?.map((json) => Power.fromJson(json as Map<String, dynamic>))
                .toList() ?? [];

            return ImportResult.success([character], items: items, powers: powers);
          } else {
            // Versão 1.0 (ou sem versão): data é o personagem direto
            final character = Character.fromJson(data as Map<String, dynamic>);
            return ImportResult.success([character]);
          }
        } catch (e) {
          return ImportResult.error('Erro ao parsear personagem: $e');
        }
      } else if (type == 'characters') {
        // Múltiplos personagens (versão 1.0 apenas)
        final data = decoded['data'];
        if (data == null) {
          return ImportResult.error('Campo "data" não encontrado');
        }

        if (data is! List) {
          return ImportResult.error('Campo "data" não é uma lista');
        }

        try {
          final characters = data
              .map((json) => Character.fromJson(json as Map<String, dynamic>))
              .toList();
          return ImportResult.success(characters);
        } catch (e) {
          return ImportResult.error('Erro ao parsear personagens: $e');
        }
      } else {
        return ImportResult.error(
            'Tipo desconhecido: $type (esperado "character" ou "characters")');
      }
    } catch (e) {
      return ImportResult.error('Erro ao decodificar JSON: $e');
    }
  }

  /// Importa de clipboard diretamente
  static Future<ImportResult> importFromClipboard() async {
    final text = await getFromClipboard();
    if (text == null || text.isEmpty) {
      return ImportResult.error('Clipboard vazio');
    }

    return importFromJson(text);
  }
}

/// Resultado de importação
class ImportResult {
  final bool success;
  final List<Character>? characters;
  final List<Item>? items;
  final List<Power>? powers;
  final String? errorMessage;

  ImportResult.success(this.characters, {this.items, this.powers})
      : success = true,
        errorMessage = null;

  ImportResult.error(this.errorMessage)
      : success = false,
        characters = null,
        items = null,
        powers = null;
}
