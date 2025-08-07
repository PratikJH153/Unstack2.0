import 'package:flutter/material.dart';

class AppSize {
  final BuildContext context;

  late final double height;
  late final double width;

  AppSize(this.context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
  }
}
