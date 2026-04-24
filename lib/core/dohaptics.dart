import 'dart:developer' as developer;
import 'package:haptic_feedback/haptic_feedback.dart';

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
    //Dependiendo del modo escogido, poner el tipo de haptics a intentar
    developer.log("Haptics llamadas: $haptics Tipo: $hapticsMode");
    if (haptics == false) {
      developer.log("Haptics NO disparadas. (Desactivadas)");
      return;
    } else {
      switch (hapticsMode) {
        case 0:
          await Haptics.vibrate(HapticsType.light);
          developer.log("Haptics Disparada (light): $hapticsMode");
          break;
        case 1:
          await Haptics.vibrate(HapticsType.soft);
          developer.log("Haptics Disparada (Soft): $hapticsMode");
          break;
        case 2:
          await Haptics.vibrate(HapticsType.medium);
          developer.log("Haptics Disparada (Medium): $hapticsMode");
          break;
        case 3:
          await Haptics.vibrate(HapticsType.heavy);
          developer.log("Haptics Disparada (Heavy): $hapticsMode");
          break;
        case 4:
          await Haptics.vibrate(HapticsType.rigid);
          developer.log("Haptics Disparada (Rigid): $hapticsMode");
          break;
        case 5:
          await Haptics.vibrate(HapticsType.selection);
          developer.log("Haptics Disparada (Selection): $hapticsMode");
          break;
        case 6:
          await Haptics.vibrate(HapticsType.success);
          developer.log("Haptics Disparada (Success): $hapticsMode");
          break;
        case 7:
          await Haptics.vibrate(HapticsType.error);
          developer.log("Haptics Disparada (Error): $hapticsMode");
          break;
        case 8:
          await Haptics.vibrate(HapticsType.warning);
          developer.log("Haptics Disparada (Warning): $hapticsMode");
          break;
        default:
          developer.log("HapticsMode fuera de límites, usando default.");
          await Haptics.vibrate(HapticsType.soft);
          break;
      }
    }
  }
}
