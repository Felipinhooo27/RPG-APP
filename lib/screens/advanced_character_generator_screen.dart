import 'dart:math';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/character.dart';
import '../models/skill.dart';
import '../services/local_database_service.dart';
import '../utils/name_generator.dart';
import '../utils/power_generator.dart';
import '../utils/item_generator.dart';
import '../utils/skill_generator.dart';

class AdvancedCharacterGeneratorScreen extends StatefulWidget {
  const AdvancedCharacterGeneratorScreen({super.key});

  @override
  State<AdvancedCharacterGeneratorScreen> createState() =>
      _AdvancedCharacterGeneratorScreenState();
}

class _AdvancedCharacterGeneratorScreenState
    extends State<AdvancedCharacterGeneratorScreen> {
  final LocalDatabaseService _databaseService = LocalDatabaseService();
  final Random _random = Random();

  String _categoria = 'Civil';
  String _genero = 'random'; // 'male', 'female', 'nonbinary', 'mixed', 'random'
  int _quantidade = 1;
  bool _isGenerating = false;

  final List<String> _categorias = [
    'Civil',
    'Mercenário',
    'Soldado',
    'Chefe',
    'Líder',
    'Profissional',
    'Deus',
  ];

  final Map<String, Map<String, dynamic>> _generos = {
    'male': {'label': 'Masculino', 'icon': Icons.male},
    'female': {'label': 'Feminino', 'icon': Icons.female},
    'nonbinary': {'label': 'Não-binário', 'icon': Icons.transgender},
    'mixed': {'label': 'Misto', 'icon': Icons.people},
    'random': {'label': 'Aleatório', 'icon': Icons.shuffle},
  };

  // Gerar atributos baseado na categoria
  Map<String, int> _gerarAtributos(String categoria) {
    switch (categoria) {
      case 'Civil':
        // 2 pontos totais distribuídos
        return _distribuirPontos(2);

      case 'Mercenário':
        // 6 pontos totais
        return _distribuirPontos(6);

      case 'Soldado':
        // 8 pontos totais
        return _distribuirPontos(8);

      case 'Chefe':
        // 12 pontos totais
        return _distribuirPontos(12);

      case 'Líder':
        // 15 pontos totais
        return _distribuirPontos(15);

      case 'Profissional':
        // 20 pontos totais
        return _distribuirPontos(20);

      case 'Deus':
        // 40 pontos totais
        return _distribuirPontos(40);

      default:
        return {'for': 0, 'agi': 0, 'vig': 0, 'int': 0, 'pre': 0};
    }
  }

  Map<String, int> _distribuirPontos(int total) {
    final atributos = {'for': 0, 'agi': 0, 'vig': 0, 'int': 0, 'pre': 0};
    final keys = atributos.keys.toList();

    for (int i = 0; i < total; i++) {
      final key = keys[_random.nextInt(keys.length)];
      atributos[key] = atributos[key]! + 1;
    }

    return atributos;
  }

  // Gerar status baseado na categoria
  Map<String, int> _gerarStatus(String categoria, int vigor) {
    switch (categoria) {
      case 'Civil':
        return {
          'nex': 5,
          'pvMax': 8 + vigor * 2,
          'peMax': 1,
          'psMax': 10,
          'creditos': _random.nextInt(300) + 50,
          'iniciativaBase': _random.nextInt(3),
        };

      case 'Mercenário':
        return {
          'nex': 10,
          'pvMax': 12 + vigor * 3,
          'peMax': 2 + _random.nextInt(2),
          'psMax': 12,
          'creditos': _random.nextInt(1000) + 200,
          'iniciativaBase': _random.nextInt(5) + 2,
        };

      case 'Soldado':
        return {
          'nex': 15,
          'pvMax': 15 + vigor * 3,
          'peMax': 3 + _random.nextInt(3),
          'psMax': 15,
          'creditos': _random.nextInt(1500) + 300,
          'iniciativaBase': _random.nextInt(6) + 3,
        };

      case 'Chefe':
        return {
          'nex': 25,
          'pvMax': 20 + vigor * 4,
          'peMax': 5 + _random.nextInt(4),
          'psMax': 18,
          'creditos': _random.nextInt(5000) + 1000,
          'iniciativaBase': _random.nextInt(8) + 5,
        };

      case 'Líder':
        return {
          'nex': 40,
          'pvMax': 30 + vigor * 5,
          'peMax': 8 + _random.nextInt(5),
          'psMax': 25,
          'creditos': _random.nextInt(15000) + 3000,
          'iniciativaBase': _random.nextInt(10) + 8,
        };

      case 'Profissional':
        return {
          'nex': 55,
          'pvMax': 40 + vigor * 6,
          'peMax': 12 + _random.nextInt(6),
          'psMax': 30,
          'creditos': _random.nextInt(30000) + 8000,
          'iniciativaBase': _random.nextInt(12) + 10,
        };

      case 'Deus':
        return {
          'nex': 99,
          'pvMax': 100 + vigor * 10,
          'peMax': 50 + _random.nextInt(20),
          'psMax': 100,
          'creditos': _random.nextInt(100000) + 50000,
          'iniciativaBase': _random.nextInt(20) + 15,
        };

      default:
        return {
          'nex': 5,
          'pvMax': 10,
          'peMax': 1,
          'psMax': 10,
          'creditos': 100,
          'iniciativaBase': 0,
        };
    }
  }

  Future<void> _gerarPersonagens() async {
    setState(() {
      _isGenerating = true;
    });

    try {
      for (int i = 0; i < _quantidade; i++) {
        final uuid = const Uuid();

        // Nome completo com gênero
        final nome = NameGenerator.generateFullName(
          category: _categoria,
          gender: _genero,
        );

        // Atributos
        final atributos = _gerarAtributos(_categoria);

        // Status
        final status = _gerarStatus(_categoria, atributos['vig']!);

        // Poderes
        final poderes = PowerGenerator.generatePowers(_categoria);

        // Perícias baseadas no nível
        final skillsMap = SkillGenerator.generateSkills(_categoria);
        final pericias = <String, Skill>{};
        skillsMap.forEach((skillName, levelString) {
          // Converter string de nível para SkillLevel enum
          SkillLevel skillLevel;
          switch (levelString) {
            case 'expert':
              skillLevel = SkillLevel.expert;
              break;
            case 'veterano':
              skillLevel = SkillLevel.veteran;
              break;
            case 'treinado':
              skillLevel = SkillLevel.trained;
              break;
            default:
              skillLevel = SkillLevel.untrained;
          }

          // Obter categoria e atributo da skill
          final skillInfo = OrdemSkills.allSkills[skillName];
          final categoryString = skillInfo?['category'] ?? 'combat';
          final attribute = skillInfo?['attribute'] ?? 'INT';

          // Converter string de categoria para enum
          SkillCategory category;
          switch (categoryString) {
            case 'investigation':
              category = SkillCategory.investigation;
              break;
            case 'social':
              category = SkillCategory.social;
              break;
            case 'occult':
              category = SkillCategory.occult;
              break;
            case 'survival':
              category = SkillCategory.survival;
              break;
            default:
              category = SkillCategory.combat;
          }

          pericias[skillName] = Skill(
            name: skillName,
            category: category,
            level: skillLevel,
            attribute: attribute,
          );
        });

        // Itens baseados na categoria
        final inventario = ItemGenerator.generateItems(_categoria);

        // Classe aleatória
        final classes = ['Combatente', 'Especialista', 'Ocultista'];
        final classe = classes[_random.nextInt(classes.length)];

        // Criar personagem
        final character = Character(
          id: uuid.v4(),
          nome: nome,
          patente: _categoria,
          nex: status['nex']!,
          origem: _categoria,
          classe: classe,
          trilha: 'Nenhuma',
          createdBy: 'master_001',
          pvAtual: status['pvMax']!,
          pvMax: status['pvMax']!,
          peAtual: status['peMax']!,
          peMax: status['peMax']!,
          psAtual: status['psMax']!,
          psMax: status['psMax']!,
          creditos: status['creditos']!,
          forca: atributos['for']!,
          agilidade: atributos['agi']!,
          vigor: atributos['vig']!,
          inteligencia: atributos['int']!,
          presenca: atributos['pre']!,
          iniciativaBase: status['iniciativaBase']!,
          pericias: pericias,
          poderes: poderes,
          inventario: inventario,
        );

        await _databaseService.createCharacter(character);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$_quantidade personagem(s) gerado(s) com sucesso!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerador Avançado'),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.background,
            ],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    size: 48,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'GERADOR AVANÇADO',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Crie personagens completos instantaneamente',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Categoria
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.category,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'CATEGORIA',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ..._categorias.map((cat) {
                      final IconData icon;
                      final String desc;
                      final Color color;

                      switch (cat) {
                        case 'Civil':
                          icon = Icons.person;
                          desc = '2 pts • Fraco, sem poderes';
                          color = Colors.grey;
                          break;
                        case 'Mercenário':
                          icon = Icons.shield_outlined;
                          desc = '6 pts • Combate básico';
                          color = Colors.blue;
                          break;
                        case 'Soldado':
                          icon = Icons.military_tech;
                          desc = '8 pts • Treinamento militar';
                          color = Colors.green;
                          break;
                        case 'Chefe':
                          icon = Icons.star;
                          desc = '12 pts • Líder de grupo';
                          color = Colors.orange;
                          break;
                        case 'Líder':
                          icon = Icons.stars;
                          desc = '15 pts • 20% chance de poder';
                          color = Colors.purple;
                          break;
                        case 'Profissional':
                          icon = Icons.workspace_premium;
                          desc = '20 pts • Sempre tem poder';
                          color = Colors.amber;
                          break;
                        case 'Deus':
                          icon = Icons.flash_on;
                          desc = '40 pts • Extremamente poderoso, 5-8 poderes';
                          color = Colors.red;
                          break;
                        default:
                          icon = Icons.help;
                          desc = '';
                          color = Colors.grey;
                      }

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        color: _categoria == cat
                            ? color.withOpacity(0.2)
                            : null,
                        child: RadioListTile<String>(
                          value: cat,
                          groupValue: _categoria,
                          onChanged: (value) {
                            setState(() {
                              _categoria = value!;
                            });
                          },
                          title: Row(
                            children: [
                              Icon(icon, color: color, size: 28),
                              const SizedBox(width: 12),
                              Text(
                                cat,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: _categoria == cat ? color : null,
                                ),
                              ),
                            ],
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(left: 40, top: 4),
                            child: Text(
                              desc,
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                          activeColor: color,
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Gênero
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'GÊNERO',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Theme.of(context).colorScheme.secondary,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _generos.entries.map((entry) {
                        final isSelected = _genero == entry.key;
                        return FilterChip(
                          selected: isSelected,
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                entry.value['icon'] as IconData,
                                size: 18,
                                color: isSelected
                                    ? Colors.white
                                    : Theme.of(context).colorScheme.secondary,
                              ),
                              const SizedBox(width: 6),
                              Text(entry.value['label'] as String),
                            ],
                          ),
                          onSelected: (selected) {
                            setState(() {
                              _genero = entry.key;
                            });
                          },
                          selectedColor: Theme.of(context).colorScheme.secondary,
                          checkmarkColor: Colors.white,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : null,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Quantidade
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.format_list_numbered,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'QUANTIDADE',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            if (_quantidade > 1) {
                              setState(() {
                                _quantidade--;
                              });
                            }
                          },
                          icon: const Icon(Icons.remove_circle),
                          iconSize: 36,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              '$_quantidade',
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            if (_quantidade < 50) {
                              setState(() {
                                _quantidade++;
                              });
                            }
                          },
                          icon: const Icon(Icons.add_circle),
                          iconSize: 36,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ],
                    ),
                    Slider(
                      value: _quantidade.toDouble(),
                      min: 1,
                      max: 50,
                      divisions: 49,
                      label: '$_quantidade',
                      onChanged: (value) {
                        setState(() {
                          _quantidade = value.toInt();
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Botão Gerar
            ElevatedButton(
              onPressed: _isGenerating ? null : _gerarPersonagens,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
              ),
              child: _isGenerating
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.auto_awesome, size: 28),
                        const SizedBox(width: 12),
                        Text(
                          _isGenerating
                              ? 'GERANDO...'
                              : 'GERAR ${_quantidade} PERSONAGEM${_quantidade > 1 ? "S" : ""}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
            ),

            const SizedBox(height: 20),

            // Info
            Card(
              color: Colors.blue.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.auto_awesome, color: Colors.blue[300]),
                        const SizedBox(width: 12),
                        Text(
                          'SISTEMA INTELIGENTE DE GERAÇÃO',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[100],
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(Icons.face, '450+ nomes (incluindo 50 deuses e títulos)'),
                    _buildInfoRow(Icons.flash_on, '110 poderes paranormais únicos'),
                    _buildInfoRow(Icons.inventory, '165 itens (mundanos a divinos)'),
                    _buildInfoRow(Icons.school, 'Perícias distribuídas por nível'),
                    _buildInfoRow(Icons.trending_up, 'Atributos e status balanceados'),
                    const SizedBox(height: 8),
                    Text(
                      '💡 Cada categoria gera personagens com poder proporcional:\n'
                      '• Civil: 1-2 perícias, itens básicos, sem poderes\n'
                      '• Soldado: 3-4 perícias, armas, 30% chance de poder\n'
                      '• Profissional: 6-8 perícias, equipamento avançado, 2-3 poderes\n'
                      '• Deus: 12-15 perícias, itens divinos, 5-8 poderes!',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.blue[100]?.withOpacity(0.9),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.blue[200]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue[100],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
