import 'package:flutter/material.dart';
import 'package:liquid_glass_shader/src/liquid_controller.dart';

class LiquidInherited extends InheritedWidget {
  final LiquidController controller;
  final BuildContext scopeContext;

  const LiquidInherited({
    super.key,
    required this.controller,
    required this.scopeContext,
    required super.child,
  });

  static LiquidInherited? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<LiquidInherited>();

  @override
  bool updateShouldNotify(LiquidInherited old) => false;
}
