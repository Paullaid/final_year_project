import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:past_questions/auth_gate.dart';
import 'package:past_questions/data/notifiers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDarkMode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(colorScheme: ColorScheme.fromSeed(
            seedColor: isDarkMode ? Colors.blueAccent :  Colors.lightBlue,
            brightness: isDarkMode ? Brightness.dark : Brightness.light,
            ),      
          ),
          home: const AuthGate(),
        );
      }
    );
  }
}