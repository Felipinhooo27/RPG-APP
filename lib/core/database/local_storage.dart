import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Camada base de persistência local usando SharedPreferences
///
/// Responsável por salvar e carregar dados em formato JSON
class LocalStorage {
  static final LocalStorage _instance = LocalStorage._internal();
  factory LocalStorage() => _instance;
  LocalStorage._internal();

  SharedPreferences? _prefs;

  /// Inicializa o SharedPreferences
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Garante que está inicializado
  Future<SharedPreferences> get prefs async {
    if (_prefs == null) {
      await init();
    }
    return _prefs!;
  }

  // ==================== PERSONAGENS ====================

  /// Salva lista de personagens
  Future<bool> saveCharacters(List<Map<String, dynamic>> characters) async {
    final p = await prefs;
    final jsonString = jsonEncode(characters);
    return await p.setString('characters', jsonString);
  }

  /// Carrega lista de personagens
  Future<List<Map<String, dynamic>>> loadCharacters() async {
    final p = await prefs;
    final jsonString = p.getString('characters');
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  // ==================== ITENS ====================

  /// Salva lista de itens
  Future<bool> saveItems(List<Map<String, dynamic>> items) async {
    final p = await prefs;
    final jsonString = jsonEncode(items);
    return await p.setString('items', jsonString);
  }

  /// Carrega lista de itens
  Future<List<Map<String, dynamic>>> loadItems() async {
    final p = await prefs;
    final jsonString = p.getString('items');
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  // ==================== PERÍCIAS ====================

  /// Salva lista de perícias
  Future<bool> saveSkills(List<Map<String, dynamic>> skills) async {
    final p = await prefs;
    final jsonString = jsonEncode(skills);
    return await p.setString('skills', jsonString);
  }

  /// Carrega lista de perícias
  Future<List<Map<String, dynamic>>> loadSkills() async {
    final p = await prefs;
    final jsonString = p.getString('skills');
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  // ==================== PODERES ====================

  /// Salva lista de poderes
  Future<bool> savePowers(List<Map<String, dynamic>> powers) async {
    final p = await prefs;
    final jsonString = jsonEncode(powers);
    return await p.setString('powers', jsonString);
  }

  /// Carrega lista de poderes
  Future<List<Map<String, dynamic>>> loadPowers() async {
    final p = await prefs;
    final jsonString = p.getString('powers');
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  // ==================== LOJAS ====================

  /// Salva lista de lojas
  Future<bool> saveShops(List<Map<String, dynamic>> shops) async {
    final p = await prefs;
    final jsonString = jsonEncode(shops);
    return await p.setString('shops', jsonString);
  }

  /// Carrega lista de lojas
  Future<List<Map<String, dynamic>>> loadShops() async {
    final p = await prefs;
    final jsonString = p.getString('shops');
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  // ==================== NOTAS ====================

  /// Salva lista de notas
  Future<bool> saveNotes(List<Map<String, dynamic>> notes) async {
    final p = await prefs;
    final jsonString = jsonEncode(notes);
    return await p.setString('notes', jsonString);
  }

  /// Carrega lista de notas
  Future<List<Map<String, dynamic>>> loadNotes() async {
    final p = await prefs;
    final jsonString = p.getString('notes');
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  // ==================== CONFIGURAÇÕES ====================

  /// Salva ID do personagem selecionado
  Future<bool> saveSelectedCharacterId(String characterId) async {
    final p = await prefs;
    return await p.setString('selected_character_id', characterId);
  }

  /// Carrega ID do personagem selecionado
  Future<String?> loadSelectedCharacterId() async {
    final p = await prefs;
    return p.getString('selected_character_id');
  }

  /// Limpa ID do personagem selecionado
  Future<bool> clearSelectedCharacterId() async {
    final p = await prefs;
    return await p.remove('selected_character_id');
  }

  // ==================== UTILIDADES ====================

  /// Limpa todos os dados
  Future<bool> clearAll() async {
    final p = await prefs;
    return await p.clear();
  }

  /// Remove uma chave específica
  Future<bool> remove(String key) async {
    final p = await prefs;
    return await p.remove(key);
  }

  /// Verifica se tem dados salvos
  Future<bool> hasData() async {
    final characters = await loadCharacters();
    return characters.isNotEmpty;
  }
}
