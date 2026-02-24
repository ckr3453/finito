import 'package:flutter/widgets.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

void preserveSplash(WidgetsBinding binding) {
  FlutterNativeSplash.preserve(widgetsBinding: binding);
}

void removeSplash() {
  FlutterNativeSplash.remove();
}
