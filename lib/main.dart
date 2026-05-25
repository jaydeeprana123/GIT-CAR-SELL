import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'repositories/car_report_repository.dart';
import 'controllers/car_report_controller.dart';
import 'controllers/auth_controller.dart';
import 'views/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    Get.log('Firebase initialization error: $e');
  }
  runApp(const CarInspectionApp());
}

class CarInspectionApp extends StatelessWidget {
  const CarInspectionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Motexa',
      initialBinding: BindingsBuilder(() {
        Get.put(AuthController());
        Get.put(CarReportController(repository: CarReportRepository()));
      }),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F766E), // Deep Teal
          brightness: Brightness.dark,
          primary: const Color(0xFF0D9488),   // Teal
          secondary: const Color(0xFF0891B2), // Cyan
          background: const Color(0xFF0F172A), // Slate 900
          surface: const Color(0xFF1E293B),    // Slate 800
        ),
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        cardColor: const Color(0xFF1E293B),
        dividerColor: const Color(0xFF334155),
        
        // Premium typography and spacing adjustments
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E293B),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFF0D9488), width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),

        chipTheme: ChipThemeData(
          backgroundColor: const Color(0xFF334155),
          disabledColor: const Color(0xFF1E293B),
          selectedColor: const Color(0xFF0D9488).withOpacity(0.2),
          secondarySelectedColor: const Color(0xFF0D9488),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          labelStyle: const TextStyle(fontSize: 12),
          secondaryLabelStyle: const TextStyle(fontSize: 12, color: Colors.white),
          brightness: Brightness.dark,
        ),
        
        dialogTheme: DialogThemeData(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
      home: const SplashPage(),
    );
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
