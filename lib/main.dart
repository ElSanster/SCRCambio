import 'dart:developer'; //Para logear "log()" variables ya que no las muestra en el visual
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:scrcambio_app/core/adaptative_colors.dart';
import 'package:scrcambio_app/core/brightness_android.dart';
import 'package:themed/themed.dart';
import 'package:flutter/material.dart';
import 'package:scrcambio_app/core/settings_keys.dart';
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
  //Para los gestos
  bool _isDoubleTapping = false;
  bool _darkMode = DefaultValues.darkMode;
  bool _textEnabled = DefaultValues.homeText;
  String _text = "Cambio";
  bool _keepAliveDark = DefaultValues.keepAliveDark;
  bool _keepAliveLight = DefaultValues.keepAliveLight;
  double _brightnessDark = DefaultValues.brightnessDarkAndroid;
  double _brightnessLight = DefaultValues.brightnessLightAndroid;
  double _opacity = DefaultValues.brightnessLightOther;

  //Sobreescribir para cargar las opciones de configuración.
  @override
  void initState() {
    _loadPrefs();
    log("initState disparado");
    super.initState();
  }

  ///Enviar usuario a la configuración, cuando vuelva a la pantalla principal, llamar _loadPrefs()
  void _navigateToConfiguration(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ConfigurationScreen()),
    );
    //Al volver de la configuración recargar las opciones.
    _loadPrefs();
    log("SetState de la configuración disparada");
  }

  ///Cargar las variables necesarias de SharedPreferences y actualizar widget. asíncrono
  void _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      //Establecer brillo dependiendo del SO
      if (Platform.isAndroid) {
        //Debería dejar los valores en números positivos entre 0 y 1
        _opacity = 0;//Sin cambios
        _brightnessDark =
            prefs.getDouble(SettingKeys.brightnessDarkAndroid) ??
            DefaultValues.brightnessDarkAndroid;
        _brightnessLight =
            prefs.getDouble(SettingKeys.brightnessLightAndroid) ??
            DefaultValues.brightnessLightAndroid;
        Brightnessandroid.setBrightness(_darkMode ? _brightnessDark : _brightnessLight);
        if(_brightnessDark > 1 || _brightnessDark < 0){
          log("_brghtdark en android supero el límite, usando Default");
          _brightnessDark = DefaultValues.brightnessDarkAndroid;
        }
        if(_brightnessLight > 1 || _brightnessLight < 0){
          log("_brghtdark en android supero el límite, usando Default");
          _brightnessDark = DefaultValues.brightnessLightAndroid;
        }
      } else {
        //Debería dejar loa valores en números negativos entre -1 y 0
        _opacity = _darkMode
            ? prefs.getDouble(SettingKeys.brightnessDarkOther) ??
                  DefaultValues.brightnessDarkOther
            : prefs.getDouble(SettingKeys.brightnessLightOther) ??
                  DefaultValues.brightnessLightOther;
        _brightnessDark =
            prefs.getDouble(SettingKeys.brightnessDarkOther) ??
            DefaultValues.brightnessDarkOther;
        _brightnessLight =
            prefs.getDouble(SettingKeys.brightnessLightOther) ??
            DefaultValues.brightnessLightOther;

        if(_brightnessLight > 0 || _brightnessLight < -1 ){
          log("_brghtLight noAndroid supero el límite, reseteado a Default");
          _brightnessLight = DefaultValues.brightnessLightOther;
        }
        if(_brightnessDark > 0 || _brightnessDark < -1){
          log("_brghtdark noAndroid supero el límite, reseteado a Default");
          _brightnessDark = DefaultValues.brightnessDarkOther;
        }
      }

      //Cargar modo de luz
      _darkMode = prefs.getBool(SettingKeys.darkMode) ?? DefaultValues.darkMode;
      log("_darkMode: $_darkMode");

      //Cargar texto
      _textEnabled =
          prefs.getBool(SettingKeys.homeText) ?? DefaultValues.homeText;
      _text = _textEnabled ? "Cambio" : "";
      log("_textEnabled: $_textEnabled, _text: $_text");

      //Cargar mantener pantalla encendida en modo oscuro
      _keepAliveDark =
          prefs.getBool(SettingKeys.keepAwakeDark) ??
          DefaultValues.keepAliveDark;
      log("_keepAliveDark: $_keepAliveDark");

      //Cargar mantener pantalla encendida en modo claro
      _keepAliveLight =
          prefs.getBool(SettingKeys.keepAwakeLight) ??
          DefaultValues.keepAliveLight;
      log("_keepAliveLight: $_keepAliveLight");
    });
  }

  ///Invierte la luz, actualizando SharedPreferences y actualizando el widget, asíncrono
  void _switchLightMode() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _darkMode = !_darkMode;
      prefs.setBool(SettingKeys.darkMode, _darkMode);
      //Dependiendo del modo oscuro poner el brillo correspondiente
      if (Platform.isAndroid) {
       log("Switch de brillo usando setBrightness (android)");
       Brightnessandroid.setBrightness(_darkMode ? _brightnessDark : _brightnessLight);
      } else {
       log("Switch de brillo usando themed (otros OS)");
        _opacity = _darkMode ? _brightnessDark : _brightnessLight;
      }
    });
    log(
      "Switch _darkMode: $_darkMode, brillo:${_darkMode ? _brightnessDark : _brightnessLight} _opacity $_opacity.",
    );
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
            //Widget que mantiene el brillo en otros OS que Android
            child: ChangeColors(
              brightness: _opacity,
              child: Scaffold(
                body: CallbackShortcuts(
                  bindings: {
                    SingleActivator(LogicalKeyboardKey.escape):(){
                      log("Botón Ir a menú Presionado.");
                      _navigateToConfiguration(scaffoldContext);
                    },
                    SingleActivator(LogicalKeyboardKey.space):(){
                      log("Botón switch presionado");
                      _switchLightMode();
                    }
                  },
                  child: Focus(
                    autofocus: true,
                    child: Container(
                      alignment: Alignment.center,
                      child: Center(
                        //Texto que cambia dependiendo del modo de luz de la app
                        child: AdaptativeColors.textHomeTitle(
                          _text, _darkMode
                        ),
                      ),
                    ),
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
