import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:liquid_glass_shader/liquid_inherited.dart';
import 'package:liquid_glass_shader/src/liquid_controller.dart';
import 'package:liquid_glass_shader/src/liquid_shader_cache.dart';
import 'package:liquid_glass_shader/painter/metaball_painter.dart';

class LiquidContainer extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color color;
  final double blur;

  const LiquidContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.borderRadius = 20.0,
    this.color = const Color(0x33FFFFFF), // Default glass tint
    this.blur = 20.0,
  });

  @override
  State<LiquidContainer> createState() => _LiquidContainerState();
}

class _LiquidContainerState extends State<LiquidContainer> {
  final GlobalKey _key = GlobalKey();
  
  // Shared Mode State
  LiquidController? _sharedController;
  
  // Standalone Mode State
  LiquidController? _localController;
  ui.FragmentProgram? _program;
  ui.Image? _placeholderImage;

  @override
  void initState() {
    super.initState();
    _initStandalone();
  }

  Future<void> _initStandalone() async {
    // We load these just in case we are in standalone mode
    final program = await LiquidShaderCache.getOrLoad();
    
    // Create a 1x1 transparent placeholder image for the shader
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawColor(Colors.transparent, BlendMode.src);
    final picture = recorder.endRecording();
    final img = await picture.toImage(1, 1);
    
    if (mounted) {
      setState(() {
        _program = program;
        _placeholderImage = img;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sharedController = LiquidInherited.of(context)?.controller;
    if (_sharedController == null && _localController == null) {
      _localController = LiquidController();
    }
  }

  @override
  void dispose() {
    _sharedController?.removeElement(_key);
    _localController?.dispose();
    super.dispose();
  }

  void _reportRect() {
    final box = _key.currentContext?.findRenderObject() as RenderBox?;
    final inherited = LiquidInherited.of(context);
    
    if (box != null) {
      final size = box.size;
      
      if (inherited != null) {
        // Shared mode: Report to scope's controller
        final controller = inherited.controller;
        final scopeBox = inherited.scopeContext.findRenderObject() as RenderBox?;
        if (scopeBox != null) {
          final position = scopeBox.globalToLocal(box.localToGlobal(Offset.zero));
          controller.updateElement(
            _key,
            position & size,
            widget.borderRadius,
            widget.color,
          );
        }
      } else if (_localController != null) {
        // Standalone mode: Report to local controller
        // In local mode, the CustomPaint is at the same position as the child
        _localController!.updateElement(
          _key,
          Offset.zero & size,
          widget.borderRadius,
          widget.color,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isStandalone = LiquidInherited.of(context) == null;
    
    // Report rect on every build to track movement
    WidgetsBinding.instance.addPostFrameCallback((_) => _reportRect());

    Widget content = Padding(
      padding: widget.padding,
      child: widget.child,
    );

    if (isStandalone) {
      return Container(
        key: _key,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: Stack(
            children: [
              // 1. Background Blur
              Positioned.fill(
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: widget.blur, sigmaY: widget.blur),
                  child: Container(color: Colors.transparent),
                ),
              ),
              
              // 2. Liquid Shader Effect
              if (_program != null && _localController != null)
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _localController!,
                    builder: (context, _) {
                      return CustomPaint(
                        painter: MetaballPainter(
                          _program!.fragmentShader(),
                          _localController!.elements.values.toList(),
                          _placeholderImage, // Use placeholder since we don't have scope capture
                        ),
                      );
                    },
                  ),
                ),
                
              // 3. Child content
              content,
            ],
          ),
        ),
      );
    }

    return Container(
      key: _key,
      child: content,
    );
  }
}
