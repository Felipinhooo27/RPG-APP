/// Modelo de Nota
/// Notas do mestre sobre sessões, NPCs, locais e plots
class Note {
  final String id;
  final String titulo;
  final String conteudo;
  final DateTime dataCriacao;
  final DateTime dataModificacao;
  final NoteCategory categoria;
  final String? tags; // Tags separadas por vírgula para busca

  Note({
    required this.id,
    required this.titulo,
    required this.conteudo,
    required this.dataCriacao,
    required this.dataModificacao,
    required this.categoria,
    this.tags,
  });

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] ?? '',
      titulo: map['titulo'] ?? '',
      conteudo: map['conteudo'] ?? '',
      dataCriacao: DateTime.parse(
        map['dataCriacao'] ?? DateTime.now().toIso8601String(),
      ),
      dataModificacao: DateTime.parse(
        map['dataModificacao'] ?? DateTime.now().toIso8601String(),
      ),
      categoria: NoteCategoryExtension.fromString(
        map['categoria'] ?? 'outro',
      ),
      tags: map['tags'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'conteudo': conteudo,
      'dataCriacao': dataCriacao.toIso8601String(),
      'dataModificacao': dataModificacao.toIso8601String(),
      'categoria': categoria.value,
      'tags': tags,
    };
  }

  Note copyWith({
    String? id,
    String? titulo,
    String? conteudo,
    DateTime? dataCriacao,
    DateTime? dataModificacao,
    NoteCategory? categoria,
    String? tags,
  }) {
    return Note(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      conteudo: conteudo ?? this.conteudo,
      dataCriacao: dataCriacao ?? this.dataCriacao,
      dataModificacao: dataModificacao ?? this.dataModificacao,
      categoria: categoria ?? this.categoria,
      tags: tags ?? this.tags,
    );
  }
}

/// Categorias de notas
enum NoteCategory {
  sessao,
  npc,
  local,
  plot,
  ritual,
  outro,
}

extension NoteCategoryExtension on NoteCategory {
  String get value {
    switch (this) {
      case NoteCategory.sessao:
        return 'sessao';
      case NoteCategory.npc:
        return 'npc';
      case NoteCategory.local:
        return 'local';
      case NoteCategory.plot:
        return 'plot';
      case NoteCategory.ritual:
        return 'ritual';
      case NoteCategory.outro:
        return 'outro';
    }
  }

  String get label {
    switch (this) {
      case NoteCategory.sessao:
        return 'Sessão';
      case NoteCategory.npc:
        return 'NPC';
      case NoteCategory.local:
        return 'Local';
      case NoteCategory.plot:
        return 'Plot';
      case NoteCategory.ritual:
        return 'Ritual';
      case NoteCategory.outro:
        return 'Outro';
    }
  }

  static NoteCategory fromString(String value) {
    switch (value.toLowerCase()) {
      case 'sessao':
        return NoteCategory.sessao;
      case 'npc':
        return NoteCategory.npc;
      case 'local':
        return NoteCategory.local;
      case 'plot':
        return NoteCategory.plot;
      case 'ritual':
        return NoteCategory.ritual;
      default:
        return NoteCategory.outro;
    }
  }
}
