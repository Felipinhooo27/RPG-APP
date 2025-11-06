#!/bin/bash

# Ordem Paranormal RPG - Setup Script
# Execute com: chmod +x setup.sh && ./setup.sh

echo "========================================"
echo " Ordem Paranormal RPG - Setup"
echo "========================================"
echo ""

# Cores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Função para verificar comando
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# 1. Verificar Flutter
echo -e "${YELLOW}[1/7] Verificando Flutter...${NC}"
if command_exists flutter; then
    echo -e "${GREEN}[OK] Flutter encontrado!${NC}"
    flutter --version
else
    echo -e "${RED}[ERRO] Flutter não encontrado!${NC}"
    echo "Por favor, instale o Flutter primeiro."
    echo "Veja: INSTALACAO_COMPLETA.md"
    exit 1
fi
echo ""

# 2. Flutter Doctor
echo -e "${YELLOW}[2/7] Verificando dependências do Flutter...${NC}"
flutter doctor
echo ""

# 3. Instalar dependências
echo -e "${YELLOW}[3/7] Instalando dependências do projeto...${NC}"
flutter pub get
if [ $? -eq 0 ]; then
    echo -e "${GREEN}[OK] Dependências instaladas!${NC}"
else
    echo -e "${RED}[ERRO] Falha ao instalar dependências!${NC}"
    exit 1
fi
echo ""

# 4. Verificar Firebase CLI
echo -e "${YELLOW}[4/7] Verificando Firebase CLI...${NC}"
if command_exists firebase; then
    echo -e "${GREEN}[OK] Firebase CLI encontrado!${NC}"
    firebase --version
else
    echo -e "${YELLOW}[AVISO] Firebase CLI não encontrado!${NC}"
    echo -e "${CYAN}Instale com: npm install -g firebase-tools${NC}"
fi
echo ""

# 5. Verificar/Instalar FlutterFire CLI
echo -e "${YELLOW}[5/7] Verificando FlutterFire CLI...${NC}"
if command_exists flutterfire; then
    echo -e "${GREEN}[OK] FlutterFire CLI encontrado!${NC}"
else
    echo -e "${YELLOW}[AVISO] FlutterFire CLI não encontrado!${NC}"
    echo -e "${CYAN}Instalando...${NC}"
    dart pub global activate flutterfire_cli

    # Adicionar ao PATH
    echo -e "${CYAN}[INFO] Adicione ao PATH no ~/.bashrc ou ~/.zshrc:${NC}"
    echo 'export PATH="$PATH:$HOME/.pub-cache/bin"'
fi
echo ""

# 6. Limpar build anterior
echo -e "${YELLOW}[6/7] Limpando builds anteriores...${NC}"
flutter clean
echo -e "${GREEN}[OK] Limpeza concluída!${NC}"
echo ""

# 7. Verificar dispositivos
echo -e "${YELLOW}[7/7] Verificando dispositivos conectados...${NC}"
flutter devices
echo ""

# Resumo
echo "========================================"
echo -e "${GREEN} Setup concluído!${NC}"
echo "========================================"
echo ""
echo -e "${YELLOW}Próximos passos:${NC}"
echo ""
echo -e "${NC}1. Configure o Firebase:${NC}"
echo -e "${CYAN}   flutterfire configure${NC}"
echo ""
echo -e "${NC}2. Habilite o Firestore no Firebase Console:${NC}"
echo -e "${CYAN}   https://console.firebase.google.com/${NC}"
echo ""
echo -e "${NC}3. Execute o app:${NC}"
echo -e "${CYAN}   flutter run${NC}"
echo ""
echo -e "${YELLOW}Para mais informações, veja: INSTALACAO_COMPLETA.md${NC}"
echo ""
