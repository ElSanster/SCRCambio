import 'package:flutter/material.dart';
import 'package:scrcambio_app/core/textStyles.dart';
import 'configuration_screen.dart';

class SwitchScreen extends StatefulWidget {
  const SwitchScreen({super.key});

  @override
  State<SwitchScreen> createState() => _SwitchScreenState();
}

class _SwitchScreenState extends State<SwitchScreen> {
  bool _isDoubleTapping = false;

  void _navigateToConfiguration() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ConfigurationScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onLongPress: () {
          //Temporal, se que debo usar un logger
          print("Botón presionado.");
        },
        onDoubleTapDown: (TapDownDetails details) {
          //Retrasa la ejecución durante 300 microsegundos, y da tiempo a onHorizontalDragEnd
          _isDoubleTapping = true;
          Future.delayed(const Duration(milliseconds: 300), () {
            _isDoubleTapping = false;
          });
        },
        onHorizontalDragEnd: (DragEndDetails details) {
          //Verifica que estemos durante este retraso para ir a la configuración
          if (_isDoubleTapping && details.velocity.pixelsPerSecond.dx < 0) {
            _navigateToConfiguration();
            _isDoubleTapping = false;
          }
        },
        child: Container(
          alignment: Alignment.center,
          child: SizedBox.expand(
            child: Center(
              //TO DO: Por alguna razón, la hitbox de este botón es la hitbox para el GestureDetector
              //Increiblemente de tamaño promedio, por lo que dificulta ir a la pantalla de config.
              //Encontrar una manera que no dependa de esto.
              child: Text("Cambio", style: TextstylesLight.homeTitle,),
              )
              ),
            ),
          ),
    );
  }
}
