import '../../models/note.dart';
import 'local_storage.dart';

/// Repository para gerenciamento de Notas da Campanha
/// Responsável por CRUD de notas usando LocalStorage
class NoteRepository {
  final LocalStorage _storage = LocalStorage();

  /// Criar nova nota
  Future<Note> create(Note note) async {
    final notes = await getAll();
    notes.add(note);
    await _saveAll(notes);
    return note;
  }

  /// Buscar nota por ID
  Future<Note?> getById(String id) async {
    final notes = await getAll();
    try {
      return notes.firstWhere((note) => note.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Buscar todas as notas
  Future<List<Note>> getAll() async {
    final notesData = await _storage.loadNotes();
    return notesData.map((data) => Note.fromMap(data)).toList();
  }

  /// Buscar notas por categoria
  Future<List<Note>> getByCategory(NoteCategory category) async {
    final allNotes = await getAll();
    return allNotes.where((note) => note.categoria == category).toList();
  }

  /// Buscar notas por tag
  Future<List<Note>> getByTag(String tag) async {
    final allNotes = await getAll();
    return allNotes.where((note) {
      if (note.tags == null) return false;
      return note.tags!.toLowerCase().contains(tag.toLowerCase());
    }).toList();
  }

  /// Buscar notas por título ou conteúdo (pesquisa)
  Future<List<Note>> search(String query) async {
    final allNotes = await getAll();
    final lowerQuery = query.toLowerCase();

    return allNotes.where((note) {
      final matchTitle = note.titulo.toLowerCase().contains(lowerQuery);
      final matchContent = note.conteudo.toLowerCase().contains(lowerQuery);
      final matchTags = note.tags?.toLowerCase().contains(lowerQuery) ?? false;

      return matchTitle || matchContent || matchTags;
    }).toList();
  }

  /// Atualizar nota existente
  Future<Note> update(Note note) async {
    final notes = await getAll();
    final index = notes.indexWhere((n) => n.id == note.id);

    if (index == -1) {
      throw Exception('Nota não encontrada: ${note.id}');
    }

    // Atualiza dataModificacao automaticamente
    final updatedNote = note.copyWith(
      dataModificacao: DateTime.now(),
    );

    notes[index] = updatedNote;
    await _saveAll(notes);
    return updatedNote;
  }

  /// Excluir nota
  Future<void> delete(String id) async {
    final notes = await getAll();
    notes.removeWhere((note) => note.id == id);
    await _saveAll(notes);
  }

  /// Obter notas ordenadas por data de modificação (mais recentes primeiro)
  Future<List<Note>> getMostRecent({int limit = 10}) async {
    final notes = await getAll();
    notes.sort((a, b) => b.dataModificacao.compareTo(a.dataModificacao));
    return notes.take(limit).toList();
  }

  /// Obter contagem total de notas
  Future<int> getCount() async {
    final notes = await getAll();
    return notes.length;
  }

  /// Obter contagem de notas por categoria
  Future<Map<NoteCategory, int>> getCountByCategory() async {
    final notes = await getAll();
    final counts = <NoteCategory, int>{};

    for (final category in NoteCategory.values) {
      counts[category] = notes.where((n) => n.categoria == category).length;
    }

    return counts;
  }

  /// Verificar se existe nota com ID
  Future<bool> exists(String id) async {
    final note = await getById(id);
    return note != null;
  }

  /// Criar múltiplas notas de uma vez (batch)
  Future<void> createBatch(List<Note> notes) async {
    final existing = await getAll();
    existing.addAll(notes);
    await _saveAll(existing);
  }

  /// Excluir todas as notas (limpar)
  Future<void> deleteAll() async {
    await _saveAll([]);
  }

  /// Exportar todas as notas como lista de mapas
  Future<List<Map<String, dynamic>>> exportAll() async {
    final notes = await getAll();
    return notes.map((note) => note.toMap()).toList();
  }

  /// Importar notas de lista de mapas
  Future<void> importAll(List<Map<String, dynamic>> notesData) async {
    final notes = notesData.map((data) => Note.fromMap(data)).toList();
    await _saveAll(notes);
  }

  // ============================================================================
  // MÉTODOS PRIVADOS
  // ============================================================================

  Future<void> _saveAll(List<Note> notes) async {
    final notesData = notes.map((note) => note.toMap()).toList();
    await _storage.saveNotes(notesData);
  }
}
