///Llaves de acceso de tipo string para obtener datos en SharedPreferences
class SettingKeys {
  /*Para evitar tener que anotar específicamente un String para obtener datos desde Shared preferences,
  se hace un llamado a este archivo y se usa esta lista de constantes. 
  Útil a la hora de cambiar llaves, nombres de las variables
  y evitar escibir llaves erroneas
  */

  ///Llave para obtener el modo oscuro usando SharedPreferences.
  ///<br />Tipo bool
  static const String darkMode = "darkMode";

  ///Llave para obtener si está habilitado el texto Cambio de la pantalla principal.
  ///<br />Tipo bool
  static const String homeText = "homeText";
}

///Valores por defecto en caso de no haber datos en SharedPreferences
class DefaultValues {

 ///Modo oscuro por defecto
  static const bool darkMode = true;

  ///Texto de la pantalla principal por defecto
  static const bool homeText = true;
}