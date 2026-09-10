import 'package:flutter/material.dart';

class AppBreakpoints {
  static const double desktop = 1024;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= desktop;
}