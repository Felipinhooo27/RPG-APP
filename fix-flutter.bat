@echo off
echo ========================================
echo  Corrigindo Configuracao do Flutter
echo ========================================
echo.

echo [1/3] Adicionando Flutter ao PATH do usuario...
setx PATH "%PATH%;C:\flutter\flutter\bin"
echo [OK] PATH atualizado!
echo.

echo [2/3] Aceitando licencas do Android SDK...
echo Pressione 'y' e Enter para cada licenca.
echo.
C:\flutter\flutter\bin\flutter doctor --android-licenses
echo.

echo [3/3] Verificando configuracao...
C:\flutter\flutter\bin\flutter doctor -v
echo.

echo ========================================
echo  Correcoes Concluidas!
echo ========================================
echo.
echo IMPORTANTE:
echo 1. FECHE E REABRA este terminal
echo 2. Execute: setup.bat
echo.
pause
