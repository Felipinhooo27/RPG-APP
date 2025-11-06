# Script para instalar FlutterFire CLI
# Execute: PowerShell -ExecutionPolicy Bypass -File install-flutterfire.ps1

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Instalando FlutterFire CLI" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 1. Instalar FlutterFire CLI
Write-Host "[1/3] Instalando FlutterFire CLI..." -ForegroundColor Yellow
Write-Host "Executando: dart pub global activate flutterfire_cli" -ForegroundColor Cyan
Write-Host ""

dart pub global activate flutterfire_cli

Write-Host ""
Write-Host "[OK] FlutterFire CLI instalado!" -ForegroundColor Green
Write-Host ""

# 2. Adicionar ao PATH
Write-Host "[2/3] Configurando PATH..." -ForegroundColor Yellow

$pubCacheBin = "$env:USERPROFILE\AppData\Local\Pub\Cache\bin"

# Verificar se existe
if (Test-Path $pubCacheBin) {
    Write-Host "Diretório encontrado: $pubCacheBin" -ForegroundColor Cyan

    # PATH do usuário
    $userPath = [Environment]::GetEnvironmentVariable("Path", "User")

    if ($userPath -notlike "*$pubCacheBin*") {
        Write-Host "Adicionando ao PATH do usuário..." -ForegroundColor Cyan
        [Environment]::SetEnvironmentVariable("Path", "$userPath;$pubCacheBin", "User")
        Write-Host "[OK] PATH atualizado!" -ForegroundColor Green
    } else {
        Write-Host "[OK] Já está no PATH!" -ForegroundColor Green
    }

    # Adicionar ao PATH da sessão atual
    $env:Path += ";$pubCacheBin"

} else {
    Write-Host "[AVISO] Diretório não encontrado: $pubCacheBin" -ForegroundColor Yellow
}

Write-Host ""

# 3. Verificar instalação
Write-Host "[3/3] Verificando instalação..." -ForegroundColor Yellow
Write-Host ""

# Tentar executar flutterfire
$flutterfirePath = "$pubCacheBin\flutterfire.bat"

if (Test-Path $flutterfirePath) {
    Write-Host "[OK] FlutterFire encontrado!" -ForegroundColor Green
    & $flutterfirePath --version
} else {
    Write-Host "[AVISO] Executável não encontrado em: $flutterfirePath" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Instalação Concluída!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Próximos passos:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. FECHE E REABRA o PowerShell" -ForegroundColor White
Write-Host "   (para carregar o PATH atualizado)" -ForegroundColor Cyan
Write-Host ""
Write-Host "2. Execute no novo terminal:" -ForegroundColor White
Write-Host "   flutterfire configure" -ForegroundColor Cyan
Write-Host ""
Write-Host "3. Siga as instruções para criar/selecionar projeto Firebase" -ForegroundColor White
Write-Host ""
Write-Host "4. Habilite o Firestore em:" -ForegroundColor White
Write-Host "   https://console.firebase.google.com/" -ForegroundColor Cyan
Write-Host ""
Write-Host "5. Execute o app:" -ForegroundColor White
Write-Host "   flutter run" -ForegroundColor Cyan
Write-Host ""

Read-Host "Pressione Enter para sair"
