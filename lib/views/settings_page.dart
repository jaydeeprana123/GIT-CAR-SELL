import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/theme_controller.dart';
import 'staff_management_page.dart';
import 'earnings_report_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authController = Get.find<AuthController>();
    final role = authController.localRole.value;
    final isAdmin = role == 'Company Admin' || role == 'admin';

    return Scaffold(
      appBar: AppBar(
        title: const Text('સેટિંગ્સ (Settings)'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: [
          // Header Info
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary.withOpacity(0.85),
                  theme.colorScheme.secondary.withOpacity(0.85),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      radius: 28,
                      child: const Icon(
                        Icons.person_outline,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            authController.firebaseUser.value?.email ?? 'અજ્ઞાત ઇમેઇલ',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isAdmin ? 'કંપની એડમિન (Admin)' : 'સ્ટાફ યુઝર (Staff)',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.tealAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (authController.localCompanyName.value.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Divider(color: Colors.white24, height: 1),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.business, size: 16, color: Colors.white70),
                      const SizedBox(width: 8),
                      Text(
                        authController.localCompanyName.value,
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 32),

          const Text(
            'સામાન્ય મેનુ (General Menu)',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 12),

          // Admin Only Menu Items
          if (isAdmin) ...[
            _buildSettingsTile(
              context: context,
              icon: Icons.people_outline,
              title: 'સ્ટાફ મેનેજમેન્ટ (Staff Management)',
              subtitle: 'સ્ટાફ યુઝર્સ ઉમેરો, એડિટ કરો અને નિયંત્રિત કરો',
              onTap: () => Get.to(() => const StaffManagementPage()),
            ),
            const SizedBox(height: 12),
            _buildSettingsTile(
              context: context,
              icon: Icons.bar_chart_outlined,
              title: 'કમાણીનો અહેવાલ (Earnings Report)',
              subtitle: 'કમાણી અને વેચાણના આંકડા ફિલ્ટર કરી જુઓ',
              onTap: () => Get.to(() => const EarningsReportPage()),
            ),
            const SizedBox(height: 12),
          ],

          // Theme Selector Tile (Visible to everyone)
          _buildSettingsTile(
            context: context,
            icon: Icons.color_lens_outlined,
            title: 'થીમ સેટિંગ્સ (Theme Settings)',
            subtitle: 'લાઇટ અને ડાર્ક કલર થીમ પસંદ કરો',
            onTap: () => _showThemeSelector(context),
          ),
          const SizedBox(height: 32),

          const Text(
            'એકાઉન્ટ (Account)',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 12),

          // Logout Tile
          _buildSettingsTile(
            context: context,
            icon: Icons.logout_rounded,
            title: 'લૉગ આઉટ (Logout)',
            subtitle: 'એકાઉન્ટમાંથી બહાર નીકળો',
            iconColor: Colors.redAccent,
            titleColor: Colors.redAccent,
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('લૉગ આઉટ?'),
                  content: const Text('શું તમે ખરેખર લૉગ આઉટ કરવા માંગો છો?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('ના', style: TextStyle(color: Colors.grey)),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        authController.logout();
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                      child: const Text('હા', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
    Color? titleColor,
  }) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.4)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (iconColor ?? theme.colorScheme.primary).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor ?? theme.colorScheme.primary, size: 22),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: titleColor ?? theme.textTheme.bodyLarge?.color,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 11, color: theme.hintColor),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 14, color: theme.hintColor),
        onTap: onTap,
      ),
    );
  }

  void _showThemeSelector(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('થીમ પસંદ કરો', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          content: Obx(() {
            final currentKey = themeController.currentThemeKey.value;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildThemeOption(context, 'teal_dark', 'Teal Dream (Dark)', const Color(0xFF0D9488), currentKey, themeController),
                _buildThemeOption(context, 'blue_dark', 'Midnight Blue (Dark)', const Color(0xFF3B82F6), currentKey, themeController),
                _buildThemeOption(context, 'amber_dark', 'Sunset Gold (Dark)', const Color(0xFFF59E0B), currentKey, themeController),
                _buildThemeOption(context, 'purple_dark', 'Royal Purple (Dark)', const Color(0xFF8B5CF6), currentKey, themeController),
                _buildThemeOption(context, 'teal_light', 'Teal Light (Light)', const Color(0xFF0F766E), currentKey, themeController),
                _buildThemeOption(context, 'mono_light', 'Black & White (Light)', const Color(0xFF000000), currentKey, themeController),
              ],
            );
          }),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('બંધ કરો (Close)'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    String key,
    String label,
    Color colorIndicator,
    String currentKey,
    ThemeController themeController,
  ) {
    final theme = Theme.of(context);
    final isSelected = key == currentKey;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? colorIndicator.withOpacity(0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? colorIndicator : Colors.transparent,
          width: 1,
        ),
      ),
      child: ListTile(
        visualDensity: VisualDensity.compact,
        leading: CircleAvatar(
          backgroundColor: colorIndicator,
          radius: 10,
        ),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? colorIndicator : theme.textTheme.bodyLarge?.color,
          ),
        ),
        trailing: isSelected
            ? Icon(Icons.check_circle, color: colorIndicator, size: 20)
            : null,
        onTap: () => themeController.changeTheme(key),
      ),
    );
  }
}
