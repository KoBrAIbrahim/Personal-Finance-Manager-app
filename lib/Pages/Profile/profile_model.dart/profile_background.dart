import 'package:flutter/material.dart';

class ProfileBackgroundDecoration extends StatelessWidget {
  const ProfileBackgroundDecoration({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -80,
          left: -80,
          child: _circle(200, const Color(0xFF00B4D8).withOpacity(0.2)),
        ),
        Positioned(
          bottom: -100,
          right: -100,
          child: _circle(250, const Color(0xFF0077B6).withOpacity(0.2)),
        ),
      ],
    );
  }

  Widget _circle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
