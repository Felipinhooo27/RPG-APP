# 🎯 Passo a Passo - Configuração Final

Seu Flutter está instalado, mas precisa de alguns ajustes!

---

## 📋 Status Atual

✅ Flutter instalado em: `C:\flutter\flutter`
✅ Android Studio instalado
✅ VS Code instalado
❌ Flutter não está no PATH
❌ Android cmdline-tools faltando
❌ Licenças do Android não aceitas

---

## 🚀 Solução em 3 Passos (5 minutos)

### **PASSO 1: Corrigir Configurações** ⏱️ 2 min

Execute UM destes scripts:

```bash
# Opção A: CMD
fix-flutter.bat

# Opção B: PowerShell (RECOMENDADO)
PowerShell -ExecutionPolicy Bypass -File fix-flutter.ps1
```

**O que o script faz:**
- ✅ Adiciona Flutter ao PATH
- ✅ Tenta aceitar licenças do Android
- ✅ Verifica a configuração

**⚠️ IMPORTANTE:** Depois de executar, **FECHE E REABRA** o terminal!

---

### **PASSO 2: Instalar cmdline-tools** ⏱️ 2 min

1. Abra o **Android Studio**
2. Tela inicial → **More Actions** (⋮) → **SDK Manager**
3. Aba **"SDK Tools"** → Marque:
   - ☑️ Android SDK Command-line Tools (latest)
   - ☑️ Android SDK Build-Tools
   - ☑️ Android SDK Platform-Tools
4. Clique em **"Apply"** → **"OK"**
5. Aguarde a instalação

---

### **PASSO 3: Aceitar Licenças** ⏱️ 1 min

Abra um **NOVO terminal** e execute:

```bash
flutter doctor --android-licenses
```

**Pressione `y` e Enter** para todas as licenças (7-8 vezes).

---

## ✅ Verificar se Está Tudo OK

Execute:

```bash
flutter doctor
```

**Esperado:**
```
[√] Flutter
[√] Android toolchain
[√] Android Studio
[√] VS Code
```

---

## 🎮 Configurar o Projeto (depois de corrigir)

```bash
# 1. Instalar dependências
flutter pub get

# 2. Configurar Firebase
flutterfire configure

# 3. Executar
flutter run
```

---

## 🔥 Configuração do Firebase (rápida)

### 1. Executar comando:
```bash
flutterfire configure
```

### 2. Seguir prompts:
- Criar novo projeto ou selecionar existente
- Nome sugerido: `ordem-paranormal-rpg`
- Plataforma: **Android**
- Package: `com.ordemparanormal.rpg` (já configurado)

### 3. Habilitar Firestore:
1. Abra: https://console.firebase.google.com/
2. Selecione seu projeto
3. **Firestore Database** → **Criar banco de dados**
4. Modo: **Teste**
5. Região: **southamerica-east1**

### 4. Regras (copiar e colar):

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

---

## 📱 Executar o App

### Conectar dispositivo:

**Dispositivo Físico:**
1. Conecte via USB
2. Ative **Depuração USB** no celular:
   - Configurações → Sobre o telefone
   - Toque 7x em "Número da versão"
   - Configurações → Opções do desenvolvedor
   - Ative "Depuração USB"

**Emulador:**
1. Android Studio → Tools → Device Manager
2. Create Device → Next → Download (uma imagem do sistema)
3. Finish → Iniciar o emulador

### Verificar:
```bash
flutter devices
```

### Executar:
```bash
flutter run
```

---

## 🎯 Resumo dos Comandos

```bash
# 1. Corrigir Flutter
fix-flutter.bat

# 2. FECHAR E REABRIR terminal

# 3. Verificar
flutter doctor

# 4. Ir para o projeto
cd "E:\Academico\008 - UNIRP 2023-2026\6 semestre\mobile\android\dart"

# 5. Instalar dependências
flutter pub get

# 6. Configurar Firebase
flutterfire configure

# 7. Conectar dispositivo/emulador
flutter devices

# 8. Executar
flutter run
```

---

## 🆘 Problemas Comuns

### "Flutter command not found"
**Solução:** Você esqueceu de fechar e reabrir o terminal após executar fix-flutter.bat

### "No devices found"
**Solução:** Conecte um celular ou inicie um emulador

### "Firebase not configured"
**Solução:** Execute `flutterfire configure`

### "Build failed"
**Solução:**
```bash
flutter clean
flutter pub get
flutter run
```

---

## 📚 Documentação Completa

- **Correções:** [CORRIGIR_PROBLEMAS.md](CORRIGIR_PROBLEMAS.md)
- **Firebase:** [FIREBASE_SETUP.md](FIREBASE_SETUP.md)
- **Instalação:** [INSTALACAO_COMPLETA.md](INSTALACAO_COMPLETA.md)

---

## ⏱️ Tempo Total Estimado

- Correções: 5 minutos
- Firebase: 3 minutos
- Primeira execução: 2 minutos

**Total: ~10 minutos** ⚡

---

**Vamos lá! Execute `fix-flutter.bat` agora!** 🚀
