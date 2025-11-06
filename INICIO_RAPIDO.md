# 🚀 Início Rápido - Ordem Paranormal RPG

## ⚡ Instalação Expressa (5 minutos)

### Pré-requisitos Mínimos

1. **Flutter SDK** instalado e no PATH
2. **Android Studio** com SDK configurado
3. **Dispositivo Android** conectado ou **Emulador** rodando

**Ainda não tem?** → Veja [INSTALACAO_COMPLETA.md](INSTALACAO_COMPLETA.md)

---

## 📦 Instalação Automática

### Windows

**Opção 1: Batch Script (CMD)**

```bash
setup.bat
```

**Opção 2: PowerShell (Recomendado)**

```powershell
PowerShell -ExecutionPolicy Bypass -File setup.ps1
```

### Linux/Mac

```bash
chmod +x setup.sh
./setup.sh
```

---

## 🛠️ Instalação Manual (4 comandos)

```bash
# 1. Navegar até o projeto
cd "E:\Academico\008 - UNIRP 2023-2026\6 semestre\mobile\android\dart"

# 2. Instalar dependências
flutter pub get

# 3. Configurar Firebase
flutterfire configure

# 4. Executar
flutter run
```

---

## 🔥 Configuração do Firebase (3 minutos)

### 1. Executar FlutterFire

```bash
flutterfire configure
```

**O que fazer:**
- ✅ Criar novo projeto ou selecionar existente
- ✅ Escolher plataforma: **Android**
- ✅ Package name: `com.ordemparanormal.rpg`

### 2. Habilitar Firestore

1. Abra: https://console.firebase.google.com/
2. Selecione seu projeto
3. Vá em **Firestore Database**
4. Clique em **Criar banco de dados**
5. Escolha **Modo de teste**
6. Região: **southamerica-east1**

### 3. Configurar Regras (Copiar e Colar)

No Firebase Console → Firestore → **Regras**:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.time < timestamp.date(2025, 12, 31);
    }
  }
}
```

Clique em **Publicar**.

✅ **Pronto!** Firebase configurado.

---

## 📱 Executar o App

### Verificar Dispositivos

```bash
flutter devices
```

**Deve mostrar:**
- 📱 Dispositivo Android conectado, OU
- 🖥️ Emulador Android rodando

### Executar

```bash
flutter run
```

**Ou para melhor performance:**

```bash
flutter run --release
```

---

## ✅ Verificação Rápida

Execute estes 3 comandos:

```bash
flutter doctor
flutter devices
flutter pub get
```

**Tudo OK?** → Execute `flutter run`

---

## 🐛 Problemas Comuns (Soluções Rápidas)

### ❌ "Flutter command not found"

**Solução:** Flutter não está no PATH
```bash
# Windows: Adicione às Variáveis de Ambiente
C:\src\flutter\bin

# Feche e reabra o terminal
```

### ❌ "No devices found"

**Soluções:**

**Dispositivo Físico:**
1. Ative **Depuração USB** no celular
2. Conecte o cabo USB
3. Aceite a permissão no celular

**Emulador:**
1. Abra Android Studio
2. Tools → Device Manager
3. Crie e inicie um emulador

### ❌ "Firebase not configured"

```bash
flutterfire configure
```

### ❌ "Build failed"

```bash
flutter clean
flutter pub get
flutter run
```

---

## 📖 Documentação Completa

- **Instalação detalhada:** [INSTALACAO_COMPLETA.md](INSTALACAO_COMPLETA.md)
- **Configuração Firebase:** [FIREBASE_SETUP.md](FIREBASE_SETUP.md)
- **Documentação do projeto:** [README.md](README.md)

---

## 🎮 Primeiros Passos no App

Depois que o app abrir:

1. **Escolha "MODO JOGADOR"**
2. **Crie seu primeiro personagem:**
   - Nome: João Silva
   - Classe: Combatente
   - Origem: Acadêmico
   - Preencha os atributos

3. **Teste as funcionalidades:**
   - ➕➖ Ajuste PV, PE, PS
   - 🎒 Adicione itens ao inventário
   - ⚔️ Adicione uma arma (ex: Revólver 1d8+2)
   - 🎲 Role dados de dano
   - 🎲 Use o rolador de dados

4. **Experimente o Modo Mestre:**
   - Volte e escolha "MODO MESTRE"
   - Veja todos os personagens
   - Teste exportar/importar

---

## 💡 Dicas

- 🔄 Suas alterações salvam automaticamente no Firestore
- 📤 Use a exportação para compartilhar fichas via WhatsApp
- 🎲 O rolador suporta fórmulas complexas: `1d20+5`, `2d6+1d8`
- ⚔️ Armas podem ter multiplicadores críticos

---

## 🆘 Precisa de Ajuda?

1. **Verificar status:** `flutter doctor -v`
2. **Ver dispositivos:** `flutter devices`
3. **Limpar e reinstalar:**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

---

**⏱️ Tempo total:** 5-10 minutos (se Flutter já estiver instalado)

**🎯 Pronto para jogar!** 🎲🎭
