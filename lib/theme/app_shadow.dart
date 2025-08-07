import 'package:flutter/material.dart';

class AppShadows {
  static const BoxShadow sm = BoxShadow(
    color: Color(0x0D000000),
    blurRadius: 2,
    offset: Offset(0, 1),
  );

  static const BoxShadow md = BoxShadow(
    color: Color(0x1A000000),
    blurRadius: 6,
    offset: Offset(0, 4),
  );

  static const BoxShadow lg = BoxShadow(
    color: Color(0x1A000000),
    blurRadius: 15,
    offset: Offset(0, 10),
  );

  static const BoxShadow xl = BoxShadow(
    color: Color(0x1A000000),
    blurRadius: 25,
    offset: Offset(0, 20),
  );
}
