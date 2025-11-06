@echo off
echo ========================================
echo  Instalando FlutterFire CLI
echo ========================================
echo.

echo [1/2] Instalando FlutterFire CLI...
dart pub global activate flutterfire_cli
echo.

echo [2/2] Configurando PATH...
setx PATH "%PATH%;%USERPROFILE%\AppData\Local\Pub\Cache\bin"
echo [OK] PATH configurado!
echo.

echo ========================================
echo  Instalacao Concluida!
echo ========================================
echo.
echo IMPORTANTE:
echo 1. FECHE este terminal
echo 2. ABRA um novo terminal
echo 3. Execute: flutterfire configure
echo.
pause
