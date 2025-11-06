# 📑 Índice de Documentação - Ordem Paranormal RPG

## 🎯 Por Onde Começar?

### **1. COMECE AQUI! → [COMECE_AQUI.txt](COMECE_AQUI.txt)**
Arquivo inicial com visão geral e próximos passos.

---

## 📚 Guias de Instalação

### **Para Iniciantes (Sem Flutter)**
- 📦 **[INSTALACAO_COMPLETA.md](INSTALACAO_COMPLETA.md)** - Instalação do zero (30-60 min)
  - Como instalar Flutter
  - Como instalar Android Studio
  - Como configurar tudo

### **Para Quem Já Tem Flutter**
- 🏃 **[INICIO_RAPIDO.md](INICIO_RAPIDO.md)** - Início rápido (5-10 min)
  - Instalação automática
  - Configuração rápida
  - Executar o app

### **Situação Atual (Seu Caso)**
- 📋 **[PASSO_A_PASSO.md](PASSO_A_PASSO.md)** ⭐ **LEIA ESTE PRIMEIRO!**
  - Guia visual completo
  - Correções necessárias
  - Configuração do Firebase
  - Execução do app

---

## 🔧 Correções e Troubleshooting

- 🔧 **[CORRIGIR_PROBLEMAS.md](CORRIGIR_PROBLEMAS.md)** - Soluções para erros comuns
  - Flutter não está no PATH
  - cmdline-tools faltando
  - Licenças não aceitas
  - Outros problemas

---

## 🔥 Configuração do Firebase

- 🔥 **[FIREBASE_SETUP.md](FIREBASE_SETUP.md)** - Configuração detalhada do Firebase
  - Criar projeto Firebase
  - Configurar Firestore
  - Regras de segurança
  - FlutterFire CLI

---

## 🤖 Scripts de Automação

### Windows (CMD)
- `fix-flutter.bat` - Corrigir configurações do Flutter
- `setup.bat` - Setup completo do projeto

### Windows (PowerShell)
- `fix-flutter.ps1` - Corrigir configurações (com cores)
- `setup.ps1` - Setup completo (com cores)

### Linux/Mac
- `setup.sh` - Setup completo

---

## 📱 Documentação do Aplicativo

- 📖 **[README.md](README.md)** - Documentação completa do app
  - Funcionalidades
  - Estrutura do projeto
  - Como usar (Modo Jogador e Mestre)
  - Estrutura de dados
  - Sistema de rolagem de dados

---

## 📂 Estrutura do Projeto

```
E:\...\dart\
├── 📄 COMECE_AQUI.txt          ⭐ Comece aqui!
├── 📋 PASSO_A_PASSO.md         ⭐ Guia principal
├── 🔧 CORRIGIR_PROBLEMAS.md
├── 🔥 FIREBASE_SETUP.md
├── 📦 INSTALACAO_COMPLETA.md
├── 🏃 INICIO_RAPIDO.md
├── 📖 README.md
├── 📑 INDICE.md                (este arquivo)
│
├── 🔧 Scripts de correção:
│   ├── fix-flutter.bat
│   ├── fix-flutter.ps1
│   └── setup.sh
│
├── 🚀 Scripts de setup:
│   ├── setup.bat
│   ├── setup.ps1
│   └── setup.sh
│
├── 📦 Configuração:
│   ├── pubspec.yaml
│   └── .gitignore
│
├── 💻 Código fonte:
│   └── lib/
│       ├── main.dart
│       ├── models/
│       ├── services/
│       ├── utils/
│       ├── theme/
│       └── screens/
│
└── 🤖 Android:
    └── android/
        ├── app/
        └── build.gradle
```

---

## 🎯 Fluxo Recomendado

### Se você está começando AGORA:

```
1. Leia: COMECE_AQUI.txt
   ↓
2. Execute: fix-flutter.bat
   ↓
3. Siga: PASSO_A_PASSO.md
   ↓
4. Configure Firebase (no PASSO_A_PASSO.md)
   ↓
5. Execute: flutter run
   ↓
6. 🎉 App rodando!
```

### Se você já corrigiu o Flutter:

```
1. Leia: INICIO_RAPIDO.md
   ↓
2. Execute: setup.bat
   ↓
3. Execute: flutterfire configure
   ↓
4. Execute: flutter run
   ↓
5. 🎉 App rodando!
```

---

## 🆘 Problemas?

### Não sabe por onde começar?
→ Abra: **COMECE_AQUI.txt**

### Erro ao executar Flutter?
→ Abra: **CORRIGIR_PROBLEMAS.md**

### Erro no Firebase?
→ Abra: **FIREBASE_SETUP.md**

### Quer entender o app?
→ Abra: **README.md**

---

## ⏱️ Tempo Estimado por Tarefa

| Tarefa | Tempo |
|--------|-------|
| Corrigir Flutter | 5 min |
| Instalar cmdline-tools | 2 min |
| Aceitar licenças | 1 min |
| Instalar dependências | 2 min |
| Configurar Firebase | 3 min |
| Primeira execução | 2 min |
| **TOTAL** | **~15 min** |

---

## 📞 Links Úteis

- 🔗 **Flutter**: https://flutter.dev
- 🔥 **Firebase Console**: https://console.firebase.google.com
- 🤖 **Android Studio**: https://developer.android.com/studio
- 📚 **Documentação Flutter**: https://docs.flutter.dev

---

## ✅ Checklist de Progresso

Marque o que você já fez:

- [ ] Leu COMECE_AQUI.txt
- [ ] Executou fix-flutter.bat
- [ ] Fechou e reabriu o terminal
- [ ] Instalou cmdline-tools no Android Studio
- [ ] Aceitou licenças (flutter doctor --android-licenses)
- [ ] Verificou com flutter doctor (tudo OK)
- [ ] Executou flutter pub get
- [ ] Configurou Firebase (flutterfire configure)
- [ ] Habilitou Firestore no Firebase Console
- [ ] Conectou dispositivo/emulador
- [ ] Executou flutter run
- [ ] 🎉 App rodando!

---

**Próximo passo:** Abra **COMECE_AQUI.txt** e siga as instruções! 🚀
