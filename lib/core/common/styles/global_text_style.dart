import 'package:flutter/material.dart';

class GlobalTextStyle {
  static TextStyle title(BuildContext context) =>
      Theme.of(context).textTheme.titleLarge ??
      const TextStyle(fontSize: 20, fontWeight: FontWeight.w600);

  static TextStyle subtitle(BuildContext context) =>
      Theme.of(context).textTheme.titleMedium ??
      const TextStyle(fontSize: 16, fontWeight: FontWeight.w500);

  static TextStyle body(BuildContext context) =>
      Theme.of(context).textTheme.bodyMedium ?? const TextStyle(fontSize: 14);
}
