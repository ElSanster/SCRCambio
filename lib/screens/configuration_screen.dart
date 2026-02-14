import 'dart:developer' as developer;
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scrcambio_app/core/adaptative_colors.dart';
import 'package:scrcambio_app/core/settings_keys.dart';
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
    //Obviamente no queremos un mensaje de bienvenida al reiniciar datos.
    //Y al llegados a este punto ya debería haberse mostrado los diálogos.
    prefs.setBool(SettingKeys.firstOpen, false);  
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

  ///Cuando lleguemos a implementar algo que requiera de esto, usarlo, me da toc dejarlo por ahí sin hacer nada

  ///Borra una lista de llaves especificadas y recarga los ajustes para regenerar los datos eliminados.
  /*void _resetVariousSettings(List<String> keys) async {
    final prefs = await SharedPreferences.getInstance();
    developer.log("Eliminando serie de llaves...");
    for (String key in keys) {
      prefs.remove(key);
      developer.log("LLave $key eliminada.");
    }
    developer.log("Eliminado de serie de llaves finalizada, recargando.");
    _loadSettings();
  }
  */

  @override
  Widget build(BuildContext context) {
    return Theme(
      //Aplicar tema correspondiente al modo que tenga el usuario
      data: _darkmode ? ThemeData.dark() : ThemeData.light(),
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
                color: AdaptativeColors.backgroundColor(_darkmode),
                child: ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Card(
                            child: SwitchListTile(
                              title: AdaptativeColors.textBody(
                                "Modo Oscuro",
                                _darkmode,
                              ),
                              value: _darkmode,
                              onChanged: (newDarkMode) {
                                setState(() {
                                  _darkmode = newDarkMode;
                                  _saveSetting(
                                    SettingKeys.darkMode,
                                    newDarkMode,
                                  );
                                });
                              },
                            ),
                          ),
                          Card(
                            child: SwitchListTile(
                              title: AdaptativeColors.textBody(
                                "Titulo Cambio",
                                _darkmode,
                              ),
                              value: _homeText,
                              onChanged: (newHomeText) {
                                setState(() {
                                  _homeText = newHomeText;
                                  _saveSetting(
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
                                ListTile(title: AdaptativeColors.subtitle("Modo Claro", _darkmode),),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0, right: 8),
                                  child: Divider(),
                                ),
                                SwitchListTile(
                                  title: AdaptativeColors.textBody(
                                    "Mantener pantalla encendida",
                                    _darkmode,
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
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0, right: 8),
                                  child: Divider(),
                                ),
                                //Slider para modificar el brillo en modo claro
                                sliderBrightnessWhite(context),
                              ],
                            ),
                          ),
                          Card(
                            child: Column(
                              children: [
                                ListTile(title: AdaptativeColors.subtitle("Modo Oscuro", _darkmode),),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0, right: 8),
                                  child: Divider(),
                                ),
                                SwitchListTile(
                                  title: AdaptativeColors.textBody(
                                    "Mantener pantalla encendida",
                                    _darkmode,
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
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0, right: 8),
                                  child: Divider(),
                                ),
                                //Slider para modificar el brillo en modo oscuro
                                sliderBrightnessDark(context),
                              ],
                            ),
                          ),
                          Padding(
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
          child: AdaptativeColors.textBody(
            "$_brightText:",
            _darkmode,
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
                      _saveSetting(SettingKeys.brightnessDarkOther, _opacity);
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
              child: AdaptativeColors.elevatedButton(
                "Reiniciar",
                context,
                _darkmode,
                () {
                  if (Platform.isAndroid) {
                    _brightnessDark = DefaultValues.brightnessDarkAndroid;
                    _resetSetting(SettingKeys.brightnessDarkAndroid);
                  } else {
                    _brightnessDark = DefaultValues.brightnessDarkOther;
                    _resetSetting(SettingKeys.brightnessDarkOther);
                  }
                },
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
          child: AdaptativeColors.textBody(
            "$_brightText:",
            _darkmode,
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
                      _saveSetting(SettingKeys.brightnessLightOther, _opacity);
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
              child: AdaptativeColors.elevatedButton(
                "Reiniciar",
                context,
                _darkmode,
                () {
                  if (Platform.isAndroid) {
                    _brightnessLight = DefaultValues.brightnessLightAndroid;
                    _resetSetting(SettingKeys.brightnessLightAndroid);
                  } else {
                    _brightnessLight = DefaultValues.brightnessLightOther;
                    _resetSetting(SettingKeys.brightnessLightOther);
                  }
                },
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
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: AdaptativeColors.backgroundColor(darkMode),
          title: AdaptativeColors.textTitle(
            "Reiniciar Configuración",
            darkMode,
          ),
          content: AdaptativeColors.textBody(
            "¿Está seguro de reiniciar la configuración a estado de fábrica?",
            darkMode,
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: TextButton(
                onPressed: () {
                  developer.log("Resetear datos Aceptado");
                  _resetAllSettings();
                  Navigator.of(context).pop();
                },
                child: AdaptativeColors.textBody("Confirmar", darkMode),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: AdaptativeColors.elevatedButton("Cancelar", contexto, darkMode, () {
                developer.log("Resetear datos Denegado");
                Navigator.of(context).pop();
              }),
            ),
          ],
        );
      },
    );
  }
}
