# Este es un script para generar los builds de los que soporta el tag actual

Write-Host "Obtener paquetes (flutter pub get)"
flutter pub get

Write-Host "Decodificando keystore para firmado usando base64"
$keystoreBytes = [Convert]::FromBase64String($env:ANDROID_KEYSTORE)
Set-Content -Path "D:\a\SCRCambio\SCRCambio\android\upload-keystore.jks" -Value $keystoreBytes -Encoding Byte

Write-Host "Creando key.properties para firmado"
$keyPropertiesContent = @"
storeFile=D:\\a\\SCRCambio\\SCRCambio\\android\\upload-keystore.jks
storePassword=$env:KEYSTORE_PASSWORD
keyAlias=$env:KEY_ALIAS
keyPassword=$env:KEY_PASSWORD
"@
Set-Content -Path "D:\\a\\SCRCambio\\SCRCambio\\android\\key.properties" -Value $keyPropertiesContent

Write-Host "Generar apk universal (flutter build apk --flavor production)"
flutter build apk --flavor production

Write-Host "Generar apks por arquitectura (flutter build apk --split-per-abi --flavor production)"
flutter build apk --split-per-abi --flavor production

Write-Host "Generar ejecutable para windows (flutter build windows)"
flutter build windows

Write-Host "Comprimir ejecutable para windows"
Compress-Archive -Path "build/windows/x64/runner/Release/*" -DestinationPath "build/windows/x64/runner/Release/Windows-x64.zip"

Write-Host "Renombrar apks correspondientes a su arquitectura"
Move-Item -Path "build/app/outputs/flutter-apk/app-armeabi-v7a-production-release.apk" -Destination "build/app/outputs/flutter-apk/Android-armeabi-v7a.apk"
Move-Item -Path "build/app/outputs/flutter-apk/app-arm64-v8a-production-release.apk" -Destination "build/app/outputs/flutter-apk/Android-arm64-v8a.apk"
Move-Item -Path "build/app/outputs/flutter-apk/app-x86_64-production-release.apk" -Destination "build/app/outputs/flutter-apk/Android-x86-64.apk"
Move-Item -Path "build/app/outputs/flutter-apk/app-production-release.apk" -Destination "build/app/outputs/flutter-apk/Android-universal.apk"

Write-Host "Finalizado generación de apks y renombrado"
