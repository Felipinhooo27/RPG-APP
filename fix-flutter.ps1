# Script de Correção Automática do Flutter
# Execute como Administrador: PowerShell -ExecutionPolicy Bypass -File fix-flutter.ps1

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Corrigindo Configuração do Flutter" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar se está rodando como Admin
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "[AVISO] Este script precisa de privilégios de Administrador para modificar o PATH do sistema." -ForegroundColor Yellow
    Write-Host "Tente executar: Botão direito -> 'Executar como Administrador'" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Continuando com correções que não precisam de Admin..." -ForegroundColor Cyan
    Write-Host ""
}

# 1. Adicionar Flutter ao PATH
Write-Host "[1/4] Adicionando Flutter ao PATH..." -ForegroundColor Yellow

$flutterPath = "C:\flutter\flutter\bin"

# Verificar se o caminho existe
if (Test-Path $flutterPath) {
    # PATH do usuário atual
    $userPath = [Environment]::GetEnvironmentVariable("Path", "User")

    if ($userPath -notlike "*$flutterPath*") {
        Write-Host "Adicionando ao PATH do usuário..." -ForegroundColor Cyan
        [Environment]::SetEnvironmentVariable("Path", "$userPath;$flutterPath", "User")
        $env:Path += ";$flutterPath"
        Write-Host "[OK] Flutter adicionado ao PATH do usuário!" -ForegroundColor Green
    } else {
        Write-Host "[OK] Flutter já está no PATH!" -ForegroundColor Green
    }

    # Tentar adicionar ao PATH do sistema (requer Admin)
    if ($isAdmin) {
        $systemPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
        if ($systemPath -notlike "*$flutterPath*") {
            Write-Host "Adicionando ao PATH do sistema..." -ForegroundColor Cyan
            [Environment]::SetEnvironmentVariable("Path", "$systemPath;$flutterPath", "Machine")
            Write-Host "[OK] Flutter adicionado ao PATH do sistema!" -ForegroundColor Green
        }
    }
} else {
    Write-Host "[ERRO] Flutter não encontrado em $flutterPath" -ForegroundColor Red
    Write-Host "Verifique se o Flutter está instalado corretamente." -ForegroundColor Red
}
Write-Host ""

# 2. Instalar cmdline-tools (via Android Studio SDK Manager)
Write-Host "[2/4] Verificando Android cmdline-tools..." -ForegroundColor Yellow
$androidHome = $env:ANDROID_HOME
if (-not $androidHome) {
    $androidHome = "$env:LOCALAPPDATA\Android\sdk"
}

if (Test-Path $androidHome) {
    Write-Host "Android SDK encontrado em: $androidHome" -ForegroundColor Cyan

    # Verificar se cmdline-tools existe
    $cmdlineTools = "$androidHome\cmdline-tools"

    if (-not (Test-Path $cmdlineTools)) {
        Write-Host "[AVISO] cmdline-tools não encontrado." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Para instalar cmdline-tools:" -ForegroundColor Cyan
        Write-Host "1. Abra o Android Studio" -ForegroundColor White
        Write-Host "2. Vá em: More Actions -> SDK Manager" -ForegroundColor White
        Write-Host "3. Na aba 'SDK Tools', marque:" -ForegroundColor White
        Write-Host "   - Android SDK Command-line Tools (latest)" -ForegroundColor White
        Write-Host "   - Android SDK Build-Tools" -ForegroundColor White
        Write-Host "   - Android SDK Platform-Tools" -ForegroundColor White
        Write-Host "4. Clique em 'Apply' e aguarde a instalação" -ForegroundColor White
        Write-Host ""
    } else {
        Write-Host "[OK] cmdline-tools encontrado!" -ForegroundColor Green
    }
} else {
    Write-Host "[AVISO] Android SDK não encontrado." -ForegroundColor Yellow
    Write-Host "Certifique-se de que o Android Studio está instalado." -ForegroundColor Yellow
}
Write-Host ""

# 3. Aceitar licenças do Android
Write-Host "[3/4] Aceitando licenças do Android SDK..." -ForegroundColor Yellow

# Adicionar flutter temporariamente ao PATH da sessão
$env:Path = "C:\flutter\flutter\bin;$env:Path"

try {
    Write-Host "Executando: flutter doctor --android-licenses" -ForegroundColor Cyan
    Write-Host "(Pressione 'y' para aceitar todas as licenças)" -ForegroundColor Cyan
    Write-Host ""

    # Tentar aceitar licenças automaticamente
    $answer = "y`ny`ny`ny`ny`ny`ny`n"
    $answer | & C:\flutter\flutter\bin\flutter doctor --android-licenses 2>&1

    Write-Host ""
    Write-Host "[OK] Licenças processadas!" -ForegroundColor Green
} catch {
    Write-Host "[AVISO] Não foi possível aceitar as licenças automaticamente." -ForegroundColor Yellow
    Write-Host "Execute manualmente: flutter doctor --android-licenses" -ForegroundColor Cyan
}
Write-Host ""

# 4. Verificar configuração
Write-Host "[4/4] Verificando configuração final..." -ForegroundColor Yellow
Write-Host ""

& C:\flutter\flutter\bin\flutter doctor -v

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Correções Concluídas!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Próximos passos:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. FECHE E REABRA o terminal/PowerShell" -ForegroundColor White
Write-Host "   (para que o PATH seja atualizado)" -ForegroundColor Cyan
Write-Host ""
Write-Host "2. Se cmdline-tools ainda estiver faltando:" -ForegroundColor White
Write-Host "   - Abra Android Studio" -ForegroundColor Cyan
Write-Host "   - More Actions -> SDK Manager -> SDK Tools" -ForegroundColor Cyan
Write-Host "   - Instale 'Android SDK Command-line Tools'" -ForegroundColor Cyan
Write-Host ""
Write-Host "3. Aceite as licenças (se necessário):" -ForegroundColor White
Write-Host "   flutter doctor --android-licenses" -ForegroundColor Cyan
Write-Host ""
Write-Host "4. Execute o setup do projeto:" -ForegroundColor White
Write-Host "   setup.ps1" -ForegroundColor Cyan
Write-Host ""
Read-Host "Pressione Enter para sair"
