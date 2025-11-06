# Guia de Instalação Completa - Ordem Paranormal RPG

Este guia irá te ajudar a instalar e configurar tudo do zero.

## ⚠️ PASSO 1: Instalar Flutter (OBRIGATÓRIO)

### Opção A: Instalação Manual do Flutter (Recomendado)

1. **Baixar Flutter SDK**
   - Acesse: https://docs.flutter.dev/get-started/install/windows
   - Baixe o arquivo ZIP do Flutter SDK
   - Extraia para: `C:\src\flutter` (ou outra pasta de sua preferência)

2. **Adicionar Flutter ao PATH**
   - Abra "Variáveis de Ambiente" do Windows:
     - Pressione `Win + R`
     - Digite: `sysdm.cpl`
     - Vá em "Avançado" → "Variáveis de Ambiente"
   - Em "Variáveis do sistema", encontre "Path" e clique em "Editar"
   - Clique em "Novo" e adicione: `C:\src\flutter\bin`
   - Clique em "OK" em todas as janelas

3. **Verificar Instalação**
   - Abra um NOVO terminal (PowerShell ou CMD)
   - Execute:
   ```bash
   flutter --version
   flutter doctor
   ```

### Opção B: Usar Chocolatey (Windows Package Manager)

```powershell
# Instalar Chocolatey (se ainda não tiver)
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Instalar Flutter
choco install flutter -y

# Verificar
flutter --version
```

## ✅ PASSO 2: Instalar Android Studio (OBRIGATÓRIO)

1. **Baixar Android Studio**
   - Acesse: https://developer.android.com/studio
   - Baixe e instale o Android Studio

2. **Configurar Android SDK**
   - Abra o Android Studio
   - Vá em: File → Settings → Appearance & Behavior → System Settings → Android SDK
   - Certifique-se de que estas versões estejam instaladas:
     - Android 13.0 (API 33)
     - Android 14.0 (API 34)
   - Na aba "SDK Tools", instale:
     - Android SDK Build-Tools
     - Android SDK Command-line Tools
     - Android SDK Platform-Tools
     - Android Emulator

3. **Configurar Variáveis de Ambiente**
   - Adicione ao PATH:
     - `C:\Users\<SEU_USUARIO>\AppData\Local\Android\Sdk\platform-tools`
     - `C:\Users\<SEU_USUARIO>\AppData\Local\Android\Sdk\tools`

4. **Aceitar Licenças**
   ```bash
   flutter doctor --android-licenses
   ```
   - Pressione 'y' para aceitar todas

## 🔥 PASSO 3: Instalar Firebase CLI (OBRIGATÓRIO)

### Opção A: Via npm (Recomendado)

1. **Instalar Node.js**
   - Baixe em: https://nodejs.org/
   - Instale a versão LTS

2. **Instalar Firebase CLI**
   ```bash
   npm install -g firebase-tools
   ```

3. **Login no Firebase**
   ```bash
   firebase login
   ```

### Opção B: Via Standalone Binary

- Baixe em: https://firebase.tools/bin/win/instant/latest
- Execute o instalador

## 🚀 PASSO 4: Instalar FlutterFire CLI

```bash
dart pub global activate flutterfire_cli
```

**Adicionar ao PATH:**
- Adicione às variáveis de ambiente:
  - Windows: `%USERPROFILE%\AppData\Local\Pub\Cache\bin`

## 📱 PASSO 5: Configurar Projeto

### 5.1 Navegar até o projeto

```bash
cd "E:\Academico\008 - UNIRP 2023-2026\6 semestre\mobile\android\dart"
```

### 5.2 Instalar Dependências

```bash
flutter pub get
```

### 5.3 Configurar Firebase

```bash
flutterfire configure
```

**Siga as instruções:**
1. Selecione ou crie um projeto Firebase
2. Escolha plataformas: **Android**
3. Para Android, use o package name: `com.ordemparanormal.rpg`
4. O comando irá gerar os arquivos de configuração automaticamente

### 5.4 Habilitar Firestore

1. Acesse: https://console.firebase.google.com/
2. Selecione seu projeto
3. Vá em "Firestore Database"
4. Clique em "Criar banco de dados"
5. Escolha "Modo de teste"
6. Selecione uma região (ex: southamerica-east1)

### 5.5 Configurar Regras do Firestore

No Firebase Console → Firestore Database → Regras, cole:

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

Clique em "Publicar".

## 📲 PASSO 6: Executar o Aplicativo

### 6.1 Conectar Dispositivo ou Emulador

**Opção A: Dispositivo Físico**
1. Conecte seu celular Android via USB
2. Ative o "Modo Desenvolvedor":
   - Configurações → Sobre o telefone
   - Toque 7 vezes em "Número da versão"
3. Ative "Depuração USB":
   - Configurações → Opções do desenvolvedor → Depuração USB

**Opção B: Emulador**
1. Abra Android Studio
2. Tools → Device Manager
3. Crie um novo dispositivo virtual
4. Inicie o emulador

### 6.2 Verificar Dispositivos

```bash
flutter devices
```

### 6.3 Executar

```bash
flutter run
```

Ou no modo release (mais rápido):
```bash
flutter run --release
```

## 🐛 Resolução de Problemas Comuns

### Erro: "Flutter command not found"
**Solução**: Flutter não está no PATH. Feche e reabra o terminal após adicionar ao PATH.

### Erro: "Android SDK not found"
**Solução**:
```bash
flutter config --android-sdk "C:\Users\<SEU_USUARIO>\AppData\Local\Android\Sdk"
```

### Erro: "No devices found"
**Solução**: Certifique-se de que:
1. USB debugging está ativado (dispositivo físico)
2. Emulador está rodando (emulador)
3. Execute: `adb devices`

### Erro: "Gradle build failed"
**Solução**:
```bash
cd android
gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

### Erro: "Firebase not initialized"
**Solução**: Execute novamente:
```bash
flutterfire configure
```

## 📋 Checklist Final

Antes de executar, certifique-se:

- [ ] Flutter instalado e no PATH
- [ ] Android Studio instalado
- [ ] Android SDK configurado
- [ ] Licenças do Android aceitas
- [ ] Firebase CLI instalado
- [ ] FlutterFire CLI instalado
- [ ] Projeto Firebase criado
- [ ] Firestore habilitado
- [ ] `flutter pub get` executado
- [ ] `flutterfire configure` executado
- [ ] Dispositivo/emulador conectado

## 🎯 Comandos de Verificação

Execute estes comandos para verificar tudo:

```bash
# Verificar Flutter
flutter doctor -v

# Verificar dispositivos
flutter devices

# Verificar Firebase
firebase --version
flutterfire --version

# Testar conexão ADB
adb devices
```

## 📞 Suporte

Se encontrar problemas:

1. Execute: `flutter doctor -v` e veja o que está faltando
2. Consulte: https://flutter.dev/docs/get-started/install
3. Firebase: https://firebase.flutter.dev/docs/overview

## 🚀 Próximos Passos Após Instalação

Depois que o app estiver rodando:

1. Crie seu primeiro personagem no "Modo Jogador"
2. Teste a rolagem de dados
3. Adicione itens ao inventário
4. Experimente o "Modo Mestre"
5. Teste a exportação/importação de personagens

---

**Tempo estimado de instalação**: 30-60 minutos (primeira vez)

**Dificuldade**: ⭐⭐⭐ (Intermediária)
