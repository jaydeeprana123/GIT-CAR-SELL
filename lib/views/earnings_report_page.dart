import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../controllers/car_report_controller.dart';
import '../models/car_report.dart';

class EarningsReportPage extends StatefulWidget {
  const EarningsReportPage({super.key});

  @override
  State<EarningsReportPage> createState() => _EarningsReportPageState();
}

class _EarningsReportPageState extends State<EarningsReportPage> {
  final _reportController = Get.find<CarReportController>();
  String _filterType = 'month'; // 'today', 'week', 'month', 'custom'
  
  DateTimeRange? _customDateRange;
  
  @override
  void initState() {
    super.initState();
    // Refresh reports on init
    _reportController.fetchReports();
  }

  // Filter sold reports list based on active filter
  List<CarReport> _getFilteredReports() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    return _reportController.soldReports.where((report) {
      if (report.soldDate == null) return false;
      final soldDate = DateTime.tryParse(report.soldDate!);
      if (soldDate == null) return false;

      switch (_filterType) {
        case 'today':
          return soldDate.year == now.year &&
              soldDate.month == now.month &&
              soldDate.day == now.day;
        case 'week':
          // Start of current week (assuming Monday is start)
          final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
          return soldDate.isAfter(startOfWeek.subtract(const Duration(seconds: 1)));
        case 'month':
          return soldDate.year == now.year && soldDate.month == now.month;
        case 'custom':
          if (_customDateRange == null) return true;
          // Inclusive range checks
          final start = DateTime(_customDateRange!.start.year, _customDateRange!.start.month, _customDateRange!.start.day);
          final end = DateTime(_customDateRange!.end.year, _customDateRange!.end.month, _customDateRange!.end.day, 23, 59, 59);
          return soldDate.isAfter(start.subtract(const Duration(seconds: 1))) && 
                 soldDate.isBefore(end.add(const Duration(seconds: 1)));
        default:
          return true;
      }
    }).toList();
  }

  // Calculations
  Map<String, dynamic> _calculateMetrics(List<CarReport> filtered) {
    int totalCars = filtered.length;
    double totalAmount = 0;

    for (var report in filtered) {
      if (report.soldPrice != null) {
        // Strip out non-numeric characters like commas and parse safely
        final digitsOnly = report.soldPrice!.replaceAll(RegExp(r'[^0-9]'), '');
        final price = double.tryParse(digitsOnly) ?? 0.0;
        totalAmount += price;
      }
    }

    return {
      'totalCars': totalCars,
      'totalAmount': totalAmount,
      'totalProfit': totalAmount, // Profit = sold amount since cost is 0
    };
  }

  // Format currency
  String _formatCurrency(double amount) {
    final format = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    return format.format(amount);
  }

  // Select custom date range
  Future<void> _selectCustomDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: _customDateRange ?? DateTimeRange(
        start: DateTime.now().subtract(const Duration(days: 7)),
        end: DateTime.now(),
      ),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      confirmText: 'પસંદ કરો'.tr,
      saveText: 'સાચવો'.tr,
      helpText: 'તારીખગાળો પસંદ કરો'.tr,
    );

    if (picked != null) {
      setState(() {
        _filterType = 'custom';
        _customDateRange = picked;
      });
    }
  }

  // Export reports to CSV
  Future<void> _exportToCsv() async {
    final filtered = _getFilteredReports();
    if (filtered.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('નિકાસ કરવા માટે કોઈ વેચાણ રેકોર્ડ ઉપલબ્ધ નથી.'.tr)),
      );
      return;
    }

    try {
      StringBuffer sb = StringBuffer();
      // Write headers
      sb.writeln('Model (મોડેલ),Owner (ઓનર),Kilometers (કિલોમીટર),Sold Price (વેચાણ કિંમત),Sold Date (વેચાણ તારીખ),Customer Name (ગ્રાહકનું નામ),Customer Mobile (ગ્રાહકનો મોબાઇલ),Customer Address (સરનામું),Remarks (નોંધ)'.tr);
      
      for (var r in filtered) {
        final model = r.model.replaceAll('"', '""');
        final owner = r.owner.replaceAll('"', '""');
        final kilometers = r.kilometers.replaceAll('"', '""');
        final soldPrice = (r.soldPrice ?? '0').replaceAll('"', '""');
        final soldDate = (r.soldDate ?? '').replaceAll('"', '""');
        final customerName = (r.customerName ?? '').replaceAll('"', '""');
        final customerMobile = (r.customerMobile ?? '').replaceAll('"', '""');
        final customerAddress = (r.customerAddress ?? '').replaceAll('"', '""');
        final remarks = (r.remarks ?? '').replaceAll('"', '""');
        
        sb.writeln('"$model","$owner","$kilometers","$soldPrice","$soldDate","$customerName","$customerMobile","$customerAddress","$remarks"');
      }

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/Sales_Report_${DateTime.now().millisecondsSinceEpoch}.csv');
      await file.writeAsString(sb.toString(), encoding: utf8);

      final xFile = XFile(file.path, name: 'sales_report.csv');
      
      await SharePlus.instance.share(
        ShareParams(
          files: [xFile],
          text: 'Car Sales Earnings Report - Motexa',
          subject: 'Sales Report CSV',
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${'CSV શેર કરવામાં નિષ્ફળતા:'.tr} $e'), backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = theme.brightness == Brightness.light
        ? theme.colorScheme.primary
        : (theme.colorScheme.secondary == const Color(0xFF0891B2) ? Colors.tealAccent : theme.colorScheme.primary);
    final filteredReports = _getFilteredReports();
    final metrics = _calculateMetrics(filteredReports);

    return Scaffold(
      appBar: AppBar(
        title: Text('કમાણીનો અહેવાલ'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded),
            tooltip: 'CSV નિકાસ કરો'.tr,
            onPressed: _exportToCsv,
          ),
        ],
      ),
      body: Column(
        children: [
          // Date Filter Bar
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            color: theme.cardColor.withOpacity(0.5),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('today', 'આજે (Today)'.tr),
                  const SizedBox(width: 8),
                  _buildFilterChip('week', 'આ અઠવાડિયે'.tr),
                  const SizedBox(width: 8),
                  _buildFilterChip('month', 'આ મહિને (Month)'.tr),
                  const SizedBox(width: 8),
                  _buildFilterChip('custom', 'તારીખ પસંદ કરો...'.tr),
                ],
              ),
            ),
          ),
          
          if (_filterType == 'custom' && _customDateRange != null)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              color: theme.colorScheme.primary.withOpacity(0.08),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${'તારીખગાળો:'.tr} ${DateFormat('dd-MM-yyyy').format(_customDateRange!.start)} ${'થી'.tr} ${DateFormat('dd-MM-yyyy').format(_customDateRange!.end)}",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                  ),
                  TextButton.icon(
                    onPressed: _selectCustomDateRange,
                    icon: const Icon(Icons.edit, size: 14),
                    label: Text('બદલો'.tr, style: const TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Metrics Summary Cards
                _buildMetricsDashboard(metrics, theme, accentColor),
                const SizedBox(height: 24),

                Text(
                  'વેચાણ યાદી (Filtered Sales List)'.tr,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
                ),
                const SizedBox(height: 12),

                if (filteredReports.isEmpty)
                  _buildEmptyState()
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredReports.length,
                    itemBuilder: (context, index) {
                      final report = filteredReports[index];
                      return _buildSalesItemTile(report, theme, accentColor);
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String type, String label) {
    final isSelected = _filterType == type;
    final theme = Theme.of(context);

    return FilterChip(
      selected: isSelected,
      label: Text(label),
      onSelected: (val) {
        if (type == 'custom') {
          _selectCustomDateRange();
        } else {
          setState(() {
            _filterType = type;
            _customDateRange = null;
          });
        }
      },
      selectedColor: theme.colorScheme.primary.withOpacity(0.2),
      checkmarkColor: theme.colorScheme.primary,
      labelStyle: TextStyle(
        fontSize: 12,
        color: isSelected ? theme.colorScheme.primary : theme.textTheme.bodyLarge?.color,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildMetricsDashboard(Map<String, dynamic> metrics, ThemeData theme, Color accentColor) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                label: 'વેચેલ ગાડીઓ'.tr,
                value: '${metrics['totalCars']}',
                icon: Icons.directions_car,
                color: theme.colorScheme.primary,
                theme: theme,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                label: 'કુલ વેચાણ રકમ'.tr,
                value: _formatCurrency(metrics['totalAmount']),
                icon: Icons.currency_rupee,
                color: theme.colorScheme.secondary,
                theme: theme,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildMetricCard(
          label: 'કુલ નફો / અંદાજિત કમાણી'.tr,
          value: _formatCurrency(metrics['totalProfit']),
          icon: Icons.trending_up,
          color: accentColor,
          theme: theme,
          isFullWidth: true,
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'નોંધ: ખરીદ કિંમત (Cost Price) ઉપલબ્ધ ન હોવાથી કમાણી વેચાણ કિંમત સમાન ગણવામાં આવેલ છે.'.tr,
            style: TextStyle(fontSize: 10, color: theme.hintColor, fontStyle: FontStyle.italic),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required ThemeData theme,
    bool isFullWidth = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.15), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: isFullWidth ? MainAxisAlignment.start : MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          if (isFullWidth) const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: isFullWidth ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 11, color: theme.hintColor, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesItemTile(CarReport report, ThemeData theme, Color accentColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report.model,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  "${'ગ્રાહક:'.tr} ${report.customerName ?? 'N/A'} | ${'તારીખ:'.tr} ${report.soldDate ?? ''}",
                  style: TextStyle(fontSize: 11, color: theme.hintColor),
                ),
              ],
            ),
          ),
          Text(
            _formatCurrency(double.tryParse((report.soldPrice ?? '0').replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0),
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: accentColor),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.query_stats, size: 50, color: Colors.grey.withOpacity(0.3)),
            const SizedBox(height: 12),
            Text(
              'પસંદ કરેલ તારીખગાળામાં કોઈ વેચાણ મળ્યું નથી'.tr,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
