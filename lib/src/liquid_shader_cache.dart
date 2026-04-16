import 'dart:ui' as ui;
import 'dart:async';
import 'package:flutter/foundation.dart';

class LiquidShaderCache {
  static ui.FragmentProgram? _program;
  static bool _loading = false;
  static final List<ValueSetter<ui.FragmentProgram>> _listeners = [];

  static Future<ui.FragmentProgram?> getOrLoad() async {
    if (_program != null) return _program;
    if (_loading) {
      final completer = Completer<ui.FragmentProgram?>();
      _listeners.add((p) => completer.complete(p));
      return completer.future;
    }

    _loading = true;
    try {
      const shaderPath = 'packages/liquid_glass_shader/lib/shaders/glass_shader.frag';
      _program = await ui.FragmentProgram.fromAsset(shaderPath);
      for (final listener in _listeners) {
        listener(_program!);
      }
      _listeners.clear();
      return _program;
    } catch (e) {
      debugPrint("LiquidShaderCache failed to load: $e");
      _loading = false;
      return null;
    }
  }
}
