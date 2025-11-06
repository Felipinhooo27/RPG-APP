import 'dart:math';

class NameGenerator {
  static final Random _random = Random();

  // 50 primeiros nomes
  static final List<String> _firstNames = [
    'Alexandre', 'Bruno', 'Carlos', 'Daniel', 'Eduardo',
    'Fernando', 'Gabriel', 'Henrique', 'Igor', 'João',
    'Lucas', 'Marcos', 'Nicolas', 'Pedro', 'Rafael',
    'Rodrigo', 'Samuel', 'Thiago', 'Victor', 'William',
    'Ana', 'Beatriz', 'Carolina', 'Diana', 'Elena',
    'Fernanda', 'Gabriela', 'Helena', 'Isabela', 'Julia',
    'Laura', 'Mariana', 'Natalia', 'Olivia', 'Patricia',
    'Rafaela', 'Sofia', 'Tatiana', 'Valentina', 'Yasmin',
    'André', 'Caio', 'Diego', 'Enzo', 'Fábio',
    'Gustavo', 'Hugo', 'Ivan', 'Jorge', 'Leonardo',
  ];

  // 50 sobrenomes
  static final List<String> _lastNames = [
    'Silva', 'Santos', 'Oliveira', 'Souza', 'Rodrigues',
    'Ferreira', 'Alves', 'Pereira', 'Lima', 'Gomes',
    'Costa', 'Ribeiro', 'Martins', 'Carvalho', 'Rocha',
    'Almeida', 'Nascimento', 'Araújo', 'Melo', 'Barbosa',
    'Cardoso', 'Correia', 'Dias', 'Fernandes', 'Garcia',
    'Gonçalves', 'Lopes', 'Machado', 'Mendes', 'Miranda',
    'Monteiro', 'Moreira', 'Nunes', 'Pinto', 'Ramos',
    'Reis', 'Rezende', 'Rocha', 'Sales', 'Santana',
    'Sousa', 'Teixeira', 'Vieira', 'Castro', 'Freitas',
    'Moura', 'Campos', 'Barros', 'Pires', 'Cavalcanti',
  ];

  // Apelidos para soldados/mercenários
  static final List<String> _nicknames = [
    'Fantasma', 'Lobo', 'Falcão', 'Cobra', 'Águia',
    'Tigre', 'Urso', 'Leão', 'Raposa', 'Corvo',
    'Sombra', 'Relâmpago', 'Trovão', 'Tempestade', 'Furacão',
    'Dente', 'Garra', 'Lâmina', 'Ferro', 'Aço',
  ];

  // Títulos para líderes/chefes
  static final List<String> _titles = [
    'Dr.', 'Sr.', 'Sra.', 'Prof.', 'Cap.',
    'Ten.', 'Sgt.', 'Cel.', 'Gen.', 'Diretor',
  ];

  /// Gera um nome completo aleatório
  static String generateFullName({String? category}) {
    final firstName = _firstNames[_random.nextInt(_firstNames.length)];
    final lastName = _lastNames[_random.nextInt(_lastNames.length)];

    // Para soldados/mercenários, adicionar apelido
    if (category == 'Soldado' || category == 'Mercenário') {
      if (_random.nextDouble() < 0.5) {
        final nickname = _nicknames[_random.nextInt(_nicknames.length)];
        return '"$nickname" $firstName $lastName';
      }
    }

    // Para líderes/chefes, adicionar título
    if (category == 'Líder' || category == 'Chefe' || category == 'Profissional') {
      if (_random.nextDouble() < 0.6) {
        final title = _titles[_random.nextInt(_titles.length)];
        return '$title $firstName $lastName';
      }
    }

    // Para Deus, nome único e místico
    if (category == 'Deus') {
      final mysticalNames = [
        'Azathoth', 'Nyarlathotep', 'Cthulhu', 'Yog-Sothoth', 'Shub-Niggurath',
        'Hastur', 'Dagon', 'Nephren-Ka', 'Yig', 'Tsathoggua',
        'Ithaqua', 'Ghatanothoa', 'Zoth-Ommog', 'Atlach-Nacha', 'Bokrug',
      ];
      return mysticalNames[_random.nextInt(mysticalNames.length)];
    }

    return '$firstName $lastName';
  }

  /// Gera apenas primeiro nome
  static String generateFirstName() {
    return _firstNames[_random.nextInt(_firstNames.length)];
  }

  /// Gera apenas sobrenome
  static String generateLastName() {
    return _lastNames[_random.nextInt(_lastNames.length)];
  }

  /// Gera apelido
  static String generateNickname() {
    return _nicknames[_random.nextInt(_nicknames.length)];
  }
}
