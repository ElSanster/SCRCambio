import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scrcambio_app/core/adaptative_colors.dart';
import 'package:scrcambio_app/core/brightness_android.dart';
import 'package:scrcambio_app/core/settings_keys.dart';
import 'package:scrcambio_app/core/preferences_values.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AdaptativeColors.themeData(_darkmode),
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
              color: AdaptativeColors.backgroundColor(_darkmode),
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsetsGeometry.all(8),
                    child: Column(
                      children: [
                        Card(
                          child: Column(
                            children: [
                              ListTile(
                                title: AdaptativeColors.subtitle(
                                  "Modo Oscuro",
                                  _darkmode,
                                ),
                                leading: Icon(Icons.dark_mode_outlined),
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
                                padding: const EdgeInsets.only(
                                  left: 8.0,
                                  right: 8,
                                ),
                                child: Divider(),
                              ),
                              //Slider para modificar el brillo en modo oscuro
                              sliderBrightnessDark(context),
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
                ],
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

  Scaffold mainSimulate() {
    String text;
    if (_homeText) {
      text = "Cambio";
    } else {
      text = "";
    }
    return Scaffold(
      backgroundColor: AdaptativeColors.backgroundColor(true),
      body: InkResponse(
        onDoubleTap: () {},
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
          alignment: Alignment.center,
          child: Center(
            //Texto que cambia dependiendo del modo de luz de la app
            child: AdaptativeColors.textHomeTitle(text, true),
          ),
        ),
      ),
    );
  }
}
