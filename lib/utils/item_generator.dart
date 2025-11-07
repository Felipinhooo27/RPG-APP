import 'dart:math';
import 'package:uuid/uuid.dart';
import '../models/item.dart';

class ItemData {
  final String nome;
  final String categoria;
  final int espaco;
  final int preco;
  final String? descricao;

  ItemData({
    required this.nome,
    required this.categoria,
    required this.espaco,
    required this.preco,
    this.descricao,
  });
}

class ItemGenerator {
  static final Random _random = Random();
  static const Uuid _uuid = Uuid();

  // ==================== ITENS MUNDANOS - BÁSICOS (30) ====================
  static final List<ItemData> _mundaneBasicItems = [
    // Pessoais básicos
    ItemData(nome: 'Carteira', categoria: 'Pessoal', espaco: 0, preco: 10),
    ItemData(nome: 'Celular', categoria: 'Eletrônico', espaco: 0, preco: 500),
    ItemData(nome: 'Chaves do Carro', categoria: 'Pessoal', espaco: 0, preco: 50),
    ItemData(nome: 'Documentos', categoria: 'Pessoal', espaco: 0, preco: 0),
    ItemData(nome: 'Relógio', categoria: 'Pessoal', espaco: 0, preco: 200),
    ItemData(nome: 'Óculos', categoria: 'Pessoal', espaco: 0, preco: 150),
    ItemData(nome: 'Mochila', categoria: 'Equipamento', espaco: 0, preco: 100, descricao: '+5 espaços de inventário'),
    ItemData(nome: 'Garrafa de Água', categoria: 'Consumível', espaco: 1, preco: 10),
    ItemData(nome: 'Lanche', categoria: 'Consumível', espaco: 1, preco: 20),
    ItemData(nome: 'Cigarro', categoria: 'Consumível', espaco: 0, preco: 15),

    // Ferramentas básicas
    ItemData(nome: 'Caneta', categoria: 'Ferramenta', espaco: 0, preco: 5),
    ItemData(nome: 'Caderno', categoria: 'Ferramenta', espaco: 1, preco: 15),
    ItemData(nome: 'Lanterna', categoria: 'Ferramenta', espaco: 1, preco: 50),
    ItemData(nome: 'Isqueiro', categoria: 'Ferramenta', espaco: 0, preco: 10),
    ItemData(nome: 'Faca Canivete', categoria: 'Ferramenta', espaco: 1, preco: 80),
    ItemData(nome: 'Corda (10m)', categoria: 'Ferramenta', espaco: 2, preco: 50),
    ItemData(nome: 'Fita Adesiva', categoria: 'Ferramenta', espaco: 1, preco: 20),
    ItemData(nome: 'Pilhas', categoria: 'Consumível', espaco: 0, preco: 15),
    ItemData(nome: 'Powerbank', categoria: 'Eletrônico', espaco: 1, preco: 100),
    ItemData(nome: 'Fones de Ouvido', categoria: 'Eletrônico', espaco: 0, preco: 80),

    // Higiene e saúde
    ItemData(nome: 'Kit Primeiros Socorros', categoria: 'Médico', espaco: 2, preco: 150),
    ItemData(nome: 'Remédio para Dor', categoria: 'Médico', espaco: 0, preco: 25),
    ItemData(nome: 'Bandagem', categoria: 'Médico', espaco: 1, preco: 30),
    ItemData(nome: 'Álcool em Gel', categoria: 'Médico', espaco: 1, preco: 15),
    ItemData(nome: 'Escova de Dentes', categoria: 'Higiene', espaco: 0, preco: 10),
    ItemData(nome: 'Sabonete', categoria: 'Higiene', espaco: 1, preco: 8),
    ItemData(nome: 'Toalha', categoria: 'Higiene', espaco: 2, preco: 40),
    ItemData(nome: 'Cortador de Unha', categoria: 'Higiene', espaco: 0, preco: 12),
    ItemData(nome: 'Desodorante', categoria: 'Higiene', espaco: 1, preco: 18),
    ItemData(nome: 'Perfume', categoria: 'Higiene', espaco: 1, preco: 120),
  ];

