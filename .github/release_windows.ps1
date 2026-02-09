# Este es un script para generar la build del tag de y para windows

Write-Host "----Obtener paquetes (flutter --version)"
flutter --version

Write-Host "----Generar ejecutable para windows (flutter build windows)"
flutter build windows

Write-Host "----Comprimir ejecutable para windows"
Compress-Archive -Path "build/windows/x64/runner/Release/*" -DestinationPath "build/windows/x64/runner/Release/Windows-x64.zip"

Write-Host "----Finalizado generación de ejecutable y comprimido"
