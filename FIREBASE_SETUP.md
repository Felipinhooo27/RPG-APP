# Configuração do Firebase

Este documento explica como configurar o Firebase no seu projeto.

## Método 1: FlutterFire CLI (Recomendado)

Este é o método mais fácil e automatizado:

### 1. Instalar FlutterFire CLI

```bash
dart pub global activate flutterfire_cli
```

### 2. Login no Firebase

```bash
firebase login
```

### 3. Configurar o projeto

```bash
flutterfire configure
```

Este comando irá:
- Criar um projeto no Firebase (ou selecionar um existente)
- Registrar seu app Android
- Baixar os arquivos de configuração necessários
- Configurar automaticamente o projeto

## Método 2: Manual

Se preferir configurar manualmente:

### 1. Criar Projeto no Firebase Console

1. Acesse https://console.firebase.google.com/
2. Clique em "Adicionar projeto"
3. Dê um nome: "ordem-paranormal-rpg"
4. Siga o assistente de configuração

### 2. Adicionar App Android

1. No console do Firebase, clique no ícone do Android
2. Package name: `com.ordemparanormal.rpg`
3. Baixe o arquivo `google-services.json`
4. Coloque o arquivo em: `android/app/google-services.json`

### 3. Habilitar Firestore Database

1. No menu lateral, clique em "Firestore Database"
2. Clique em "Criar banco de dados"
3. Selecione "Modo de teste" (para desenvolvimento)
4. Escolha uma região próxima (ex: southamerica-east1)

### 4. Regras de Segurança do Firestore (Modo de Teste)

Para desenvolvimento, use estas regras (NO CONSOLE DO FIREBASE):

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

**IMPORTANTE**: Estas regras são apenas para desenvolvimento! Para produção, implemente regras de segurança adequadas.

### 5. Regras de Segurança para Produção (Exemplo)

Quando estiver pronto para produção, use regras como estas:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Permitir leitura de todos os personagens
    match /characters/{characterId} {
      // Qualquer um pode ler personagens
      allow read: if true;

      // Apenas o criador pode escrever/atualizar/deletar
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null
        && resource.data.createdBy == request.auth.uid;
    }
  }
}
```

## Estrutura de Arquivos Esperada

Após a configuração, você deve ter:

```
android/
├── app/
│   ├── google-services.json  ← Arquivo baixado do Firebase
│   └── build.gradle
└── build.gradle
```

## Testando a Configuração

Após configurar o Firebase:

```bash
# Limpar cache
flutter clean

# Obter dependências
flutter pub get

# Executar o app
flutter run
```

Se tudo estiver configurado corretamente, o app deve iniciar sem erros relacionados ao Firebase.

## Verificando Conexão com Firestore

1. Execute o aplicativo
2. Crie um personagem no Modo Jogador
3. Verifique no Firebase Console → Firestore Database
4. Você deve ver uma coleção "characters" com o personagem criado

## Troubleshooting

### Erro: "google-services.json not found"

**Solução**: Certifique-se de que o arquivo está em `android/app/google-services.json`

### Erro: "Default FirebaseApp is not initialized"

**Soluções**:
1. Execute `flutterfire configure`
2. Ou adicione manualmente no `main.dart`:

```dart
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

### Erro: "Firestore permission denied"

**Solução**: Verifique as regras de segurança no Firebase Console

## Próximos Passos

Após configurar o Firebase:

1. ✅ Firestore configurado
2. ⏭️ (Opcional) Configure Firebase Authentication
3. ⏭️ (Opcional) Configure Firebase Storage para imagens
4. ⏭️ (Opcional) Configure Cloud Functions para lógica do servidor

## Links Úteis

- [Firebase Console](https://console.firebase.google.com/)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firestore Documentation](https://firebase.google.com/docs/firestore)
- [Firebase Security Rules](https://firebase.google.com/docs/rules)