  // ==================== ITENS PROFISSIONAIS (25) ====================
  static final List<ItemData> _professionalItems = [
    // Investigação
    ItemData(nome: 'Lupa', categoria: 'Investigação', espaco: 1, preco: 60),
    ItemData(nome: 'Kit Forense', categoria: 'Investigação', espaco: 3, preco: 500),
    ItemData(nome: 'Câmera Fotográfica', categoria: 'Investigação', espaco: 2, preco: 800),
    ItemData(nome: 'Gravador de Voz', categoria: 'Investigação', espaco: 1, preco: 200),
    ItemData(nome: 'Binóculos', categoria: 'Investigação', espaco: 2, preco: 300),

    // Tecnologia
    ItemData(nome: 'Laptop', categoria: 'Eletrônico', espaco: 3, preco: 2000),
    ItemData(nome: 'Tablet', categoria: 'Eletrônico', espaco: 1, preco: 1200),
    ItemData(nome: 'GPS', categoria: 'Eletrônico', espaco: 1, preco: 400),
    ItemData(nome: 'Rádio Comunicador', categoria: 'Eletrônico', espaco: 1, preco: 350),
    ItemData(nome: 'Drone', categoria: 'Eletrônico', espaco: 4, preco: 3000),

    // Ferramentas profissionais
    ItemData(nome: 'Kit de Ferramentas', categoria: 'Ferramenta', espaco: 4, preco: 500),
    ItemData(nome: 'Alicate', categoria: 'Ferramenta', espaco: 1, preco: 45),
    ItemData(nome: 'Chave de Fenda', categoria: 'Ferramenta', espaco: 1, preco: 35),
    ItemData(nome: 'Martelo', categoria: 'Ferramenta', espaco: 2, preco: 60),
    ItemData(nome: 'Serra', categoria: 'Ferramenta', espaco: 2, preco: 80),
    ItemData(nome: 'Furadeira', categoria: 'Ferramenta', espaco: 3, preco: 350),
    ItemData(nome: 'Chave Inglesa', categoria: 'Ferramenta', espaco: 2, preco: 70),
    ItemData(nome: 'Kit de Lockpick', categoria: 'Ferramenta', espaco: 1, preco: 250),

    // Médico
    ItemData(nome: 'Estetoscópio', categoria: 'Médico', espaco: 1, preco: 300),
    ItemData(nome: 'Termômetro', categoria: 'Médico', espaco: 0, preco: 50),
    ItemData(nome: 'Seringa', categoria: 'Médico', espaco: 0, preco: 15),
    ItemData(nome: 'Kit Cirúrgico', categoria: 'Médico', espaco: 4, preco: 1000),
    ItemData(nome: 'Analgésico Forte', categoria: 'Médico', espaco: 1, preco: 100),
    ItemData(nome: 'Antibiótico', categoria: 'Médico', espaco: 1, preco: 120),
    ItemData(nome: 'Adrenalina', categoria: 'Médico', espaco: 1, preco: 200),
  ];

  // ==================== ARMAS BRANCAS (15) ====================
  static final List<ItemData> _meleeWeapons = [
    ItemData(nome: 'Faca de Combate', categoria: 'Arma', espaco: 1, preco: 200, descricao: '1d6 dano'),
    ItemData(nome: 'Adaga', categoria: 'Arma', espaco: 1, preco: 150, descricao: '1d4 dano'),
    ItemData(nome: 'Machado', categoria: 'Arma', espaco: 3, preco: 350, descricao: '1d8 dano'),
    ItemData(nome: 'Espada Curta', categoria: 'Arma', espaco: 2, preco: 500, descricao: '1d6 dano'),
    ItemData(nome: 'Espada Longa', categoria: 'Arma', espaco: 3, preco: 800, descricao: '1d8 dano'),
    ItemData(nome: 'Bastão', categoria: 'Arma', espaco: 2, preco: 100, descricao: '1d6 dano'),
    ItemData(nome: 'Taco de Beisebol', categoria: 'Arma', espaco: 2, preco: 80, descricao: '1d6 dano'),
    ItemData(nome: 'Cassetete', categoria: 'Arma', espaco: 1, preco: 150, descricao: '1d6 dano'),
    ItemData(nome: 'Lança', categoria: 'Arma', espaco: 3, preco: 300, descricao: '1d8 dano'),
    ItemData(nome: 'Katana', categoria: 'Arma', espaco: 2, preco: 1500, descricao: '1d10 dano'),
    ItemData(nome: 'Machete', categoria: 'Arma', espaco: 2, preco: 250, descricao: '1d6 dano'),
    ItemData(nome: 'Marreta', categoria: 'Arma', espaco: 4, preco: 400, descricao: '2d6 dano'),
    ItemData(nome: 'Soqueira', categoria: 'Arma', espaco: 0, preco: 120, descricao: '1d4 dano'),
    ItemData(nome: 'Corrente', categoria: 'Arma', espaco: 2, preco: 180, descricao: '1d6 dano'),
    ItemData(nome: 'Nunchaku', categoria: 'Arma', espaco: 1, preco: 200, descricao: '1d6 dano'),
  ];

