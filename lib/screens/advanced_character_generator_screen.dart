import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import '../models/character.dart';
import '../models/skill.dart';
import '../services/local_database_service.dart';
import '../theme/app_theme.dart';
import '../utils/name_generator.dart';
import '../utils/power_generator.dart';
import '../utils/item_generator.dart';
import '../utils/skill_generator.dart';
import '../widgets/widgets.dart';

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

  String _categoria = 'Civil Iniciante';
  String _genero = 'random';
  int _quantidade = 1;
  bool _isGenerating = false;

  final List<String> _categorias = [
    'Civil Iniciante',
    'Mercenário/Civil Treinado',
    'Soldado/Agente',
    'Profissional Especializado',
    'Líder de Operação',
    'Chefe (Boss)',
    'Elite Paranormal',
    'Entidade Menor/Semideus',
    'Deus/Entidade Maior',
  ];

  final Map<String, Map<String, dynamic>> _generos = {
    'male': {'label': 'Masculino', 'icon': Icons.male},
    'female': {'label': 'Feminino', 'icon': Icons.female},
    'nonbinary': {'label': 'Não-binário', 'icon': Icons.transgender},
    'mixed': {'label': 'Misto', 'icon': Icons.people},
    'random': {'label': 'Aleatório', 'icon': Icons.shuffle},
  };

  Map<String, int> _gerarAtributos(String categoria) {
    int pontosTotal;
    int maxAtributo;

    switch (categoria) {
      case 'Civil Iniciante':
        pontosTotal = 2;
        maxAtributo = 3;
        break;
      case 'Mercenário/Civil Treinado':
        pontosTotal = 3;
        maxAtributo = 3;
        break;
      case 'Soldado/Agente':
        pontosTotal = 4;
        maxAtributo = 3;
        break;
      case 'Profissional Especializado':
        pontosTotal = 5;
        maxAtributo = 4;
        break;
      case 'Líder de Operação':
        pontosTotal = 6;
        maxAtributo = 4;
        break;
      case 'Chefe (Boss)':
        pontosTotal = 7;
        maxAtributo = 5;
        break;
      case 'Elite Paranormal':
        pontosTotal = 8;
        maxAtributo = 5;
        break;
      case 'Entidade Menor/Semideus':
        pontosTotal = 9;
        maxAtributo = 5;
        break;
      case 'Deus/Entidade Maior':
        pontosTotal = 10;
        maxAtributo = 6;
        break;
      default:
        pontosTotal = 4;
        maxAtributo = 3;
    }

    return _distribuirPontos(pontosTotal, maxAtributo);
  }

  Map<String, int> _distribuirPontos(int total, int maxPorAtributo) {
    final atributos = {'for': 0, 'agi': 0, 'vig': 0, 'int': 0, 'pre': 0};
    final keys = atributos.keys.toList();

    for (int i = 0; i < total; i++) {
      bool distribuido = false;
      int tentativas = 0;

      while (!distribuido && tentativas < 50) {
        final key = keys[_random.nextInt(keys.length)];
        if (atributos[key]! < maxPorAtributo) {
          atributos[key] = atributos[key]! + 1;
          distribuido = true;
        }
        tentativas++;
      }

      if (!distribuido) break;
    }

    return atributos;
  }

  Map<String, int> _gerarStatus(String categoria, int vigor) {
    switch (categoria) {
      case 'Civil Iniciante':
        return {
          'nex': 5,
          'pvMax': _random.nextInt(5) + 8,
          'peMax': _random.nextInt(2),
          'psMax': _random.nextInt(5) + 10,
          'creditos': _random.nextInt(300) + 50,
          'iniciativaBase': _random.nextInt(3),
        };

      case 'Mercenário/Civil Treinado':
        return {
          'nex': 10,
          'pvMax': _random.nextInt(5) + 12,
          'peMax': _random.nextInt(3),
          'psMax': _random.nextInt(5) + 12,
          'creditos': _random.nextInt(1000) + 200,
          'iniciativaBase': _random.nextInt(4) + 1,
        };

      case 'Soldado/Agente':
        return {
          'nex': 15,
          'pvMax': _random.nextInt(5) + 14,
          'peMax': _random.nextInt(3) + 1,
          'psMax': _random.nextInt(5) + 14,
          'creditos': _random.nextInt(1500) + 500,
          'iniciativaBase': _random.nextInt(5) + 2,
        };

      case 'Profissional Especializado':
        return {
          'nex': 25,
          'pvMax': _random.nextInt(5) + 16,
          'peMax': _random.nextInt(3) + 2,
          'psMax': _random.nextInt(5) + 16,
          'creditos': _random.nextInt(3000) + 1000,
          'iniciativaBase': _random.nextInt(6) + 3,
        };

      case 'Líder de Operação':
        return {
          'nex': 40,
          'pvMax': _random.nextInt(7) + 20,
          'peMax': _random.nextInt(3) + 3,
          'psMax': _random.nextInt(5) + 18,
          'creditos': _random.nextInt(5000) + 2000,
          'iniciativaBase': _random.nextInt(7) + 5,
        };

      case 'Chefe (Boss)':
        return {
          'nex': 55,
          'pvMax': _random.nextInt(7) + 26,
          'peMax': _random.nextInt(4) + 4,
          'psMax': _random.nextInt(7) + 20,
          'creditos': _random.nextInt(10000) + 5000,
          'iniciativaBase': _random.nextInt(8) + 7,
        };

      case 'Elite Paranormal':
        return {
          'nex': 70,
          'pvMax': _random.nextInt(9) + 30,
          'peMax': _random.nextInt(5) + 6,
          'psMax': _random.nextInt(7) + 24,
          'creditos': _random.nextInt(20000) + 10000,
          'iniciativaBase': _random.nextInt(10) + 10,
        };

      case 'Entidade Menor/Semideus':
        return {
          'nex': 85,
          'pvMax': _random.nextInt(13) + 36,
          'peMax': _random.nextInt(7) + 8,
          'psMax': _random.nextInt(11) + 30,
          'creditos': _random.nextInt(50000) + 25000,
          'iniciativaBase': _random.nextInt(12) + 15,
        };

      case 'Deus/Entidade Maior':
        return {
          'nex': 99,
          'pvMax': _random.nextInt(31) + 50,
          'peMax': _random.nextInt(9) + 12,
          'psMax': _random.nextInt(21) + 40,
          'creditos': _random.nextInt(100000) + 50000,
          'iniciativaBase': _random.nextInt(15) + 20,
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

        final nome = NameGenerator.generateFullName(
          category: _categoria,
          gender: _genero,
        );

        final atributos = _gerarAtributos(_categoria);
        final status = _gerarStatus(_categoria, atributos['vig']!);
        final poderes = PowerGenerator.generatePowers(_categoria);

        final skillsMap = SkillGenerator.generateSkills(_categoria);
        final pericias = <String, Skill>{};
        skillsMap.forEach((skillName, levelString) {
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

          final skillInfo = OrdemSkills.allSkills[skillName];
          final categoryString = skillInfo?['category'] ?? 'combat';
          final attribute = skillInfo?['attribute'] ?? 'INT';

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

        final inventario = ItemGenerator.generateItems(_categoria);

        final classes = ['Combatente', 'Especialista', 'Ocultista'];
        final classe = classes[_random.nextInt(classes.length)];

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
            backgroundColor: AppTheme.mutagenGreen,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: $e'),
            backgroundColor: AppTheme.ritualRed,
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

  Color _getCategoryColor(String categoria) {
    switch (categoria) {
      case 'Civil Iniciante':
        return AppTheme.coldGray;
      case 'Mercenário/Civil Treinado':
        return AppTheme.iron;
      case 'Soldado/Agente':
        return AppTheme.mutagenGreen;
      case 'Profissional Especializado':
        return AppTheme.alertYellow;
      case 'Líder de Operação':
        return AppTheme.etherealPurple;
      case 'Chefe (Boss)':
        return AppTheme.chaoticMagenta;
      case 'Elite Paranormal':
        return AppTheme.ritualRed;
      case 'Entidade Menor/Semideus':
        return AppTheme.bloodRed;
      case 'Deus/Entidade Maior':
        return AppTheme.scarletRed;
      default:
        return AppTheme.silver;
    }
  }

  IconData _getCategoryIcon(String categoria) {
    switch (categoria) {
      case 'Civil Iniciante':
        return Icons.person;
      case 'Mercenário/Civil Treinado':
        return Icons.shield;
      case 'Soldado/Agente':
        return Icons.military_tech;
      case 'Profissional Especializado':
        return Icons.workspace_premium;
      case 'Líder de Operação':
        return Icons.stars;
      case 'Chefe (Boss)':
        return Icons.star;
      case 'Elite Paranormal':
        return Icons.flash_on;
      case 'Entidade Menor/Semideus':
        return Icons.auto_awesome;
      case 'Deus/Entidade Maior':
        return Icons.flare;
      default:
        return Icons.help;
    }
  }

  String _getCategoryDescription(String categoria) {
    switch (categoria) {
      case 'Civil Iniciante':
        return '2 pts • NEX 5% • Fraco';
      case 'Mercenário/Civil Treinado':
        return '3 pts • NEX 10% • Básico';
      case 'Soldado/Agente':
        return '4 pts • NEX 15% • Padrão';
      case 'Profissional Especializado':
        return '5 pts • NEX 25% • Forte';
      case 'Líder de Operação':
        return '6 pts • NEX 40% • Líder';
      case 'Chefe (Boss)':
        return '7 pts • NEX 55% • Boss';
      case 'Elite Paranormal':
        return '8 pts • NEX 70% • Elite';
      case 'Entidade Menor/Semideus':
        return '9 pts • NEX 85% • Semideus';
      case 'Deus/Entidade Maior':
        return '10 pts • NEX 99% • Deus';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return HexatombeBackground(
      showParticles: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: AppTheme.abyssalBlack.withOpacity(0.9),
          elevation: 0,
          title: const Text(
            'GERADOR AVANÇADO',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              fontFamily: 'BebasNeue',
              letterSpacing: 2,
              color: AppTheme.alertYellow,
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header Card
            RitualCard(
              glowEffect: true,
              glowColor: AppTheme.alertYellow,
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppTheme.alertYellow.withOpacity(0.2),
                      border: Border.all(color: AppTheme.alertYellow, width: 2),
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      size: 32,
                      color: AppTheme.alertYellow,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'GERADOR AVANÇADO',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.alertYellow,
                            fontFamily: 'BebasNeue',
                            letterSpacing: 1.5,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Crie personagens completos instantaneamente',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.coldGray,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.2, end: 0),

            const SizedBox(height: 24),

            // Categoria
            Text(
              'CATEGORIA',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.silver,
                fontFamily: 'BebasNeue',
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),

            ..._categorias.asMap().entries.map((entry) {
              final index = entry.key;
              final cat = entry.value;
              final isSelected = _categoria == cat;
              final color = _getCategoryColor(cat);
              final icon = _getCategoryIcon(cat);
              final desc = _getCategoryDescription(cat);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _categoria = cat;
                  });
                },
                child: RitualCard(
                  margin: const EdgeInsets.only(bottom: 8),
                  glowEffect: isSelected,
                  glowColor: color,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.2),
                          border: Border.all(color: color, width: 1.5),
                        ),
                        child: Icon(icon, color: color, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cat.toUpperCase(),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isSelected ? color : AppTheme.paleWhite,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              desc,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.coldGray,
                                fontFamily: 'SpaceMono',
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Icon(Icons.check_circle, color: color, size: 24),
                    ],
                  ),
                ),
              ).animate(delay: (index * 50).ms).fadeIn(duration: 300.ms).slideX(begin: -0.1, end: 0);
            }),

            const SizedBox(height: 24),

            // Gênero
            Text(
              'GÊNERO',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.silver,
                fontFamily: 'BebasNeue',
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _generos.entries.map((entry) {
                final isSelected = _genero == entry.key;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _genero = entry.key;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.etherealPurple.withOpacity(0.2)
                          : AppTheme.obscureGray,
                      border: Border.all(
                        color: isSelected ? AppTheme.etherealPurple : AppTheme.industrialGray,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          entry.value['icon'] as IconData,
                          size: 18,
                          color: isSelected ? AppTheme.etherealPurple : AppTheme.coldGray,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          entry.value['label'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? AppTheme.etherealPurple : AppTheme.paleWhite,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Quantidade
            RitualCard(
              glowEffect: true,
              glowColor: AppTheme.mutagenGreen,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.format_list_numbered,
                        color: AppTheme.mutagenGreen,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'QUANTIDADE',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.mutagenGreen,
                          fontFamily: 'BebasNeue',
                          letterSpacing: 2,
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
                        iconSize: 32,
                        color: AppTheme.ritualRed,
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            '$_quantidade',
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.mutagenGreen,
                              fontFamily: 'SpaceMono',
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
                        iconSize: 32,
                        color: AppTheme.mutagenGreen,
                      ),
                    ],
                  ),
                  Slider(
                    value: _quantidade.toDouble(),
                    min: 1,
                    max: 50,
                    divisions: 49,
                    activeColor: AppTheme.mutagenGreen,
                    inactiveColor: AppTheme.obscureGray,
                    onChanged: (value) {
                      setState(() {
                        _quantidade = value.toInt();
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Botão Gerar
            GlowingButton(
              label: _isGenerating
                  ? 'GERANDO...'
                  : 'GERAR $_quantidade PERSONAGEM${_quantidade > 1 ? "S" : ""}',
              onPressed: _isGenerating ? null : _gerarPersonagens,
              isLoading: _isGenerating,
              icon: Icons.auto_awesome,
              style: GlowingButtonStyle.primary,
              fullWidth: true,
              pulsateGlow: !_isGenerating,
            ),

            const SizedBox(height: 24),

            // Info
            RitualCard(
              glowEffect: true,
              glowColor: AppTheme.etherealPurple,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: AppTheme.etherealPurple, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'SISTEMA PROMPT SUPREMO',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.etherealPurple,
                          fontFamily: 'BebasNeue',
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow('450+ nomes completos'),
                  _buildInfoRow('110 poderes paranormais'),
                  _buildInfoRow('165 itens equipáveis'),
                  _buildInfoRow('Perícias distribuídas por nível'),
                  _buildInfoRow('9 categorias de poder'),
                  const SizedBox(height: 8),
                  const Text(
                    'Cada categoria gera personagens balanceados com poder proporcional ao NEX.',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.coldGray,
                      fontFamily: 'Montserrat',
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          const Icon(Icons.check, size: 14, color: AppTheme.mutagenGreen),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.silver,
                fontFamily: 'Montserrat',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
