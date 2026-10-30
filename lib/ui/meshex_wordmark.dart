import 'package:flutter/material.dart';

/// Website wordmark: Manrope ExtraBold with the three Meshex brand colors.
class MeshexWordmark extends StatelessWidget {
  const MeshexWordmark({super.key});

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text.rich(
        const TextSpan(
          children: [
            TextSpan(
              text: 'mes',
              style: TextStyle(color: Color(0xFF227DF3)),
            ),
            TextSpan(
              text: 'h',
              style: TextStyle(color: Color(0xFF8848DB)),
            ),
            TextSpan(
              text: 'ex',
              style: TextStyle(color: Color(0xFFCF3E83)),
            ),
          ],
        ),
        style: const TextStyle(
          fontFamily: 'Manrope',
          fontSize: 64,
          fontWeight: FontWeight.w800,
          letterSpacing: -4.8,
          height: 1,
        ),
        semanticsLabel: 'Meshex',
        textDirection: TextDirection.ltr,
        maxLines: 1,
      ),
    );
  }
}
