import 'dart:math';

class NameGenerator {
  static final Random _random = Random();

  // ==================== NOMES MASCULINOS (100) ====================
  static final List<String> _maleNames = [
    // Brasileiros clássicos
    'Alexandre', 'Bruno', 'Carlos', 'Daniel', 'Eduardo',
    'Fernando', 'Gabriel', 'Henrique', 'Igor', 'João',
    'Lucas', 'Marcos', 'Nicolas', 'Pedro', 'Rafael',
    'Rodrigo', 'Samuel', 'Thiago', 'Victor', 'William',
    'André', 'Caio', 'Diego', 'Enzo', 'Fábio',
    'Gustavo', 'Hugo', 'Ivan', 'Jorge', 'Leonardo',
    // Internacionais
    'Aaron', 'Benjamin', 'Christopher', 'David', 'Ethan',
    'Felix', 'George', 'Henry', 'Isaac', 'Jack',
    'Kevin', 'Liam', 'Matthew', 'Nathan', 'Oscar',
    'Patrick', 'Quinn', 'Ryan', 'Sebastian', 'Thomas',
    // Heróicos/Fortes
    'Arthur', 'Atlas', 'Dante', 'Draven', 'Ezra',
    'Finn', 'Gideon', 'Hunter', 'Jax', 'Kane',
    'Knox', 'Magnus', 'Orion', 'Phoenix', 'Ronan',
    'Silas', 'Titan', 'Vander', 'Wade', 'Zane',
    // Místicos
    'Alaric', 'Caspian', 'Dorian', 'Elias', 'Fabian',
    'Galen', 'Hadrian', 'Ithiel', 'Jasper', 'Kael',
    'Lucan', 'Malakai', 'Nolan', 'Oberyn', 'Percival',
    'Quinlan', 'Raphael', 'Soren', 'Theron', 'Ulric',
    'Vladimir', 'Weston', 'Xavier', 'York', 'Zephyr',
    'Aldric', 'Balthazar', 'Cedric', 'Desmond', 'Edmund',
  ];

  // ==================== NOMES FEMININOS (100) ====================
  static final List<String> _femaleNames = [
    // Brasileiras clássicas
    'Ana', 'Beatriz', 'Carolina', 'Diana', 'Elena',
    'Fernanda', 'Gabriela', 'Helena', 'Isabela', 'Julia',
    'Laura', 'Mariana', 'Natalia', 'Olivia', 'Patricia',
    'Rafaela', 'Sofia', 'Tatiana', 'Valentina', 'Yasmin',
    'Amanda', 'Bruna', 'Camila', 'Daniela', 'Eduarda',
    'Fabiana', 'Giovanna', 'Heloisa', 'Ingrid', 'Juliana',
    // Internacionais
    'Alice', 'Bella', 'Charlotte', 'Daisy', 'Emma',
    'Fiona', 'Grace', 'Hannah', 'Ivy', 'Jade',
    'Kate', 'Lily', 'Maya', 'Nina', 'Opal',
    'Paige', 'Quinn', 'Rose', 'Stella', 'Tessa',
    // Heróicas/Fortes
    'Aria', 'Astrid', 'Blair', 'Brynn', 'Sage',
    'Freya', 'Gwen', 'Harper', 'Juno', 'Kira',
    'Lyra', 'Morgan', 'Nova', 'Phoenix', 'Raven',
    'Scarlett', 'Storm', 'Thora', 'Valkyrie', 'Zara',
    // Místicas
    'Aurora', 'Celeste', 'Delilah', 'Elara', 'Faye',
    'Gaia', 'Haven', 'Isolde', 'Juniper', 'Kaia',
    'Luna', 'Mira', 'Nyx', 'Ophelia', 'Persephone',
    'Quintessa', 'Rhiannon', 'Seraphina', 'Thalia', 'Ursula',
    'Violet', 'Willow', 'Xanthe', 'Yara', 'Zenith',
    'Adriana', 'Bianca', 'Cassandra', 'Daphne', 'Evangeline',
  ];

