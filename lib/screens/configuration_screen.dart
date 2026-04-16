import 'dart:developer' as developer;
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scrcambio_app/core/adaptative_colors.dart';
import 'package:scrcambio_app/core/dohaptics.dart';
import 'package:scrcambio_app/core/settings_keys.dart';
import 'package:scrcambio_app/core/brightness_android.dart';
import 'package:scrcambio_app/core/preferences_values.dart';
import 'package:scrcambio_app/screens/dark_mode_config_screen.dart';
import 'package:scrcambio_app/screens/light_mode_config_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:themed/themed.dart';

class ConfigurationScreen extends StatefulWidget {
  const ConfigurationScreen({super.key});

  @override
  State<ConfigurationScreen> createState() => _ConfigurationScreenState();
}

class _ConfigurationScreenState extends State<ConfigurationScreen> {
  bool _darkmode = DefaultValues.darkMode;
  bool _homeText = DefaultValues.homeText;
  bool _keepAliveDark = DefaultValues.keepAliveDark;
  bool _keepAliveLight = DefaultValues.keepAliveLight;
  double _brightnessDark = DefaultValues.brightnessDarkAndroid;
  double _brightnessLight = DefaultValues.brightnessLightAndroid;
  double _opacity = DefaultValues.brightnessLightOther;
  String _brightText = "Brillo";
  bool _haptics = DefaultValues.haptics;
  int _hapticsMode = DefaultValues.hapticsMode;
  Color _darkColor = AdaptativeColors.backgroundColor(true);
  Color _lightColor = AdaptativeColors.backgroundColor(true);
  bool _useSystemThemeDark = DefaultValues.useSystemThemeDark;
  bool _useSystemThemeLight = DefaultValues.useSystemThemeLight;

  //Sobreescribimos esto para cargar los datos al abrir la ventana de configuración.
  @override
  void initState() {
    _loadSettings();
    developer.log("initState config iniciado");
    super.initState();
  }

  ///Cargar datos almacenados en SharedPreferences
  void _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      //Aquí se añaden los datos de la configuración

      //Establecer brillo dependiendo del SO
      if (Platform.isAndroid) {
        developer.log("Cargando brillo desde android");
        _opacity = 0;
        _brightnessDark =
            prefs.getDouble(SettingKeys.brightnessDarkAndroid) ??
            DefaultValues.brightnessDarkAndroid;
        _brightnessLight =
            prefs.getDouble(SettingKeys.brightnessLightAndroid) ??
            DefaultValues.brightnessLightAndroid;
        Brightnessandroid.setBrightness(
          _darkmode ? _brightnessDark : _brightnessLight,
        );

        //Prevenir datos por fuera de los permitidos para brillo
        if (_brightnessDark > 1 || _brightnessDark < 0) {
          developer.log(
            "_brghtdark en android supero el límite, reseteado a Default",
          );
          _brightnessDark = DefaultValues.brightnessDarkAndroid;
          PreferencesValues.resetSetting(SettingKeys.brightnessDarkAndroid, () {
            _loadSettings();
          });
        }
        if (_brightnessLight > 1 || _brightnessLight < 0) {
          developer.log(
            "_brghtdark en android supero el límite, reseteado a Default",
          );
          _brightnessDark = DefaultValues.brightnessLightAndroid;
          PreferencesValues.resetSetting(
            SettingKeys.brightnessLightAndroid,
            () {
              _loadSettings();
            },
          );
        }
      } else {
        _opacity = _darkmode
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
        _brightText = "Opacidad";

        if (_brightnessLight > 1 || _brightnessLight < 0) {
          developer.log(
            "_brghtLight noAndroid supero el límite, reseteado a Default",
          );
          _brightnessLight = DefaultValues.brightnessLightOther;
          PreferencesValues.resetSetting(SettingKeys.brightnessLightOther, () {
            _loadSettings();
          });
        }
        if (_brightnessDark > 1 || _brightnessDark < 0) {
          developer.log(
            "_brghtdark noAndroid supero el límite, reseteado a Default",
          );
          _brightnessDark = DefaultValues.brightnessDarkOther;
          PreferencesValues.resetSetting(SettingKeys.brightnessDarkOther, () {
            _loadSettings();
          });
        }
      }
      developer.log(
        "_opacity: $_opacity, _brDark: $_brightnessDark, _brLight: $_brightnessLight",
      );

