import 'dart:math';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/character.dart';
import '../services/local_database_service.dart';

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

  // Gerar atributos baseados no nível de poder
  Map<String, int> _gerarAtributos(String nivel) {
    final random = Random();

    switch (nivel) {
      case 'Recruta (NEX 5%)':
        // Soma total: ~4 a 6
        return {
          'for': random.nextInt(3), // 0-2
          'agi': random.nextInt(3), // 0-2
          'vig': random.nextInt(3), // 0-2
          'int': random.nextInt(3), // 0-2
          'pre': random.nextInt(3), // 0-2
        };

      case 'Operador (NEX 10-25%)':
        // Soma total: ~7 a 12
        return {
          'for': random.nextInt(3) + 1, // 1-3
          'agi': random.nextInt(3) + 1, // 1-3
          'vig': random.nextInt(3) + 1, // 1-3
          'int': random.nextInt(3) + 1, // 1-3
          'pre': random.nextInt(3) + 1, // 1-3
        };

      case 'Agente Especial (NEX 30-55%)':
        // Soma total: ~15 a 20
        return {
          'for': random.nextInt(3) + 2, // 2-4
          'agi': random.nextInt(3) + 2, // 2-4
          'vig': random.nextInt(3) + 2, // 2-4
          'int': random.nextInt(3) + 2, // 2-4
          'pre': random.nextInt(3) + 2, // 2-4
        };

      case 'Elite (NEX 60-99%)':
        // Soma total: ~25 a 30
        return {
          'for': random.nextInt(3) + 4, // 4-6
          'agi': random.nextInt(3) + 4, // 4-6
          'vig': random.nextInt(3) + 4, // 4-6
          'int': random.nextInt(3) + 4, // 4-6
          'pre': random.nextInt(3) + 4, // 4-6
        };

      default:
        return {
          'for': 0,
          'agi': 0,
          'vig': 0,
          'int': 0,
          'pre': 0,
        };
    }
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_awesome,
                          color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'GERADOR DE NPCs',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Gere personagens rapidamente para combates e encontros. '
                    'Deixe os campos em branco para geração totalmente aleatória.',
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Nível de Poder
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nível de Poder',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 12),
                  ..._niveisPoder.map((nivel) {
                    return RadioListTile<String>(
                      value: nivel,
                      groupValue: _nivelPoder,
                      onChanged: (value) {
                        setState(() {
                          _nivelPoder = value!;
                        });
                      },
                      title: Text(nivel),
                      dense: true,
                    );
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Campos Opcionais
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Personalização (Opcional)',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _nomeController,
                    decoration: const InputDecoration(
                      labelText: 'Nome Personalizado',
                      hintText: 'Ex: Capanga 3, Cultista Alpha',
                      helperText: 'Deixe vazio para gerar automaticamente',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _iniciativaBaseController,
                    decoration: const InputDecoration(
                      labelText: 'Iniciativa Base',
                      hintText: 'Ex: 15',
                      helperText: 'Deixe vazio para gerar automaticamente',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Botão Gerar
          ElevatedButton.icon(
            onPressed: _isGenerating ? null : _gerarPersonagem,
            icon: _isGenerating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.auto_awesome),
            label: Text(_isGenerating ? 'Gerando...' : 'Gerar Personagem'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 16),

          // Informações
          Card(
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline,
                          size: 16, color: Colors.blue[300]),
                      const SizedBox(width: 8),
                      Text(
                        'Como funciona',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[300],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• Atributos, Status e Créditos são gerados automaticamente baseados no nível de poder\n'
                    '• Origem, Classe e Trilha são escolhidos aleatoriamente\n'
                    '• O personagem é salvo imediatamente no banco de dados\n'
                    '• Use para gerar NPCs, inimigos e aliados rapidamente',
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
