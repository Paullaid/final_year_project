import 'package:flutter/material.dart';
import 'package:past_questions/data/notifiers.dart';
import 'package:past_questions/views/pages/welcome_page.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
          home: WelcomePage(),
        );
      }
    );
  }
}