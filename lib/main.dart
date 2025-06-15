import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'models/falta.dart';
import 'providers/falta_provider.dart';
import 'screens/main_screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(FaltaAdapter());
  await Hive.openBox<Falta>('faltas');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FaltaProvider()..cargarFaltas()),
      ],
      child: const FaltApp(),
    ),
  );
}

class FaltApp extends StatelessWidget {
  const FaltApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FaltApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.redAccent, useMaterial3: true),
      initialRoute: '/',
      routes: {
        '/': (context) => const MainScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}
