import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:liquid_glass_shader/painter/metaball_painter.dart';
import 'package:liquid_glass_shader/src/liquid_controller.dart';
import 'package:liquid_glass_shader/liquid_inherited.dart';

class LiquidScope extends StatefulWidget {
  final Widget background;
  final Widget child;
  const LiquidScope({super.key, required this.background, required this.child});

  @override
  State<LiquidScope> createState() => _LiquidScopeState();
}

class _LiquidScopeState extends State<LiquidScope> {
  final LiquidController controller = LiquidController();
  final GlobalKey _backgroundKey = GlobalKey();
  ui.FragmentProgram? program;
  ui.Image? _placeholderImage;
  bool _isBackgroundCaptured = false;
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    _load();
    _createPlaceholder();
  }

  Future<void> _createPlaceholder() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawColor(Colors.transparent, BlendMode.src);
    final picture = recorder.endRecording();
    final img = await picture.toImage(1, 1);
    if (mounted) setState(() => _placeholderImage = img);
  }

  void _load() async {
    try {
      String shaderPath =
          'packages/liquid_glass_shader/lib/shaders/glass_shader.frag';
      final p = await ui.FragmentProgram.fromAsset(shaderPath);
      if (mounted) setState(() => program = p);
    } catch (e) {
      debugPrint("Primary shader load failed: $e");
    }
  }

  void _captureBackground() async {
    if (_isCapturing || _isBackgroundCaptured) return;
    _isCapturing = true;

    try {
      // Small delay to ensure the background has fully rendered its network image
      await Future.delayed(const Duration(milliseconds: 500));
      
      final boundary =
          _backgroundKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) {
        _isCapturing = false;
        return;
      }

      final image = await boundary.toImage(pixelRatio: 1.0);
      controller.updateBackground(image);
      _isBackgroundCaptured = true;
    } catch (e) {
      debugPrint("Background capture failed: $e");
    } finally {
      _isCapturing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (program == null || _placeholderImage == null) return widget.child;

    // Capture the static background once
    if (!_isBackgroundCaptured && !_isCapturing) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _captureBackground());
    }

    return LiquidInherited(
      controller: controller,
      scopeContext: context,
      child: Stack(
        children: [
          // 1. The Background Layer
          RepaintBoundary(key: _backgroundKey, child: widget.background),

          // 2. The Shader Layer
          AnimatedBuilder(
            animation: controller,
            builder: (context, _) {
              return CustomPaint(
                painter: MetaballPainter(
                  program!.fragmentShader(),
                  controller.elements.values.toList(),
                  controller.backgroundImage ?? _placeholderImage,
                ),
                child: const SizedBox.expand(),
              );
            },
          ),

          // 3. The Foreground Layer
          widget.child,
        ],
      ),
    );
  }
}
