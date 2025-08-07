// ignore: file_names
import 'package:flutter/material.dart';

Widget buildScrollableWithFade({
  required Widget child,
  double fadeHeight = 40.0, // Adjust fade height as needed
}) {
  return ShaderMask(
    shaderCallback: (Rect bounds) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white,
          Colors.transparent,
          Colors.transparent,
          Colors.transparent,
          Colors.white,
        ],
        stops: [
          0.0,
          0.02,
          0.05,
          0.95,
          1.0,
        ], // Adjust stops to control fade intensity
      ).createShader(bounds);
    },
    blendMode: BlendMode.dstOut,
    child: child,
  );
}
