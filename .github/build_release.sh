#Este es un script para generar los builds de los que soporta el tag actual

#Instalar zip para empacar la build de windows
sudo apt-get install zip
#Obtener paquetes
flutter pub get
#Testear
flutter test
#Generar apk universal
flutter build apk --flavor production -v
#Generar apks por arquitectura
flutter build apk --split-per-abi --flavor production -v
#Generar ejecutable para windows
flutter build windows -v
#Comprimir ejecutable para windows
cd build/windows/x64/runner/Release
zip -r ../Windows-x64.zip .

#Renombrar apks correspondientes a su arquitectura
cd -
cd build/app/outputs/flutter-apk/
mv app-armeabi-v7a-production-release.apk Android-armeabi-v7a.apk
mv app-arm64-v8a-production-release.apk Android-arm64-v8a.apk
mv app-x86_64-production-release.apk Android-x86-64.apk
mv app-production-release.apk Android-universal.apk
