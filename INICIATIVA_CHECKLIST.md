# Checklist de Refatoração - IniciativaScreen

## Arquivo
- [x] E:\RPG-APP\lib\screens\iniciativa_screen.dart

## Requisito 1: HexLoading.large() com Mensagens
- [x] Loading state mostra HexLoading.large()
- [x] Mensagem contextual adicionada: "Carregando combatentes..."
- [x] Localização: Linha 174-177
- [x] Center wrapping aplicado

## Requisito 2: EmptyState para Estados Vazios
- [x] Character selection vazio usa EmptyState
  - [x] Ícone: Icons.shield_outlined
  - [x] Título: "Nenhum Combatente"
  - [x] Mensagem: "Crie personagens primeiro para iniciar um combate"
  - [x] Localização: Linhas 180-184
- [x] Combat vazio usa EmptyState.noCombat()
  - [x] Localização: Linhas 509-510

## Requisito 3: RitualCard para Character Selection
- [x] Cada personagem em RitualCard
- [x] RitualCard tem glowEffect quando selecionado
- [x] Checkbox com styling 48x48
- [x] Info do personagem (nome, classe, AGI, init)
- [x] Auto-save toggle condicional
- [x] Animações (fadeIn + slideX)
- [x] Localização: Linhas 237-373

## Requisito 4: RitualCard para Combat Tracker
- [x] Cada combatente em RitualCard
- [x] Position indicator 48x48
- [x] Title com nome + initiative badge
- [x] Subtitle com PV bar + stats
- [x] Expansion tile para detalhes
- [x] Glow quando é turno atual
- [x] Localização: Linhas 547-813

## Requisito 5: BorderRadius 6-8px (NÃO 20px)
- [x] Checkbox container: circular(6) - Linha 263
- [x] Auto-save toggle: circular(6) - Linha 322
- [x] Combat position indicator: circular(6) - Linha 562
- [x] Initiative badge: circular(6) - Linha 601
- [x] Initiative details container: circular(6) - Linha 675
- [x] PV display container: circular(6) - Linha 750
- [x] PV buttons: circular(6) - Linha 830
- [x] Progress bar: circular(3) - Linha 629
- [x] Nenhum elemento com circular(20) ou maior

## Requisito 6: GlowingButton para Ações
- [x] Botão "Anterior" (secondary style)
  - [x] Icon: Icons.arrow_back
  - [x] Localização: Linhas 477-486
- [x] Botão "Próximo" (danger style)
  - [x] Icon: Icons.arrow_forward
  - [x] Localização: Linhas 490-500
- [x] Botão "Remover do Combate" (danger style)
  - [x] Icon: Icons.remove_circle_outline
  - [x] Localização: Linhas 803-810
- [x] Todos os botões chamam callbacks apropriados

## Requisito 7: Diálogos com Dialog + RitualCard + GlowingButton

### Dialog 1: Erro Inicial (_showInitErrorDialog)
- [x] Função criada - Linhas 849-916
- [x] Disparado quando selectedIds.isEmpty
- [x] Dialog com backgroundColor: Colors.transparent
- [x] RitualCard com glowEffect: true
- [x] glowColor: AppTheme.ritualRed
- [x] Icon container 64x64
- [x] Icon: Icons.warning_outlined
- [x] Título: "AVISO" (BebasNeue, ritualRed)
- [x] Mensagem paramétrica (Montserrat, coldGray)
- [x] GlowingButton "Entendido" (primary, fullWidth)
- [x] Navigator.pop ao confirmar

### Dialog 2: Re-rolar Iniciativa (_showRerollInitiativeDialog)
- [x] Função criada - Linhas 918-1017
- [x] Disparado via IconButton (refresh icon)
- [x] glowColor: AppTheme.etherealPurple
- [x] Icon: Icons.shuffle
- [x] Título: "RE-ROLAR INICIATIVA"
- [x] Dois botões: Cancelar (secondary) + Confirmar (primary)
- [x] Lógica ao confirmar:
  - [x] Re-rola todas as iniciativas
  - [x] Ordena por iniciativa
  - [x] Reseta session
  - [x] setState() atualiza UI

### Dialog 3: Finalizar Combate (_showEndCombatDialog)
- [x] Função criada - Linhas 1019-1102
- [x] Disparado via IconButton (close icon)
- [x] glowColor: AppTheme.alertYellow
- [x] Icon: Icons.stop_circle_outlined
- [x] Título: "FINALIZAR COMBATE"
- [x] Dois botões: Cancelar + Encerrar (danger)
- [x] Lógica ao confirmar:
  - [x] Navigator.pop()
  - [x] Chama _finalizarCombate()

### Dialog 4: Remover Combatente (_showRemoveCombatantDialog)
- [x] Função criada - Linhas 1104-1193
- [x] Disparado via GlowingButton em expansion
- [x] Parâmetros: combatente, index, session
- [x] glowColor: AppTheme.ritualRed
- [x] Icon: Icons.person_remove_outlined
- [x] Título: "REMOVER COMBATENTE"
- [x] Mensagem inclui nome: "Remover ${combatente.character.nome}..."
- [x] Dois botões: Cancelar + Remover (danger)
- [x] Lógica ao confirmar:
  - [x] Navigator.pop()
  - [x] setState() com session.removerCombatente(index)

## Validações Gerais
- [x] Nenhum erro crítico no flutter analyze
- [x] Todos os imports presentes (via widgets.dart)
- [x] Sintaxe Dart válida
- [x] Funcionalidade original preservada
- [x] Estado gerenciado corretamente com setState()
- [x] Animações usando flutter_animate

## Melhorias de UX Implementadas
- [x] Mensagens de carregamento descritivas
- [x] Estados vazios visuais
- [x] Confirmações para ações destrutivas
- [x] Feedback visual com diálogos
- [x] Cores semânticas por contexto
- [x] Ícones contextuais
- [x] Bordas consistentes
- [x] Sem SnackBar (substituído por Dialog)

## Componentes Utilizados
- [x] HexLoading - Spinner com mensagem
- [x] EmptyState - Estados vazios
- [x] RitualCard - Cards temáticos
- [x] GlowingButton - Botões com brilho
- [x] Dialog - Diálogos modais
- [x] AppTheme - Paleta de cores

## Arquivo Final
- [x] Total de linhas: 1195
- [x] Sem erros críticos
- [x] Pronto para merge

