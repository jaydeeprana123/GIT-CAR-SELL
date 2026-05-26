import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/auth_controller.dart';
import '../../models/company.dart';
import '../../services/auth_service.dart';
import 'register_company_page.dart';

class SuperAdminDashboardPage extends StatefulWidget {
  const SuperAdminDashboardPage({super.key});

  @override
  State<SuperAdminDashboardPage> createState() => _SuperAdminDashboardPageState();
}

class _SuperAdminDashboardPageState extends State<SuperAdminDashboardPage> {
  final AuthService _authService = AuthService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Toggle active/deactive company status
  Future<void> _toggleCompanyStatus(Company company) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(company.isActive ? 'નિષ્ક્રિય કરવો?'.tr : 'સક્રિય કરવો?'.tr),
        content: Text('શું તમે ખરેખર @name ને @status કરવા માંગો છો?'.trParams({
          'name': company.companyName,
          'status': company.isActive ? 'નિષ્ક્રિય'.tr : 'સક્રિય'.tr,
        })),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('ના'.tr, style: const TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: company.isActive ? Colors.redAccent : Colors.teal,
            ),
            child: Text('હા'.tr, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _authService.updateCompanyStatus(company.companyId, !company.isActive);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('@name ની સ્થિતિ બદલાઈ છે.'.trParams({'name': company.companyName}))),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('ભૂલ આવી: \$e'.tr.replaceAll(r'$e', e.toString()))),
          );
        }
      }
    }
  }

  // Extend Subscription using Calendar DatePicker
  Future<void> _extendSubscription(Company company) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: company.subscriptionExpiryDate.isBefore(DateTime.now()) 
          ? DateTime.now().add(const Duration(days: 30))
          : company.subscriptionExpiryDate.add(const Duration(days: 30)),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      helpText: '@name સબ્સ્ક્રિપ્શન લંબાવો'.trParams({'name': company.companyName}),
      confirmText: 'પસંદ કરો'.tr,
      cancelText: 'રદ કરો'.tr,
    );

    if (picked != null) {
      try {
        await _authService.extendSubscription(company.companyId, picked);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('@name સબ્સ્ક્રિપ્શન @date સુધી લંબાવ્યું છે.'.trParams({
                'name': company.companyName,
                'date': DateFormat('dd-MM-yyyy').format(picked),
              })),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('ભૂલ આવી: \$e'.tr.replaceAll(r'$e', e.toString()))),
          );
        }
      }
    }
  }

  // Trigger Password Reset
  Future<void> _resetAdminPassword(Company company) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('પાસવર્ડ રીસેટ?'.tr),
        content: Text('શું તમે @name ના એડમિન (@email) ને પાસવર્ડ રીસેટ લિંક મોકલવા માંગો છો?'.trParams({
          'name': company.companyName,
          'email': company.email,
        })),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('ના'.tr, style: const TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            child: Text('હા, મોકલો'.tr, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _authService.sendPasswordReset(company.email);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('@email પર પાસવર્ડ રીસેટ ઇમેલ મોકલ્યો છે.'.trParams({'email': company.email}))),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('ઇમેલ મોકલવામાં ભૂલ આવી: \$e'.tr.replaceAll(r'$e', e.toString()))),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('સુપર એડમિન ડેશબોર્ડ'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => authController.logout(),
            tooltip: 'લૉગ આઉટ'.tr,
          ),
        ],
      ),
      body: StreamBuilder<List<Company>>(
        stream: _authService.getCompaniesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("${'ભૂલ આવી'.tr}: ${snapshot.error}"));
          }

          final companies = snapshot.data ?? [];
          final filteredCompanies = companies.where((c) {
            final query = _searchQuery.toLowerCase();
            return c.companyName.toLowerCase().contains(query) ||
                c.ownerName.toLowerCase().contains(query) ||
                c.companyId.toLowerCase().contains(query) ||
                c.email.toLowerCase().contains(query);
          }).toList();

          final total = companies.length;
          final active = companies.where((c) => c.isActive && c.subscriptionExpiryDate.isAfter(DateTime.now())).length;
          final expired = companies.where((c) => c.subscriptionExpiryDate.isBefore(DateTime.now())).length;
          final inactive = companies.where((c) => !c.isActive).length;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats Panels
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    _buildStatCard('કુલ કંપની'.tr, total.toString(), theme.brightness == Brightness.light ? Colors.blue.shade700 : Colors.blueAccent, theme),
                    const SizedBox(width: 8),
                    _buildStatCard('સક્રિય'.tr, active.toString(), theme.brightness == Brightness.light ? Colors.teal.shade700 : Colors.tealAccent, theme),
                    const SizedBox(width: 8),
                    _buildStatCard('સમાપ્ત'.tr, expired.toString(), theme.brightness == Brightness.light ? Colors.red.shade700 : Colors.redAccent, theme),
                    const SizedBox(width: 8),
                    _buildStatCard('નિષ્ક્રિય'.tr, inactive.toString(), theme.brightness == Brightness.light ? Colors.orange.shade800 : Colors.orangeAccent, theme),
                  ],
                ),
              ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.brightness == Brightness.light
                          ? Colors.black.withOpacity(0.08)
                          : Colors.white.withOpacity(0.08),
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(
                      color: theme.brightness == Brightness.light ? Colors.black87 : Colors.white,
                    ),
                    decoration: InputDecoration(
                      hintText: 'કંપની નામ અથવા એડમિન સર્ચ કરો...'.tr,
                      hintStyle: TextStyle(
                        color: theme.brightness == Brightness.light
                            ? Colors.black38
                            : Colors.white.withOpacity(0.5),
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: theme.brightness == Brightness.light ? Colors.black45 : Colors.grey,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: theme.brightness == Brightness.light ? Colors.black45 : Colors.grey,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 12),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: Text(
                  "${'નોંધાયેલ કંપનીઓ'.tr} (${filteredCompanies.length})",
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.grey),
                ),
              ),

              const SizedBox(height: 8),

              // Company List
              Expanded(
                child: filteredCompanies.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        itemCount: filteredCompanies.length,
                        itemBuilder: (context, index) {
                          final company = filteredCompanies[index];
                          return _buildCompanyCard(company, theme);
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RegisterCompanyPage()),
        ),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('નવી કંપની રજીસ્ટર'.tr, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: theme.colorScheme.primary,
        elevation: 6,
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color, ThemeData theme) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2), width: 1.2),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withOpacity(0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.business_rounded,
            size: 60,
            color: isLight ? Colors.black26 : Colors.white.withOpacity(0.2),
          ),
          const SizedBox(height: 12),
          Text(
            'કોઈ કંપની મળી નથી'.tr,
            style: TextStyle(
              fontSize: 16,
              color: isLight ? Colors.black38 : Colors.white.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyCard(Company company, ThemeData theme) {
    final isExpired = company.subscriptionExpiryDate.isBefore(DateTime.now());
    final isLight = theme.brightness == Brightness.light;
    final statusColor = !company.isActive
        ? (isLight ? Colors.orange.shade800 : Colors.orangeAccent)
        : isExpired
            ? (isLight ? Colors.red.shade700 : Colors.redAccent)
            : (isLight ? Colors.teal.shade700 : Colors.tealAccent);

    final statusText = !company.isActive
        ? 'નિષ્ક્રિય'
        : isExpired
            ? 'સમાપ્ત'
            : 'ચાલુ';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: statusColor.withOpacity(0.15),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ExpansionTile(
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.business_rounded,
            color: statusColor,
            size: 24,
          ),
        ),
        title: Text(
          company.companyName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          "ID: ${company.companyId} | ${'ઓનર'.tr}: ${company.ownerName}",
          style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.6)),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: statusColor.withOpacity(0.3)),
          ),
          child: Text(
            statusText.tr,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        childrenPadding: const EdgeInsets.all(16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(color: Color(0xFF334155), height: 1),
          const SizedBox(height: 12),
          
          // Company details listing
          _buildDetailRow('એડમિન ઇમેલ'.tr, company.email, Icons.email_outlined, theme),
          _buildDetailRow(
            'સબ્સ્ક્રિપ્શન ચાલુ થયા તારીખ'.tr, 
            DateFormat('dd-MM-yyyy').format(company.subscriptionStartDate), 
            Icons.date_range, 
            theme
          ),
          _buildDetailRow(
            'સબ્સ્ક્રિપ્શન સમાપ્તિ તારીખ'.tr, 
            DateFormat('dd-MM-yyyy').format(company.subscriptionExpiryDate), 
            Icons.event_busy, 
            theme,
            valueColor: isExpired
                ? (theme.brightness == Brightness.light ? Colors.red.shade700 : Colors.redAccent)
                : (theme.brightness == Brightness.light ? Colors.teal.shade700 : Colors.tealAccent),
          ),
          _buildDetailRow(
            'પર્ચેઝ સ્કીમ (Purchase Scheme)'.tr, 
            company.purchaseScheme == 'online' ? 'ઓનલાઇન (Online)'.tr : 'ઓફલાઇન (Offline)'.tr, 
            Icons.shopping_bag_outlined, 
            theme,
            valueColor: company.purchaseScheme == 'online'
                ? (theme.brightness == Brightness.light ? Colors.cyan.shade800 : Colors.cyanAccent)
                : (theme.brightness == Brightness.light ? Colors.amber.shade900 : Colors.amberAccent),
          ),
          
          const SizedBox(height: 12),

          // Purchase Scheme Switcher
          Row(
            children: [
              Icon(Icons.edit_note, size: 18, color: theme.colorScheme.secondary),
              const SizedBox(width: 8),
              Text(
                'સ્કીમ બદલો: '.tr,
                style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.6)),
              ),
              const SizedBox(width: 8),
              Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: company.purchaseScheme,
                    dropdownColor: theme.cardColor,
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.white, size: 18),
                    onChanged: (String? newValue) async {
                      if (newValue != null && newValue != company.purchaseScheme) {
                        try {
                          await _authService.updatePurchaseScheme(company.companyId, newValue);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('@name ની સ્કીમ બદલીને @scheme કરાઈ છે.'.trParams({
                                'name': company.companyName,
                                'scheme': newValue == 'online' ? 'ઓનલાઇન'.tr : 'ઓફલાઇન'.tr,
                              }))),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('સ્કીમ બદલવામાં ભૂલ આવી: \$e'.tr.replaceAll(r'$e', e.toString()))),
                            );
                          }
                        }
                      }
                    },
                    items: [
                      DropdownMenuItem(
                        value: 'offline',
                        child: Text('ઓફલાઇન (Offline)'.tr),
                      ),
                      DropdownMenuItem(
                        value: 'online',
                        child: Text('ઓનલાઇન (Online)'.tr),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Action Buttons
          Row(
            children: [
              // Toggle Status
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _toggleCompanyStatus(company),
                  icon: Icon(
                    company.isActive ? Icons.block : Icons.check_circle_outline,
                    size: 16,
                    color: Colors.white,
                  ),
                  label: Text(
                    company.isActive ? 'નિષ્ક્રિય કરો'.tr : 'સક્રિય કરો'.tr,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: company.isActive ? Colors.orange.shade800 : Colors.teal.shade800,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Extend Subscription
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _extendSubscription(company),
                  icon: const Icon(Icons.add_moderator, size: 16, color: Colors.white),
                  label: Text(
                    'સબ્સ્ક્રિપ્શન વધારો'.tr,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Reset Password
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _resetAdminPassword(company),
                  icon: const Icon(Icons.vpn_key_outlined, size: 16, color: Colors.white),
                  label: Text(
                    'પાસવર્ડ રીસેટ'.tr,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey.shade800,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon, ThemeData theme, {Color? valueColor}) {
    final isLight = theme.brightness == Brightness.light;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.secondary),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 13,
              color: isLight ? Colors.black54 : Colors.white.withOpacity(0.6),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13, 
                fontWeight: FontWeight.w600,
                color: valueColor ?? (isLight ? Colors.black87 : Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
