import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(FaltApp());
}

class FaltApp extends StatelessWidget {
  const FaltApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FaltApp',
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}