  // ==================== SOBRENOMES (100) ====================
  static final List<String> _lastNames = [
    // Brasileiros
    'Silva', 'Santos', 'Oliveira', 'Souza', 'Rodrigues',
    'Ferreira', 'Alves', 'Pereira', 'Lima', 'Gomes',
    'Costa', 'Ribeiro', 'Martins', 'Carvalho', 'Rocha',
    'Almeida', 'Nascimento', 'Araújo', 'Melo', 'Barbosa',
    'Cardoso', 'Correia', 'Dias', 'Fernandes', 'Garcia',
    'Gonçalves', 'Lopes', 'Machado', 'Mendes', 'Miranda',
    'Monteiro', 'Moreira', 'Nunes', 'Pinto', 'Ramos',
    'Reis', 'Rezende', 'Sales', 'Santana', 'Sousa',
    'Teixeira', 'Vieira', 'Castro', 'Freitas', 'Moura',
    'Campos', 'Barros', 'Pires', 'Cavalcanti', 'Azevedo',
    // Internacionais
    'Anderson', 'Brown', 'Clark', 'Davis', 'Edwards',
    'Foster', 'Green', 'Harris', 'Irving', 'Johnson',
    'King', 'Lewis', 'Miller', 'Nelson', 'O\'Brien',
    'Parker', 'Quinn', 'Roberts', 'Smith', 'Taylor',
    'García', 'Martínez', 'López', 'González', 'Rodríguez',
    'Fernández', 'Pérez', 'Sánchez', 'Ramírez', 'Torres',
    'Müller', 'Schmidt', 'Schneider', 'Fischer', 'Weber',
    'Meyer', 'Wagner', 'Becker', 'Schulz', 'Hoffmann',
    'Rossi', 'Russo', 'Ferrari', 'Esposito', 'Bianchi',
    'Romano', 'Colombo', 'Ricci', 'Marino', 'Bruno',
  ];

  // ==================== APELIDOS/CODINOMES (50) ====================
  static final List<String> _nicknames = [
    // Animais
    'Fantasma', 'Lobo', 'Falcão', 'Cobra', 'Águia',
    'Tigre', 'Urso', 'Leão', 'Raposa', 'Corvo',
    'Pantera', 'Tubarão', 'Dragão', 'Escorpião', 'Fera',
    // Elementos/Fenômenos
    'Sombra', 'Relâmpago', 'Trovão', 'Tempestade', 'Furacão',
    'Tornado', 'Eclipse', 'Cometa', 'Meteoro', 'Raio',
    // Características
    'Dente', 'Garra', 'Lâmina', 'Ferro', 'Aço',
    'Cinza', 'Branco', 'Negro', 'Vermelho', 'Azul',
    // Números/Letras
    'Zero', 'Alfa', 'Ômega', 'Delta', 'Sigma',
    'Viper', 'Reaper', 'Ghost', 'Rogue', 'Sentinel',
  ];

  // ==================== TÍTULOS (50) ====================
  static final List<String> _titles = [
    // Militares
    'Ten.', 'Cap.', 'Maj.', 'Cel.', 'Gen.',
    'Sgt.', 'Cabo', 'Soldado', 'Comandante', 'Almirante',
    // Acadêmicos
    'Dr.', 'Prof.', 'Dra.', 'Mestre', 'PhD',
    'Pesquisador', 'Cientista', 'Especialista', 'Acadêmico', 'Erudito',
    // Corporativos
    'Sr.', 'Sra.', 'Diretor', 'CEO', 'Presidente',
    'Vice-Presidente', 'Gerente', 'Supervisor', 'Coordenador', 'Chefe',
    // Místicos/Paranormais
    'Mago', 'Bruxo', 'Médium', 'Vidente', 'Oracle',
    'Sacerdote', 'Xamã', 'Druida', 'Necromante', 'Ocultista',
    // Honoríficos
    'Lord', 'Lady', 'Sir', 'Duque', 'Conde',
  ];

