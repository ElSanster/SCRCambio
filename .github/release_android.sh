#!/bin/bash
# Script para generar los builds de android usando flutter_distributor

echo "----Obtener paquetes (flutter pub get)"
flutter pub get

echo "----Instalar flutter_distributor"
dart pub global activate flutter_distributor

echo "----Generar key.properties para firmado"
cd android
touch key.properties
echo storePassword=$RELEASE_STOREPASSWORD >> key.properties
echo keyPassword=$RELEASE_KEYPASSWORD >> key.properties
echo keyAlias=$RELEASE_KEYALIAS >> key.properties
echo storeFile=release.jks >> key.properties
cd -

echo "----Crear directorio release"
mkdir -p release

echo "----Generar APK universal"
flutter_distributor package --platform android --targets apk --flavor production --skip-clean
mv dist/*/*.apk release/Android-universal.apk

echo "----Generar APKs por arquitectura"
flutter_distributor package --platform android --targets apk --flavor production \
  --build-param="--split-per-abi" --skip-clean
mv dist/*/*armeabi-v7a*.apk release/Android-armeabi-v7a.apk
mv dist/*/*arm64-v8a*.apk release/Android-arm64-v8a.apk
mv dist/*/*x86_64*.apk release/Android-x86-64.apk

echo "----Finalizado generación de APKs"