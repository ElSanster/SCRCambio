import 'package:flutter/material.dart';
import 'package:scrcambio_app/core/text_styles.dart';

class AdaptativeColors {
  /// Devuelve un color para fondos de tarjeta que interpola entre el
  /// color base de la tarjeta y el color primario del tema.
  /// [amount] controla cuánto acercarse al color primario (0..1). Default 0.2 (20%).
  static Color backgroundColor(bool darkMode, [double amount = 0.1]) {
    ThemeData theme = darkMode ? ThemeData.dark() : ThemeData.light();
    final base = theme.cardColor;
    final primary = theme.colorScheme.primary;
    return Color.lerp(base, primary, amount) ?? base;
  }

  ///Devuelve el themedata dependiendo del darkMode, para ocasiones especiales.
  static ThemeData themeData (bool darkMode){
    ThemeData theme = darkMode ? ThemeData.dark() : ThemeData.light();
    return theme;
  }

/// Devuelve un color para fondos de tarjeta que interpola entre el
  /// color base de la tarjeta y el color primario del tema.
  /// [amount] controla cuánto acercarse al color primario (0..1). Default 0.2 (20%).
  static Color highlightColor(bool darkMode, [double amount = 0.9]) {
    ThemeData theme = darkMode ? ThemeData.dark() : ThemeData.light();
    final base = theme.cardColor;
    final primary = theme.colorScheme.primary;
    return Color.lerp(base, primary, amount) ?? base;
  }

///Genera un Text para botones elevados AdaptativeColors.elevatedButton donde los colores
///están invertidos, y usa el body text de text_styles
///[text] Texto a usar
///[darkMode] De este depende el modo de luz del texto
  static Text textForElevatedButtons(String text, bool darkMode) {
    return Text(
      text,
      style: darkMode ? TextstylesLight.bodyText : TextstylesDark.bodyText,
    );
  }


///Genera un Text que usa el body text de text_styles
///[text] Texto a usar
///[darkMode] De este depende el modo de luz del texto
static Text smallText (String text, bool darkMode){
  return Text(
    text,
    style: darkMode ?TextstylesDark.smallText : TextstylesLight.smallText
    ,
    );
}

///Genera un Text que usa el body text de text_styles
///[text] Texto a usar
///[darkMode] De este depende el modo de luz del texto
static Text textBody (String text, bool darkMode){
  return Text(
    text,
    style: darkMode ?TextstylesDark.bodyText : TextstylesLight.bodyText
    ,
    );
}

///Genera un Text que usa el subtitle text de text_styles
///[text] Texto a usar
///[darkMode] De este depende el modo de luz del texto
static Text subtitle (String text, bool darkMode){
  return Text(
    text,
    style: darkMode ?TextstylesDark.subtitle : TextstylesLight.subtitle
    ,
    );
}



///Genera un Text que usa el title de text_styles
///[text] Texto a usar
///[darkMode] De este depende el modo de luz del texto
  static Text textTitle (String text, bool darkMode){
    return Text(
      text,
      style: darkMode ?TextstylesDark.title : TextstylesLight.title
      ,
      );
  }
///Genera un Text que usa el HomeTitle de text_styles, usualmente para la pantalla de inicio y linterna
///[text] Texto a usar
///[darkMode] De este depende el modo de luz del texto
  static Text textHomeTitle (String text, bool darkMode){
    return Text(
      text,
      style: darkMode ?TextstylesDark.homeTitle : TextstylesLight.homeTitle
      ,
      );
  }

///Devuelve un elevated button con un color resaltable, que se adapta al modo de luz
///[text] Texto a mostrar, usa el body de text_styles
///[context] Por si las dudas
///[darkmode] De este depende el modo de luz en el botón
///[onPressed] Una Función definida para el botón
  static ElevatedButton elevatedButton(
    String text,
    BuildContext context,
    bool darkmode,
    Function onPressed,
  ) {
    ThemeData theme = darkmode ? ThemeData.dark() : ThemeData.light();
    final accentColor = highlightColor(darkmode);

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentColor,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      onPressed: () {
        onPressed();
      },
      child: textForElevatedButtons(text, darkmode),
    );
  }
}
