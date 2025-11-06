class Note {
  final String id;
  final String titulo;
  final String conteudo;
  final DateTime dataCriacao;
  final DateTime dataModificacao;
  final String categoria; // Sessão, NPC, Local, Plot, Outro

  Note({
    required this.id,
    required this.titulo,
    required this.conteudo,
    required this.dataCriacao,
    required this.dataModificacao,
    required this.categoria,
  });

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] ?? '',
      titulo: map['titulo'] ?? '',
      conteudo: map['conteudo'] ?? '',
      dataCriacao: DateTime.parse(map['dataCriacao'] ?? DateTime.now().toIso8601String()),
      dataModificacao: DateTime.parse(map['dataModificacao'] ?? DateTime.now().toIso8601String()),
      categoria: map['categoria'] ?? 'Outro',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'conteudo': conteudo,
      'dataCriacao': dataCriacao.toIso8601String(),
      'dataModificacao': dataModificacao.toIso8601String(),
      'categoria': categoria,
    };
  }

  Note copyWith({
    String? id,
    String? titulo,
    String? conteudo,
    DateTime? dataCriacao,
    DateTime? dataModificacao,
    String? categoria,
  }) {
    return Note(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      conteudo: conteudo ?? this.conteudo,
      dataCriacao: dataCriacao ?? this.dataCriacao,
      dataModificacao: dataModificacao ?? this.dataModificacao,
      categoria: categoria ?? this.categoria,
    );
  }
}
