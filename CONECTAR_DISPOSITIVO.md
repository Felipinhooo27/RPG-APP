# 📱 Como Conectar um Dispositivo Android

Você tem 2 opções:

---

## Opção 1: Dispositivo Físico (Celular Android) ⚡ RÁPIDO

### Passo 1: Ativar Modo Desenvolvedor

1. No seu celular Android:
   - Vá em **Configurações** → **Sobre o telefone**
   - Toque **7 vezes** em "Número da versão" ou "Número da compilação"
   - Aparecerá: "Você agora é um desenvolvedor!"

### Passo 2: Ativar Depuração USB

1. Volte para **Configurações**
2. Procure por **Opções do desenvolvedor** ou **Opções de desenvolvedor**
3. Ative **Depuração USB**
4. (Opcional) Ative também **Instalação via USB**

### Passo 3: Conectar o Celular

1. Conecte o celular no PC via **cabo USB**
2. No celular, aparecerá uma mensagem:
   - **"Permitir depuração USB?"**
   - Marque **"Sempre permitir neste computador"**
   - Toque em **"OK"** ou **"Permitir"**

### Passo 4: Verificar Conexão

No PowerShell/CMD:
```bash
flutter devices
```

Deve mostrar algo como:
```
SM G975F (mobile) • RZ8M802WPPP • android-arm64 • Android 13
```

### Passo 5: Executar

```bash
flutter run
```

---

## Opção 2: Emulador Android (Mais Lento) 🐢

### Passo 1: Abrir Android Studio

1. Abra o **Android Studio**
2. Clique em **More Actions** (⋮) ou **Três pontinhos**
3. Selecione **Virtual Device Manager** ou **Device Manager**

### Passo 2: Criar Emulador (se não tiver)

1. Clique em **Create Device** ou **Create Virtual Device**
2. Escolha um dispositivo:
   - Recomendado: **Pixel 7** ou **Pixel 6**
3. Clique em **Next**
4. Selecione uma imagem do sistema:
   - Recomendado: **Tiramisu (API 33)** ou **UpsideDownCake (API 34)**
   - Se precisar baixar, clique no ícone de download
5. Clique em **Next** → **Finish**

### Passo 3: Iniciar Emulador

1. No Device Manager, encontre seu emulador
2. Clique no botão **▶ Play**
3. Aguarde o emulador iniciar (pode demorar 1-2 minutos)

### Passo 4: Verificar

No PowerShell/CMD:
```bash
flutter devices
```

Deve mostrar:
```
emulator-5554 (mobile) • emulator-5554 • android-x86 • Android 13 (API 33)
```

### Passo 5: Executar

```bash
flutter run
```

---

## 🚀 Comandos Úteis

### Verificar dispositivos conectados:
```bash
flutter devices
```

### Listar todos os dispositivos (incluindo offline):
```bash
adb devices
```

### Reiniciar ADB (se o dispositivo não aparecer):
```bash
adb kill-server
adb start-server
flutter devices
```

### Executar em um dispositivo específico:
```bash
flutter run -d <device-id>
```

Exemplo:
```bash
flutter run -d emulator-5554
```

---

## ❌ Problemas Comuns

### Dispositivo conectado mas não aparece

**Solução 1: Reinstalar drivers USB**
- Windows: Instale o driver do seu celular do site do fabricante
- Ou use: Google USB Driver (no Android Studio SDK Manager)

**Solução 2: Trocar cabo USB**
- Use um cabo USB de dados (não apenas carregamento)

**Solução 3: Trocar porta USB**
- Tente outra porta USB do PC

**Solução 4: Reiniciar ADB**
```bash
adb kill-server
adb start-server
```

### Emulador não inicia

**Solução 1: Ativar virtualização**
- Entre na BIOS do PC
- Ative Intel VT-x ou AMD-V
- Salve e reinicie

**Solução 2: Desativar Hyper-V (Windows)**
```powershell
# Execute como Administrador
bcdedit /set hypervisorlaunchtype off
```
Depois reinicie o PC.

**Solução 3: Aumentar RAM do emulador**
- No Device Manager → Editar emulador
- Aumente a RAM para 2048 MB ou mais

### "Unauthorized" no adb devices

**Solução:**
1. Desconecte o celular
2. Execute: `adb kill-server`
3. Reconecte o celular
4. Aceite a permissão de depuração que aparecer

---

## ✅ Checklist

- [ ] Modo desenvolvedor ativado no celular
- [ ] Depuração USB ativada
- [ ] Celular conectado via USB
- [ ] Permissão de depuração aceita no celular
- [ ] `flutter devices` mostra o dispositivo
- [ ] Executou `flutter run`

---

## 📞 Dica Rápida

**Opção 1 (Celular)** é MUITO mais rápida que o emulador!

Se você tem um celular Android, use ele. O emulador é lento e pesado.

---

**Próximo passo:** Execute `flutter devices` e me mostre o resultado! 🚀