  // ==================== ARMAS DE FOGO (20) ====================
  static final List<ItemData> _firearms = [
    // Pistolas
    ItemData(nome: 'Pistola .38', categoria: 'Arma de Fogo', espaco: 2, preco: 1200, descricao: '2d6 dano'),
    ItemData(nome: 'Pistola 9mm', categoria: 'Arma de Fogo', espaco: 2, preco: 1500, descricao: '2d6 dano'),
    ItemData(nome: 'Revólver .357', categoria: 'Arma de Fogo', espaco: 2, preco: 1800, descricao: '2d8 dano'),
    ItemData(nome: 'Desert Eagle', categoria: 'Arma de Fogo', espaco: 3, preco: 2500, descricao: '3d6 dano'),

    // Rifles
    ItemData(nome: 'Rifle de Assalto', categoria: 'Arma de Fogo', espaco: 5, preco: 3500, descricao: '3d8 dano'),
    ItemData(nome: 'Rifle de Precisão', categoria: 'Arma de Fogo', espaco: 6, preco: 4000, descricao: '4d8 dano'),
    ItemData(nome: 'AK-47', categoria: 'Arma de Fogo', espaco: 5, preco: 3000, descricao: '3d8 dano'),
    ItemData(nome: 'M16', categoria: 'Arma de Fogo', espaco: 5, preco: 3500, descricao: '3d8 dano'),

    // Escopetas
    ItemData(nome: 'Escopeta', categoria: 'Arma de Fogo', espaco: 4, preco: 2000, descricao: '4d6 dano (curto alcance)'),
    ItemData(nome: 'Escopeta Sawed-off', categoria: 'Arma de Fogo', espaco: 3, preco: 1800, descricao: '3d8 dano (curto alcance)'),

    // SMGs
    ItemData(nome: 'UZI', categoria: 'Arma de Fogo', espaco: 3, preco: 2500, descricao: '2d8 dano (automático)'),
    ItemData(nome: 'MP5', categoria: 'Arma de Fogo', espaco: 3, preco: 2800, descricao: '2d8 dano (automático)'),

    // Especiais
    ItemData(nome: 'Arco', categoria: 'Arma', espaco: 4, preco: 500, descricao: '2d6 dano'),
    ItemData(nome: 'Besta', categoria: 'Arma', espaco: 4, preco: 800, descricao: '2d8 dano'),
    ItemData(nome: 'Granada', categoria: 'Explosivo', espaco: 1, preco: 500, descricao: '6d6 dano (área)'),
    ItemData(nome: 'Granada de Fumaça', categoria: 'Tático', espaco: 1, preco: 200, descricao: 'Cria nuvem de fumaça'),
    ItemData(nome: 'Granada Flashbang', categoria: 'Tático', espaco: 1, preco: 250, descricao: 'Atordoa inimigos'),

    // Munição
    ItemData(nome: 'Munição Pistola (50)', categoria: 'Munição', espaco: 1, preco: 100),
    ItemData(nome: 'Munição Rifle (30)', categoria: 'Munição', espaco: 1, preco: 150),
    ItemData(nome: 'Cartuchos Escopeta (25)', categoria: 'Munição', espaco: 1, preco: 120),
  ];

