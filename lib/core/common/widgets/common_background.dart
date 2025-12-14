import 'package:flutter/material.dart';

class CommonBackground extends StatelessWidget {
  const CommonBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: child,
    );
  }
}