  // ==================== NOMES DE DEUSES (50) ====================
  static final List<String> _godNames = [
    // Mitologia Grega
    'Zeus', 'Hera', 'Poseidon', 'Hades', 'Athena',
    'Apollo', 'Artemis', 'Ares', 'Aphrodite', 'Hermes',
    // Mitologia Nórdica
    'Odin', 'Thor', 'Loki', 'Freya', 'Frigg',
    'Baldur', 'Tyr', 'Heimdall', 'Hel', 'Fenrir',
    // Mitologia Egípcia
    'Ra', 'Anubis', 'Osiris', 'Isis', 'Horus',
    'Set', 'Thoth', 'Bastet', 'Sekhmet', 'Ptah',
    // Mitologia Celta
    'Dagda', 'Morrigan', 'Lugh', 'Brigid', 'Cernunnos',
    // Lovecraftiano
    'Azathoth', 'Nyarlathotep', 'Cthulhu', 'Yog-Sothoth', 'Shub-Niggurath',
    'Hastur', 'Dagon', 'Nephren-Ka', 'Yig', 'Tsathoggua',
  ];

  /// Gera um nome completo aleatório baseado em categoria e gênero
  static String generateFullName({
    String? category,
    String? gender, // 'male', 'female', 'nonbinary', 'mixed', 'random'
  }) {
    // Para Deus, usar nomes divinos
    if (category == 'Deus') {
      return _godNames[_random.nextInt(_godNames.length)];
    }

    // Determinar pool de nomes baseado no gênero
    String firstName;
    if (gender == 'male') {
      firstName = _maleNames[_random.nextInt(_maleNames.length)];
    } else if (gender == 'female') {
      firstName = _femaleNames[_random.nextInt(_femaleNames.length)];
    } else if (gender == 'nonbinary' || gender == 'mixed' || gender == 'random') {
      // Pool combinado
      final allNames = [..._maleNames, ..._femaleNames];
      firstName = allNames[_random.nextInt(allNames.length)];
    } else {
      // Default: aleatório
      final allNames = [..._maleNames, ..._femaleNames];
      firstName = allNames[_random.nextInt(allNames.length)];
    }

    final lastName = _lastNames[_random.nextInt(_lastNames.length)];

    // Para soldados/mercenários, 50% chance de adicionar apelido
    if (category == 'Soldado' || category == 'Mercenário') {
      if (_random.nextDouble() < 0.5) {
        final nickname = _nicknames[_random.nextInt(_nicknames.length)];
        return '"$nickname" $firstName $lastName';
      }
    }

    // Para líderes/chefes/profissionais, 60% chance de adicionar título
    if (category == 'Líder' || category == 'Chefe' || category == 'Profissional') {
      if (_random.nextDouble() < 0.6) {
        final title = _titles[_random.nextInt(_titles.length)];
        return '$title $firstName $lastName';
      }
    }

    return '$firstName $lastName';
  }

  /// Gera apenas primeiro nome baseado no gênero
  static String generateFirstName({String? gender}) {
    if (gender == 'male') {
      return _maleNames[_random.nextInt(_maleNames.length)];
    } else if (gender == 'female') {
      return _femaleNames[_random.nextInt(_femaleNames.length)];
    } else {
      final allNames = [..._maleNames, ..._femaleNames];
      return allNames[_random.nextInt(allNames.length)];
    }
  }

  /// Gera apenas sobrenome
  static String generateLastName() {
    return _lastNames[_random.nextInt(_lastNames.length)];
  }

  /// Gera apelido/codinome
  static String generateNickname() {
    return _nicknames[_random.nextInt(_nicknames.length)];
  }

  /// Gera título
  static String generateTitle() {
    return _titles[_random.nextInt(_titles.length)];
  }

  /// Gera nome divino
  static String generateGodName() {
    return _godNames[_random.nextInt(_godNames.length)];
  }
}
