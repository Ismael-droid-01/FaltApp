import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../models/falta.dart';
import '../providers/falta_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPressed = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // Se carga el controller de la animacion
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Se carga la lista de faltas al iniciar la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FaltaProvider>().cargarFaltas();
    });

    // Si la animacion termina y el boton sigue presionado, se registra la falta
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && _isPressed) {
        _registrarFalta();
      }
    });
  }

  void _registrarFalta() {
    final falta = Falta(materia: 'Sistemas', fecha: DateTime(2024, 10, 5));

    context.read<FaltaProvider>().agregarFalta(falta);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Falta registrada')));

    _controller.reset(); // Reinicia la animacion
    _isPressed = false;
  }

  void _onLongPressStart() {
    _isPressed = true;
    _controller.forward(); // Inicia animacion
  }

  void _onLongPressEnd() {
    if (_controller.status != AnimationStatus.completed) {
      _controller.reset(); // Cancela si no completo
    }
    _isPressed = false;
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Faltas'), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Consumer<FaltaProvider>(
              builder: (context, faltaProvider, _) {
                final faltas = faltaProvider.faltas;

                if (faltas.isEmpty) {
                  return const Text('No hay faltas registradas');
                }

                // Agrupar por materia
                final faltasPorMateria = <String, List<Falta>>{};
                for (var falta in faltas) {
                  faltasPorMateria
                      .putIfAbsent(falta.materia, () => [])
                      .add(falta);
                }

                // Crear una card por materia
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 3 / 2,
                    children:
                        faltasPorMateria.entries.map((entry) {
                          final materia = entry.key;
                          final listaFaltas = entry.value;

                          return Card(
                            elevation: 4,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    materia,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  ...listaFaltas.map(
                                    (f) => Text(
                                      '-${f.fecha.toLocal().toString().split(" ")[0]}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),
            const Text(
              'Matematicas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            GestureDetector(
              onLongPressStart: (_) => _onLongPressStart(),
              onLongPressEnd: (_) => _onLongPressEnd(),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 140,
                    height: 140,
                    child: CustomPaint(
                      painter: ProgressCirclePainter(_controller),
                    ),
                  ),
                  Container(
                    width: 120,
                    height: 120,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.redAccent,
                    ),
                    child: const Center(
                      child: Text(
                        'Registrar\nFalta',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProgressCirclePainter extends CustomPainter {
  final Animation<double> animation;

  ProgressCirclePainter(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint =
        Paint()
          ..color = Colors.redAccent
          ..strokeWidth = 6
          ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final sweepAngle = 2 * pi * animation.value;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant ProgressCirclePainter oldDelegate) =>
      oldDelegate.animation != animation;
}
