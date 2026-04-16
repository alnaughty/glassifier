import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class LiquidElementInfo {
  final Rect rect;
  final double borderRadius;
  final Color color;

  LiquidElementInfo({
    required this.rect,
    required this.borderRadius,
    required this.color,
  });
}

class LiquidController extends ChangeNotifier {
  final Map<Key, LiquidElementInfo> elements = {};
  ui.Image? backgroundImage;

  void updateElement(Key key, Rect rect, double borderRadius, Color color) {
    elements[key] = LiquidElementInfo(
      rect: rect,
      borderRadius: borderRadius,
      color: color,
    );
    notifyListeners();
  }

  void removeElement(Key key) {
    elements.remove(key);
    notifyListeners();
  }

  void updateBackground(ui.Image? image) {
    backgroundImage = image;
    notifyListeners();
  }
}
