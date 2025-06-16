import 'package:flutter/material.dart';

class FaltasProgressBar extends StatelessWidget {
  final int faltasActuales;
  final int limiteFaltas;

  const FaltasProgressBar({
    super.key,
    required this.faltasActuales,
    required this.limiteFaltas,
  });

  @override
  Widget build(BuildContext context) {
    final currentStep = faltasActuales.clamp(0, limiteFaltas);

    return SizedBox(
      height: 30,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(limiteFaltas, (index) {
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 10,
                  decoration: BoxDecoration(
                    color:
                        index < currentStep
                            ? Colors.redAccent
                            : Colors.grey[300],
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              );
            }),
          ),

          // Flecha eliminada
        ],
      ),
    );
  }
}
