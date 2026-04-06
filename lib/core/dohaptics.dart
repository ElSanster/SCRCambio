import 'dart:developer' as developer;
import 'dart:io';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:scrcambio_app/core/settings_keys.dart';

class Dohaptics {
  ///Solicitar una vibración,<br>
  ///[hapticsMode] Tipo de haptic:
  ///<br>0 para light
  ///<br>1 para soft
  ///<br>2 para medium
  ///<br>3 para heavy
  ///<br>4 para rigid
  ///<br>5 para selection
  ///<br>6 para success
  ///<br>7 para error
  ///<br>8 para warning
  static void dohaptics(int hapticsMode, bool haptics) async {
    developer.log("Haptics Disparada: $hapticsMode");
    //Dependiendo del modo escogido, poner el tipo de haptics a intentar
    HapticsType ht = HapticsType.light;
    switch (hapticsMode) {
      case 0:
        ht = HapticsType.light;
        break;
      case 1:
        ht = HapticsType.soft;
        break;
      case 2:
        ht = HapticsType.medium;
        break;
      case 3:
        ht = HapticsType.heavy;
        break;
      case 4:
        ht = HapticsType.rigid;
        break;
      case 5:
        ht = HapticsType.selection;
        break;
      case 6:
        ht = HapticsType.success;
        break;
      case 7:
        ht = HapticsType.error;
        break;
      case 8: 
        ht = HapticsType.warning;
      default:
        developer.log("HapticsMode fuera de límites, usando default.");
        dohaptics(DefaultValues.hapticsMode, haptics);
        return;
    }
    //Verificar sistema operativo que usualmente tiene vibración
    if (Platform.isAndroid || Platform.isIOS) {
      developer.log("Haptics: Plataforma Android/iOS detectada. Verificando haptics.");
      final canVibrate = await Haptics.canVibrate(); //Verificar haptics, puede que el dispositivo no pueda hacerlo a pesar de usar un OS
      if (haptics && canVibrate) {
        developer.log("Haptics: Positivo para vibración");
        await Haptics.vibrate(ht); //Aquí es donde se hace la vibración
      } else {
        developer.log(
          "ERROR: No se puede usar vibración a pesar de estar en Android/iOS, consulta con tu madre de confianza.",
        );
      }
    }
  }
}