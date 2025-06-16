import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'models/clase.dart';
import 'providers/clase_provider.dart';
import 'screens/main_screen.dart';
import 'screens/settings_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  //await Hive.deleteBoxFromDisk('clases');
  //await Hive.deleteBoxFromDisk('ajustes');

  Hive.registerAdapter(ClaseAdapter());

  await Hive.openBox<Clase>('clases');

  await initializeDateFormatting('es', null);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ClaseProvider()..cargarClases()),
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
