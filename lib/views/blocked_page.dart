import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class BlockedPage extends StatelessWidget {
  const BlockedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authController = Get.find<AuthController>();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.background,
              const Color(0xFF090D1A), // Dark Navy
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
            child: Obx(() {
              final reason = authController.blockedReason.value;
              String title = 'એક્સેસ મર્યાદિત છે';
              String message = 'કૃપા કરીને એડમિનિસ્ટ્રેટરનો સંપર્ક કરો.';
              IconData icon = Icons.lock_outline_rounded;
              Color iconColor = Colors.orangeAccent;

              if (reason == 'expired') {
                title = 'સબ્સ્ક્રિપ્શન સમાપ્ત થઈ ગયું છે';
                message = 'તમારી કંપનીનું સબ્સ્ક્રિપ્શન સમાપ્ત થઈ ગયું છે.\nકૃપા કરીને સુપર એડમિનનો સંપર્ક કરો.';
                icon = Icons.hourglass_disabled_rounded;
                iconColor = Colors.redAccent;
              } else if (reason == 'deactivated') {
                title = 'કંપની એકાઉન્ટ નિષ્ક્રિય છે';
                message = 'તમારી કંપનીનું એકાઉન્ટ નિષ્ક્રિય કરવામાં આવ્યું છે.\nકૃપા કરીને સુપર એડમિનનો સંપર્ક કરો.';
                icon = Icons.block_flipped;
                iconColor = Colors.redAccent;
              } else if (reason == 'offline_limit') {
                title = 'ઓનલાઇન વેરિફિકેશન જરૂરી';
                message = 'તમે છેલ્લા ૭ દિવસથી ઇન્ટરનેટ કનેક્ટ કર્યું નથી.\nએપ્લિકેશન ચાલુ રાખવા માટે કૃપા કરીને ઇન્ટરનેટ કનેક્ટ કરો.';
                icon = Icons.wifi_off_rounded;
                iconColor = Colors.cyanAccent;
              }

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  
                  // Icon display with glowing background
                  Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.08),
                      shape: BoxShape.circle,
                      border: Border.all(color: iconColor.withOpacity(0.2), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: iconColor.withOpacity(0.1),
                          blurRadius: 40,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        icon,
                        size: 60,
                        color: iconColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Text messaging
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.65),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(),

                  // Actions
                  if (authController.isLoading.value)
                    const CircularProgressIndicator()
                  else ...[
                    // Retry Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (authController.firebaseUser.value != null) {
                            authController.checkAccess(authController.firebaseUser.value!);
                          }
                        },
                        icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                        label: const Text(
                          'ફરી તપાસો (લોડ કરો)',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    
                    // Logout button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: () => authController.logout(),
                        icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                        label: const Text(
                          'લૉગ આઉટ',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.redAccent),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.redAccent, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
