import 'dart:async';
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';
import '../models/character.dart';
import '../models/note.dart';

class LocalDatabaseService {
  static Database? _database;
  final _uuid = const Uuid();

  // StreamController para simular o comportamento de streams do Firestore
  final _charactersController = StreamController<List<Character>>.broadcast();
  final _notesController = StreamController<List<Note>>.broadcast();

  // Singleton
  static final LocalDatabaseService _instance = LocalDatabaseService._internal();
  factory LocalDatabaseService() => _instance;
  LocalDatabaseService._internal();

  // Inicializar banco de dados
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'ordem_paranormal.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE characters (
            id TEXT PRIMARY KEY,
            data TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE notes (
            id TEXT PRIMARY KEY,
            data TEXT NOT NULL
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE notes (
              id TEXT PRIMARY KEY,
              data TEXT NOT NULL
            )
          ''');
        }
      },
    );
  }

  // CRUD - Create
  Future<void> createCharacter(Character character) async {
    try {
      final db = await database;
      final newId = character.id.isEmpty ? _uuid.v4() : character.id;
      final characterWithId = character.copyWith(id: newId);

      await db.insert(
        'characters',
        {
          'id': newId,
          'data': jsonEncode(characterWithId.toMap()),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      _notifyListeners();
    } catch (e) {
      throw Exception('Erro ao criar personagem: $e');
    }
  }

  // CRUD - Read (Todos os personagens) - Stream
  Stream<List<Character>> getAllCharacters() {
    // Retorna o stream e atualiza os dados
    _notifyListeners();
    return _charactersController.stream;
  }

  // CRUD - Read (Personagens do usuário) - Stream
  Stream<List<Character>> getCharactersByUser(String userId) {
    return _charactersController.stream.map((characters) {
      return characters.where((c) => c.createdBy == userId).toList();
    });
  }

  // CRUD - Read (Todos os personagens) - Future
  Future<List<Character>> getAllCharactersList() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('characters');

      return maps.map((map) {
        final data = jsonDecode(map['data'] as String) as Map<String, dynamic>;
        return Character.fromMap(data);
      }).toList();
    } catch (e) {
      throw Exception('Erro ao buscar personagens: $e');
    }
  }

  // CRUD - Read (Um personagem específico)
  Future<Character?> getCharacter(String id) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'characters',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        final data = jsonDecode(maps.first['data'] as String) as Map<String, dynamic>;
        return Character.fromMap(data);
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao buscar personagem: $e');
    }
  }

  // CRUD - Update
  Future<void> updateCharacter(Character character) async {
    try {
      final db = await database;
      await db.update(
        'characters',
        {
          'id': character.id,
          'data': jsonEncode(character.toMap()),
        },
        where: 'id = ?',
        whereArgs: [character.id],
      );

      _notifyListeners();
    } catch (e) {
      throw Exception('Erro ao atualizar personagem: $e');
    }
  }

  // CRUD - Delete
  Future<void> deleteCharacter(String id) async {
    try {
      final db = await database;
      await db.delete(
        'characters',
        where: 'id = ?',
        whereArgs: [id],
      );

      _notifyListeners();
    } catch (e) {
      throw Exception('Erro ao excluir personagem: $e');
    }
  }

  // Atualizar apenas os status (PV, PE, PS, Créditos)
  Future<void> updateCharacterStatus({
    required String characterId,
    int? pvAtual,
    int? peAtual,
    int? psAtual,
    int? creditos,
  }) async {
    try {
      final character = await getCharacter(characterId);
      if (character == null) return;

      final updatedCharacter = character.copyWith(
        pvAtual: pvAtual ?? character.pvAtual,
        peAtual: peAtual ?? character.peAtual,
        psAtual: psAtual ?? character.psAtual,
        creditos: creditos ?? character.creditos,
      );

      await updateCharacter(updatedCharacter);
    } catch (e) {
      throw Exception('Erro ao atualizar status do personagem: $e');
    }
  }

  // Importar múltiplos personagens
  Future<void> importCharacters(List<Character> characters, String userId) async {
    try {
      final db = await database;
      final batch = db.batch();

      for (var character in characters) {
        final newId = _uuid.v4();
        final characterWithNewId = character.copyWith(
          id: newId,
          createdBy: userId,
        );

        batch.insert(
          'characters',
          {
            'id': newId,
            'data': jsonEncode(characterWithNewId.toMap()),
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await batch.commit(noResult: true);
      _notifyListeners();
    } catch (e) {
      throw Exception('Erro ao importar personagens: $e');
    }
  }

  // Notificar listeners (simular comportamento de stream)
  Future<void> _notifyListeners() async {
    final characters = await getAllCharactersList();
    _charactersController.add(characters);
  }

  // Limpar banco de dados (útil para testes)
  Future<void> clearDatabase() async {
    try {
      final db = await database;
      await db.delete('characters');
      _notifyListeners();
    } catch (e) {
      throw Exception('Erro ao limpar banco de dados: $e');
    }
  }

  // ========== NOTAS ==========

  // CRUD - Create Note
  Future<void> createNote(Note note) async {
    try {
      final db = await database;
      final newId = note.id.isEmpty ? _uuid.v4() : note.id;
      final noteWithId = note.copyWith(id: newId);

      await db.insert(
        'notes',
        {
          'id': newId,
          'data': jsonEncode(noteWithId.toMap()),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      _notifyNotesListeners();
    } catch (e) {
      throw Exception('Erro ao criar nota: $e');
    }
  }

  // CRUD - Read All Notes - Stream
  Stream<List<Note>> getAllNotes() {
    _notifyNotesListeners();
    return _notesController.stream;
  }

  // CRUD - Read All Notes - Future
  Future<List<Note>> getAllNotesList() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('notes');

      return maps.map((map) {
        final data = jsonDecode(map['data'] as String) as Map<String, dynamic>;
        return Note.fromMap(data);
      }).toList();
    } catch (e) {
      throw Exception('Erro ao buscar notas: $e');
    }
  }

  // CRUD - Read One Note
  Future<Note?> getNote(String id) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'notes',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        final data = jsonDecode(maps.first['data'] as String) as Map<String, dynamic>;
        return Note.fromMap(data);
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao buscar nota: $e');
    }
  }

  // CRUD - Update Note
  Future<void> updateNote(Note note) async {
    try {
      final db = await database;
      final updatedNote = note.copyWith(
        dataModificacao: DateTime.now(),
      );

      await db.update(
        'notes',
        {
          'id': updatedNote.id,
          'data': jsonEncode(updatedNote.toMap()),
        },
        where: 'id = ?',
        whereArgs: [updatedNote.id],
      );

      _notifyNotesListeners();
    } catch (e) {
      throw Exception('Erro ao atualizar nota: $e');
    }
  }

  // CRUD - Delete Note
  Future<void> deleteNote(String id) async {
    try {
      final db = await database;
      await db.delete(
        'notes',
        where: 'id = ?',
        whereArgs: [id],
      );

      _notifyNotesListeners();
    } catch (e) {
      throw Exception('Erro ao excluir nota: $e');
    }
  }

  // Notificar listeners de notas
  Future<void> _notifyNotesListeners() async {
    final notes = await getAllNotesList();
    _notesController.add(notes);
  }

  // Fechar banco de dados
  Future<void> close() async {
    final db = await database;
    await db.close();
    await _charactersController.close();
    await _notesController.close();
  }
}
