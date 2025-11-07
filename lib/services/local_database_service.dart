import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/character.dart';
import '../models/note.dart';
import '../models/skill.dart';

/// Serviço de armazenamento local usando SharedPreferences e JSON
/// Substitui o antigo sistema SQL para armazenamento mais simples
class LocalDatabaseService {
  static SharedPreferences? _prefs;
  final _uuid = const Uuid();

  // Storage keys
  static const String _charactersKey = 'characters_json';
  static const String _notesKey = 'notes_json';
  static const String _shopsKey = 'shops_json';

  // StreamController para reatividade
  final _charactersController = StreamController<List<Character>>.broadcast();
  final _notesController = StreamController<List<Note>>.broadcast();

  // Singleton
  static final LocalDatabaseService _instance = LocalDatabaseService._internal();
  factory LocalDatabaseService() => _instance;
  LocalDatabaseService._internal();

  /// Inicializar SharedPreferences
  Future<SharedPreferences> get prefs async {
    if (_prefs != null) return _prefs!;
    _prefs = await SharedPreferences.getInstance();
    return _prefs!;
  }

  // ==================== CHARACTERS ====================

  Future<void> createCharacter(Character character) async {
    final sp = await prefs;
    final characters = await getAllCharactersList();

    // Adicionar novo personagem
    characters.add(character);

    // Salvar lista atualizada
    final jsonList = characters.map((c) => c.toJson()).toList();
    await sp.setString(_charactersKey, jsonEncode(jsonList));

    // Notificar listeners
    await _notifyListeners();
  }

  Stream<List<Character>> getAllCharacters() {
    Future.microtask(() => _notifyListeners());
    return _charactersController.stream;
  }

  Stream<List<Character>> getCharactersByUser(String userId) {
    Future.microtask(() => _notifyListeners());
    return _charactersController.stream.map((characters) {
      return characters.where((c) => c.createdBy == userId).toList();
    });
  }