      //Cargar modo oscuro
      _darkmode = prefs.getBool(SettingKeys.darkMode) ?? DefaultValues.darkMode;
      developer.log("_darkmode despues de loadSettings: $_darkmode");

      //Cargar texto habilitado para la pantalla principal
      _homeText = prefs.getBool(SettingKeys.homeText) ?? DefaultValues.homeText;
      developer.log("_homeText despues de loadSettings: $_homeText");

      //Cargar mantener pantalla encendida en modo oscuro
      _keepAliveDark =
          prefs.getBool(SettingKeys.keepAwakeDark) ??
          DefaultValues.keepAliveDark;
      developer.log("_keepAliveDark despues de loadSettings: $_keepAliveDark");

      //Cargar mantener pantalla encendida en modo claro
      _keepAliveLight =
          prefs.getBool(SettingKeys.keepAwakeLight) ??
          DefaultValues.keepAliveLight;
      developer.log(
        "_keepAliveLight despues de loadSettings: $_keepAliveLight",
      );

      //Setear firstOpen en caso de que el usuario abra la config antes que cambiar el modo de luz, o cuando presione el botón de reiniciar configuracion
      if (prefs.getBool(SettingKeys.firstOpen) ??
          DefaultValues.firstOpen ||
              DefaultValues.forceMessagesDEBUG == false) {
        developer.log(
          "FirstOpen true detectado después de loadsettings, poniendolo en false.",
        );
        prefs.setBool(SettingKeys.firstOpen, false);
      }
      if (DefaultValues.forceMessagesDEBUG) {
        //Forzar mensajes de tutorial,
        developer.log("FORZANDO MENSAJES DE TUTORIAL, CUIDAO CON ESO");
        prefs.setBool(SettingKeys.firstOpen, true);
      }

      _haptics = prefs.getBool(SettingKeys.haptics) ?? DefaultValues.haptics;
      developer.log("_haptics después de loadsettings $_haptics");

      _hapticsMode =
          prefs.getInt(SettingKeys.hapticsMode) ?? DefaultValues.hapticsMode;
      developer.log("_hapticsMode después de loadsettings $_hapticsMode");

      //Cargar si se usa el tema del sistema en modo oscuro
      _useSystemThemeDark =
          prefs.getBool(SettingKeys.useSystemThemeDark) ??
          DefaultValues.useSystemThemeDark;

      //Cargar si se usa el tema del sistema en modo claro
      _useSystemThemeLight =
          prefs.getBool(SettingKeys.useSystemThemeLight) ??
          DefaultValues.useSystemThemeLight;

      //Cargar color personalizado de modo oscuro
      _darkColor = Color(
        prefs.getInt(SettingKeys.darkColor) ??
            AdaptativeColors.themeData(true).colorScheme.primary.value,
      );