  // ==================== PROTEÇÃO (20) ====================
  static final List<ItemData> _armor = [
    // Colete
    ItemData(nome: 'Colete Leve', categoria: 'Proteção', espaco: 3, preco: 800, descricao: '+2 Defesa'),
    ItemData(nome: 'Colete Médio', categoria: 'Proteção', espaco: 4, preco: 1500, descricao: '+4 Defesa'),
    ItemData(nome: 'Colete Pesado', categoria: 'Proteção', espaco: 6, preco: 2500, descricao: '+6 Defesa'),
    ItemData(nome: 'Colete Tático', categoria: 'Proteção', espaco: 5, preco: 2000, descricao: '+5 Defesa, +2 espaços'),

    // Capacete
    ItemData(nome: 'Capacete Tático', categoria: 'Proteção', espaco: 2, preco: 500, descricao: '+1 Defesa'),
    ItemData(nome: 'Capacete Balístico', categoria: 'Proteção', espaco: 3, preco: 1000, descricao: '+2 Defesa'),

    // Escudos
    ItemData(nome: 'Escudo Pequeno', categoria: 'Proteção', espaco: 3, preco: 400, descricao: '+2 Defesa'),
    ItemData(nome: 'Escudo Grande', categoria: 'Proteção', espaco: 5, preco: 800, descricao: '+4 Defesa'),
    ItemData(nome: 'Escudo Riot', categoria: 'Proteção', espaco: 6, preco: 1200, descricao: '+5 Defesa'),

    // Roupas de proteção
    ItemData(nome: 'Jaqueta de Couro', categoria: 'Proteção', espaco: 2, preco: 300, descricao: '+1 Defesa'),
    ItemData(nome: 'Roupa Kevlar', categoria: 'Proteção', espaco: 3, preco: 1800, descricao: '+3 Defesa'),
    ItemData(nome: 'Traje Hazmat', categoria: 'Proteção', espaco: 4, preco: 1000, descricao: 'Proteção química'),

    // Acessórios
    ItemData(nome: 'Luvas Táticas', categoria: 'Proteção', espaco: 1, preco: 150, descricao: '+1 Luta'),
    ItemData(nome: 'Botas Táticas', categoria: 'Proteção', espaco: 2, preco: 300, descricao: '+1 Atletismo'),
    ItemData(nome: 'Óculos de Proteção', categoria: 'Proteção', espaco: 1, preco: 120, descricao: 'Proteção ocular'),
    ItemData(nome: 'Máscara de Gás', categoria: 'Proteção', espaco: 2, preco: 600, descricao: 'Imune a gases'),
    ItemData(nome: 'Joelheiras', categoria: 'Proteção', espaco: 1, preco: 100),
    ItemData(nome: 'Cotoveleiras', categoria: 'Proteção', espaco: 1, preco: 100),
    ItemData(nome: 'Protetor Bucal', categoria: 'Proteção', espaco: 0, preco: 50),
    ItemData(nome: 'Capa Longa', categoria: 'Proteção', espaco: 2, preco: 200, descricao: '+1 Defesa, estilo'),
  ];

