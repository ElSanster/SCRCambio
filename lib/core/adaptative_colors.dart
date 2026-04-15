import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:scrcambio_app/core/text_styles.dart';

class AdaptativeColors {
  /// Devuelve un color para fondos de tarjeta que interpola entre el
  /// color base de la tarjeta y el color primario del tema.
  /// [amount] controla cuánto acercarse al color primario (0..1). Default 0.1 (10%).
  static Color backgroundColor(
    bool darkMode, {
    Color? seedColor,
    double amount = 0.1,
  }) {
    //En teoría nos debería dar el themedata, ya que si seed es null, nos dara los de por defecto
    ThemeData theme = themeData(darkMode, seedColor: seedColor);
    final base = theme.cardColor;
    final primary = theme.colorScheme.primary;
    return Color.lerp(base, primary, amount) ?? base;
  }

  ///Devuelve el themedata dependiendo del darkMode y si son colores personalizados.
  ///<br>[darkmode] Devuelve el themedata dependiendo del modo
  ///<br>[seedColor] Usa este color para obtener un themedata, no usarlo da los colores del sistema
  static ThemeData themeData(bool darkMode, {Color? seedColor}) {
    ThemeData theme;
    if (seedColor != null) {
      developer.log("Devolviendo tema custom: $seedColor");
      theme = ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: darkMode ? Brightness.dark : Brightness.light,
        ),
      );
    } else {
      theme = darkMode ? ThemeData.dark() : ThemeData.light();
    }
    return theme;
  }

  static List<Color> darkColors = [
    Color(0xFFB71C1C), // Rojo
    Color(0xFF880E4F), // Rosa
    Color(0xFF6A1B9A), // Púrpura
    Color(0xFF4527A0), // Púrpura profundo
    Color(0xFF283593), // Índigo
    Color(0xFF1565C0), // Azul
    Color(0xFF0277BD), // Azul claro
    Color(0xFF00838F), // Cian
    Color(0xFF00695C), // Verde azulado
    Color(0xFF2E7D32), // Verde
    Color(0xFF558B2F), // Verde claro
    Color(0xFF9E9D24), // Lima
    Color(
      0xFFF9A825,
    ), // Amarillo → naranja oscuro (el amarillo puro oscurecido se vuelve mostaza)
    Color(0xFFFF6F00), // Ámbar
    Color(0xFFE65100), // Naranja
    Color(0xFFBF360C), // Naranja profundo
    Color(0xFF4E342E), // Marrón
    Color(0xFF616161), // Gris
    Color(0xFF37474F), // Gris azulado
    Color(0xFF000000), // Negro (sin cambio)
  ];
  static List<Color> lightColors = [
    Color(0xFFF44336),
    Color(0xFFE91E63),
    Color(0xFF9C27B0),
    Color(0xFF673AB7),
    Color(0xFF3F51B5),
    Color(0xFF2196F3),
    Color(0xFF03A9F4),
    Color(0xFF00BCD4),
    Color(0xFF009688),
    Color(0xFF4CAF50),
    Color(0xFF8BC34A),
    Color(0xFFCDDC39),
    Color(0xFFFFEB3B),
    Color(0xFFFFC107),
    Color(0xFFFF9800),
    Color(0xFFFF5722),
    Color(0xFF795548),
    Color(0xFF9E9E9E),
    Color(0xFF607D8B),
    Color(0xFF000000),
  ];

  /// Devuelve un color para fondos de tarjeta que interpola entre el
  /// color base de la tarjeta y el color primario del tema.
  /// [amount] controla cuánto acercarse al color primario (0..1). Default 0.2 (20%).
  static Color highlightColor(
    bool darkMode, {
    double amount = 0.9,
    Color? seedColor,
  }) {
    ThemeData theme = themeData(darkMode, seedColor: seedColor);
    return theme.colorScheme.primary;
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
  static Text smallText(String text, bool darkMode) {
    return Text(
      text,
      style: darkMode ? TextstylesDark.smallText : TextstylesLight.smallText,
    );
  }

  ///Genera un Text que usa el body text de text_styles
  ///[text] Texto a usar
  ///[darkMode] De este depende el modo de luz del texto
  static Text textBody(String text, bool darkMode) {
    return Text(
      text,
      style: darkMode ? TextstylesDark.bodyText : TextstylesLight.bodyText,
    );
  }

  ///Genera un Text que usa el subtitle text de text_styles
  ///[text] Texto a usar
  ///[darkMode] De este depende el modo de luz del texto
  static Text subtitle(String text, bool darkMode) {
    return Text(
      text,
      style: darkMode ? TextstylesDark.subtitle : TextstylesLight.subtitle,
    );
  }

  ///Genera un Text que usa el title de text_styles
  ///[text] Texto a usar
  ///[darkMode] De este depende el modo de luz del texto
  static Text textTitle(String text, bool darkMode) {
    return Text(
      text,
      style: darkMode ? TextstylesDark.title : TextstylesLight.title,
    );
  }

  ///Genera un Text que usa el HomeTitle de text_styles, usualmente para la pantalla de inicio y linterna
  ///[text] Texto a usar
  ///[darkMode] De este depende el modo de luz del texto
  static Text textHomeTitle(String text, bool darkMode) {
    return Text(
      text,
      style: darkMode ? TextstylesDark.homeTitle : TextstylesLight.homeTitle,
    );
  }

  ///Devuelve un elevated button con un color resaltable, que se adapta al modo de luz
  ///[text] Texto a mostrar, usa el body de text_styles
  ///[context] Por si las dudas
  ///[darkmode] De este depende el modo de luz en el botón
  ///[onPressed] Una Función definida para el botón
  ///
  static Widget elevatedButton(
  String text,
  BuildContext context,
  bool darkmode,
  Function onPressed, {
  Color? seedColor,
}) {
  // Builder garantiza que Theme.of() se evalúa en cada rebuild,
  // usando siempre el contexto más reciente del árbol
  return Builder(
    builder: (builderContext) {
      final theme = Theme.of(builderContext); // ✅ siempre fresco
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
        ),
        onPressed: () => onPressed(),
        child: textForElevatedButtons(text, darkmode),
      );
    },
  );
}
}
