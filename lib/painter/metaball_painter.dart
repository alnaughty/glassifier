import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:liquid_glass_shader/src/liquid_controller.dart';

class MetaballPainter extends CustomPainter {
  final ui.FragmentShader shader;
  final List<LiquidElementInfo> elements;
  final ui.Image? background;

  MetaballPainter(this.shader, this.elements, this.background);

  @override
  void paint(Canvas canvas, Size size) {
    if (background != null) {
      shader.setImageSampler(0, background!);
    }
    
    shader.setFloat(0, size.width);
    shader.setFloat(1, size.height);
    shader.setFloat(2, elements.length.toDouble());

    int count = elements.length > 20 ? 20 : elements.length;

    for (int i = 0; i < 20; i++) {
        // uElements starts at index 3. 4 floats per element.
        int elOffset = 3 + (i * 4);
        
        // uRadii starts at index 83. 1 float per element.
        int radOffset = 83 + i;
        
        // uColors starts at index 103. 4 floats per element.
        int colOffset = 103 + (i * 4);

        if (i < count) {
            final info = elements[i];
            shader.setFloat(elOffset, info.rect.center.dx);
            shader.setFloat(elOffset + 1, info.rect.center.dy);
            shader.setFloat(elOffset + 2, info.rect.width);
            shader.setFloat(elOffset + 3, info.rect.height);

            shader.setFloat(radOffset, info.borderRadius);

            shader.setFloat(colOffset, info.color.r);
            shader.setFloat(colOffset + 1, info.color.g);
            shader.setFloat(colOffset + 2, info.color.b);
            shader.setFloat(colOffset + 3, info.color.a);
        } else {
            shader.setFloat(elOffset, 0);
            shader.setFloat(elOffset + 1, 0);
            shader.setFloat(elOffset + 2, 0);
            shader.setFloat(elOffset + 3, 0);

            shader.setFloat(radOffset, 0);

            shader.setFloat(colOffset, 0);
            shader.setFloat(colOffset + 1, 0);
            shader.setFloat(colOffset + 2, 0);
            shader.setFloat(colOffset + 3, 0);
        }
    }

    // uGooFactor at index 183
    shader.setFloat(183, 30.0);

    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
  }

  @override
  bool shouldRepaint(covariant MetaballPainter old) => true;
}
