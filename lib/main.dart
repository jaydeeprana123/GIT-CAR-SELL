import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'repositories/car_report_repository.dart';
import 'controllers/car_report_controller.dart';
import 'views/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CarInspectionApp());
}

class CarInspectionApp extends StatelessWidget {
  const CarInspectionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Motexa',
      initialBinding: BindingsBuilder(() {
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
      home: const HomePage(),
    );
  }
}
