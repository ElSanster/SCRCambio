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

class LightModeConfigScreen extends StatefulWidget {
  const LightModeConfigScreen({super.key});

  @override
  State<LightModeConfigScreen> createState() => _LightModeConfigScreenState();
}

class _LightModeConfigScreenState extends State<LightModeConfigScreen> {
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
  bool _useSystemThemeLight = DefaultValues.useSystemThemeLight;

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
      data: _useSystemThemeLight
          ? AdaptativeColors.themeData(_darkmode)
          : (_darkmode
                ? AdaptativeColors.themeData(true, seedColor: _darkColor)
                : AdaptativeColors.themeData(false, seedColor: _lightColor)),
      child: ChangeColors(
        brightness: _opacity,
        child: Scaffold(
          appBar: AppBar(title: Text("Modo claro - SCRCambio")),
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
                color: _useSystemThemeLight
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
                child: ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsetsGeometry.all(8),
                      child: Column(
                        children: [
                          Card(
                            child: ListTile(
                              title: AdaptativeColors.subtitle(
                                "Modo Claro",
                                _darkmode,
                              ),
                              leading: Icon(Icons.light_mode_outlined),
                            ),
                          ),
                          Card(
                            child: Column(
                              children: [
                                ListTile(
                                  title: AdaptativeColors.textTitle(
                                    "General",
                                    _darkmode,
                                  ),
                                  leading: Icon(Icons.wb_sunny_outlined),
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
                                  padding: const EdgeInsets.only(
                                    left: 8.0,
                                    right: 8,
                                  ),
                                  child: Divider(),
                                ),
                                //Slider para modificar el brillo en modo claro
                                sliderBrightnessWhite(context),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0, right: 8),
                            child: Divider(),
                          ),
                          //Selección de colores
                          Card(
                            child: Column(
                              children: [
                                ListTile(
                                  title: AdaptativeColors.textTitle(
                                    "Colores",
                                    _darkmode,
                                  ),
                                  leading: Icon(Icons.palette_outlined),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 8.0,
                                    right: 8,
                                  ),
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
                                    value: _useSystemThemeLight,
                                    onChanged: (value) {
                                      setState(() {
                                        _useSystemThemeLight = value;
                                        PreferencesValues.saveSetting(
                                          SettingKeys.useSystemThemeLight,
                                          value,
                                        );
                                      });
                                    },
                                  ),
                                ),
                                if (_useSystemThemeLight == false)
                                  ColorSelectorTile(
                                    text: "Color en modo Claro",
                                    currentColor: _lightColor,
                                    presetColors: AdaptativeColors.lightColors,
                                    darkMode: _darkmode,
                                    onColorChanged: (color) {
                                      setState(() {
                                        _lightColor = color;
                                        PreferencesValues.saveSetting(
                                          SettingKeys.lightColor,
                                          color,
                                        );
                                      });
                                    },
                                  ),
                              ],
                            ),
                          ),
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
                                  padding: const EdgeInsets.only(
                                    left: 8.0,
                                    right: 8,
                                  ),
                                  child: Divider(),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SizedBox(
                                    width: double.infinity,
                                    height: 400,
                                    child: mainSimulate(_darkmode),
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
            ),
          ),
        ),
      ),
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

  Widget mainSimulate(bool darkMode) {
    String text;
    if (_homeText) {
      text = "Cambio";
    } else {
      text = "";
    }
    return Builder(
      builder: (context) {
        return Theme(
          data: _useSystemThemeLight
              ? AdaptativeColors.themeData(_darkmode)
              : AdaptativeColors.themeData(false, seedColor: _lightColor),
          child: Scaffold(
            body: InkResponse(
              focusColor: Colors.transparent,
              hoverColor: Colors.transparent,
              onDoubleTap: () {},
              child: Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
                alignment: Alignment.center,
                child: Center(
                  //Texto que cambia dependiendo del modo de luz de la app
                  child: AdaptativeColors.textHomeTitle(text, false),
                ),
              ),
            ),
          ),
        );
      }
    );
  }
}
