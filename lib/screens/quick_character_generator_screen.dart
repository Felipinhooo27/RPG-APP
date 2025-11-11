import 'dart:math';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/character.dart';
import '../services/local_database_service.dart';
import '../theme/app_theme.dart';
import '../widgets/hex_loading.dart';
import '../widgets/ritual_card.dart';
import '../widgets/glowing_button.dart';

class QuickCharacterGeneratorScreen extends StatefulWidget {
  const QuickCharacterGeneratorScreen({super.key});

  @override
  State<QuickCharacterGeneratorScreen> createState() =>
      _QuickCharacterGeneratorScreenState();
}

class _QuickCharacterGeneratorScreenState
    extends State<QuickCharacterGeneratorScreen> {
  final LocalDatabaseService _databaseService = LocalDatabaseService();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _iniciativaBaseController =
      TextEditingController();

  String _nivelPoder = 'Recruta'; // Recruta, Operador, Agente Especial, Elite
  bool _isGenerating = false;

  final List<String> _niveisPoder = [
    'Recruta (NEX 5%)',
    'Operador (NEX 10-25%)',
    'Agente Especial (NEX 30-55%)',
    'Elite (NEX 60-99%)',
  ];

  final List<String> _origens = [
    'Acadêmico',
    'Agente de Saúde',
    'Amnésico',
    'Artista',
    'Atleta',
    'Chef',
    'Criminalista',
    'Cultista Arrependido',
    'Desgarrado',
    'Engenheiro',
    'Executivo',
    'Investigador',
    'Lutador',
    'Magnata',
    'Mercenário',
    'Militar',
    'Operário',
    'Policial',
    'Profissional Liberal',
    'Religioso',
    'Servidor Público',
    'Teórico da Conspiração',
    'TI',
    'Trabalhador Rural',
    'Trambiqueiro',
    'Universitário',
    'Vítima',
  ];

  final List<String> _classes = [
    'Combatente',
    'Especialista',
    'Ocultista',
  ];

  final Map<String, List<String>> _trilhas = {
    'Combatente': [
      'Aniquilador',
      'Comandante de Campo',
      'Guerreiro',
      'Operações Especiais',
      'Tropa de Choque',
    ],
    'Especialista': [
      'Atirador de Elite',
      'Infiltrador',
      'Médico de Campo',
      'Negociador',
      'Técnico',
    ],
    'Ocultista': [
      'Conduite',
      'Flagelador',
      'Graduado',
      'Intuitivo',
      'Lâmina Paranormal',
    ],
  };

  @override
  void dispose() {
    _nomeController.dispose();
    _iniciativaBaseController.dispose();
    super.dispose();
  }

  // Gerar atributos baseados no nível de poder (seguindo regras Ordem Paranormal)
  Map<String, int> _gerarAtributos(String nivel) {
    final random = Random();
    int pontosTotal;

    // Define total de pontos baseado no nível (seguindo prompt supremo)
    switch (nivel) {
      case 'Recruta (NEX 5%)':
        pontosTotal = 2; // Civil iniciante
        break;
      case 'Operador (NEX 10-25%)':
        pontosTotal = 3; // Mercenário/Civil treinado
        break;
      case 'Agente Especial (NEX 30-55%)':
        pontosTotal = 4; // Soldado/Agente (padrão do sistema)
        break;
      case 'Elite (NEX 60-99%)':
        pontosTotal = random.nextInt(2) + 5; // 5-6 pontos (Profissional Especializado)
        break;
      default:
        pontosTotal = 4;
    }

    // Distribui pontos aleatoriamente entre os 5 atributos
    List<int> atributos = [0, 0, 0, 0, 0];

    for (int i = 0; i < pontosTotal; i++) {
      int index = random.nextInt(5);
      // Garante que nenhum atributo ultrapasse 3 (máximo inicial)
      if (atributos[index] < 3) {
        atributos[index]++;
      } else {
        // Tenta colocar em outro atributo que não está no máximo
        bool distribuido = false;
        for (int j = 0; j < 5; j++) {
          if (atributos[j] < 3) {
            atributos[j]++;
            distribuido = true;
            break;
          }
        }
        // Se todos estão no máximo, para de distribuir
        if (!distribuido) break;
      }
    }

    // Aleatoriza a ordem para variar a distribuição
    atributos.shuffle();

    return {
      'for': atributos[0],
      'agi': atributos[1],
      'vig': atributos[2],
      'int': atributos[3],
      'pre': atributos[4],
    };
  }

  // Gerar status baseado no nível
  Map<String, int> _gerarStatus(String nivel, int vigor) {
    final random = Random();

    switch (nivel) {
      case 'Recruta (NEX 5%)':
        return {
          'nex': 5,
          'pvMax': 10 + vigor * 2 + random.nextInt(5),
          'peMax': 1 + random.nextInt(3),
          'psMax': 10 + random.nextInt(5),
          'creditos': random.nextInt(500) + 100,
          'iniciativaBase': random.nextInt(5),
        };

      case 'Operador (NEX 10-25%)':
        final nex = [10, 15, 20, 25][random.nextInt(4)];
        return {
          'nex': nex,
          'pvMax': 15 + vigor * 3 + random.nextInt(10),
          'peMax': 3 + random.nextInt(5),
          'psMax': 15 + random.nextInt(10),
          'creditos': random.nextInt(2000) + 500,
          'iniciativaBase': random.nextInt(8) + 2,
        };

      case 'Agente Especial (NEX 30-55%)':
        final nex = [30, 35, 40, 45, 50, 55][random.nextInt(6)];
        return {
          'nex': nex,
          'pvMax': 25 + vigor * 4 + random.nextInt(15),
          'peMax': 5 + random.nextInt(8),
          'psMax': 20 + random.nextInt(15),
          'creditos': random.nextInt(10000) + 2000,
          'iniciativaBase': random.nextInt(10) + 5,
        };

      case 'Elite (NEX 60-99%)':
        final nex = [60, 65, 70, 75, 80, 85, 90, 95, 99][random.nextInt(9)];
        return {
          'nex': nex,
          'pvMax': 40 + vigor * 5 + random.nextInt(20),
          'peMax': 10 + random.nextInt(15),
          'psMax': 30 + random.nextInt(20),
          'creditos': random.nextInt(50000) + 10000,
          'iniciativaBase': random.nextInt(15) + 10,
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

  Future<void> _gerarPersonagem() async {
    setState(() {
      _isGenerating = true;
    });

    try {
      final random = Random();
      final uuid = const Uuid();

      // Nome
      String nome;
      if (_nomeController.text.trim().isNotEmpty) {
        nome = _nomeController.text.trim();
      } else {
        // Gerar nome aleatório
        final prefixos = [
          'Agente',
          'Operador',
          'Investigador',
          'Dr.',
          'Sgt.',
          'Cap.'
        ];
        final numeros = random.nextInt(999) + 1;
        nome = '${prefixos[random.nextInt(prefixos.length)]} $numeros';
      }

      // Atributos
      final atributos = _gerarAtributos(_nivelPoder);

      // Status
      final status = _gerarStatus(_nivelPoder, atributos['vig']!);

      // Iniciativa Base
      int iniciativaBase;
      if (_iniciativaBaseController.text.trim().isNotEmpty) {
        iniciativaBase = int.tryParse(_iniciativaBaseController.text.trim()) ??
            status['iniciativaBase']!;
      } else {
        iniciativaBase = status['iniciativaBase']!;
      }

      // Origem, Classe e Trilha aleatórios
      final origem = _origens[random.nextInt(_origens.length)];
      final classe = _classes[random.nextInt(_classes.length)];
      final trilhasClasse = _trilhas[classe]!;
      final trilha = trilhasClasse[random.nextInt(trilhasClasse.length)];

      // Criar personagem
      final character = Character(
        id: uuid.v4(),
        nome: nome,
        patente: _nivelPoder.split(' ')[0], // Pega só o primeiro termo
        nex: status['nex']!,
        origem: origem,
        classe: classe,
        trilha: trilha,
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
        iniciativaBase: iniciativaBase,
        pericias: {},
        poderes: [],
        inventario: [],
      );

      // Salvar no banco
      await _databaseService.createCharacter(character);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Personagem "$nome" gerado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );

        // Limpar campos
        _nomeController.clear();
        _iniciativaBaseController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao gerar personagem: $e'),
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
        title: const Text('Gerador Rápido de Personagens'),
      ),
      body: Stack(
        children: [
          // Conteúdo principal
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Header com apresentação
              RitualCard(
                glowEffect: true,
                glowColor: AppTheme.ritualRed,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          color: AppTheme.ritualRed,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'GERADOR DE NPCs',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: AppTheme.ritualRed,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Gere personagens rapidamente para combates e encontros. '
                      'Deixe os campos em branco para geração totalmente aleatória.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.coldGray,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Seleção de Nível de Poder
              RitualCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nível de Poder',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    ..._niveisPoder.asMap().entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildPowerLevelOption(entry.key, entry.value),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Campos Opcionais
              RitualCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Personalização (Opcional)',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _nomeController,
                      decoration: const InputDecoration(
                        labelText: 'Nome Personalizado',
                        hintText: 'Ex: Capanga 3, Cultista Alpha',
                        helperText: 'Deixe vazio para gerar automaticamente',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                          borderSide: BorderSide(
                            color: AppTheme.ritualRed,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _iniciativaBaseController,
                      decoration: const InputDecoration(
                        labelText: 'Iniciativa Base',
                        hintText: 'Ex: 15',
                        helperText: 'Deixe vazio para gerar automaticamente',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                          borderSide: BorderSide(
                            color: AppTheme.ritualRed,
                            width: 2,
                          ),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Botão Gerar com GlowingButton
              GlowingButton(
                label: _isGenerating ? 'Gerando Personagem...' : 'Gerar Personagem',
                onPressed: _isGenerating ? null : _gerarPersonagem,
                icon: Icons.auto_awesome,
                isLoading: _isGenerating,
                fullWidth: true,
                pulsateGlow: !_isGenerating,
              ),
              const SizedBox(height: 20),

              // Informações com design moderno
              RitualCard(
                glowColor: AppTheme.etherealPurple,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.etherealPurple.withOpacity(0.2),
                            border: Border.all(color: AppTheme.etherealPurple, width: 1),
                          ),
                          child: const Icon(
                            Icons.info_outline,
                            color: AppTheme.etherealPurple,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Como Funciona',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.etherealPurple,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildInfoPoint(
                      'Atributos, Status e Créditos são gerados automaticamente baseados no nível de poder',
                    ),
                    const SizedBox(height: 12),
                    _buildInfoPoint(
                      'Origem, Classe e Trilha são escolhidos aleatoriamente',
                    ),
                    const SizedBox(height: 12),
                    _buildInfoPoint(
                      'O personagem é salvo imediatamente no banco de dados',
                    ),
                    const SizedBox(height: 12),
                    _buildInfoPoint(
                      'Use para gerar NPCs, inimigos e aliados rapidamente',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),

          // Loading Overlay
          if (_isGenerating)
            const HexLoadingOverlay(
              message: 'Gerando personagem...',
            ),
        ],
      ),
    );
  }

  /// Constrói opção de nível de poder com estilo moderno
  Widget _buildPowerLevelOption(int index, String nivel) {
    final isSelected = _nivelPoder == nivel;
    final colors = [
      AppTheme.ritualRed,
      AppTheme.chaoticMagenta,
      AppTheme.etherealPurple,
      AppTheme.alertYellow,
    ];
    final accentColor = colors[index % colors.length];

    return GestureDetector(
      onTap: () => setState(() => _nivelPoder = nivel),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? accentColor : AppTheme.industrialGray,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected
              ? accentColor.withOpacity(0.1)
              : AppTheme.industrialGray.withOpacity(0.3),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accentColor.withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: accentColor,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: accentColor,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              nivel,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: isSelected ? accentColor : AppTheme.paleWhite,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Constrói ponto de informação com ícone
  Widget _buildInfoPoint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.etherealPurple,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.coldGray,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