  // ==================== ITENS PARANORMAIS - MENOR (25) ====================
  static final List<ItemData> _paranormalMinor = [
    // Amuletos
    ItemData(nome: 'Amuleto de Proteção', categoria: 'Paranormal', espaco: 0, preco: 500, descricao: '+1 Defesa contra paranormal'),
    ItemData(nome: 'Talismã da Sorte', categoria: 'Paranormal', espaco: 0, preco: 400, descricao: '+1 em um teste/dia'),
    ItemData(nome: 'Colar de Safira', categoria: 'Paranormal', espaco: 0, preco: 800, descricao: '+2 SAN'),
    ItemData(nome: 'Anel de Rubi', categoria: 'Paranormal', espaco: 0, preco: 900, descricao: '+2 PV'),
    ItemData(nome: 'Bracelete de Prata', categoria: 'Paranormal', espaco: 0, preco: 600, descricao: 'Detecta paranormal'),

    // Livros místicos
    ItemData(nome: 'Grimório Menor', categoria: 'Paranormal', espaco: 2, preco: 1000, descricao: '+1 Ocultismo'),
    ItemData(nome: 'Diário de Investigador', categoria: 'Paranormal', espaco: 1, preco: 500, descricao: '+1 Investigação'),
    ItemData(nome: 'Tomo Ancestral', categoria: 'Paranormal', espaco: 3, preco: 1500, descricao: '+2 Conhecimento'),

    // Ferramentas paranormais
    ItemData(nome: 'Vela Ritualística', categoria: 'Paranormal', espaco: 0, preco: 100, descricao: 'Usada em rituais'),
    ItemData(nome: 'Incenso Místico', categoria: 'Paranormal', espaco: 1, preco: 150, descricao: 'Acalma espíritos'),
    ItemData(nome: 'Cristal de Quartzo', categoria: 'Paranormal', espaco: 1, preco: 300, descricao: 'Amplifica energia'),
    ItemData(nome: 'Sal Consagrado', categoria: 'Paranormal', espaco: 1, preco: 200, descricao: 'Cria barreira espiritual'),
    ItemData(nome: 'Água Benta', categoria: 'Paranormal', espaco: 1, preco: 250, descricao: '2d6 dano em mortos-vivos'),
    ItemData(nome: 'Crucifixo Abençoado', categoria: 'Paranormal', espaco: 1, preco: 400, descricao: 'Repele mortos-vivos'),
    ItemData(nome: 'Pentagrama', categoria: 'Paranormal', espaco: 1, preco: 500, descricao: 'Proteção em rituais'),

    // Detecção
    ItemData(nome: 'EMF Detector', categoria: 'Paranormal', espaco: 1, preco: 600, descricao: 'Detecta atividade paranormal'),
    ItemData(nome: 'Termômetro Paranormal', categoria: 'Paranormal', espaco: 1, preco: 400, descricao: 'Detecta quedas de temperatura'),
    ItemData(nome: 'Spirit Box', categoria: 'Paranormal', espaco: 2, preco: 800, descricao: 'Comunica com espíritos'),
    ItemData(nome: 'Câmera Infravermelha', categoria: 'Paranormal', espaco: 2, preco: 1200, descricao: 'Vê no escuro'),
    ItemData(nome: 'Pêndulo Místico', categoria: 'Paranormal', espaco: 0, preco: 300, descricao: 'Radiestesia'),

    // Consumíveis paranormais
    ItemData(nome: 'Poção de Cura Menor', categoria: 'Paranormal', espaco: 1, preco: 500, descricao: 'Recupera 2d8 PV'),
    ItemData(nome: 'Elixir de Coragem', categoria: 'Paranormal', espaco: 1, preco: 400, descricao: 'Imune a medo por 10min'),
    ItemData(nome: 'Ungento de Resistência', categoria: 'Paranormal', espaco: 1, preco: 600, descricao: '+2 Defesa por 1 hora'),
    ItemData(nome: 'Pó de Revelação', categoria: 'Paranormal', espaco: 1, preco: 350, descricao: 'Revela o invisível'),
    ItemData(nome: 'Essência Espiritual', categoria: 'Paranormal', espaco: 1, preco: 700, descricao: 'Recupera 5 PE'),
  ];

