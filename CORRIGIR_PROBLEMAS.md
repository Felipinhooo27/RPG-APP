# 🔧 Corrigir Problemas do Flutter

Baseado no resultado do `flutter doctor`, aqui estão as correções necessárias:

## ⚠️ Problemas Identificados

1. ❌ Flutter não está no PATH
2. ❌ Android cmdline-tools não encontrado
3. ❌ Licenças do Android não aceitas

---

## 🚀 Solução Rápida (RECOMENDADO)

### Execute um destes scripts:

**Opção 1: Batch (CMD)**
```bash
fix-flutter.bat
```

**Opção 2: PowerShell**
```powershell
PowerShell -ExecutionPolicy Bypass -File fix-flutter.ps1
```

Depois de executar, **FECHE E REABRA** o terminal.

---

## 🛠️ Solução Manual

Se preferir fazer manualmente, siga os passos abaixo:

### PASSO 1: Adicionar Flutter ao PATH

#### Windows 10/11:

1. Pressione `Win + R`
2. Digite: `sysdm.cpl`
3. Vá em **"Avançado"** → **"Variáveis de Ambiente"**
4. Em **"Variáveis do usuário"**, encontre **"Path"**
5. Clique em **"Editar"**
6. Clique em **"Novo"**
7. Adicione: `C:\flutter\flutter\bin`
8. Clique em **"OK"** em todas as janelas
9. **FECHE E REABRA** todos os terminais

#### Verificar:
```bash
flutter --version
```

---

### PASSO 2: Instalar Android cmdline-tools

1. Abra o **Android Studio**
2. Na tela inicial, clique em **"More Actions"** (⋮)
3. Selecione **"SDK Manager"**
4. Vá na aba **"SDK Tools"**
5. Marque as seguintes opções:
   - ✅ **Android SDK Command-line Tools (latest)**
   - ✅ **Android SDK Build-Tools**
   - ✅ **Android SDK Platform-Tools**
6. Clique em **"Apply"**
7. Aguarde o download e instalação

---

### PASSO 3: Aceitar Licenças do Android

Abra um **NOVO terminal** (para pegar o PATH atualizado) e execute:

```bash
flutter doctor --android-licenses
```

**Pressione `y` e Enter** para aceitar todas as licenças (serão 7-8 licenças).

---

## ✅ Verificar Correções

Depois de fazer tudo, execute:

```bash
flutter doctor -v
```

**Resultado esperado:**

```
[√] Flutter (Channel stable, 3.35.6, ...)
[√] Windows Version (...)
[√] Android toolchain - develop for Android devices
[√] Chrome - develop for the web
[√] Visual Studio - develop Windows apps
[√] Android Studio
[√] VS Code
[√] Connected device
[√] Network resources

! Doctor found no issues.
```

---

## 🎯 Após Corrigir Tudo

1. **Feche e reabra o terminal**
2. Execute:
   ```bash
   cd "E:\Academico\008 - UNIRP 2023-2026\6 semestre\mobile\android\dart"
   setup.bat
   ```

3. Configure o Firebase:
   ```bash
   flutterfire configure
   ```

4. Execute o app:
   ```bash
   flutter run
   ```

---

## 🐛 Ainda com Problemas?

### Erro: "Flutter command not found"
**Solução:** O PATH não foi atualizado. Feche TODOS os terminais e abra um novo.

### Erro: "cmdline-tools component is missing"
**Solução:** Siga o PASSO 2 novamente e certifique-se de instalar o cmdline-tools no Android Studio.

### Erro: "Android license status unknown"
**Solução:** Execute:
```bash
flutter doctor --android-licenses
```

### Erro: "ANDROID_HOME not set"
**Solução:** Adicione às variáveis de ambiente:
- Nome: `ANDROID_HOME`
- Valor: `C:\Users\SEU_USUARIO\AppData\Local\Android\sdk`

---

## 📞 Checklist Final

Antes de continuar, certifique-se:

- [ ] Flutter está no PATH (teste: `flutter --version`)
- [ ] Android cmdline-tools instalado no Android Studio
- [ ] Licenças do Android aceitas (`flutter doctor --android-licenses`)
- [ ] `flutter doctor` não mostra erros críticos
- [ ] Terminal foi fechado e reaberto

---

## 🎉 Pronto!

Agora você pode continuar com o setup do projeto:

```bash
setup.bat
```

Boa sorte! 🚀
