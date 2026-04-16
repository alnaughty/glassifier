import 'package:flutter/material.dart';
import 'package:liquid_glass_shader/src/liquid_container.dart';

class LiquidButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final double width;
  final double height;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color color;

  const LiquidButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.width = 150,
    this.height = 50,
    this.padding = const EdgeInsets.all(16.0),
    this.borderRadius = 20.0,
    this.color = const Color(0x33FFFFFF),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: LiquidContainer(
        padding: padding,
        borderRadius: borderRadius,
        color: color,
        child: SizedBox(
          width: width,
          height: height,
          child: Center(child: child),
        ),
      ),
    );
  }
}