  // ==================== ITENS PARANORMAIS - MAIOR (20) ====================
  static final List<ItemData> _paranormalMajor = [
    // Armas encantadas
    ItemData(nome: 'Lâmina Flamejante', categoria: 'Arma Mágica', espaco: 2, preco: 3000, descricao: '2d8 + 2d6 fogo'),
    ItemData(nome: 'Adaga das Sombras', categoria: 'Arma Mágica', espaco: 1, preco: 2500, descricao: '1d8 + invisibilidade'),
    ItemData(nome: 'Espada Sagrada', categoria: 'Arma Mágica', espaco: 3, preco: 4000, descricao: '2d10 + 3d6 vs mortos-vivos'),
    ItemData(nome: 'Arco Élfico', categoria: 'Arma Mágica', espaco: 4, preco: 3500, descricao: '3d6 + nunca erra'),
    ItemData(nome: 'Martelo do Trovão', categoria: 'Arma Mágica', espaco: 4, preco: 5000, descricao: '3d8 + 2d6 elétrico'),

    // Armaduras mágicas
    ItemData(nome: 'Armadura Espectral', categoria: 'Proteção Mágica', espaco: 0, preco: 4500, descricao: '+8 Defesa, não pesa'),
    ItemData(nome: 'Manto da Invisibilidade', categoria: 'Proteção Mágica', espaco: 2, preco: 6000, descricao: 'Invisibilidade 3x/dia'),
    ItemData(nome: 'Escudo da Fé', categoria: 'Proteção Mágica', espaco: 4, preco: 3500, descricao: '+6 Defesa + imune medo'),

    // Artefatos poderosos
    ItemData(nome: 'Varinha das Estrelas', categoria: 'Artefato', espaco: 1, preco: 5000, descricao: 'Lança rajada mágica 3d10'),
    ItemData(nome: 'Orbe do Conhecimento', categoria: 'Artefato', espaco: 2, preco: 4000, descricao: '+5 em todos testes de Conhecimento'),
    ItemData(nome: 'Anel do Poder', categoria: 'Artefato', espaco: 0, preco: 7000, descricao: '+1 em todos atributos'),
    ItemData(nome: 'Cajado Arcano', categoria: 'Artefato', espaco: 3, preco: 6000, descricao: '+10 PE, +2 magia'),
    ItemData(nome: 'Coroa da Mente', categoria: 'Artefato', espaco: 1, preco: 5500, descricao: '+4 Intelecto, Telepatia'),

    // Grimórios poderosos
    ItemData(nome: 'Necronomicon', categoria: 'Grimório', espaco: 4, preco: 10000, descricao: '+5 Ocultismo, -2 SAN/dia'),
    ItemData(nome: 'Livro das Sombras', categoria: 'Grimório', espaco: 3, preco: 8000, descricao: 'Aprende 3 magias'),
    ItemData(nome: 'Códice Dracônico', categoria: 'Grimório', espaco: 3, preco: 7000, descricao: 'Fala com dragões'),

    // Relíquias
    ItemData(nome: 'Cálice Sagrado', categoria: 'Relíquia', espaco: 2, preco: 12000, descricao: 'Cura completa 1x/dia'),
    ItemData(nome: 'Lança do Destino', categoria: 'Relíquia', espaco: 3, preco: 15000, descricao: '5d10 dano, +10 Luta'),
    ItemData(nome: 'Olho de Horus', categoria: 'Relíquia', espaco: 1, preco: 9000, descricao: 'Visão verdadeira permanente'),
    ItemData(nome: 'Coração de Fênix', categoria: 'Relíquia', espaco: 1, preco: 20000, descricao: 'Ressurreição automática'),
  ];

  // ==================== ITENS DIVINOS (10) ====================
  static final List<ItemData> _divineItems = [
    ItemData(nome: 'Excalibur', categoria: 'Arma Divina', espaco: 3, preco: 50000, descricao: '10d10 dano, +15 todos atributos'),
    ItemData(nome: 'Mjölnir', categoria: 'Arma Divina', espaco: 4, preco: 50000, descricao: '10d12 + controla raios'),
    ItemData(nome: 'Égide de Athena', categoria: 'Proteção Divina', espaco: 5, preco: 45000, descricao: '+20 Defesa, imune magia'),
    ItemData(nome: 'Elmo de Hades', categoria: 'Proteção Divina', espaco: 2, preco: 40000, descricao: 'Invisibilidade permanente'),
    ItemData(nome: 'Tridente de Poseidon', categoria: 'Arma Divina', espaco: 4, preco: 50000, descricao: '10d10 + controla água'),
    ItemData(nome: 'Anel de Salomão', categoria: 'Artefato Divino', espaco: 0, preco: 60000, descricao: 'Controla demônios'),
    ItemData(nome: 'Arca da Aliança', categoria: 'Relíquia Divina', espaco: 10, preco: 100000, descricao: 'Poder divino absoluto'),
    ItemData(nome: 'Santo Graal', categoria: 'Relíquia Divina', espaco: 2, preco: 80000, descricao: 'Imortalidade'),
    ItemData(nome: 'Asas de Ícaros', categoria: 'Artefato Divino', espaco: 0, preco: 35000, descricao: 'Voo permanente'),
    ItemData(nome: 'Cetro de Zeus', categoria: 'Arma Divina', espaco: 3, preco: 70000, descricao: 'Lança relâmpagos divinos'),
  ];

