import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:scrcambio_app/core/settings_keys.dart';
import 'package:scrcambio_app/core/text_styles.dart';
import 'package:scrcambio_app/screens/configuration_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool _isDoubleTapping = false;
  bool _darkMode = false;
  bool _textEnabled = true;
  String _text = "Cambio";

  @override
  void initState() {
    //TO Do: Por alguna razón, al inicializar la app, no refleja las configuraciones.
    //Cargan a la hora de hacer el cambio a modo oscuro o en la configuración.
    //Pero no aquí.
    _loadPrefs();
    log("initState disparado");
    super.initState();
  }

  void _navigateToConfiguration(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ConfigurationScreen()),
    );
    //Al volver de la configuración recargar las opciones.
    setState(() {
      _loadPrefs();
      log("SetState de la configuración disparada");
    });
  }

  void _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    //Cargar modo claro
    _darkMode = prefs.getBool(SettingKeys.darkMode) ?? DefaultValues.darkMode;
    log("_darkMode: $_darkMode");

    //Cargar texto habilitado
    _textEnabled =
        prefs.getBool(SettingKeys.homeText) ?? DefaultValues.homeText;
    _text = _textEnabled ? "Cambio" : "";
    log("_textEnabled: $_textEnabled, _text: $_text");
  }

  void _switchLightMode() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _darkMode = !_darkMode;
      prefs.setBool(SettingKeys.darkMode, _darkMode);
    });
    log("Switch _darkMode: $_darkMode");
  }

  @override
  Widget build(BuildContext context) {
    //Material app contiene los temas y transciciones rápidas, tambien el contexto para navegar
    //a la configuración, transferido al builder
    return MaterialApp(
      theme: _darkMode ? ThemeData.dark() : ThemeData.light(),
      home: Builder(
        builder: (BuildContext scaffoldContext) {
          //Este builder nos da el contexto del materialapp para poder navegar a gusto a la config
          return GestureDetector(
            //Al mantener click
            onLongPress: () {
              log("INFO: Botón mantenido presionado");
              _switchLightMode();
            },
            //Al tocar dos veces
            onDoubleTapDown: (TapDownDetails details) {
              //Retrasa la ejecución durante 300 microsegundos, y
              // da tiempo a onHorizontalDragEnd a detectar el deliz a la izquierda
              log("INFO: Doble toque registrado");
              _isDoubleTapping = true;
              Future.delayed(const Duration(milliseconds: 300), () {
                _isDoubleTapping = false;
              });
            },
            onHorizontalDragEnd: (DragEndDetails details) {
              //Verifica que estemos durante este retraso para ir a la configuración
              log("Deslizado registrado.");
              if (_isDoubleTapping && details.velocity.pixelsPerSecond.dx < 0) {
                log("Requisitos para configuración dados");
                _navigateToConfiguration(
                  scaffoldContext,
                ); //Uso del contexto para ir a la config
                _isDoubleTapping = false;
              }
            },
            child: Scaffold(
              body: Container(
                alignment: Alignment.center,
                child: Center(
                  child: Text(
                    _text,
                    style: _darkMode
                        ? TextstylesDark.title
                        : TextstylesLight.title,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
