#!/bin/bash

echo "----Obtener paquetes"
flutter pub get

echo "----Instalar dependencias de sistema"
sudo apt-get update -y
sudo apt-get install -y clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev rpm

echo "----Instalar flutter_distributor"
dart pub global activate flutter_distributor

echo "----Crear directorio release"
mkdir -p release

echo "----Generar .deb"
flutter_distributor package --platform linux --targets deb --skip-clean
mv dist/*/*.deb release/Linux-x64.deb

echo "----Generar .rpm"
flutter_distributor package --platform linux --targets rpm --skip-clean
mv dist/*/*.rpm release/Linux-x64.rpm

echo "----Finalizado"