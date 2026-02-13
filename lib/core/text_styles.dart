import 'package:flutter/material.dart';

///Fuentes de texto para el modo oscuro (Letra blanca que resalta con un fondo oscuro)
class TextstylesDark {
  /// Tamaño:18
  static const TextStyle bodyText = TextStyle(color: Colors.white, fontSize: 18);
  /// Tamaño 18 + Negrilla
  static const TextStyle subtitle = TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold);
  /// Tamaño 22 + Negrilla
  static const TextStyle title = TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold);
  /// Tamaño 60 + Negrilla
  static const TextStyle homeTitle = TextStyle(color: Colors.white, fontSize: 60, fontWeight: FontWeight.bold);

}

///Fuentes de texto para el modo oscuro (Letra negra que resalta con un fondo claro)
class TextstylesLight {
  ///Tamaño:18
  static const TextStyle bodyText = TextStyle(color: Colors.black, fontSize: 18);
  ///Tamaño 18 + Negrilla
  static const TextStyle subtitle = TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold);
  ///Tamaño 22 + Negrilla
  static const TextStyle title = TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold);
  ///Tamaño 60 + Negrilla
  static const TextStyle homeTitle = TextStyle(color: Colors.black, fontSize: 60, fontWeight: FontWeight.bold);

}