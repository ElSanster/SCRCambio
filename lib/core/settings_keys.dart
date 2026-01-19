class Settingskeys {
  /*Para evitar tener que anotar específicamente un String para obtener datos desde Shared preferences,
  se hace un llamado a este archivo y se usa esta lista de constantes. 
  Útil a la hora de cambiar llaves, nombres de las variables
  y evitar escibir llaves erroneas
  */

  ///Llave para obtener el modo oscuro usando SharedPreferences.
  ///<br />Tipo bool
  static const String darkMode = "darkMode";

  /**
   * También aprovecho para poner datos de por defecto en caso de
   * que no sean encontrados.
   */

  ///Modo oscuro por defecto si no hay llave en SharedPreferences
  static const bool defaultDarkMode = true;
}