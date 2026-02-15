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
import 'package:wakelock_plus/wakelock_plus.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with TickerProviderStateMixin {
  //Para los gestos
  bool _isDoubleTapping = false;
  late AnimationController _swipeAnimationController;
  late Animation<Offset> _swipeAnimation;

  //Inicializar variables
  bool _darkMode = DefaultValues.darkMode;
  bool _textEnabled = DefaultValues.homeText;
  String _text = "Cambio";
  bool _keepAliveDark = DefaultValues.keepAliveDark;
  bool _keepAliveLight = DefaultValues.keepAliveLight;
  double _brightnessDark = DefaultValues.brightnessDarkAndroid;
  double _brightnessLight = DefaultValues.brightnessLightAndroid;
  double _opacity = DefaultValues.brightnessLightOther;
  bool _firstOpen = false;
  bool _firstOpenDialogShown = false;

  //Sobreescribir para cargar las opciones de configuración.
  @override
  void initState() {
    log("initState disparado");
    _swipeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _swipeAnimation = Tween<Offset>(begin: Offset.zero, end: const Offset(-0.3, 0))
        .animate(CurvedAnimation(parent: _swipeAnimationController, curve: Curves.easeInOut));
    log("Initstate: Carga de animaciones completada");
    _loadPrefs();
    super.initState();
    log("initState finalizado");
  }

  @override
  void dispose() {
    _swipeAnimationController.dispose();
    super.dispose();
  }

  ///Enviar usuario a la configuración, cuando vuelva a la pantalla principal, llamar _loadPrefs()
  void _navigateToConfiguration(BuildContext context) async {
    // Ejecutar animación de deslizamiento
    await _swipeAnimationController.forward();
    _swipeAnimationController.reset();
    
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ConfigurationScreen()),
    );
    //Al volver de la configuración recargar las opciones.
    _loadPrefs();
    log("SetState de la configuración disparada");
  }

  ///Cargar las variables necesarias de SharedPreferences y actualizar widget. asíncrono
  Future _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      //Establecer brillo dependiendo del SO
      if (Platform.isAndroid) {
        //Debería dejar los valores en números positivos entre 0 y 1
        _opacity = 0; //Sin cambios
        _brightnessDark =
            prefs.getDouble(SettingKeys.brightnessDarkAndroid) ??
            DefaultValues.brightnessDarkAndroid;
        _brightnessLight =
            prefs.getDouble(SettingKeys.brightnessLightAndroid) ??
            DefaultValues.brightnessLightAndroid;
        Brightnessandroid.setBrightness(
          _darkMode ? _brightnessDark : _brightnessLight,
        );
        if (_brightnessDark > 1 || _brightnessDark < 0) {
          log("_brghtdark en android supero el límite, usando Default");
          _brightnessDark = DefaultValues.brightnessDarkAndroid;
        }
        if (_brightnessLight > 1 || _brightnessLight < 0) {
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

        if (_brightnessLight > 0 || _brightnessLight < -1) {
          log("_brghtLight noAndroid supero el límite, reseteado a Default");
          _brightnessLight = DefaultValues.brightnessLightOther;
        }
        if (_brightnessDark > 0 || _brightnessDark < -1) {
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

      //Cargar Wakelock
      if(_darkMode){
        if(_keepAliveDark){
          WakelockPlus.enable();
        }else{
          WakelockPlus.disable();
        }
      }else if (_keepAliveLight){
        WakelockPlus.enable();
      }else{
        WakelockPlus.disable();
      }

      //Verificar primer inicio de aplicación
      _firstOpen =
          prefs.getBool(SettingKeys.firstOpen) ?? DefaultValues.firstOpen;
      log("_firstOpen: $_firstOpen");

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
        Brightnessandroid.setBrightness(
          _darkMode ? _brightnessDark : _brightnessLight,
        );
      } else {
        log("Switch de brillo usando themed (otros OS)");
        _opacity = _darkMode ? _brightnessDark : _brightnessLight;
      }
      if(_darkMode){
        if(_keepAliveDark){
          WakelockPlus.enable();
        }else{
          WakelockPlus.disable();
        }
      }else if (_keepAliveLight){
        WakelockPlus.enable();
      }else{
        WakelockPlus.disable();
      }
    });
    bool wakelockPlusEnabled = await WakelockPlus.enabled;
    log(
      "Switch _darkMode: $_darkMode, brillo:${_darkMode ? _brightnessDark : _brightnessLight} _opacity $_opacity wakelockPlus habilitado: $wakelockPlusEnabled",
    );
  }

  @override
  Widget build(BuildContext context) {
    //Material app contiene los temas y transciciones rápidas, tambien el contexto para navegar
    //a la configuración, transferido al builder
    return MaterialApp(
      theme: _darkMode ? ThemeData.dark() : ThemeData.light(),
      home: Builder(
        //Este builder nos da el contexto del materialapp para poder navegar a gusto a la config
        builder: (BuildContext scaffoldContext) {
          // Mostrar el diálogo de bienvenida si es el primer inicio (solo una vez por sesión)
          log("First Open (Builder): $_firstOpen");
          if (_firstOpen && !_firstOpenDialogShown) {
            _firstOpenDialogShown = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              firstOpenDialog(scaffoldContext);
            });
          }
          return CallbackShortcuts(
            bindings: {
              SingleActivator(LogicalKeyboardKey.escape): () {
                log("Botón Ir a menú (ESC) Presionado.");
                _navigateToConfiguration(scaffoldContext);
              },
              SingleActivator(LogicalKeyboardKey.space): () {
                log("Botón switch (Espacio) presionado");
          
                _switchLightMode();
                if (_firstOpen) {
                  settingsOpenDialog(scaffoldContext);
                }
              },
            },
            child: Focus(
              autofocus: true,
              child: CallbackShortcuts(
                bindings: {
                  SingleActivator(LogicalKeyboardKey.escape): () {
                    log("Botón Ir a menú (ESC) Presionado.");
                    _navigateToConfiguration(scaffoldContext);
                  },
                  SingleActivator(LogicalKeyboardKey.space): () {
                    log("Botón switch (Espacio) presionado");
              
                    _switchLightMode();
                    if (_firstOpen) {
                      settingsOpenDialog(scaffoldContext);
                    }
                  },
                },
                child: GestureDetector(
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
                  child: ChangeColors(
                    brightness: _opacity,
                    child: Scaffold(
                      body: Focus(
                        autofocus: true,
                        child: CallbackShortcuts(
                          bindings: {
                            SingleActivator(LogicalKeyboardKey.escape): () {
                              log("Botón Ir a menú (ESC) Presionado.");
                              _navigateToConfiguration(scaffoldContext);
                            },
                            SingleActivator(LogicalKeyboardKey.space): () {
                              log("Botón switch (Espacio) presionado");
                        
                              _switchLightMode();
                              if (_firstOpen) {
                                settingsOpenDialog(scaffoldContext);
                              }
                            },
                          },
                          child: SlideTransition(
                            position: _swipeAnimation,
                            child: InkResponse(
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              onLongPress: () {
                                log("INFO: Botón mantenido presionado");
                                _switchLightMode();
                                if (_firstOpen) {
                                  settingsOpenDialog(scaffoldContext);
                                }
                              },
                              onDoubleTap: () {
                                //Retrasa la ejecución durante 500 microsegundos, y
                                // da tiempo a onHorizontalDragEnd a detectar el deliz a la izquierda
                                log("INFO: Doble toque registrado");
                                _isDoubleTapping = true;
                                Future.delayed(const Duration(milliseconds: 500), () {
                                  _isDoubleTapping = false;
                                });
                              },
                              child: Container(
                                alignment: Alignment.center,
                                child: Center(
                                  //Texto que cambia dependiendo del modo de luz de la app
                                  child: AdaptativeColors.textHomeTitle(
                                    _text,
                                    _darkMode,
                                  ),
                                ),
                              ),
                            ),
                          ),
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

  void firstOpenDialog(BuildContext scaffoldContext) {
    //Llamar respectiva tarjeta de bienvenida
    if (_firstOpen) {
      showDialog(
        context: scaffoldContext,
        builder: (BuildContext ctx) {
          return AlertDialog(
            backgroundColor: AdaptativeColors.backgroundColor(_darkMode),
            title: AdaptativeColors.textTitle(
              "SCR Cambio - Bienvenida",
              _darkMode,
            ),
            content: AdaptativeColors.textBody(
              DefaultValues.welcomeMessage,
              _darkMode,
            ),
            actions: [
              AdaptativeColors.elevatedButton(
                "Aceptar",
                scaffoldContext,
                _darkMode,
                () {
                  log("Bienvenida Aceptada :)");
                  Navigator.of(ctx).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  void settingsOpenDialog(BuildContext scaffoldContext) async {
    //Llamar respectiva tarjeta de bienvenida
    log("Primer inicio detectado para cuadro de info de config");
    final prefs = await SharedPreferences.getInstance();
    showDialog(
      context: scaffoldContext,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: AdaptativeColors.backgroundColor(_darkMode),
          title: AdaptativeColors.textTitle(
            "SCR Cambio - Bienvenida",
            _darkMode,
          ),
          content: AdaptativeColors.textBody(
            DefaultValues.settingsMessage,
            _darkMode,
          ),
          actions: [
            AdaptativeColors.elevatedButton(
              "Aceptar",
              scaffoldContext,
              _darkMode,
              () {
                log("Bienvenida  config Aceptada, seteando _firstOpen :)");
                // Marcar que ya se mostró el diálogo de bienvenida
                setState(() {
                  _firstOpen = false;
                });
                prefs.setBool(SettingKeys.firstOpen, false);
                Navigator.of(ctx).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
