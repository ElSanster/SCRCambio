import 'dart:developer' as developer;
import 'package:flutter/material.dart' show debugPrint;
import 'package:screen_brightness/screen_brightness.dart';

class Brightnessandroid {
  ///Aplicar una cantidad de brillo en la pantalla en Android
  ///<br />Valor entre 0.0 y 1.0
  static Future<void> setBrightness(double brightness) async {
  if (brightness < 0.0 || brightness > 1.0) {
    developer.log("setAplicationBrightness FALLIDO, valores fuera del rango.");
    return;
  }
  try {
    await ScreenBrightness.instance.setApplicationScreenBrightness(brightness);
  } catch (e) {
    debugPrint(e.toString());
    throw 'Falla al intentar poner el brillo';
  }
  }
}