import 'dart:developer' as developer;
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scrcambio_app/core/settings_keys.dart';
import 'package:scrcambio_app/core/text_styles.dart';
import 'package:scrcambio_app/core/brightness_android.dart';
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
  bool _keepAwakeDark = DefaultValues.keepAliveDark;
  bool _keepAliveLight = DefaultValues.keepAliveLight;
  double _brightnessDark = DefaultValues.brightnessDarkAndroid;
  double _brightnessLight = DefaultValues.brightnessLightAndroid;
  double _opacity = DefaultValues.brightnessLightOther;
  String _brightText = "Brillo";

  //Sobreescribimos esto para cargar los datos al abrir la ventana de configuración.
  @override
  void initState() {
    _loadSettings();
    developer.log("initState config iniciado");
    super.initState();
  }

  ///Cargar datos en SharedPreferences
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
        if (_brightnessDark > 1 || _brightnessDark < 0) {
          developer.log(
            "_brghtdark en android supero el límite, reseteado a Default",
          );
          _brightnessDark = DefaultValues.brightnessDarkAndroid;
          _resetSetting(SettingKeys.brightnessDarkAndroid);
        }
        if (_brightnessLight > 1 || _brightnessLight < 0) {
          developer.log(
            "_brghtdark en android supero el límite, reseteado a Default",
          );
          _brightnessDark = DefaultValues.brightnessLightAndroid;
          _resetSetting(SettingKeys.brightnessLightAndroid);
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
          _resetSetting(SettingKeys.brightnessLightOther);
        }
        if (_brightnessDark > 1 || _brightnessDark < 0) {
          developer.log(
            "_brghtdark noAndroid supero el límite, reseteado a Default",
          );
          _brightnessDark = DefaultValues.brightnessDarkOther;
          _resetSetting(SettingKeys.brightnessDarkOther);
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
      _keepAwakeDark =
          prefs.getBool(SettingKeys.keepAwakeDark) ??
          DefaultValues.keepAliveDark;
      developer.log("_keepAliveDark despues de loadSettings: $_keepAwakeDark");

      //Cargar mantener pantalla encendida en modo claro
      _keepAliveLight =
          prefs.getBool(SettingKeys.keepAwakeLight) ??
          DefaultValues.keepAliveLight;
      developer.log(
        "_keepAliveLight despues de loadSettings: $_keepAliveLight",
      );
    });
  }

  ///Guardar datos en SharedPreferences <br /> La llave prefereiblemente debe ser una de SettingKeys, y su valor correspondiente.
  void _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    //Verificar dato existente usando el key, pueden haber datos del mismo tipo,
    //así que no usaré el tipo de dato como identificador, ir añadiendo los que hay en core/settings_keys
    switch (key) {
      case SettingKeys.darkMode:
        await prefs.setBool(key, value);
        break;
      case SettingKeys.homeText:
        await prefs.setBool(key, value);
        break;
      case SettingKeys.brightnessDarkAndroid:
        if (value < 0 || value > 1) {
          throw RangeError.range(
            value,
            0,
            1,
            "Intento de guardado para brillo de android fuera de los limites",
          );
        }
        await prefs.setDouble(key, value);
        break;
      case SettingKeys.brightnessLightAndroid:
        if (value < 0 || value > 1) {
          throw RangeError.range(
            value,
            0,
            1,
            "Intento de guardado para brillo de android fuera de los limites",
          );
        }
        await prefs.setDouble(key, value);
        break;
      case SettingKeys.keepAwakeDark:
        await prefs.setBool(key, value);
        break;
      case SettingKeys.keepAwakeLight:
        await prefs.setBool(key, value);
        break;
      case SettingKeys.brightnessLightOther:
        if (value < -1 || value > 0) {
          throw RangeError.range(
            value,
            -1,
            0,
            "Intento de guardado para opacidad (no android) fuera de los limites",
          );
        }
        await prefs.setDouble(key, value);
        break;
      case SettingKeys.brightnessDarkOther:
        if (value < -1 || value > 0) {
          throw RangeError.range(
            value,
            -1,
            0,
            "Intento de guardado para opacidad (no android) fuera de los limites",
          );
        }
        await prefs.setDouble(key, value);
        break;
      default:
        developer.log(
          "Error: settingKey $key no encontrada o establecida. Valor $value no guardado. Contacta con tu mami xd",
        );
    }
    developer.log("$key set to $value hecho");
  }

  ///Borra todas las llaves en SharedPreferences y recarga la pantalla para regenerar los datos.
  void _resetAllSettings() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
    developer.log("Datos Eliminados Exitosamente, recargando.");
    _loadSettings();
  }

  ///Borra la llave especificada y recarga los ajustes para regenerar el dato eliminado.
  void _resetSetting(String key) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
    developer.log("Llave $key eliminada Exitosamente, recargando.");
    _loadSettings();
  }

  ///Borra una lista de llaves especificadas y recarga los ajustes para regenerar los datos eliminados.
  void _resetVariousSettings(List<String> keys) async {
    final prefs = await SharedPreferences.getInstance();
    developer.log("Eliminando serie de llaves...");
    for (String key in keys) {
      prefs.remove(key);
      developer.log("LLave $key eliminada.");
    }
    developer.log("Eliminado de serie de llaves finalizada, recargando.");
    _loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _darkmode ? ThemeData.dark() : ThemeData.light(),
      child: ChangeColors(
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
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Card(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.addOpacity(0.5),
                          child: SwitchListTile(
                            title: Text("Modo Oscuro"),
                            value: _darkmode,
                            onChanged: (newDarkMode) {
                              setState(() {
                                _darkmode = newDarkMode;
                                _saveSetting(SettingKeys.darkMode, newDarkMode);
                              });
                            },
                          ),
                        ),
                        Card(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.addOpacity(0.5),
                          child: SwitchListTile(
                            title: Text("Titulo Cambio"),
                            value: _homeText,
                            onChanged: (newHomeText) {
                              setState(() {
                                _homeText = newHomeText;
                                _saveSetting(SettingKeys.homeText, newHomeText);
                              });
                            },
                          ),
                        ),
                        Card(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.addOpacity(0.5),
                          child: SwitchListTile(
                            title: Text(
                              "Mantener pantalla encendida en Modo Oscuro",
                            ),
                            value: _keepAwakeDark,
                            onChanged: (newkeepAliveDark) {
                              setState(() {
                                _keepAwakeDark = newkeepAliveDark;
                                _saveSetting(
                                  SettingKeys.keepAwakeDark,
                                  newkeepAliveDark,
                                );
                              });
                            },
                          ),
                        ),

                        Card(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.addOpacity(0.5),
                          child: SwitchListTile(
                            title: Text(
                              "Mantener pantalla encendida en Modo Claro",
                            ),
                            value: _keepAliveLight,
                            onChanged: (newkeepAliveLight) {
                              setState(() {
                                _keepAliveLight = newkeepAliveLight;
                                _saveSetting(
                                  SettingKeys.keepAwakeLight,
                                  newkeepAliveLight,
                                );
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  //Slider para modificar el brillo en modo claro
                  sliderBrightnessWhite(context),
                  //Slider para modificar el brillo en modo oscuro
                  sliderBrightnessDark(context),

                  Row(
                    children: [
                      Spacer(),
                      ElevatedButton(
                        onPressed: () {
                          _callConfirmResetDialog(context);
                        },
                        child: Text(
                          "Reiniciar toda la configuración",
                          style: _darkmode
                              ? TextstylesDark.bodyText
                              : TextstylesLight.bodyText,
                        ),
                      ),
                      Spacer()
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Padding sliderBrightnessDark(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        color: Theme.of(context).colorScheme.primary.addOpacity(0.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 17.0,
                top: 10,
                right: 8,
                bottom: 10,
              ),
              child: Text(
                "$_brightText en modo oscuro:",
                style: _darkmode
                    ? TextstylesDark.bodyText
                    : TextstylesLight.bodyText,
              ),
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
                          _saveSetting(
                            SettingKeys.brightnessDarkAndroid,
                            _brightnessDark,
                          );
                        } else {
                          _opacity = newBrightnesDark * -1;
                          _saveSetting(
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
                          _saveSetting(SettingKeys.darkMode, true);
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
                  child: ElevatedButton(
                    onPressed: () {
                      if (Platform.isAndroid) {
                        _brightnessDark = DefaultValues.brightnessDarkAndroid;
                        _resetSetting(SettingKeys.brightnessDarkAndroid);
                      } else {
                        _brightnessDark = DefaultValues.brightnessDarkOther;
                        _resetSetting(SettingKeys.brightnessDarkOther);
                      }
                    },
                    child: Text(
                      "Reiniciar",
                      style: _darkmode
                          ? TextstylesDark.bodyText
                          : TextstylesLight.bodyText,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Padding sliderBrightnessWhite(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        color: Theme.of(context).colorScheme.primary.addOpacity(0.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 17.0,
                top: 10,
                right: 8,
                bottom: 10,
              ),
              child: Text(
                "$_brightText en modo Claro:",
                style: _darkmode
                    ? TextstylesDark.bodyText
                    : TextstylesLight.bodyText,
              ),
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
                          _saveSetting(
                            SettingKeys.brightnessLightAndroid,
                            _brightnessLight,
                          );
                        } else {
                          _opacity = newBrightnesLight * -1;
                          _saveSetting(
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
                          _saveSetting(SettingKeys.darkMode, false);
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
                  child: ElevatedButton(
                    onPressed: () {
                      if (Platform.isAndroid) {
                        _brightnessLight = DefaultValues.brightnessLightAndroid;
                        _resetSetting(SettingKeys.brightnessLightAndroid);
                      } else {
                        _brightnessLight = DefaultValues.brightnessLightOther;
                        _resetSetting(SettingKeys.brightnessLightOther);
                      }
                    },
                    child: Text(
                      "Reiniciar",
                      style: _darkmode
                          ? TextstylesDark.bodyText
                          : TextstylesLight.bodyText,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _callConfirmResetDialog (BuildContext contexto ) {
    developer.log("Resetear datos llamado");
    showDialog(context: contexto,
     builder: (BuildContext ctx){
      return AlertDialog(
        title: Text("Reiniciar Configuración"),
        content: Text("¿Está seguro de reiniciar la configuración a estado de fábrica?"),
        actions: [
          TextButton(onPressed: () {
            developer.log("Resetear datos Aceptado");
            _resetAllSettings();
            Navigator.of(context).pop();
          }, child: Text("Confirmar")),
          ElevatedButton(child: Text("Cancelar"), onPressed: () {
            developer.log("Resetear datos Denegado");
            Navigator.of(context).pop();
          },
          )
        ],
      );
    }
    );
  }
}
