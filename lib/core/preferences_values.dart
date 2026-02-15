import 'dart:developer' as developer;

import 'package:scrcambio_app/core/settings_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesValues {
  ///Guardar datos en SharedPreferences <br /> La llave prefereiblemente debe ser una de SettingKeys, y su valor correspondiente.
  ///[key] Llave SettingsKeys para almacenar el dato
  ///[value] Dato a guardar, las propias SettingsKeys indican que tipo de dato devuelven.
  static void saveSetting(String key, dynamic value) async {
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
  ///[loadVariablesFunction] Función para llamar la recarga de variables y regenerar datos eliminados.
  static void resetAllSettings(Function loadVariablesFunction) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
    developer.log("Datos Eliminados Exitosamente, recargando.");
    loadVariablesFunction();
  }

  ///Borra la llave especificada y recarga los ajustes para regenerar el dato eliminado.
  ///[key] LLave de SettingsKeys para borrar una entrada.
  ///[loadVariablesFunction] Función para llamar la recarga de variables y regenerarla.
  static void resetSetting(String key, Function loadVariablesFunction) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
    developer.log("Llave $key eliminada Exitosamente.");
    loadVariablesFunction();
  }

  ///Borra una lista de llaves especificadas y recarga los ajustes para regenerar los datos eliminados.
  ///<br> La función de recarga de variables es personalizada para cada pantalla de configuración. <br>
  ///[keys] Lista de llaves de SettingKeys para borrar varias entradas.
  ///[loadVariablesFunction] Función para llamar la recarga de variables y regenerar los datos eliminados.
  static void resetVariousSettings(List<String> keys, loadVariablesFunction) async {
    final prefs = await SharedPreferences.getInstance();
    developer.log("Eliminando serie de llaves...");
    for (String key in keys) {
      prefs.remove(key);
      developer.log("LLave $key eliminada.");
    }
    developer.log("Eliminado de serie de llaves finalizada");
    loadVariablesFunction();
  }
}