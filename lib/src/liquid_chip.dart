import 'package:flutter/material.dart';
import 'package:liquid_glass_shader/src/liquid_container.dart';

class LiquidChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color color;
  final double blur;

  const LiquidChip({
    super.key, 
    required this.label, 
    this.icon,
    this.padding = const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
    this.borderRadius = 16.0,
    this.color = const Color(0x33FFFFFF), // Default glass tint
    this.blur = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    return LiquidContainer(
      padding: padding,
      borderRadius: borderRadius,
      color: color,
      blur: blur,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) Icon(icon, color: Colors.white, size: 16),
          if (icon != null) const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
