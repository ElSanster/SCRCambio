#Este es un script para generar los builds de android del tag en ubuntu

echo "----Obtener paquetes (flutter pub get)"
flutter pub get

echo "----Generando key.properties"
cd android
touch key.properties
echo storePassword=$RELEASE_STOREPASSWORD >> key.properties
echo keyPassword=$RELEASE_KEYPASSWORD >> key.properties
echo keyAlias=$RELEASE_KEYALIAS >> key.properties

echo "----Generar apk universal (flutter build apk --flavor production)"
flutter build apk --flavor production

echo "----Generar apks por arquitectura (flutter build apk --split-per-abi --flavor production)"
flutter build apk --split-per-abi --flavor production

echo "----Renombrar apks correspondientes a su arquitectura (con mv en build/app/outputs/flutter-apk/)"
cd -
cd build/app/outputs/flutter-apk/
mv app-armeabi-v7a-production-release.apk release/Android-armeabi-v7a.apk
mv app-arm64-v8a-production-release.apk release/Android-arm64-v8a.apk
mv app-x86_64-production-release.apk release/Android-x86-64.apk
mv app-production-release.apk release/Android-universal.apk

echo "Finalizado generación de apks y renombrado"