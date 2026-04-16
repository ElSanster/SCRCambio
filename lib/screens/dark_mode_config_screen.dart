import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scrcambio_app/components/color_selector_title.dart';
import 'package:scrcambio_app/core/adaptative_colors.dart';
import 'package:scrcambio_app/core/brightness_android.dart';
import 'package:scrcambio_app/core/settings_keys.dart';
import 'package:scrcambio_app/core/preferences_values.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:themed/themed.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class DarkModeConfigScreen extends StatefulWidget {
  const DarkModeConfigScreen({super.key});

  @override
  State<DarkModeConfigScreen> createState() => _DarkModeConfigScreenState();
}

class _DarkModeConfigScreenState extends State<DarkModeConfigScreen> {
  bool _darkmode = DefaultValues.darkMode;
  bool _homeText = DefaultValues.homeText;
  bool _keepAliveDark = DefaultValues.keepAliveDark;
  bool _keepAliveLight = DefaultValues.keepAliveLight;
  double _brightnessDark = DefaultValues.brightnessDarkAndroid;
  double _brightnessLight = DefaultValues.brightnessLightAndroid;
  double _opacity = DefaultValues.brightnessLightOther;
  String _brightText = "Brillo";
  Color _darkColor = AdaptativeColors.backgroundColor(true);
  Color _lightColor = AdaptativeColors.backgroundColor(true);
  bool _useSystemThemeDark = DefaultValues.useSystemThemeDark;

  @override
  void initState() {
    _loadSettings();
    developer.log("initState config iniciado");
    super.initState();
  }

  void _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    //Aquí se añaden los datos de la configuración
    setState(() {
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
      _darkColor = Color(
        prefs.getInt(SettingKeys.darkColor) ??
            AdaptativeColors.themeData(true).colorScheme.primary.value,
      );

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

      //Cargar Wakelock
      if (_darkmode) {
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

    //Cargar si se usa el tema del sistema en modo oscuro
    _useSystemThemeDark =
        prefs.getBool(SettingKeys.useSystemThemeDark) ??
        DefaultValues.useSystemThemeDark;

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
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _useSystemThemeDark
          ? AdaptativeColors.themeData(_darkmode)
          : (_darkmode
                ? AdaptativeColors.themeData(true, seedColor: _darkColor)
                : AdaptativeColors.themeData(false, seedColor: _lightColor)),
      child: ChangeColors(
        brightness: _opacity,
        child: Scaffold(
          appBar: AppBar(title: Text("Modo Oscuro - SCRCambio")),
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
                            child: ListView(children: _leftColumnItems()),
                          ),
                          VerticalDivider(width: 1),
                          Expanded(
                            child: ListView(children: _rightColumnItems()),
                          ),
                        ],
                      );
                    } else {
                      // Pantalla angosta: 1 columna normal
                      return ListView(
                        children: [
                          ..._leftColumnItems(),
                          ..._rightColumnItems(),
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

  Widget mainSimulate() {
    String text;
    if (_homeText) {
      text = "Cambio";
    } else {
      text = "";
    }
    return Builder(
      builder: (context) {
        return Theme(
          data: _useSystemThemeDark
              ? AdaptativeColors.themeData(_darkmode)
              : AdaptativeColors.themeData(true, seedColor: _darkColor),
          child: Scaffold(
            body: InkResponse(
              focusColor: Colors.transparent,
              hoverColor: Colors.transparent,
              onLongPress: () {},
              onDoubleTap: () {},
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Center(
                  //Texto que cambia dependiendo del modo de luz de la app
                  child: AdaptativeColors.textHomeTitle(text, true),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _leftColumnItems() {
    return [
      Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
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
            //Selección de colores
            Card(
              child: Column(
                children: [
                  ListTile(
                    title: AdaptativeColors.textTitle("Colores", _darkmode),
                    leading: Icon(Icons.palette_outlined),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8),
                    child: Divider(),
                  ),
                  Tooltip(
                    message:
                        "Usa los colores de por defecto (Usualmente del sistema en Android)",
                    child: SwitchListTile(
                      title: AdaptativeColors.textBody(
                        "Usar colores del sistema",
                        _darkmode,
                      ),
                      value: _useSystemThemeDark,
                      onChanged: (value) {
                        setState(() {
                          PreferencesValues.saveSetting(
                            SettingKeys.useSystemThemeDark,
                            value,
                          );
                          _useSystemThemeDark = value;
                        });
                      },
                    ),
                  ),
                  if (_useSystemThemeDark == false)
                    ColorSelectorTile(
                      text: "Color para modo Oscuro",
                      currentColor: _darkColor,
                      presetColors: AdaptativeColors.darkColors,
                      darkMode: _darkmode,
                      onColorChanged: (color) {
                        setState(() {
                          _darkColor = color;
                          PreferencesValues.saveSetting(
                            SettingKeys.darkColor,
                            color,
                          );
                        });
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

  List<Widget> _rightColumnItems() {
    return [
      Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Column(
          children: [
            Card(
              child: Column(
                children: [
                  //Vista previa
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          title: AdaptativeColors.textTitle(
                            "Vista Previa",
                            _darkmode,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 8),
                          child: Divider(),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            width: double.infinity,
                            height: 400,
                            child: mainSimulate(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ];
  }
}
