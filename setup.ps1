# Ordem Paranormal RPG - Setup Script
# Execute com: PowerShell -ExecutionPolicy Bypass -File setup.ps1

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Ordem Paranormal RPG - Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Função para verificar comando
function Test-Command {
    param($Command)
    try {
        if (Get-Command $Command -ErrorAction Stop) {
            return $true
        }
    }
    catch {
        return $false
    }
}

# 1. Verificar Flutter
Write-Host "[1/7] Verificando Flutter..." -ForegroundColor Yellow
if (Test-Command "flutter") {
    Write-Host "[OK] Flutter encontrado!" -ForegroundColor Green
    flutter --version
} else {
    Write-Host "[ERRO] Flutter não encontrado!" -ForegroundColor Red
    Write-Host "Por favor, instale o Flutter primeiro." -ForegroundColor Red
    Write-Host "Veja: INSTALACAO_COMPLETA.md" -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Pressione Enter para sair"
    exit 1
}
Write-Host ""

# 2. Flutter Doctor
Write-Host "[2/7] Verificando dependências do Flutter..." -ForegroundColor Yellow
flutter doctor
Write-Host ""

# 3. Instalar dependências
Write-Host "[3/7] Instalando dependências do projeto..." -ForegroundColor Yellow
flutter pub get
if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] Dependências instaladas!" -ForegroundColor Green
} else {
    Write-Host "[ERRO] Falha ao instalar dependências!" -ForegroundColor Red
    Read-Host "Pressione Enter para sair"
    exit 1
}
Write-Host ""

# 4. Verificar Firebase CLI
Write-Host "[4/7] Verificando Firebase CLI..." -ForegroundColor Yellow
if (Test-Command "firebase") {
    Write-Host "[OK] Firebase CLI encontrado!" -ForegroundColor Green
    firebase --version
} else {
    Write-Host "[AVISO] Firebase CLI não encontrado!" -ForegroundColor Yellow
    Write-Host "Instale com: npm install -g firebase-tools" -ForegroundColor Cyan
    Write-Host "Ou baixe em: https://firebase.tools/bin/win/instant/latest" -ForegroundColor Cyan
}
Write-Host ""

# 5. Verificar/Instalar FlutterFire CLI
Write-Host "[5/7] Verificando FlutterFire CLI..." -ForegroundColor Yellow
if (Test-Command "flutterfire") {
    Write-Host "[OK] FlutterFire CLI encontrado!" -ForegroundColor Green
} else {
    Write-Host "[AVISO] FlutterFire CLI não encontrado!" -ForegroundColor Yellow
    Write-Host "Instalando..." -ForegroundColor Cyan
    dart pub global activate flutterfire_cli

    # Adicionar ao PATH da sessão atual
    $env:Path += ";$env:USERPROFILE\AppData\Local\Pub\Cache\bin"

    Write-Host "[INFO] Adicione permanentemente ao PATH:" -ForegroundColor Cyan
    Write-Host "       %USERPROFILE%\AppData\Local\Pub\Cache\bin" -ForegroundColor Cyan
}
Write-Host ""

# 6. Limpar build anterior
Write-Host "[6/7] Limpando builds anteriores..." -ForegroundColor Yellow
flutter clean
Write-Host "[OK] Limpeza concluída!" -ForegroundColor Green
Write-Host ""

# 7. Verificar dispositivos
Write-Host "[7/7] Verificando dispositivos conectados..." -ForegroundColor Yellow
flutter devices
Write-Host ""

# Resumo
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Setup concluído!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Próximos passos:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Configure o Firebase:" -ForegroundColor White
Write-Host "   flutterfire configure" -ForegroundColor Cyan
Write-Host ""
Write-Host "2. Habilite o Firestore no Firebase Console:" -ForegroundColor White
Write-Host "   https://console.firebase.google.com/" -ForegroundColor Cyan
Write-Host ""
Write-Host "3. Execute o app:" -ForegroundColor White
Write-Host "   flutter run" -ForegroundColor Cyan
Write-Host ""
Write-Host "Para mais informações, veja: INSTALACAO_COMPLETA.md" -ForegroundColor Yellow
Write-Host ""
Read-Host "Pressione Enter para sair"
