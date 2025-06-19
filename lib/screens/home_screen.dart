import 'dart:async';
import 'dart:math';

import '../widgets/faltas_progess_bar.dart';
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
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
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
                    items:
                        clasesDisponibles
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

  final List<Color> coloresIconos = [
    Colors.redAccent, // Principal
    Colors.orangeAccent, // Cálido, análogo al rojo
    Colors.blueAccent, // Contraste fresco, elegante
    Colors.pinkAccent, // Luminoso pero equilibrado
    Colors.deepPurpleAccent, // Profundo y contrastante
  ];

  @override
  Widget build(BuildContext context) {
    final double cardWidth = (MediaQuery.of(context).size.width - 52) / 2;
    final double cardHeight = 180;

    // Contenedor fijo para 2x2 cards
    final double containerWidth =
        cardWidth * 2 + 12; // 2 cards + espacio entre columnas
    final double containerHeight =
        cardHeight * 2 + 12; // 2 cards + espacio entre filas

    return Scaffold(
      appBar: AppBar(
        title: const Text('Faltas'),
        centerTitle: true,
        actions: [
          Consumer<ClaseProvider>(
            builder: (context, claseProvider, _) {
              return claseProvider.clases.isNotEmpty
                  ? IconButton(
                    padding: const EdgeInsets.only(right: 22.0),
                    icon: const Icon(
                      Icons.add_circle_outline_rounded,
                      size: 32,
                    ),
                    tooltip: 'Agregar falta manualmente',
                    onPressed: _mostrarFormularioAgregarFalta,
                  )
                  : const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// 🔽 Sección scrollable con las tarjetas
            // Calcula el ancho y alto de cada card
            SizedBox(
              width: containerWidth,
              height: containerHeight,
              child: ScrollConfiguration(
                behavior: const ScrollBehavior().copyWith(overscroll: false),
                child: SingleChildScrollView(
                  child: Consumer<ClaseProvider>(
                    builder: (context, claseProvider, _) {
                      final clases = claseProvider.clases;

                      if (clases.isEmpty) {
                        return const Center(
                          child: Text('No hay clases registradas'),
                        );
                      }

                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children:
                            clases.map((clase) {
                              final index = claseProvider.clases.indexOf(clase);
                              final colorIcono =
                                  coloresIconos[index % coloresIconos.length];

                              return SizedBox(
                                width: cardWidth,
                                height: cardHeight,
                                child: Card(
                                  elevation: 4,
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        IconoCircular(
                                          icono: Icons.school,
                                          colorFondo: colorIcono,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          clase.materia,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8),
                                        if (clase.faltas.isNotEmpty) ...[
                                          Text(
                                            DateFormat(
                                              "d 'de' MMMM",
                                              'es',
                                            ).format(clase.faltas.last),
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          FaltasProgressBar(
                                            faltasActuales: clase.faltas.length,
                                            color: colorIcono,
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
                                ),
                              );
                            }).toList(),
                      );
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// 🔽 Botón central solo si hay clases
            Consumer<ClaseProvider>(
              builder: (context, claseProvider, _) {
                if (claseProvider.clases.isEmpty) {
                  return const SizedBox.shrink();
                }

                final materiaActual = ClaseUtils.obtenerMateriaActual(
                  claseProvider.clases,
                );
                final hayClase = materiaActual.isNotEmpty;

                return FutureBuilder<int>(
                  future: ClaseStorageService.obtenerLimiteFaltas(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }

                    final limiteFaltas = snapshot.data!;
                    final faltasActuales =
                        hayClase
                            ? ClaseStorageService.obtenerFaltas(materiaActual)
                            : 0;
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
                                color:
                                    estaDisponible
                                        ? Colors.redAccent
                                        : Colors.grey,
                              ),
                              child: Center(
                                child:
                                    hayClase
                                        ? (limiteAlcanzado
                                            ? const Icon(
                                              Icons.sentiment_neutral_sharp,
                                              color: Colors.white,
                                              size: 50,
                                            )
                                            : const Icon(
                                              Icons.thumb_down_alt_rounded,
                                              color: Colors.white,
                                              size: 50,
                                            ))
                                        : const Icon(
                                          Icons.hourglass_disabled_rounded,
                                          color: Colors.white,
                                          size: 50,
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

            const SizedBox(height: 12),

            /// 🔽 Etiqueta solo si hay clases
            Consumer<ClaseProvider>(
              builder: (context, claseProvider, _) {
                if (claseProvider.clases.isEmpty) {
                  return const SizedBox.shrink();
                }

                final materiaActual = ClaseUtils.obtenerMateriaActual(
                  claseProvider.clases,
                );
                final hayClase = materiaActual.isNotEmpty;

                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: hayClase ? Colors.white : Colors.grey.shade300,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Text(
                      hayClase ? materiaActual : 'No hay clase en este momento',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: hayClase ? Colors.black : Colors.grey.shade600,
                      ),
                    ),
                  ),
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
