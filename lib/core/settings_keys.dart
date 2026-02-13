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

  ///Llave para obtener la cantidad de brillo en modo oscuro de android
  ///<br />Tipo Double Positivo (entre 0.0 y 1.0)
  static const String brightnessDarkAndroid = "brightnessDark";

  ///Llave para obtener la cantidad de brillo en modo claro de Android
  ///<br />Tipo Double Positivo (entre 0.0 y 1.0)
  static const String brightnessLightAndroid = "brightnessLight";

  ///Llave para obtener la cantidad de opacidad en modo claro en otros OS.
  ///Esto como reemplazo para el brillo automático de Android
  ///<br />Tipo Double Negativo (entre -1.0 y 0.0)
  static const String brightnessLightOther = "opacityLight";

  ///LLave apra obtener la cantidad de opacidad en modo oscuro en otros OS
  ///Esto como reemplazo para el brillo automático de Android
  ///<br />Tipo Double Negativo (entre -1.0 y 0.0)
  static const String brightnessDarkOther = "opacityDark";

  ///LLave para obtener la opción de mantener la pantalla encendida en modo oscuro
  ///<br />Tipo Bool
  static const String keepAwakeDark = "keepAliveDark";

  ///Llave para obtener la opción de mantener la pantalla encendida modo claro
  ///<br />Tipo Bool
  static const String keepAwakeLight = "keepAliveLight";
  ///Llave para verificar si es la primera vez que el usuario abre la app
  ///<br />Tipo Bool
  static const String firstOpen = "firstOpen";
}

///Valores por defecto en caso de no haber datos en SharedPreferences
class DefaultValues {

 ///Modo oscuro por defecto
  static const bool darkMode = true;

  ///Texto de la pantalla principal por defecto
  static const bool homeText = true;

  ///Cantidad de brillo en modo oscuro por defecto para Android
  static const double brightnessDarkAndroid = 0.2;

  ///Cantidad de brillo en modo claro por defecto para Android
  static const double brightnessLightAndroid = 1;

  ///Cantidad de opacidad en modo claro por defecto para otros OS,
  ///como reemplazo para la cantidad de brillo de Android
  static const double brightnessLightOther = 0;

  ///Cantidad de opacidad en modo oscuro por defecto para otros OS,
  ///como reemplazo para la cantidad de brillo de Android
  static const double brightnessDarkOther = 0;

  ///Mantener la pantalla encendida en modo oscuro por defecto
  static const bool keepAliveDark = false;

  ///Mantener la pantalla encendida en modo claro por defecto
  static const bool keepAliveLight = true;
  
  ///Usuario abre la aplicación por primera vez
  static const bool firstOpen = true;
}