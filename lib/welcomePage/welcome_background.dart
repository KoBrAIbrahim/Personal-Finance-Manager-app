import 'package:flutter/material.dart';

class WelcomeBackgroundDecoration extends StatelessWidget {
  const WelcomeBackgroundDecoration({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -100,
          left: -100,
          child: Container(
            width: 200,
            height: 200,
            decoration: const BoxDecoration(
              color: Color(0xFF00B4D8),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          bottom: -120,
          right: -120,
          child: Container(
            width: 250,
            height: 250,
            decoration: const BoxDecoration(
              color: Color(0xFF0077B6),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}
