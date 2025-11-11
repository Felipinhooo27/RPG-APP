import 'dart:math';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/character.dart';
import '../../core/database/character_repository.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Tela de Gerador Rápido de Personagens
/// Gera NPCs rapidamente para combates e encontros
class QuickCharacterGeneratorScreen extends StatefulWidget {
  const QuickCharacterGeneratorScreen({super.key});

  @override
  State<QuickCharacterGeneratorScreen> createState() =>
      _QuickCharacterGeneratorScreenState();
}

class _QuickCharacterGeneratorScreenState
    extends State<QuickCharacterGeneratorScreen> {
  final CharacterRepository _repo = CharacterRepository();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _iniciativaBaseController =
      TextEditingController();

  String _nivelPoder = 'Recruta (NEX 5%)';
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

    // Define total de pontos baseado no nível
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
        userId: 'master_001',
        nome: nome,
        patente: _nivelPoder.split(' ')[0], // Pega só o primeiro termo
        nex: status['nex']!,
        origem: _mapOrigem(origem),
        classe: _mapClasse(classe),
        trilha: trilha,
        pvAtual: status['pvMax']!,
        pvMax: status['pvMax']!,
        peAtual: status['peMax']!,
        peMax: status['peMax']!,
        sanAtual: status['psMax']!,
        sanMax: status['psMax']!,
        creditos: status['creditos']!,
        forca: atributos['for']!,
        agilidade: atributos['agi']!,
        vigor: atributos['vig']!,
        intelecto: atributos['int']!,
        presenca: atributos['pre']!,
        defesa: 10 + atributos['agi']!,
        bloqueio: 0,
        deslocamento: 9,
        iniciativaBase: iniciativaBase,
        periciasTreinadas: [],
        poderesIds: [],
        inventarioIds: [],
      );

      // Salvar no banco
      await _repo.create(character);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Personagem "$nome" gerado com sucesso!'),
            backgroundColor: AppColors.conhecimentoGreen,
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
            backgroundColor: AppColors.neonRed,
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
      backgroundColor: AppColors.deepBlack,
      appBar: AppBar(
        backgroundColor: AppColors.darkGray,
        title: Text(
          'GERADOR RÁPIDO DE NPCs',
          style: AppTextStyles.uppercase.copyWith(fontSize: 14),
        ),
        iconTheme: const IconThemeData(color: AppColors.lightGray),
      ),
      body: Stack(
        children: [
          // Conteúdo principal
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Header com apresentação
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.darkGray,
                  border: Border.all(color: AppColors.neonRed, width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.auto_awesome,
                          color: AppColors.neonRed,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'GERADOR DE NPCs',
                            style: AppTextStyles.uppercase.copyWith(
                              fontSize: 16,
                              color: AppColors.neonRed,
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
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.silver,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Seleção de Nível de Poder
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.darkGray,
                  border: Border.all(color: AppColors.silver.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NÍVEL DE PODER',
                      style: AppTextStyles.uppercase.copyWith(
                        fontSize: 14,
                        color: AppColors.lightGray,
                      ),
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
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.darkGray,
                  border: Border.all(color: AppColors.silver.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PERSONALIZAÇÃO (OPCIONAL)',
                      style: AppTextStyles.uppercase.copyWith(
                        fontSize: 14,
                        color: AppColors.lightGray,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _nomeController,
                      style: AppTextStyles.body.copyWith(color: AppColors.lightGray),
                      decoration: InputDecoration(
                        labelText: 'Nome Personalizado',
                        labelStyle: TextStyle(color: AppColors.silver.withOpacity(0.7)),
                        hintText: 'Ex: Capanga 3, Cultista Alpha',
                        hintStyle: TextStyle(color: AppColors.silver.withOpacity(0.5)),
                        helperText: 'Deixe vazio para gerar automaticamente',
                        helperStyle: TextStyle(color: AppColors.silver.withOpacity(0.5), fontSize: 10),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                          borderSide: BorderSide(color: AppColors.silver.withOpacity(0.3)),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                          borderSide: BorderSide(
                            color: AppColors.neonRed,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _iniciativaBaseController,
                      style: AppTextStyles.body.copyWith(color: AppColors.lightGray),
                      decoration: InputDecoration(
                        labelText: 'Iniciativa Base',
                        labelStyle: TextStyle(color: AppColors.silver.withOpacity(0.7)),
                        hintText: 'Ex: 15',
                        hintStyle: TextStyle(color: AppColors.silver.withOpacity(0.5)),
                        helperText: 'Deixe vazio para gerar automaticamente',
                        helperStyle: TextStyle(color: AppColors.silver.withOpacity(0.5), fontSize: 10),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                          borderSide: BorderSide(color: AppColors.silver.withOpacity(0.3)),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                          borderSide: BorderSide(
                            color: AppColors.neonRed,
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

              // Botão Gerar
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isGenerating ? null : _gerarPersonagem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neonRed,
                    disabledBackgroundColor: AppColors.darkGray,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isGenerating)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.lightGray),
                          ),
                        )
                      else
                        const Icon(Icons.auto_awesome, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        _isGenerating ? 'GERANDO...' : 'GERAR PERSONAGEM',
                        style: const TextStyle(
                          fontSize: 14,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Informações
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.darkGray,
                  border: Border.all(color: AppColors.medoPurple.withOpacity(0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.medoPurple.withOpacity(0.2),
                            border: Border.all(color: AppColors.medoPurple, width: 1),
                          ),
                          child: const Icon(
                            Icons.info_outline,
                            color: AppColors.medoPurple,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'COMO FUNCIONA',
                          style: AppTextStyles.uppercase.copyWith(
                            fontSize: 12,
                            color: AppColors.medoPurple,
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
            Container(
              color: AppColors.deepBlack.withOpacity(0.8),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.neonRed),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Gerando personagem...',
                      style: AppTextStyles.body.copyWith(color: AppColors.lightGray),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Constrói opção de nível de poder com estilo moderno
  Widget _buildPowerLevelOption(int index, String nivel) {
    final isSelected = _nivelPoder == nivel;
    final colors = [
      AppColors.neonRed,
      AppColors.magenta,
      AppColors.medoPurple,
      AppColors.energiaYellow,
    ];
    final accentColor = colors[index % colors.length];

    return GestureDetector(
      onTap: () => setState(() => _nivelPoder = nivel),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? accentColor : AppColors.silver.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          color: isSelected
              ? accentColor.withOpacity(0.1)
              : AppColors.deepBlack,
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
              style: AppTextStyles.body.copyWith(
                color: isSelected ? accentColor : AppColors.lightGray,
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
              color: AppColors.medoPurple,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.silver,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  /// Mapeia string de origem para enum
  Origem _mapOrigem(String origem) {
    final origemNorm = origem
        .toLowerCase()
        .replaceAll(' ', '')
        .replaceAll('á', 'a')
        .replaceAll('ã', 'a')
        .replaceAll('ê', 'e')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ô', 'o')
        .replaceAll('ú', 'u');

    switch (origemNorm) {
      case 'academico':
        return Origem.academico;
      case 'agente':
      case 'agentesaude':
      case 'agentedesaude':
        return Origem.agente;
      case 'artista':
        return Origem.artista;
      case 'atleta':
        return Origem.atleta;
      case 'chef':
        return Origem.chef;
      case 'criminalista':
      case 'criminoso':
        return Origem.criminoso;
      case 'cultista':
      case 'cultistaarrependido':
        return Origem.cultista;
      case 'desgarrado':
        return Origem.desgarrado;
      case 'engenheiro':
        return Origem.engenheiro;
      case 'executivo':
        return Origem.executivo;
      case 'investigador':
        return Origem.investigador;
      case 'lutador':
        return Origem.lutador;
      case 'mercenario':
        return Origem.mercenario;
      case 'militar':
        return Origem.militar;
      case 'operario':
        return Origem.operario;
      case 'policial':
        return Origem.policial;
      case 'religioso':
        return Origem.religioso;
      case 'servidor':
      case 'servidorpublico':
        return Origem.servidor;
      case 'trambiqueiro':
        return Origem.trambiqueiro;
      case 'universitario':
        return Origem.universitario;
      case 'veterano':
        return Origem.veterano;
      case 'vitima':
        return Origem.vitima;
      default:
        return Origem.mercenario; // Fallback
    }
  }

  /// Mapeia string de classe para enum
  CharacterClass _mapClasse(String classe) {
    switch (classe.toLowerCase()) {
      case 'combatente':
        return CharacterClass.combatente;
      case 'especialista':
        return CharacterClass.especialista;
      case 'ocultista':
        return CharacterClass.ocultista;
      default:
        return CharacterClass.combatente;
    }
  }
}
