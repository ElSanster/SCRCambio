#Este es un script para generar los builds de los que soporta el tag actual

echo "Instalar zip para empacar la build de windows (sudo apt-get install zip)"
sudo apt-get install zip

echo "Obtener paquetes (apt-get install zip)"
flutter pub get

echo "Decodificando keystore para firmado usando base64"
echo "${{ secrets.ANDROID_KEYSTORE }}" | base64 -d > android/upload-keystore.jks

echo "Creando key.properties para firmado"
cat > android/key.properties << EOF
storeFile=upload-keystore.jks
storePassword=${{ secrets.KEYSTORE_PASSWORD }}
keyAlias=${{ secrets.KEY_ALIAS }}
keyPassword=${{ secrets.KEY_PASSWORD }}
EOF

echo "Testear (flutter test)"
flutter test

echo "Generar apk universal (flutter build apk --flavor production)"
flutter build apk --flavor production

echo "Generar apks por arquitectura (flutter build apk --split-per-abi --flavor production)"
flutter build apk --split-per-abi --flavor production

echo "Generar ejecutable para windows (flutter build windows)"
flutter build windows

echo "Comprimir ejecutable para windows (cd build/windows/x64/runner/Release & zip -r ../Windows-x64.zip .)"
cd build/windows/x64/runner/Release
zip -r ../Windows-x64.zip .

echo "Renombrar apks correspondientes a su arquitectura (con mv en build/app/outputs/flutter-apk/)"
cd -
cd build/app/outputs/flutter-apk/
mv app-armeabi-v7a-production-release.apk Android-armeabi-v7a.apk
mv app-arm64-v8a-production-release.apk Android-arm64-v8a.apk
mv app-x86_64-production-release.apk Android-x86-64.apk
mv app-production-release.apk Android-universal.apk

echo "Finalizado generación de apks y renombrado"