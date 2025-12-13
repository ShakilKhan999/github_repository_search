import 'package:flutter/widgets.dart';

class Sizer {
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.shortestSide >= 600;

  static double w(BuildContext context, double percent) =>
      MediaQuery.of(context).size.width * (percent / 100);

  static double h(BuildContext context, double percent) =>
      MediaQuery.of(context).size.height * (percent / 100);

  static double sp(BuildContext context, double size) {
    final width = MediaQuery.of(context).size.width;
    final scale = (width / 375.0).clamp(0.85, 1.25);
    return size * scale;
  }
}
