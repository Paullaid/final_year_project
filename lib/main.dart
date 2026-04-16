import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:past_questions/auth_wrapper.dart';
import 'package:past_questions/firebase_options.dart';
import 'package:past_questions/providers/auth_flow_controller.dart';
import 'package:past_questions/providers/admin_role_provider.dart';
import 'package:past_questions/providers/courses_provider.dart';
import 'package:past_questions/providers/departments_provider.dart';
import 'package:past_questions/providers/guest_session_provider.dart';
import 'package:past_questions/providers/navigation_provider.dart';
import 'package:past_questions/providers/past_questions_provider.dart';
import 'package:past_questions/providers/theme_provider.dart';
import 'package:past_questions/providers/upload_provider.dart';
import 'package:past_questions/services/app_config_service.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: 'assets/app.env');
  } catch (e, st) {
    debugPrint('dotenv load failed (Worker URL may be unset): $e\n$st');
  }
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);
  await AppConfigService.instance.initialize();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => GuestSessionProvider()),
        ChangeNotifierProvider(create: (_) => AuthFlowController()),
        ChangeNotifierProvider(create: (_) => AdminRoleProvider()),
        ChangeNotifierProvider(create: (_) => DepartmentsProvider()),
        ChangeNotifierProvider(create: (_) => CoursesProvider()),
        ChangeNotifierProvider(create: (_) => UploadProvider()),
        ChangeNotifierProvider(create: (_) => PastQuestionsProvider()),
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
