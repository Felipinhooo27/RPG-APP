import 'dart:convert';
import 'package:flutter/services.dart';
import '../../models/item.dart';

/// Helper para export/import de itens de inventário
class ItemExportHelper {
  /// Copia texto para clipboard
  static Future<void> copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  /// Obtém texto do clipboard
  static Future<String?> getFromClipboard() async {
    final data = await Clipboard.getData('text/plain');
    return data?.text;
  }

  /// Exporta item para texto plano (fácil copiar/colar)
  static String exportItem(Item item) {
    final buffer = StringBuffer();

    buffer.writeln('═══ ITEM - HEXATOMBE RPG ═══');
    buffer.writeln();
    buffer.writeln('Nome: ${item.nome}');
    buffer.writeln('Tipo: ${_getTipoNome(item.tipo)}');
    if (item.categoria != null) buffer.writeln('Categoria: ${item.categoria}');
    buffer.writeln('Quantidade: ${item.quantidade}');
    buffer.writeln('Peso (un): ${item.espaco}kg');
    buffer.writeln('Peso Total: ${item.espacoTotal}kg');
    buffer.writeln();

    if (item.descricao.isNotEmpty) {
      buffer.writeln('DESCRIÇÃO');
      buffer.writeln('━'.padRight(40, '━'));
      buffer.writeln(item.descricao);
      buffer.writeln();
    }

    // Campos específicos por tipo
    if (item.isArma) {
      buffer.writeln('ARMA');
      buffer.writeln('━'.padRight(40, '━'));
      if (item.formulaDano != null) buffer.writeln('Dano: ${item.formulaDano}');
      if (item.multiplicadorCritico != null) buffer.writeln('Crítico: x${item.multiplicadorCritico}');
      if (item.efeitoCritico != null) buffer.writeln('Efeito Crítico: ${item.efeitoCritico}');
      if (item.isAmaldicoado) {
        buffer.writeln('⚠ AMALDIÇOADO');
        if (item.efeitoMaldicao != null) buffer.writeln('Maldição: ${item.efeitoMaldicao}');
      }
      buffer.writeln();
    }

    if (item.isCura) {
      buffer.writeln('CURA');
      buffer.writeln('━'.padRight(40, '━'));
      if (item.formulaCura != null) buffer.writeln('Cura: ${item.formulaCura}');
      if (item.efeitoAdicional != null) buffer.writeln('Efeito: ${item.efeitoAdicional}');
      buffer.writeln();
    }

    if (item.defesaBonus != null && item.defesaBonus! > 0) {
      buffer.writeln('EQUIPAMENTO');
      buffer.writeln('━'.padRight(40, '━'));
      buffer.writeln('Bônus de Defesa: +${item.defesaBonus}');
      buffer.writeln();
    }

    buffer.writeln('═══════════════════════════════════════');
    buffer.writeln('Exportado em: ${DateTime.now().toString().split('.')[0]}');
    buffer.writeln('ID: ${item.id}');

    return buffer.toString();
  }

  static String _getTipoNome(ItemType tipo) {
    switch (tipo) {
      case ItemType.arma:
        return 'Arma';
      case ItemType.cura:
        return 'Cura';
      case ItemType.municao:
        return 'Munição';
      case ItemType.equipamento:
        return 'Equipamento';
      case ItemType.consumivel:
        return 'Consumível';
    }
  }

  /// Exporta múltiplos itens para JSON
  static String exportItems(List<Item> items) {
    final export = {
      'version': '1.0',
      'type': 'items',
      'exportDate': DateTime.now().toIso8601String(),
      'count': items.length,
      'data': items.map((i) => i.toJson()).toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(export);
  }

  /// Exporta um único item para JSON
  static String exportSingleItem(Item item) {
    final export = {
      'version': '1.0',
      'type': 'item',
      'exportDate': DateTime.now().toIso8601String(),
      'data': item.toJson(),
    };

    return const JsonEncoder.withIndent('  ').convert(export);
  }

  /// Exporta inventário completo (todos os itens de um personagem)
  static String exportInventory(List<Item> items, {String? characterName}) {
    final export = {
      'version': '1.0',
      'type': 'inventory',
      'exportDate': DateTime.now().toIso8601String(),
      'characterName': characterName,
      'totalItems': items.length,
      'totalWeight': items.fold<int>(0, (sum, item) => sum + item.espacoTotal),
      'data': items.map((i) => i.toJson()).toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(export);
  }

  /// Importa item(ns) de JSON
  static ItemImportResult importFromJson(String jsonString) {
    try {
      final decoded = jsonDecode(jsonString);

      // Valida estrutura básica
      if (decoded is! Map<String, dynamic>) {
        return ItemImportResult.error('JSON inválido: não é um objeto');
      }

      final type = decoded['type'] as String?;

      if (type == 'item') {
        // Um único item
        final data = decoded['data'];
        if (data == null) {
          return ItemImportResult.error('Campo "data" não encontrado');
        }

        try {
          final item = Item.fromJson(data as Map<String, dynamic>);
          return ItemImportResult.success([item]);
        } catch (e) {
          return ItemImportResult.error('Erro ao parsear item: $e');
        }
      } else if (type == 'items' || type == 'inventory') {
        // Múltiplos itens
        final data = decoded['data'];
        if (data == null) {
          return ItemImportResult.error('Campo "data" não encontrado');
        }

        if (data is! List) {
          return ItemImportResult.error('Campo "data" não é uma lista');
        }

        try {
          final items = data
              .map((json) => Item.fromJson(json as Map<String, dynamic>))
              .toList();
          return ItemImportResult.success(items);
        } catch (e) {
          return ItemImportResult.error('Erro ao parsear itens: $e');
        }
      } else {
        return ItemImportResult.error(
            'Tipo desconhecido: $type (esperado "item", "items" ou "inventory")');
      }
    } catch (e) {
      return ItemImportResult.error('Erro ao decodificar JSON: $e');
    }
  }

  /// Importa de clipboard diretamente
  static Future<ItemImportResult> importFromClipboard() async {
    final text = await getFromClipboard();
    if (text == null || text.isEmpty) {
      return ItemImportResult.error('Clipboard vazio');
    }

    return importFromJson(text);
  }

  /// Exporta item para texto e copia para clipboard
  static Future<void> exportAndCopyItem(Item item, {bool asJson = false}) async {
    final text = asJson ? exportSingleItem(item) : exportItem(item);
    await copyToClipboard(text);
  }

  /// Exporta lista de itens para JSON e copia para clipboard
  static Future<void> exportAndCopyItems(List<Item> items) async {
    final text = exportItems(items);
    await copyToClipboard(text);
  }

  /// Exporta inventário completo para JSON e copia para clipboard
  static Future<void> exportAndCopyInventory(
    List<Item> items, {
    String? characterName,
  }) async {
    final text = exportInventory(items, characterName: characterName);
    await copyToClipboard(text);
  }
}

/// Resultado de importação de itens
class ItemImportResult {
  final bool success;
  final List<Item>? items;
  final String? errorMessage;

  ItemImportResult.success(this.items)
      : success = true,
        errorMessage = null;

  ItemImportResult.error(this.errorMessage)
      : success = false,
        items = null;
}