  Future<List<Character>> getAllCharactersList() async {
    final sp = await prefs;
    final jsonString = sp.getString(_charactersKey);

    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => Character.fromJson(json)).toList();
    } catch (e) {
      print('Erro ao carregar personagens: $e');
      return [];
    }
  }

  Future<Character?> getCharacter(String id) async {
    final characters = await getAllCharactersList();
    try {
      return characters.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> updateCharacter(Character character) async {
    final sp = await prefs;
    final characters = await getAllCharactersList();

    // Encontrar e atualizar personagem
    final index = characters.indexWhere((c) => c.id == character.id);
    if (index != -1) {
      characters[index] = character;

      // Salvar lista atualizada
      final jsonList = characters.map((c) => c.toJson()).toList();
      await sp.setString(_charactersKey, jsonEncode(jsonList));

      // Notificar listeners
      await _notifyListeners();
    }
  }

  Future<void> deleteCharacter(String id) async {
    final sp = await prefs;
    final characters = await getAllCharactersList();

    // Remover personagem
    characters.removeWhere((c) => c.id == id);

    // Salvar lista atualizada
    final jsonList = characters.map((c) => c.toJson()).toList();
    await sp.setString(_charactersKey, jsonEncode(jsonList));

    // Notificar listeners
    await _notifyListeners();
  }

  Future<void> updateCharacterStatus({
    required String characterId,
    int? pvAtual,
    int? peAtual,
    int? psAtual,
    int? creditos,
  }) async {
    final character = await getCharacter(characterId);
    if (character == null) return;

    final updatedCharacter = character.copyWith(
      pvAtual: pvAtual ?? character.pvAtual,
      peAtual: peAtual ?? character.peAtual,
      psAtual: psAtual ?? character.psAtual,
      creditos: creditos ?? character.creditos,
    );

    await updateCharacter(updatedCharacter);
  }

  Future<void> updateCharacterSkills({
    required String characterId,
    required Map<String, Skill> pericias,
  }) async {
    final character = await getCharacter(characterId);
    if (character == null) return;

    final updatedCharacter = character.copyWith(pericias: pericias);
    await updateCharacter(updatedCharacter);
  }

  Future<void> updateSkillLevel({
    required String characterId,
    required String skillName,
    required SkillLevel level,
  }) async {
    final character = await getCharacter(characterId);
    if (character == null) return;

    final updatedSkills = Map<String, Skill>.from(character.pericias);
    final currentSkill = updatedSkills[skillName];

    if (currentSkill != null) {
      updatedSkills[skillName] = currentSkill.copyWith(level: level);
      await updateCharacterSkills(
        characterId: characterId,
        pericias: updatedSkills,
      );
    }
  }

  Future<void> importCharacters(List<Character> characters, String userId) async {
    final sp = await prefs;
    final existingCharacters = await getAllCharactersList();

    // Adicionar personagens importados
    for (var character in characters) {
      // Gerar novo ID para evitar conflitos
      final newCharacter = character.copyWith(
        id: _uuid.v4(),
        createdBy: userId,
      );
      existingCharacters.add(newCharacter);
    }

    // Salvar lista atualizada
    final jsonList = existingCharacters.map((c) => c.toJson()).toList();
    await sp.setString(_charactersKey, jsonEncode(jsonList));

    // Notificar listeners
    await _notifyListeners();
  }

  // ==================== EXPORT/IMPORT INDIVIDUAL CHARACTER ====================

  /// Exportar personagem individual para JSON
  Future<String> exportCharacter(String characterId) async {
    final character = await getCharacter(characterId);
    if (character == null) throw Exception('Personagem não encontrado');

    final exportData = {
      'version': '1.0',
      'character': character.toJson(),
      'exportDate': DateTime.now().toIso8601String(),
    };

    return const JsonEncoder.withIndent('  ').convert(exportData);
  }

  /// Importar personagem individual de JSON
  Future<Character> importCharacter(String jsonString, String newCreatedBy) async {
    final data = jsonDecode(jsonString);

    final characterData = data['character'] as Map<String, dynamic>;
    final character = Character.fromJson(characterData);

    // Criar novo personagem com novo ID e createdBy
    final newCharacter = character.copyWith(
      id: _uuid.v4(),
      createdBy: newCreatedBy,
    );

    await createCharacter(newCharacter);

    return newCharacter;
  }

  Future<void> _notifyListeners() async {
    final characters = await getAllCharactersList();
    _charactersController.add(characters);

    final notes = await getAllNotesList();
    _notesController.add(notes);
  }

  Future<void> clearDatabase() async {
    final sp = await prefs;
    await sp.remove(_charactersKey);
    await sp.remove(_notesKey);
    await sp.remove(_shopsKey);
    await _notifyListeners();
  }

  // ==================== NOTES ====================

  Future<void> createNote(Note note) async {
    final sp = await prefs;
    final notes = await getAllNotesList();

    // Adicionar nova nota
    notes.add(note);

    // Salvar lista atualizada
    final jsonList = notes.map((n) => n.toMap()).toList();
    await sp.setString(_notesKey, jsonEncode(jsonList));

    // Notificar listeners
    await _notifyListeners();
  }

  Stream<List<Note>> getAllNotes() {
    Future.microtask(() => _notifyListeners());
    return _notesController.stream;
  }

  Future<List<Note>> getAllNotesList() async {
    final sp = await prefs;
    final jsonString = sp.getString(_notesKey);

    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => Note.fromMap(json)).toList();
    } catch (e) {
      print('Erro ao carregar notas: $e');
      return [];
    }
  }

  Future<Note?> getNote(String id) async {
    final notes = await getAllNotesList();
    try {
      return notes.firstWhere((n) => n.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> updateNote(Note note) async {
    final sp = await prefs;
    final notes = await getAllNotesList();

    // Encontrar e atualizar nota
    final index = notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      notes[index] = note;

      // Salvar lista atualizada
      final jsonList = notes.map((n) => n.toMap()).toList();
      await sp.setString(_notesKey, jsonEncode(jsonList));

      // Notificar listeners
      await _notifyListeners();
    }
  }

  Future<void> deleteNote(String id) async {
    final sp = await prefs;
    final notes = await getAllNotesList();

    // Remover nota
    notes.removeWhere((n) => n.id == id);

    // Salvar lista atualizada
    final jsonList = notes.map((n) => n.toMap()).toList();
    await sp.setString(_notesKey, jsonEncode(jsonList));

    // Notificar listeners
    await _notifyListeners();
  }

  // ==================== SHOPS ====================
  // Métodos para shops são usados pelo ShopService

  Future<String?> getShopsJson() async {
    final sp = await prefs;
    return sp.getString(_shopsKey);
  }

  Future<void> setShopsJson(String jsonString) async {
    final sp = await prefs;
    await sp.setString(_shopsKey, jsonString);
  }

  // ==================== DISPOSE ====================

  void dispose() {
    _charactersController.close();
    _notesController.close();
  }
}
