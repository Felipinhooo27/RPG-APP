# Character Wizard Screen - Guia Visual Hexatombe

## Estrutura da Tela

```
┌─────────────────────────────────────┐
│  AppBar (NOVO/EDITAR AGENTE)       │
│  Passo X de 6                       │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│  Progress Indicator                 │
│  [====  ]                           │
│  Progresso: 2 de 6                  │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│                                     │
│   RitualCard (Step Content)         │
│   ┌─────────────────────────────┐   │
│   │ ✦ Título                   ✦ │   │
│   │                             │   │
│   │ Conteúdo do Step           │   │
│   │                             │   │
│   │ ✦ ✦ ✦ ✦               ✦ ✦ │   │
│   └─────────────────────────────┘   │
│   [Glow: Cor temática]              │
│                                     │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│  [Anterior]  [Próximo/Finalizar]   │
│  Secondary     Primary Glowing      │
└─────────────────────────────────────┘
```

## Cores por Step

| Step | Título | Cor | Glow |
|------|--------|-----|------|
| 1 | INFORMAÇÕES BÁSICAS | Red | Red |
| 2 | ORIGEM & CLASSE | Magenta | Magenta |
| 3 | ATRIBUTOS | Purple | Purple |
| 4 | PONTOS DE VIDA & ENERGIA | Green | Green |
| 5 | PERÍCIAS | Yellow | Yellow |
| 6 | REVISÃO FINAL | Red | Red + Pulsate |

## Componentes Hexatombe Utilizados

### 1. HexLoading.large() - Estado de Salvamento
```dart
HexLoading.large(
  color: AppTheme.ritualRed,
  message: 'Salvando Agente...',
)
```
- Spinner circular com brilho
- Pulsação animada
- Mensagem contextualizada

### 2. RitualCard - Containers de Step
```dart
RitualCard(
  glowEffect: true,
  glowColor: AppTheme.ritualRed,
  ritualCorners: true,  // Símbolos nos cantos
  pulsate: false,       // true apenas no Step 6
  child: Column(...)
)
```
- Gradient obscureGray → industrialGray
- Símbolos rituais nos 4 cantos
- BoxShadow com cor temática
- BorderRadius.circular(8)

### 3. GlowingButton - Navegação
```dart
GlowingButton(
  label: 'Próximo',
  icon: Icons.arrow_forward_rounded,
  onPressed: _nextStep,
  pulsateGlow: false,
  style: GlowingButtonStyle.primary,
)
```
- Glow animado com intensidade variável
- Escala ao pressionar (0.96)
- BorderRadius.circular(8)
- Cores: primary/secondary/danger/occult

### 4. TextField Modernizado
```dart
TextField(
  decoration: InputDecoration(
    filled: true,
    fillColor: AppTheme.obscureGray,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(
        color: AppTheme.ritualRed,
        width: 2,
      ),
    ),
  ),
)
```
- BorderRadius: 6px
- Focus: ritualRed com width 2
- Enabled: coldGray com width 1.5

### 5. Diálogo Moderno
```dart
Dialog(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(8),
  ),
  child: Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [obscureGray, industrialGray],
      ),
      borderRadius: BorderRadius.circular(8),
      boxShadow: [
        BoxShadow(
          color: accentColor.withOpacity(0.3),
          blurRadius: 16,
          spreadRadius: 2,
        ),
      ],
    ),
    child: Column(
      children: [
        // Ícone com container brilhante
        Container(
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: accentColor.withOpacity(0.4),
                blurRadius: 12,
              ),
            ],
          ),
          child: Icon(icon, color: accentColor),
        ),
        // Título BebasNeue
        Text(title, style: BebasNeue),
        // Mensagem Montserrat
        Text(message, style: Montserrat),
        // Botão GlowingButton
        GlowingButton(label: 'Confirmar'),
      ],
    ),
  ),
)
```

## Animações Aplicadas

### Fade In
```dart
.animate().fadeIn(duration: 400.ms)
```
- Todos os RitualCards

### Scale
```dart
.animate().scale(begin: const Offset(0.9, 0.9))
```
- Steps 5 e 6

### SlideX
```dart
.animate().slideX(begin: -0.2, end: 0)
```
- Cards durante navegação

### Shimmer
```dart
.animate().shimmer(duration: 2000.ms, color: ...)
```
- Step 6 Review (pulsate)

## Fluxo de Navegação

```
Step 1: Informações Básicas
    ↓ [Próximo]
Step 2: Origem & Classe
    ↓ [Próximo]
Step 3: Atributos
    ↓ [Próximo]
Step 4: Pontos de Vida
    ↓ [Próximo]
Step 5: Perícias (EmptyState visual)
    ↓ [Próximo]
Step 6: Revisão Final
    ↓ [Finalizar] (pulsateGlow)
    
    Dialog Moderno (Sucesso)
    ↓ [Confirmar]
    Retorna para Lista
```

## Estados e Validações

### Validação - Campo Vazio
```
Dialog:
  Icon: warning_rounded (alertYellow)
  Title: VALIDAÇÃO
  Message: Por favor, preencha o nome do personagem
  Button: Confirmar
```

### Sucesso - Criação
```
Dialog:
  Icon: check_circle_rounded (mutagenGreen)
  Title: SUCESSO
  Message: Agente criado com sucesso! Prepare-se para a jornada.
  Button: Confirmar → Retorna
```

### Erro - Salvamento
```
Dialog:
  Icon: error_rounded (ritualRed)
  Title: ERRO
  Message: Falha ao salvar: {detalhes}
  Button: Confirmar
```

## BorderRadius Summary

| Componente | Radius | Motivo |
|-----------|--------|--------|
| TextField | 6px | Moderno, consistente |
| Dropdown | 6px | Alinha com TextField |
| RitualCard | 8px | Padrão Hexatombe |
| Dialog | 8px | Destaque visual |
| GlowingButton | 8px | Padrão existente |
| Containers (ícones) | 8px | Harmonia visual |
| Progress bar | 3px | Delicado |

## Tipografia

- **Títulos**: BebasNeue, 20-24px, letterSpacing: 2
- **Subtítulos**: Montserrat, 12-14px, letterSpacing: 1
- **Corpo**: Montserrat, 13-14px
- **Modificadores**: SpaceMono (apenas atributos)

## Melhorias Implementadas

1. **Consistência Visual**: Todas as RitualCards com glowEffect e cores temáticas
2. **Feedback Visual**: Progress bar com glow no step ativo
3. **Loading State**: HexLoading.large() em overlay
4. **Diálogos**: Design moderno com ícones e gradientes
5. **Navegação**: GlowingButton com pulsateGlow no final
6. **Inputs**: BorderRadius 6px em todos os campos
7. **Animações**: Fade, scale e slideX em todos os elementos
8. **Acessibilidade**: SafeArea para navegação

## Arquivo Modificado
- **E:\RPG-APP\lib\screens\character_wizard_screen.dart**
- **Linhas**: 847 → 1056 (+302)
- **Commit**: 652fd0f

