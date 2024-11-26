import 'package:flutter/material.dart';
import 'package:controle_de_abastecimento/components/drawer_menu.dart';

class AnimatedDrawerLayout extends StatefulWidget {
  final Widget child;
  const AnimatedDrawerLayout({super.key, required this.child});

  @override
  State<AnimatedDrawerLayout> createState() => _AnimatedDrawerLayoutState();
}

class _AnimatedDrawerLayoutState extends State<AnimatedDrawerLayout> {
  double xOffset = 0.0;
  double yOffset = 0.0;
  double scaleFactor = 1.0;
  bool isDrawerOpen = false;

  void toggleDrawer() {
    setState(() {
      if (isDrawerOpen) {
        xOffset = 0.0;
        yOffset = 0.0;
        scaleFactor = 1.0;
        isDrawerOpen = false;
      } else {
        xOffset = 300.0;
        yOffset = 100.0;
        scaleFactor = 0.85;
        isDrawerOpen = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const DrawerMenu(),
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            transform: Matrix4.translationValues(xOffset, yOffset, 0)
              ..scale(scaleFactor)
              ..rotateZ(isDrawerOpen ? -50 : 0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: isDrawerOpen ? BorderRadius.circular(40) : BorderRadius.circular(0)
            ),
            child: GestureDetector(
              onTap: () {
                if (isDrawerOpen) toggleDrawer();
              },
              child: Stack(
                children: [
                  widget.child,
                  Positioned(
                    top: 40,
                    left: isDrawerOpen ? 20 : 10,
                    child: IconButton(
                      icon: Icon(
                        isDrawerOpen ? Icons.arrow_back_ios : Icons.menu,
                        size: 30,
                      ),
                      onPressed: toggleDrawer,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
