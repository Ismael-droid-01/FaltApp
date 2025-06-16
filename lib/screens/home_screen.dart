import 'dart:async';
import 'dart:math';

import 'package:faltapp/widgets/faltas_progess_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/clase_provider.dart';
import '../services/clase_storage_service.dart';
import '../utils/clase_utils.dart';
import 'package:intl/intl.dart';
import '../widgets/icono_circular.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  bool _isPressed = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.easeInOut,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ClaseProvider>().cargarClases();
      }
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && _isPressed) {
        _registrarFalta();
      }
    });
  }

  void _mostrarFormularioAgregarFalta() async {
    final claseProvider = context.read<ClaseProvider>();
    final clases = claseProvider.clases;

    final limiteFaltas = await ClaseStorageService.obtenerLimiteFaltas();

    if (!mounted) return;

    final clasesDisponibles =
        clases.where((clase) => clase.faltas.length < limiteFaltas).toList();

    String? materiaSeleccionada;
    DateTime? fechaSeleccionada;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Agregar Falta'),
          content: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.5,
                maxWidth: MediaQuery.of(context).size.width * 0.8,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Materia'),
                    isExpanded: true,
                    items: clasesDisponibles
                        .map(
                          (clase) => DropdownMenuItem(
                            value: clase.materia,
                            child: Text(
                              clase.materia,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              softWrap: false,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      materiaSeleccionada = value;
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      fechaSeleccionada != null
                          ? '${fechaSeleccionada!.toLocal()}'.split(' ')[0]
                          : 'Seleccionar fecha',
                    ),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          fechaSeleccionada = picked;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('Guardar'),
              onPressed: () async {
                if (materiaSeleccionada == null || fechaSeleccionada == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Completa todos los campos')),
                  );
                  return;
                }

                await ClaseStorageService.agregarFaltaAClase(
                  materiaSeleccionada!,
                  fechaSeleccionada!,
                );
                claseProvider.cargarClases();
                if (!context.mounted) return;
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Falta agregada manualmente')),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _registrarFalta() async {
    try {
      final clases = context.read<ClaseProvider>().clases;
      final materiaActual = ClaseUtils.obtenerMateriaActual(clases);

      if (materiaActual.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No hay clase para registrar falta')),
        );
        return;
      }

      await ClaseStorageService.agregarFaltaAClase(
        materiaActual,
        DateTime.now(),
      );

      if (!mounted) return;
      context.read<ClaseProvider>().cargarClases();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Falta registrada')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }

    _controller.reset();
    _isPressed = false;
    _scaleController.reverse();
  }

  void _onLongPressStart() {
    _isPressed = true;
    _controller.forward();
    _scaleController.forward();
  }

  void _onLongPressEnd() {
    if (_controller.status != AnimationStatus.completed) {
      _controller.reset();
    }
    _isPressed = false;
    _scaleController.reverse();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scaleController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Faltas'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Agregar falta manualmente',
            onPressed: _mostrarFormularioAgregarFalta,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Consumer<ClaseProvider>(
              builder: (context, claseProvider, _) {
                final clases = claseProvider.clases;

                if (clases.isEmpty) {
                  return const Text('No hay clases registradas');
                }

                return GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.09,
                  children: clases.map((clase) {
                    return Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const IconoCircular(),
                                const SizedBox(height: 8),
                                Text(
                                  clase.materia,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.start,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (clase.faltas.isNotEmpty) ...[
                              Text(
                                DateFormat(
                                  "d 'de' MMMM",
                                  'es',
                                ).format(clase.faltas.last),
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 8),
                              FaltasProgressBar(
                                faltasActuales: clase.faltas.length,
                                limiteFaltas: 3,
                              ),
                            ] else ...[
                              const Text(
                                'Sin faltas',
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 20),
            Consumer<ClaseProvider>(
              builder: (context, claseProvider, _) {
                final materiaActual = ClaseUtils.obtenerMateriaActual(
                  claseProvider.clases,
                );
                return Text(
                  materiaActual.isNotEmpty
                      ? materiaActual
                      : 'No hay clase en este momento',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            FutureBuilder<int>(
              future: ClaseStorageService.obtenerLimiteFaltas(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                final limiteFaltas = snapshot.data!;
                return Consumer<ClaseProvider>(
                  builder: (context, claseProvider, _) {
                    final materiaActual = ClaseUtils.obtenerMateriaActual(
                      claseProvider.clases,
                    );
                    final hayClase = materiaActual.isNotEmpty;

                    final faltasActuales =
                        hayClase ? ClaseStorageService.obtenerFaltas(materiaActual) : 0;

                    final limiteAlcanzado = faltasActuales >= limiteFaltas;
                    final estaDisponible = hayClase && !limiteAlcanzado;

                    return GestureDetector(
                      onLongPressStart:
                          estaDisponible ? (_) => _onLongPressStart() : null,
                      onLongPressEnd:
                          estaDisponible ? (_) => _onLongPressEnd() : null,
                      child: AnimatedBuilder(
                        animation: _scaleAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _scaleAnimation.value,
                            child: child,
                          );
                        },
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
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: estaDisponible ? Colors.redAccent : Colors.grey,
                              ),
                              child: Center(
                                child: Text(
                                  hayClase
                                      ? (limiteAlcanzado
                                          ? 'Límite\nalcanzado'
                                          : 'Registrar\nFalta')
                                      : 'Fuera\nde horario',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
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
                    );
                  },
                );
              },
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
    final Paint paint = Paint()
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
