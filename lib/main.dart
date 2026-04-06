import 'dart:developer' as developer;//Para logear "log()" variables ya que no las muestra en el visual
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:scrcambio_app/core/adaptative_colors.dart';
import 'package:scrcambio_app/core/brightness_android.dart';
import 'package:scrcambio_app/core/dohaptics.dart';
import 'package:scrcambio_app/core/preferences_values.dart';
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

  //Inicializar variables con placeholders
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
  bool _haptics = DefaultValues.haptics;
  int _hapticsMode = DefaultValues.hapticsMode;
  Color _darkColor = AdaptativeColors.backgroundColor(true);
  Color _lightColor = AdaptativeColors.backgroundColor(true);
  bool _useSystemThemeDark = DefaultValues.useSystemThemeDark;
  bool _useSystemThemeLight = DefaultValues.useSystemThemeLight;

  //Sobreescribir para cargar las opciones de configuración.
  @override
  void initState() {
    developer.log("initState disparado");
    _swipeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _swipeAnimation =
        Tween<Offset>(begin: Offset.zero, end: const Offset(-0.3, 0)).animate(
          CurvedAnimation(
            parent: _swipeAnimationController,
            curve: Curves.easeInOut,
          ),
        );
    developer.log("Initstate: Carga de animaciones completada");
    _loadPrefs();
    super.initState();
    developer.log("initState finalizado");
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
    developer.log("SetState de la configuración disparada");
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
          developer.log("_brghtdark en android supero el límite, usando Default");
          _brightnessDark = DefaultValues.brightnessDarkAndroid;
        }
        if (_brightnessLight > 1 || _brightnessLight < 0) {
          developer.log("_brghtdark en android supero el límite, usando Default");
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
          developer.log("_brghtLight noAndroid supero el límite, reseteado a Default");
          _brightnessLight = DefaultValues.brightnessLightOther;
        }
        if (_brightnessDark > 0 || _brightnessDark < -1) {
          developer.log("_brghtdark noAndroid supero el límite, reseteado a Default");
          _brightnessDark = DefaultValues.brightnessDarkOther;
        }
      }

      //Cargar modo de luz
      _darkMode = prefs.getBool(SettingKeys.darkMode) ?? DefaultValues.darkMode;
      developer.log("_darkMode: $_darkMode");

      //Cargar texto
      _textEnabled =
          prefs.getBool(SettingKeys.homeText) ?? DefaultValues.homeText;
      _text = _textEnabled ? "Cambio" : "";
      developer.log("_textEnabled: $_textEnabled, _text: $_text");

      //Cargar mantener pantalla encendida en modo oscuro
      _keepAliveDark =
          prefs.getBool(SettingKeys.keepAwakeDark) ??
          DefaultValues.keepAliveDark;
      developer.log("_keepAliveDark: $_keepAliveDark");

      //Cargar mantener pantalla encendida en modo claro
      _keepAliveLight =
          prefs.getBool(SettingKeys.keepAwakeLight) ??
          DefaultValues.keepAliveLight;
      developer.log("_keepAliveLight: $_keepAliveLight");

      //Cargar Wakelock
      if (_darkMode) {
        if (_keepAliveDark) {
          WakelockPlus.enable();
        } else {
          WakelockPlus.disable();
        }
      } else if (_keepAliveLight) {
        WakelockPlus.enable();
      } else {
        WakelockPlus.disable();
      }

      //Verificar primer inicio de aplicación
      _firstOpen =
          prefs.getBool(SettingKeys.firstOpen) ?? DefaultValues.firstOpen;
      developer.log("_firstOpen: $_firstOpen");

      //Cargar vibracion activada
      _haptics = prefs.getBool(SettingKeys.haptics) ?? DefaultValues.firstOpen;
      developer.log("_haptics: $_haptics");

      //Cargar tipo de vibración
      _hapticsMode = prefs.getInt(SettingKeys.hapticsMode) ?? DefaultValues.hapticsMode;
      developer.log("_hapticsMode:$_hapticsMode");

      //Cargar si se usa el tema del sistema en modo oscuro
      _useSystemThemeDark = prefs.getBool(SettingKeys.useSystemThemeDark) ?? DefaultValues.useSystemThemeDark;

      //Cargar si se usa el tema del sistema en modo claro
      _useSystemThemeLight = prefs.getBool(SettingKeys.useSystemThemeLight) ?? DefaultValues.useSystemThemeLight;

      //Cargar color personalizado de modo oscuro
      _darkColor = Color(prefs.getInt(SettingKeys.darkColor) ?? AdaptativeColors.themeData(true).colorScheme.primary.value);

      //Cargar color personalizado de modo claro
      _lightColor = Color(prefs.getInt(SettingKeys.lightColor) ?? AdaptativeColors.themeData(false).colorScheme.primary.value);

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
        developer.log("Switch de brillo usando setBrightness (android)");
        Brightnessandroid.setBrightness(
          _darkMode ? _brightnessDark : _brightnessLight,
        );
      } else {
        developer.log("Switch de brillo usando themed (otros OS)");
        _opacity = _darkMode ? _brightnessDark : _brightnessLight;
      }
      if (_darkMode) {
        if (_keepAliveDark) {
          WakelockPlus.enable();
        } else {
          WakelockPlus.disable();
        }
      } else if (_keepAliveLight) {
        WakelockPlus.enable();
      } else {
        WakelockPlus.disable();
      }
    });
    Dohaptics.dohaptics(_hapticsMode,_haptics);
    bool wakelockPlusEnabled = await WakelockPlus.enabled;
    developer.log(
      "Switch _darkMode: $_darkMode, brillo:${_darkMode ? _brightnessDark : _brightnessLight} _opacity $_opacity wakelockPlus habilitado: $wakelockPlusEnabled",
    );
  }

  @override
  Widget build(BuildContext context) {
    //Material app contiene los temas y transciciones rápidas, tambien el contexto para navegar
    //a la configuración, transferido al builder
    return MaterialApp(
      theme: _useSystemThemeLight ? AdaptativeColors.themeData(false) :AdaptativeColors.themeData(false, seedColor: _lightColor),
      darkTheme: _useSystemThemeDark ? AdaptativeColors.themeData(true) :AdaptativeColors.themeData(true, seedColor: _darkColor),
      themeMode: _darkMode ? ThemeMode.dark : ThemeMode.light,
      home: Builder(
        //Este builder nos da el contexto del materialapp para poder navegar a gusto a la config
        builder: (BuildContext scaffoldContext) {
          // Mostrar el diálogo de bienvenida si es el primer inicio (solo una vez por sesión)
          developer.log("First Open (Builder): $_firstOpen");
          if (_firstOpen && !_firstOpenDialogShown) {
            _firstOpenDialogShown = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              firstOpenDialog(scaffoldContext);
            });
          }
          //Este es para las teclas
          return CallbackShortcuts(
            bindings: {
              SingleActivator(LogicalKeyboardKey.escape): () {
                developer.log("Botón Ir a menú (ESC) Presionado.");
                _navigateToConfiguration(scaffoldContext);
              },
              SingleActivator(LogicalKeyboardKey.space): () {
                developer.log("Botón switch (Espacio) presionado");

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
                    developer.log("Botón Ir a menú (ESC) Presionado.");
                    _navigateToConfiguration(scaffoldContext);
                  },
                  SingleActivator(LogicalKeyboardKey.space): () {
                    developer.log("Botón switch (Espacio) presionado");
                    if (_firstOpen) {
                      settingsOpenDialog(scaffoldContext);
                    }
                    _switchLightMode();
                    if (_firstOpen) {
                      settingsOpenDialog(scaffoldContext);
                    }
                  },
                },
                child: GestureDetector(
                  onHorizontalDragEnd: (DragEndDetails details) {
                    //Verifica que estemos durante este retraso para ir a la configuración
                    developer.log("Deslizado registrado.");
                    if (_isDoubleTapping &&
                        details.velocity.pixelsPerSecond.dx < 0) {
                      developer.log("Requisitos para configuración dados");
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
                              developer.log("Botón Ir a menú (ESC) Presionado.");
                              _navigateToConfiguration(scaffoldContext);
                            },
                            SingleActivator(LogicalKeyboardKey.space): () {
                              developer.log("Botón switch (Espacio) presionado");

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
                                developer.log("INFO: Botón mantenido presionado");
                                _switchLightMode();
                                if (_firstOpen) {
                                  settingsOpenDialog(scaffoldContext);
                                }
                              },
                              onDoubleTap: () {
                                //Retrasa la ejecución durante 500 microsegundos, y
                                // da tiempo a onHorizontalDragEnd a detectar el deliz a la izquierda
                                developer.log("INFO: Doble toque registrado");
                                _isDoubleTapping = true;
                                Future.delayed(
                                  const Duration(milliseconds: 500),
                                  () {
                                    _isDoubleTapping = false;
                                  },
                                );
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
                  developer.log("Bienvenida Aceptada :)");
                  Navigator.of(ctx).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  void settingsOpenDialog(BuildContext scaffoldContext)  {
    //Llamar respectiva tarjeta de bienvenida
    developer.log("Primer inicio detectado para cuadro de info de config");
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
                developer.log("Bienvenida  config Aceptada, seteando _firstOpen :)");
                // Marcar que ya se mostró el diálogo de bienvenida
                setState(() {
                  _firstOpen = false;
                });
                PreferencesValues.saveSetting(SettingKeys.firstOpen, false);
                Navigator.of(ctx).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
