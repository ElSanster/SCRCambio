import 'dart:developer' as developer;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:scrcambio_app/core/settings_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfigurationScreen extends StatefulWidget {
  const ConfigurationScreen({super.key});

  @override
  State<ConfigurationScreen> createState() => _ConfigurationScreenState();
}

class _ConfigurationScreenState extends State<ConfigurationScreen> {
  bool _darkmode = false;

  //Sobreescribimos esto para cargar los datos al abrir la ventana de configuración.
  @override
  void initState(){  
    super.initState();
    _loadSettings();
  }

  ///Cargar datos
  void _loadSettings() async{
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      //Aquí se añaden los datos de la configuración
      _darkmode = prefs.getBool(Settingskeys.darkMode)?? Settingskeys.defaultDarkMode;
      developer.log("INFO: _darkmode despues de loadSettings: $_darkmode");
    });
  }

  ///Guardar datos<br /> La llave prefereiblemente debe ser una de SettingsKeys, y su valor correspondiente.
  void _saveSetting(String key, dynamic value) async{
    final prefs = await SharedPreferences.getInstance();
    //Verificar dato existente usando el key, pueden haber datos del mismo tipo,
    //así que no usaré el tipo de dato como identificador, ir añadiendo los que hay en core/text_styles
    switch (key) {
      case Settingskeys.darkMode:
        await prefs.setBool(key, value);
        break;
      default:
        developer.log("Error: settingKey $key no encontrada o establecida. Valor $value no guardado. Contacta con tu mami xd");

    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _darkmode ? ThemeData.dark() : ThemeData.light(),
      child: Scaffold(
            appBar: AppBar(title:  Text("SCRCambio - Alpha"),
            ),
            body: Column(
              children:[
                SwitchListTile(
                title: Text("Modo Oscuro"),
                value: _darkmode,
                onChanged: (newDarkMode) {
                  setState(() {
                    _darkmode = newDarkMode;
                    _saveSetting(Settingskeys.darkMode, newDarkMode);
                  });
                },
              ),
              ]
            ),
      ),
    );
  }
}