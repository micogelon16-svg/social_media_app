import 'package:flutter/material.dart';
import 'screens/object_recognizer_screen.dart';

void main() {
  runApp(const ObjectRecognizerApp());
}

class ObjectRecognizerApp extends StatelessWidget {
  const ObjectRecognizerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Object Recognizer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.grey[50],
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
          ),
        ),
      ),
      home: const ObjectRecognizerScreen(),
    );
  }
}