  /// Gera itens aleatórios baseado na categoria do personagem
  static List<Item> generateItems(String category) {
    final items = <Item>[];

    switch (category) {
      case 'Civil':
        // Civis têm 3-5 itens mundanos básicos
        items.addAll(_getRandomItems(_mundaneBasicItems, 3 + _random.nextInt(3)));
        break;

      case 'Mercenário':
      case 'Soldado':
        // Soldados/Mercenários: itens básicos + 1-2 armas + proteção leve
        items.addAll(_getRandomItems(_mundaneBasicItems, 2));
        items.addAll(_getRandomItems([..._meleeWeapons, ..._firearms], 1 + _random.nextInt(2)));
        items.addAll(_getRandomItems(_armor, 1));
        break;

      case 'Chefe':
        // Chefes: itens profissionais + arma + proteção média
        items.addAll(_getRandomItems(_mundaneBasicItems, 2));
        items.addAll(_getRandomItems(_professionalItems, 2));
        items.addAll(_getRandomItems([..._meleeWeapons, ..._firearms], 1));
        items.addAll(_getRandomItems(_armor, 1));
        break;

      case 'Líder':
        // Líderes: itens profissionais + boa arma + boa proteção + paranormal menor
        items.addAll(_getRandomItems(_professionalItems, 3));
        items.addAll(_getRandomItems(_firearms, 1));
        items.addAll(_getRandomItems(_armor, 2));
        items.addAll(_getRandomItems(_paranormalMinor, 1 + _random.nextInt(2)));
        break;

      case 'Profissional':
        // Profissionais: muitos itens profissionais + arma + proteção + paranormal
        items.addAll(_getRandomItems(_professionalItems, 4));
        items.addAll(_getRandomItems(_firearms, 1));
        items.addAll(_getRandomItems(_armor, 2));
        items.addAll(_getRandomItems(_paranormalMinor, 2 + _random.nextInt(2)));
        items.addAll(_getRandomItems(_paranormalMajor, 1));
        break;

      case 'Deus':
        // Deuses: itens divinos + paranormais maiores
        items.addAll(_getRandomItems(_divineItems, 2 + _random.nextInt(3)));
        items.addAll(_getRandomItems(_paranormalMajor, 3 + _random.nextInt(3)));
        break;
    }

    return items;
  }

  static List<Item> _getRandomItems(List<ItemData> pool, int count) {
    final items = <Item>[];
    final shuffled = List<ItemData>.from(pool)..shuffle(_random);

    for (int i = 0; i < count && i < shuffled.length; i++) {
      final itemData = shuffled[i];
      items.add(Item(
        id: _uuid.v4(),
        nome: itemData.nome,
        descricao: itemData.descricao ?? '',
        quantidade: 1,
        tipo: itemData.categoria,
        categoria: itemData.categoria,
        espaco: itemData.espaco,
        preco: itemData.preco,
      ));
    }

    return items;
  }

  /// Retorna um item aleatório de qualquer categoria
  static Item getRandomItem() {
    final allItems = [
      ..._mundaneBasicItems,
      ..._professionalItems,
      ..._meleeWeapons,
      ..._firearms,
      ..._armor,
      ..._paranormalMinor,
      ..._paranormalMajor,
      ..._divineItems,
    ];

    final itemData = allItems[_random.nextInt(allItems.length)];
    return Item(
      id: _uuid.v4(),
      nome: itemData.nome,
      descricao: itemData.descricao ?? '',
      quantidade: 1,
      tipo: itemData.categoria,
      categoria: itemData.categoria,
      espaco: itemData.espaco,
      preco: itemData.preco,
    );
  }

  /// Conta total de itens disponíveis
  static int getTotalItemCount() {
    return _mundaneBasicItems.length +
        _professionalItems.length +
        _meleeWeapons.length +
        _firearms.length +
        _armor.length +
        _paranormalMinor.length +
        _paranormalMajor.length +
        _divineItems.length;
  }
}
