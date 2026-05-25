import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/car_report_controller.dart';
import '../controllers/auth_controller.dart';
import '../models/car_report.dart';
import 'report_form_page.dart';
import 'report_details_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _deleteReport(BuildContext context, CarReportController controller, int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('રિપોર્ટ ડિલીટ કરો?'),
        content: const Text('શું તમે ખરેખર આ ઇન્સ્પેક્શન રિપોર્ટ કાઢી નાખવા માંગો છો?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ના', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('હા, ડિલીટ', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await controller.deleteReportData(id);
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('રિપોર્ટ સફળતાપૂર્વક ડિલીટ કરાયો છે')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Get.find<CarReportController>();
    final authController = Get.find<AuthController>();
    final TextEditingController searchController = TextEditingController(text: controller.searchQuery.value);

    // Keep search field controller synced with the GetX reactive search query
    controller.searchQuery.listen((val) {
      if (searchController.text != val) {
        searchController.text = val;
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Custom Header with Gradient and Brand Logo
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Premium Motexa Brand Logo
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1.5,
                          ),
                          image: const DecorationImage(
                            image: AssetImage('assets/images/motexa_logo.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Motexa',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Obx(() {
                                  final role = authController.localRole.value;
                                  if (role.isEmpty) return const SizedBox.shrink();
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.25),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.white.withOpacity(0.15)),
                                    ),
                                    child: Text(
                                      role == 'Company Admin' ? 'એડમિન' : 'સ્ટાફ',
                                      style: const TextStyle(
                                        fontSize: 9, 
                                        color: Colors.tealAccent, 
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                            Obx(() {
                              final compName = authController.localCompanyName.value;
                              return Text(
                                compName.isNotEmpty ? compName : 'સેકન્ડ હેન્ડ ગાડી સેલ અને ઇન્સ્પેક્શન',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.85),
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              );
                            }),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout_rounded, color: Colors.white),
                        tooltip: 'લૉગ આઉટ',
                        onPressed: () {
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
                  const SizedBox(height: 20),
                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: TextField(
                      controller: searchController,
                      onChanged: controller.updateSearchQuery,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'મોડેલ અથવા ઓનર સર્ચ કરો...',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                        prefixIcon: const Icon(Icons.search, color: Colors.white),
                        suffixIcon: Obx(() => controller.searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, color: Colors.white),
                                onPressed: () {
                                  searchController.clear();
                                  controller.updateSearchQuery('');
                                },
                              )
                            : const SizedBox.shrink()),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Section Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(() => Text(
                        'તાજેતરના ઇન્સ્પેક્શન (${controller.reports.length})',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                  Obx(() => controller.isLoading.value
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const SizedBox.shrink()),
                ],
              ),
            ),

            // Report List
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.reports.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.reports.isEmpty) {
                  return _buildEmptyState();
                }
                return RefreshIndicator(
                  onRefresh: controller.fetchReports,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: controller.reports.length,
                    itemBuilder: (context, index) {
                      final report = controller.reports[index];
                      return _buildReportCard(context, controller, report);
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ReportFormPage()),
          );
          if (result == true) {
            controller.fetchReports();
          }
        },
        icon: const Icon(Icons.add_photo_alternate, color: Colors.white),
        label: const Text('નવું ઇન્સ્પેક્શન', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: theme.colorScheme.primary,
        elevation: 6,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_car_outlined,
              size: 80,
              color: Colors.grey.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'કોઈ ઇન્સ્પેક્શન મળ્યું નથી',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'નવું ઇન્સ્પેક્શન ઉમેરવા માટે નીચેના બટન પર ક્લિક કરો',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(BuildContext context, CarReportController controller, CarReport report) {
    final theme = Theme.of(context);
    final photoCount = report.images.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReportDetailsPage(reportId: report.id!),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Icon indicator
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.directions_car,
                      color: theme.colorScheme.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Report details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          report.model.isEmpty ? 'અજ્ઞાત મોડેલ' : report.model,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ઓનર: ${report.owner.isEmpty ? 'N/A' : report.owner}',
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.hintColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.speed, size: 14, color: theme.colorScheme.secondary),
                            const SizedBox(width: 4),
                            Text(
                              '${report.kilometers} km',
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.hintColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(Icons.photo_library_outlined, size: 14, color: theme.colorScheme.secondary),
                            const SizedBox(width: 4),
                            Text(
                              '$photoCount ફોટો',
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.hintColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Actions/Date
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: () => _deleteReport(context, controller, report.id!),
                      ),
                      Text(
                        report.createdAt.split(' ').first,
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.hintColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
