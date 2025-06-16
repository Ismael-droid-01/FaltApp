import 'package:flutter/material.dart';

class IconoCircular extends StatelessWidget {
  const IconoCircular({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.redAccent,
        shape: BoxShape.circle,
      ),
      padding: const EdgeInsets.all(8),
      child: const Icon(Icons.school, size: 20, color: Colors.white),
    );
  }
}
