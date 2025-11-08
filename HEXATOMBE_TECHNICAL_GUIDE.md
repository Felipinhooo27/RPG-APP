# Guia Técnico: Design Hexatombe - Character Form Screen

## Visão Geral
Refatoração completa da tela de formulário de personagem aplicando o sistema de design Hexatombe com componentes de interface ocultista e animações rituais.

## Componentes Principais

### 1. HexLoading.large()
**Responsabilidade**: Indicador de carregamento com tema ritual

Spinner circular com pulsação, mensagem contextual e glow effect em vermelho ritualístico.

**Características**:
- Spinner circular com pulsação
- Mensagem contextual personalizável
- Glow effect em vermelho ritualístico
- Overlay escuro 70% opacidade

---

### 2. RitualCard - Seções do Formulário
**Responsabilidade**: Container estilizado para agrupamento visual

4 seções do formulário envolvidas em RitualCard:
1. INFORMAÇÕES BÁSICAS (6 campos)
2. STATUS MÁXIMO (4 campos)
3. ATRIBUTOS (5 campos)
4. COMBATE (1 campo)

**Características**:
- Gradiente cinza (obscureGray → industrialGray)
- Símbolos rituais nos cantos
- Padding/margin otimizado
- Helper method _buildSectionCard()

---

### 3. TextFields com BorderRadius 7px
**Responsabilidade**: Campos de entrada estilizados Hexatombe

**Styling Aplicado**:
- Border radius: 7px
- Estado desabilitado: Cinza industrial (1.5px)
- Estado focus: Vermelho ritual (2px)
- Label flutuante: Vermelho ao focar
- Fill color: Cinza industrial

---

### 4. GlowingButton - Salvar e Cancelar
**Responsabilidade**: Botões com efeito de brilho ritual

**Estilos Implementados**:
- Cancelar: Secondary (Roxo etéreo)
- Salvar: Primary (Vermelho ritual + brilho)
- Loading state integrado
- Efeito de escala no tap

**Estados**:
- Default: Glow normal
- Loading: Spinner circular
- Disabled: Cinza 30% opacidade
- Pressed: Scale 0.96

---

### 5. Diálogos Modernos com RitualCard

#### Dialog de Sucesso
- Glow verde mutagênico
- Ícone check grande (56px)
- Mensagem adaptativa (criação vs atualização)
- Botão "Continuar" com navegação dupla

#### Dialog de Erro
- Glow amarelo alerta
- Ícone error grande (56px)
- Mensagem de erro contextual
- Botão "Tentar Novamente"

---

## Fluxo de Salvamento

1. Usuário tapa "Salvar"
   - Validação do formulário

2. Se válido:
   - setState(_isLoading = true)
   - Loading overlay aparece (HexLoading.large)
   - Salva no banco de dados

3. Se sucesso:
   - setState(_isLoading = false)
   - Dialog sucesso (RitualCard + verde)
   - Usuario tapa "Continuar"
   - Volta para lista

4. Se erro:
   - setState(_isLoading = false)
   - Dialog erro (RitualCard + amarelo)
   - Usuario pode "Tentar Novamente" ou fechar

---

## Paleta Hexatombe Utilizada

| Nome | Valor | Uso |
|------|-------|-----|
| Ritual Red | #C12725 | Primária, títulos, focus |
| Abyssal Black | #0E0E0F | Background principal |
| Obscure Gray | #1A1B1F | Cards |
| Ethereal Purple | #3C235B | Secundária (cancelar) |
| Industrial Gray | #2A2D31 | Borders, inputs |
| Cold Gray | #7A7D81 | Texto secundário |
| Pale White | #F2F2F2 | Texto principal |
| Mutagen Green | #468B45 | Sucesso |
| Alert Yellow | #D1A040 | Aviso/Erro |

---

## Validação

- Flutter analyze: No issues found!
- Sem erros de sintaxe
- Compatível com Material 3
- Todas as dependências disponíveis

---

## Boas Práticas

1. Sempre usar RitualCard para agrupar campos relacionados
2. Manter loading overlay durante operações async
3. Usar cores semanticamente (verde=sucesso, amarelo=aviso)
4. Manter barrierDismissible=false para ações críticas
5. Mostrar mensagens contextuais no loading
6. Usar GlowingButton em vez de botões padrão
7. Respeitar BorderRadius 7-8px em inputs

---

## Arquivos Afetados

- `lib/screens/character_form_screen.dart` (MODIFICADO)
- `lib/widgets/hex_loading.dart` (USADO)
- `lib/widgets/ritual_card.dart` (USADO)
- `lib/widgets/glowing_button.dart` (USADO)
- `lib/theme/app_theme.dart` (USADO)

---

## Histórico de Mudanças

| Versão | Data | Mudanças |
|--------|------|----------|
| 1.0 | 2025-11-07 | Implementação completa design Hexatombe |
