# Script para generar la build de windows usando flutter_distributor

Write-Host "----Obtener paquetes"
flutter pub get

Write-Host "----Instalar flutter_distributor"
dart pub global activate flutter_distributor

Write-Host "----Generar instalador .exe para windows"
flutter_distributor package --platform windows --targets exe --skip-clean

Write-Host "----Crear directorio release si no existe"
New-Item -ItemType Directory -Force -Path release

Write-Host "----Mover .exe a release/"
Move-Item -Path "dist\*\*.exe" -Destination "release\Windows-x64.exe"

Write-Host "----Finalizado generación de instalador windows"