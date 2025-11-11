# 🎲 Como Adicionar Imagens de Dados Personalizadas

## 📁 Localização
Coloque suas imagens **NESTA PASTA**: `assets/images/dice/`

## 📝 Nomes dos Arquivos (use exatamente esses nomes)

| Tipo de Dado | Nome do Arquivo |
|--------------|----------------|
| D4           | `d4.png`       |
| D6           | `d6.png`       |
| D8           | `d8.png`       |
| D10          | `d10.png`      |
| D12          | `d12.png`      |
| D20          | `d20.png`      |
| D100         | `d100.png`     |

## 🎨 Formato Recomendado
- **PNG** com fundo transparente (recomendado)
- **WebP** também funciona (mais leve)

## 📐 Tamanho Recomendado
- **256x256 pixels** até **512x512 pixels**
- Tamanhos diferentes? Sem problema! O app redimensiona automaticamente
- Formato quadrado funciona melhor

## ✅ Como Testar

1. Coloque os arquivos nesta pasta
2. Rode `flutter run` ou faça build do APK
3. As imagens aparecerão automaticamente no app!

## 🔄 Fallback Automático
Se alguma imagem não for encontrada, o app usa os ícones geométricos padrão automaticamente.

## 🎨 Colorização
As imagens são automaticamente coloridas com:
- **Vermelho escarlate** quando selecionado
- **Prata** quando não selecionado

Por isso, use imagens em **tons de cinza** ou **preto e branco** para melhor resultado!
