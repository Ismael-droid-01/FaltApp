import 'package:flutter/material.dart';
import '../services/clase_storage_service.dart';

class FaltasProgressBar extends StatelessWidget {
  final int faltasActuales;

  const FaltasProgressBar({super.key, required this.faltasActuales});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: ClaseStorageService.obtenerLimiteFaltas(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(
            height: 30,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final limiteFaltas = snapshot.data!;
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
      },
    );
  }
}
