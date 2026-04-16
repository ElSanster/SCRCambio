package com.elsanster.scrcambio

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    // Deshabilita el haptic feedback nativo de la surface de Flutter
    window.decorView.isHapticFeedbackEnabled = false
  }
}