      //Cargar color personalizado de modo claro
      _lightColor = Color(
        prefs.getInt(SettingKeys.lightColor) ??
            AdaptativeColors.themeData(false).colorScheme.primary.value,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      //Aplicar tema correspondiente al modo que tenga el usuario
      data: (_darkmode ? _useSystemThemeDark : _useSystemThemeLight)
          ? AdaptativeColors.themeData(_darkmode)
          : (_darkmode
                ? AdaptativeColors.themeData(true, seedColor: _darkColor)
                : AdaptativeColors.themeData(false, seedColor: _lightColor)),
      child: ChangeColors(
        //Capa que controla la opacidad fuera de android
        brightness: _opacity,
        child: Scaffold(
          appBar: AppBar(title: Text("SCRCambio - Alpha")),
          body: CallbackShortcuts(
            bindings: {
              SingleActivator(LogicalKeyboardKey.escape): () {
                developer.log("Botón Ir a menú principal Presionado.");
                Navigator.pop(context);
              },
            },
            child: Focus(
              autofocus: true,
              child: CardTheme(
                color: _useSystemThemeDark
                    ? AdaptativeColors.backgroundColor(_darkmode)
                    : (_darkmode
                          ? AdaptativeColors.backgroundColor(
                              true,
                              seedColor: _darkColor,
                            )
                          : AdaptativeColors.backgroundColor(
                              false,
                              seedColor: _lightColor,
                            )),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final bool isWide = constraints.maxWidth > 600;

                    if (isWide) {
                      // Pantalla ancha: 2 columnas
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ListView(children: _leftColumnItems(true)),
                          ),
                          VerticalDivider(width: 1),
                          Expanded(
                            child: ListView(children: _rightColumnItems(true)),
                          ),
                        ],
                      );
                    } else {
                      // Pantalla angosta: 1 columna normal
                      return ListView(
                        children: [
                          ..._leftColumnItems(false),
                          ..._rightColumnItems(false),
                        ],
                      );
                    }
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Column sliderBrightnessDark(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: 17.0,
            top: 10,
            right: 8,
            bottom: 10,
          ),
          child: AdaptativeColors.textBody("$_brightText:", _darkmode),
        ),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: _brightnessLight >= 0
                    ? _brightnessDark
                    : _brightnessDark * -1,
                onChangeEnd: (newBrightnesDark) {
                  setState(() {
                    _brightnessDark = newBrightnesDark;
                    if (Platform.isAndroid) {
                      Brightnessandroid.setBrightness(_brightnessDark);
                      PreferencesValues.saveSetting(
                        SettingKeys.brightnessDarkAndroid,
                        _brightnessDark,
                      );
                    } else {
                      _opacity = newBrightnesDark * -1;
                      PreferencesValues.saveSetting(
                        SettingKeys.brightnessDarkOther,
                        _opacity,
                      );
                    }
                  });
                },
                onChangeStart: (newBrightnesDark) {
                  _brightnessDark = newBrightnesDark;
                  if (_darkmode == false) {
                    setState(() {
                      _darkmode = true;
                      PreferencesValues.saveSetting(SettingKeys.darkMode, true);
                    });
                  }
                },
                onChanged: (newBrightnesDark) {
                  setState(() {
                    _brightnessDark = newBrightnesDark;
                  });
                },
                min: 0,
                max: 1,
                divisions: 100,
                label: (_brightnessDark * 100).toStringAsFixed(0),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Tooltip(
                message:
                    "Reinicia la cantidad de $_brightText a la por defecto.",
                child: AdaptativeColors.elevatedButton(
                  "Reiniciar",
                  context,
                  _darkmode,
                  () {
                    if (Platform.isAndroid) {
                      _brightnessDark = DefaultValues.brightnessDarkAndroid;
                      PreferencesValues.resetSetting(
                        SettingKeys.brightnessDarkAndroid,
                        () {
                          _loadSettings();
                        },
                      );
                    } else {
                      _brightnessDark = DefaultValues.brightnessDarkOther;
                      PreferencesValues.resetSetting(
                        SettingKeys.brightnessDarkOther,
                        () {
                          _loadSettings();
                        },
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Column sliderBrightnessWhite(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: 17.0,
            top: 10,
            right: 8,
            bottom: 10,
          ),
          child: AdaptativeColors.textBody("$_brightText:", _darkmode),
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Slider(
                //Evitar que el valor del slider sea distinto a los valores minimos
                value: _brightnessLight >= 0
                    ? _brightnessLight
                    : _brightnessLight * -1,
                onChangeEnd: (newBrightnesLight) {
                  setState(() {
                    _brightnessLight = newBrightnesLight;
                    if (Platform.isAndroid) {
                      Brightnessandroid.setBrightness(_brightnessLight);
                      PreferencesValues.saveSetting(
                        SettingKeys.brightnessLightAndroid,
                        _brightnessLight,
                      );
                    } else {
                      _opacity = newBrightnesLight * -1;
                      PreferencesValues.saveSetting(
                        SettingKeys.brightnessLightOther,
                        _opacity,
                      );
                    }
                  });
                },
                onChangeStart: (newBrightnesLight) {
                  _brightnessLight = newBrightnesLight;
                  if (_darkmode == true) {
                    setState(() {
                      _darkmode = false;
                      PreferencesValues.saveSetting(
                        SettingKeys.darkMode,
                        false,
                      );
                    });
                  }
                },
                onChanged: (newBrightnesLight) {
                  setState(() {
                    _brightnessLight = newBrightnesLight;
                  });
                },
                min: 0,
                max: 1,
                divisions: 100,
                label: (_brightnessLight * 100).toStringAsFixed(0),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Tooltip(
                message: "Reinicia la cantidad de $_brightText a por defecto.",
                child: AdaptativeColors.elevatedButton(
                  "Reiniciar",
                  context,
                  _darkmode,
                  () {
                    if (Platform.isAndroid) {
                      _brightnessLight = DefaultValues.brightnessLightAndroid;
                      PreferencesValues.resetSetting(
                        SettingKeys.brightnessLightAndroid,
                        () {
                          _loadSettings();
                        },
                      );
                    } else {
                      _brightnessLight = DefaultValues.brightnessLightOther;
                      PreferencesValues.resetSetting(
                        SettingKeys.brightnessLightOther,
                        () {
                          _loadSettings();
                        },
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _callConfirmResetDialog(BuildContext contexto, bool darkMode) {
    developer.log("Resetear datos llamado");
    showDialog(
      context: contexto,
      builder: (BuildContext ctx) => Theme(
        data: AdaptativeColors.themeData(darkMode, seedColor: _darkColor),
        child: AlertDialog(
          backgroundColor: AdaptativeColors.backgroundColor(darkMode),
          title: AdaptativeColors.textTitle(
            "Reiniciar Configuración",
            darkMode,
          ),
          content: AdaptativeColors.textBody(
            "¿Está seguro de reiniciar la configuración a estado de fábrica?${DefaultValues.forceMessagesDEBUG ? "\nMODO FORZAR MENSAJE ACTIVADO, Avisale a Sanster si ves esto." : ""}",
            darkMode,
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: TextButton(
                onPressed: () {
                  developer.log("Resetear datos Aceptado");
                  PreferencesValues.resetAllSettings(() {
                    _loadSettings();
                  });
                  Navigator.of(context).pop();
                },
                child: AdaptativeColors.textBody("Confirmar", darkMode),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: AdaptativeColors.elevatedButton(
                "Cancelar",
                contexto,
                darkMode,
                () {
                  developer.log("Resetear datos Denegado");
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _leftColumnItems(bool iswide) {
    return [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Card(
              child: SwitchListTile(
                title: AdaptativeColors.textBody("Modo Oscuro", _darkmode),
                secondary: _darkmode
                    ? Icon(Icons.dark_mode)
                    : Icon(Icons.light_mode),
                value: _darkmode,
                onChanged: (newDarkMode) {
                  setState(() {
                    _darkmode = newDarkMode;
                    PreferencesValues.saveSetting(
                      SettingKeys.darkMode,
                      newDarkMode,
                    );
                  });
                },
              ),
            ),
            if (iswide == false)
            Card(
              child: SwitchListTile(
                title: AdaptativeColors.textBody("Titulo Cambio", _darkmode),
                subtitle: AdaptativeColors.smallText(
                  "Habilita el titulo \"Cambio\" en la pantalla principal.",
                  _darkmode,
                ),
                secondary: Icon(Icons.abc),
                value: _homeText,
                onChanged: (newHomeText) {
                  setState(() {
                    _homeText = newHomeText;
                    PreferencesValues.saveSetting(
                      SettingKeys.homeText,
                      newHomeText,
                    );
                  });
                },
              ),
            ),
            if (Platform.isAndroid)
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      title: AdaptativeColors.textBody(
                        "Vibración al cambio",
                        _darkmode,
                      ),
                      secondary: Icon(Icons.vibration),
                      value: _haptics,
                      onChanged: (newHaptics) {
                        setState(() {
                          _haptics = newHaptics;
                          PreferencesValues.saveSetting(
                            SettingKeys.haptics,
                            newHaptics,
                          );
                        });
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          AdaptativeColors.textBody(
                            "Tipo de Vibración",
                            _darkmode,
                          ),
                          Spacer(),
                          DropdownMenu(
                            dropdownMenuEntries: <DropdownMenuEntry<int>>[
                              DropdownMenuEntry(value: 0, label: "Ligera"),
                              DropdownMenuEntry(value: 1, label: "Suave"),
                              DropdownMenuEntry(value: 2, label: "Mediana"),
                              DropdownMenuEntry(value: 3, label: "Pesada"),
                              DropdownMenuEntry(value: 4, label: "Rigida"),
                            ],
                            onSelected: (value) {
                              if (value != null && !(value < 0 || value > 8)) {
                                setState(() {
                                  _hapticsMode = value;
                                });
                                Dohaptics.dohaptics(value, _haptics);
                                PreferencesValues.saveSetting(
                                  SettingKeys.hapticsMode,
                                  value,
                                );
                              }
                            },
                            enabled: _haptics,
                            width: 200,
                            hintText: "Ligera",
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            Card(
              child: Column(
                children: [
                  ListTile(
                    title: AdaptativeColors.subtitle("Modo Claro", _darkmode),
                    leading: Icon(Icons.light_mode_outlined),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8),
                    child: Divider(),
                  ),
                  Tooltip(
                    message:
                        "Evita que la pantalla se apague al estar en modo claro. Puede gastar más batería.",
                    child: SwitchListTile(
                      title: AdaptativeColors.textBody(
                        "Mantener pantalla encendida",
                        _darkmode,
                      ),
                      value: _keepAliveLight,
                      onChanged: (newkeepAliveLight) {
                        setState(() {
                          _keepAliveLight = newkeepAliveLight;
                          PreferencesValues.saveSetting(
                            SettingKeys.keepAwakeLight,
                            newkeepAliveLight,
                          );
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8),
                    child: Divider(),
                  ),
                  //Slider para modificar el brillo en modo claro
                  sliderBrightnessWhite(context),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8),
                    child: Divider(),
                  ),
                  ListTile(
                    trailing: Icon(Icons.arrow_forward_ios_rounded),
                    title: AdaptativeColors.textBody("Más Opciones", _darkmode),
                    onTap: () {
                      developer.log("Más opciones del modo claro presionado.");
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LightModeConfigScreen(),
                        ),
                      ).then((_) => _loadSettings());
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _rightColumnItems(bool iswide) {
    return [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            if (iswide == true)
            Card(
              child: SwitchListTile(
                title: AdaptativeColors.textBody("Titulo Cambio", _darkmode),
                subtitle: AdaptativeColors.smallText(
                  "Habilita el titulo \"Cambio\" en la pantalla principal.",
                  _darkmode,
                ),
                secondary: Icon(Icons.abc),
                value: _homeText,
                onChanged: (newHomeText) {
                  setState(() {
                    _homeText = newHomeText;
                    PreferencesValues.saveSetting(
                      SettingKeys.homeText,
                      newHomeText,
                    );
                  });
                },
              ),
            ),

            Card(
              child: Column(
                children: [
                  ListTile(
                    title: AdaptativeColors.subtitle("Modo Oscuro", _darkmode),
                    leading: Icon(Icons.dark_mode_outlined),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8),
                    child: Divider(),
                  ),
                  Tooltip(
                    message:
                        "Evita que la pantalla se apague en modo oscuro, Puede gastar más batería",
                    child: SwitchListTile(
                      title: AdaptativeColors.textBody(
                        "Mantener pantalla encendida",
                        _darkmode,
                      ),
                      value: _keepAliveDark,
                      onChanged: (newkeepAliveDark) {
                        setState(() {
                          _keepAliveDark = newkeepAliveDark;
                          PreferencesValues.saveSetting(
                            SettingKeys.keepAwakeDark,
                            newkeepAliveDark,
                          );
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8),
                    child: Divider(),
                  ),
                  //Slider para modificar el brillo en modo oscuro
                  sliderBrightnessDark(context),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8),
                    child: Divider(),
                  ),
                  ListTile(
                    trailing: Icon(Icons.arrow_forward_ios_rounded),
                    title: AdaptativeColors.textBody("Más Opciones", _darkmode),
                    onTap: () {
                      developer.log("Más opciones del modo claro presionado.");
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DarkModeConfigScreen(),
                        ),
                      ).then((_) => _loadSettings());
                    },
                  ),
                ],
              ),
            ),
            Tooltip(
              message: "Reincia TODAS las configuraciones a por defecto.",
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: AdaptativeColors.elevatedButton(
                  "Reiniciar toda la configuración",
                  context,
                  _darkmode,
                  () {
                    _callConfirmResetDialog(context, _darkmode);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    ];
  }
}
