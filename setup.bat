@echo off
echo ========================================
echo  Ordem Paranormal RPG - Setup
echo ========================================
echo.

:: Verificar se Flutter está instalado
echo [1/5] Verificando Flutter...
where flutter >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERRO] Flutter nao encontrado!
    echo Por favor, instale o Flutter primeiro.
    echo Veja: INSTALACAO_COMPLETA.md
    pause
    exit /b 1
)
echo [OK] Flutter encontrado!
flutter --version
echo.

:: Verificar Flutter Doctor
echo [2/5] Verificando dependencias do Flutter...
flutter doctor
echo.

:: Instalar dependências do projeto
echo [3/5] Instalando dependencias do projeto...
flutter pub get
if %ERRORLEVEL% NEQ 0 (
    echo [ERRO] Falha ao instalar dependencias!
    pause
    exit /b 1
)
echo [OK] Dependencias instaladas!
echo.

:: Verificar Firebase CLI
echo [4/5] Verificando Firebase CLI...
where firebase >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [AVISO] Firebase CLI nao encontrado!
    echo Instale com: npm install -g firebase-tools
    echo Ou baixe em: https://firebase.tools/bin/win/instant/latest
) else (
    echo [OK] Firebase CLI encontrado!
    firebase --version
)
echo.

:: Verificar FlutterFire CLI
echo [5/5] Verificando FlutterFire CLI...
where flutterfire >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [AVISO] FlutterFire CLI nao encontrado!
    echo Instalando...
    dart pub global activate flutterfire_cli
    echo [INFO] Adicione ao PATH: %%USERPROFILE%%\AppData\Local\Pub\Cache\bin
) else (
    echo [OK] FlutterFire CLI encontrado!
)
echo.

:: Limpar build anterior
echo Limpando builds anteriores...
flutter clean
echo.

echo ========================================
echo  Setup concluido!
echo ========================================
echo.
echo Proximos passos:
echo 1. Configure o Firebase:
echo    flutterfire configure
echo.
echo 2. Execute o app:
echo    flutter run
echo.
echo Para mais informacoes, veja: INSTALACAO_COMPLETA.md
echo.
pause
