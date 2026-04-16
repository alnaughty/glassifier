import 'package:flutter/material.dart';
import 'package:liquid_glass_shader/liquid_glass_shader.dart';

void main() {
  runApp(const LiquidExampleApp());
}

class LiquidExampleApp extends StatelessWidget {
  const LiquidExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LiquidGlassShowcase(),
    );
  }
}

class LiquidGlassShowcase extends StatefulWidget {
  const LiquidGlassShowcase({super.key});

  @override
  State<LiquidGlassShowcase> createState() => _LiquidGlassShowcaseState();
}

class _LiquidGlassShowcaseState extends State<LiquidGlassShowcase> {
  Offset _dragPosition = const Offset(100, 100);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LiquidScope(
        background: Image.network(
          'https://t3.ftcdn.net/jpg/02/99/04/20/360_F_299042079_vGBD7wIlSeNl7vOevWHiL93G4koMM967.jpg',
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
        child: Stack(
          children: [
            // 2. Static Liquid Elements
            Positioned(
              top: 200,
              left: 50,
              child: LiquidContainer(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Text(
                    "STATIONARY",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: kToolbarHeight,
              left: 10,
              child: LiquidChip(label: "TEST"),
            ),

            Positioned(
              bottom: 150,
              right: 60,
              child: LiquidContainer(
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: Icon(Icons.water_drop, color: Colors.white, size: 32),
                ),
              ),
            ),

            // 3. Draggable Liquid Element (The "Interaction" demo)
            Positioned(
              top: _dragPosition.dy,
              left: _dragPosition.dx,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    _dragPosition += details.delta;
                  });
                },
                child: LiquidContainer(
                  borderRadius: 60,
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircleAvatar(
                      backgroundColor: Colors.transparent,
                      child: Text(
                        "DRAG",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: kToolbarHeight,
              right: 100,
              child: Row(
                spacing: 20,
                children: [
                  LiquidButton(onPressed: () {}, child: Icon(Icons.back_hand)),
                  LiquidChip(label: "label"),
                ],
              ),
            ),

            // 4. Instructional Text
            const Positioned(
              top: 60,
              left: 20,
              child: Text(
                "Drag the bubble near others to see the gooey merge.",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
