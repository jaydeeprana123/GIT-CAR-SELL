import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'repositories/car_report_repository.dart';
import 'controllers/car_report_controller.dart';
import 'controllers/auth_controller.dart';
import 'controllers/theme_controller.dart';
import 'db/db_helper.dart';
import 'views/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    Get.log('Firebase initialization error: $e');
  }
  
  // Load saved theme key
  final dbHelper = DbHelper();
  final savedTheme = await dbHelper.getSetting('themeKey') ?? 'teal_dark';
  
  runApp(CarInspectionApp(initialTheme: savedTheme));
}

class CarInspectionApp extends StatelessWidget {
  final String initialTheme;
  const CarInspectionApp({super.key, required this.initialTheme});

  @override
  Widget build(BuildContext context) {
    // Put ThemeController
    final themeController = Get.put(ThemeController(initialTheme: initialTheme));

    return Obx(() => GetMaterialApp(
      title: 'Motexa',
      initialBinding: BindingsBuilder(() {
        Get.put(AuthController());
        Get.put(CarReportController(repository: CarReportRepository()));
      }),
      debugShowCheckedModeBanner: false,
      theme: themeController.currentThemeData,
      themeMode: themeController.currentThemeMode,
      home: const SplashPage(),
    ));
  }
}

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.background,
              const Color(0xFF020617), // Deepest dark
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.2),
                      blurRadius: 30,
                      spreadRadius: 2,
                    ),
                  ],
                  image: const DecorationImage(
                    image: AssetImage('assets/images/motexa_logo.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Motexa',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'સેકન્ડ હેન્ડ ગાડી સેલ અને ઇન્સ્પેક્શન',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
