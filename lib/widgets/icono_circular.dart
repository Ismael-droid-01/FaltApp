import 'package:flutter/material.dart';

class IconoCircular extends StatelessWidget {
  final IconData icono;
  final Color colorFondo;

  const IconoCircular({
    super.key,
    required this.icono,
    required this.colorFondo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: colorFondo, shape: BoxShape.circle),
      padding: const EdgeInsets.all(8),
      child: Icon(icono, size: 20, color: Colors.white),
    );
  }
}
