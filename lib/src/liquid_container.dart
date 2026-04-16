import 'package:flutter/material.dart';
import 'package:liquid_glass_shader/liquid_inherited.dart';
import 'package:liquid_glass_shader/src/liquid_controller.dart';

class LiquidContainer extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color color;

  const LiquidContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.borderRadius = 20.0,
    this.color = const Color(0x33FFFFFF), // Default glass tint
  });

  @override
  State<LiquidContainer> createState() => _LiquidContainerState();
}

class _LiquidContainerState extends State<LiquidContainer> {
  final GlobalKey _key = GlobalKey();
  LiquidController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller = LiquidInherited.of(context)?.controller;
  }

  @override
  void dispose() {
    _controller?.removeElement(_key);
    super.dispose();
  }

  void _reportRect() {
    final box = _key.currentContext?.findRenderObject() as RenderBox?;
    final inherited = LiquidInherited.of(context);
    final controller = inherited?.controller;
    final scopeBox = inherited?.scopeContext.findRenderObject() as RenderBox?;

    if (box != null && controller != null && scopeBox != null) {
      final position = scopeBox.globalToLocal(box.localToGlobal(Offset.zero));
      controller.updateElement(
        _key,
        position & box.size,
        widget.borderRadius,
        widget.color,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Report rect on every build to track movement
    WidgetsBinding.instance.addPostFrameCallback((_) => _reportRect());

    return Opacity(
      key: _key,
      opacity: 1.0, // Child is visible, but background is handled by shader
      child: Padding(padding: widget.padding, child: widget.child),
    );
  }
}
