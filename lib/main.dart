import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:past_questions/auth_wrapper.dart';
import 'package:past_questions/firebase_options.dart';
import 'package:past_questions/providers/auth_flow_controller.dart';
import 'package:past_questions/providers/guest_session_provider.dart';
import 'package:past_questions/providers/navigation_provider.dart';
import 'package:past_questions/providers/theme_provider.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => GuestSessionProvider()),
        ChangeNotifierProvider(create: (_) => AuthFlowController()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, theme, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: theme.isDarkMode ? Colors.blueAccent : Colors.lightBlue,
              brightness: theme.isDarkMode ? Brightness.dark : Brightness.light,
            ),
          ),
          home: const AuthWrapper(),
        );
      },
    );
  }
}
