import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/car_report_controller.dart';
import '../models/car_report.dart';
import '../services/pdf_service.dart';
import 'report_form_page.dart';

class ReportDetailsPage extends StatefulWidget {
  final int reportId;

  const ReportDetailsPage({super.key, required this.reportId});

  @override
  State<ReportDetailsPage> createState() => _ReportDetailsPageState();
}

class _ReportDetailsPageState extends State<ReportDetailsPage> {
  CarReport? _report;
  bool _isLoading = true;
  bool _isSharing = false;

  @override
  void initState() {
    super.initState();
    _loadReportDetails();
  }

  Future<void> _loadReportDetails() async {
    setState(() => _isLoading = true);
    try {
      final controller = Get.find<CarReportController>();
      final report = await controller.getReportDetails(widget.reportId);
      setState(() {
        _report = report;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('વિગતો લોડ કરવામાં ભૂલ થઈ: $e')),
      );
    }
  }

  Future<void> _editReport() async {
    if (_report == null) return;
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ReportFormPage(report: _report),
      ),
    );
    if (updated == true) {
      _loadReportDetails();
    }
  }

  Future<String?> _showQuotationPriceDialog() async {
    final TextEditingController priceController = TextEditingController();
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: const Text('ઓફર કિંમત (Quotation Price)'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('જો તમે પીડીએફ રીપોર્ટમાં કિંમત ઉમેરવા માંગો છો, તો અહીં લખો (નહીંતર ખાલી છોડો):'),
              const SizedBox(height: 12),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'કિંમત (દા.ત. 4,50,000)',
                  prefixText: '₹ ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, ''),
              child: const Text('કિંમત વગર મોકલો (Skip)', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, priceController.text.trim()),
              style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.primary),
              child: const Text('ઓકે (OK)', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _sharePdfReport() async {
    if (_report == null) return;

    // Prompt user for quotation price (not saved to database)
    final quotationPrice = await _showQuotationPriceDialog() ?? '';

    bool showWhatsappSteps = false;
    bool step1Completed = false;
    bool step2Completed = false;
    bool isModalSharing = false;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final theme = Theme.of(context);

            if (showWhatsappSteps) {
              return Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Pull Bar
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: theme.dividerColor.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Text(
                      'વોટ્સએપ શેરિંગ (૨-પગલાં)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'વોટ્સએપની મર્યાદાના કારણે PDF અને ફોટા અલગ-અલગ મોકલવા પડશે.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    // Step 1 Card
                    Card(
                      elevation: 0,
                      color: theme.colorScheme.surfaceVariant.withOpacity(0.15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: step1Completed ? Colors.green : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: step1Completed ? Colors.green : theme.colorScheme.primary.withOpacity(0.1),
                          child: Icon(
                            step1Completed ? Icons.check : Icons.looks_one,
                            color: step1Completed ? Colors.white : theme.colorScheme.primary,
                          ),
                        ),
                        title: const Text(
                          'પગલું ૧: PDF રિપોર્ટ મોકલો',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        trailing: isModalSharing
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : ElevatedButton(
                                onPressed: () async {
                                  setModalState(() => isModalSharing = true);
                                  try {
                                    await PdfService.shareReport(_report!, shareMode: 'pdf_only', quotationPrice: quotationPrice);
                                    setModalState(() {
                                      step1Completed = true;
                                    });
                                  } catch (e) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('શેર કરવામાં નિષ્ફળતા: $e')),
                                      );
                                    }
                                  } finally {
                                    setModalState(() => isModalSharing = false);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: step1Completed ? Colors.grey : Colors.green,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: Text(step1Completed ? 'ફરી મોકલો' : 'મોકલો'),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Step 2 Card
                    Card(
                      elevation: 0,
                      color: theme.colorScheme.surfaceVariant.withOpacity(0.15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: step2Completed ? Colors.green : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: step2Completed ? Colors.green : theme.colorScheme.primary.withOpacity(0.1),
                          child: Icon(
                            step2Completed ? Icons.check : Icons.looks_two,
                            color: step2Completed ? Colors.white : theme.colorScheme.primary,
                          ),
                        ),
                        title: Text(
                          'પગલું ૨: ગાડીના ફોટા મોકલો'.tr,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        trailing: isModalSharing
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : ElevatedButton(
                                onPressed: !step1Completed
                                    ? null
                                    : () async {
                                        setModalState(() => isModalSharing = true);
                                        try {
                                          await PdfService.shareReport(_report!, shareMode: 'photos_only');
                                          setModalState(() {
                                            step2Completed = true;
                                          });
                                        } catch (e) {
                                          if (mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('${'શેર કરવામાં નિષ્ફળતા:'.tr} $e')),
                                            );
                                          }
                                        } finally {
                                          setModalState(() => isModalSharing = false);
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: step2Completed ? Colors.grey : Colors.green,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: Text(step2Completed ? 'ફરી મોકલો'.tr : 'મોકલો'.tr),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text('પૂર્ણ (Done)'.tr),
                      ),
                    ),
                  ],
                ),
              );
            }

            return Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Pull Bar
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: theme.dividerColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Text(
                    'રિપોર્ટ શેર કરો'.tr,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'શેર કરવાની રીત પસંદ કરો'.tr,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  // Option 1: WhatsApp (Sequential: PDF + Images)
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.chat, color: Colors.green),
                    ),
                    title: Text(
                      'વોટ્સએપ પર મોકલો (PDF અને ફોટા)'.tr,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('પીડીએફ રીપોર્ટ અને ગાડીના ફોટા બંને મોકલાશે.'.tr),
                    onTap: () {
                      if (_report!.images.isEmpty) {
                        Navigator.pop(context);
                        _sharePdfDirectly('pdf_only', quotationPrice: quotationPrice);
                      } else {
                        setModalState(() {
                          showWhatsappSteps = true;
                        });
                      }
                    },
                  ),
                  const Divider(),
                  // Option 2: Email (Mixed: PDF + Images together)
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.email, color: Colors.blue),
                    ),
                    title: Text(
                      'ઇમેઇલ પર મોકલો (PDF + ફોટા એકસાથે)'.tr,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('ઇમેઇલમાં પીડીએફ અને ફોટા એક સાથે અટેચ થશે.'.tr),
                    onTap: () {
                      Navigator.pop(context);
                      _sharePdfDirectly('mixed', quotationPrice: quotationPrice);
                    },
                  ),
                  const Divider(),
                  // Option 3: PDF Only
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
                    ),
                    title: Text(
                      'ફક્ત PDF રીપોર્ટ મોકલો'.tr,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('માત્ર પીડીએફ રીપોર્ટ જ મોકલાશે.'.tr),
                    onTap: () {
                      Navigator.pop(context);
                      _sharePdfDirectly('pdf_only', quotationPrice: quotationPrice);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _sharePdfDirectly(String shareMode, {String? quotationPrice}) async {
    setState(() => _isSharing = true);
    try {
      await PdfService.shareReport(_report!, shareMode: shareMode, quotationPrice: quotationPrice);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${'PDF શેર કરવામાં નિષ્ફળતા:'.tr} $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  Future<void> _deleteReport() async {
    if (_report == null) return;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('ડિલીટ કરો?'.tr),
        content: Text('શું તમે ખરેખર આ રિપોર્ટ કાઢી નાખવા માંગો છો?'.tr),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('ના'.tr, style: const TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: Text('હા, ડિલીટ'.tr, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final controller = Get.find<CarReportController>();
      final success = await controller.deleteReportData(_report!.id!);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('રિપોર્ટ ડિલીટ કરાયો છે'.tr)),
        );
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_report == null) {
      return Scaffold(
        appBar: AppBar(title: Text('રિપોર્ટ વિગતો'.tr)),
        body: Center(child: Text('રિપોર્ટ મળ્યો નથી'.tr)),
      );
    }

    final report = _report!;

    return Scaffold(
      appBar: AppBar(
        title: Text(report.model),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: _editReport,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _deleteReport,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Car Header Card
                _buildHeaderCard(report),
                const SizedBox(height: 16),

                // Owner Info Card (Internal details - not in PDF)
                _buildOwnerInfoCard(report),
                const SizedBox(height: 16),

                // Attached Images slider
                if (report.images.isNotEmpty) ...[
                  Text(
                    'અટેચ કરેલ ફોટા'.tr,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildImageSlider(report.images),
                  const SizedBox(height: 20),
                ],

                // Checklists
                _buildCategorySection(
                  title: '૧. બોડી અને બહારનો ભાગ (Exterior Check)'.tr,
                  icon: Icons.directions_car,
                  items: [
                    _buildDetailRow('૧ થાંભલી (Pillar 1)'.tr, report.bodyDent1),
                    _buildDetailRow('૨ થાંભલી (Pillar 2)'.tr, report.bodyDent2),
                    _buildDetailRow('૩ થાંભલી (Pillar 3)'.tr, report.bodyDent3),
                    _buildDetailRow('૪ થાંભલી (Pillar 4)'.tr, report.bodyDent4),
                    _buildDetailRow('ડેકી (Dickey)'.tr, report.dickey),
                    _buildDetailRow('૧ દરવાજો (Door 1)'.tr, report.door1),
                    _buildDetailRow('૨ દરવાજો (Door 2)'.tr, report.door2),
                    _buildDetailRow('૩ દરવાજો (Door 3)'.tr, report.door3),
                    _buildDetailRow('૪ દરવાજો (Door 4)'.tr, report.door4),
                    _buildDetailRow('કાચ ૧ (Glass 1)'.tr, report.glass1),
                    _buildDetailRow('કાચ ૨ (Glass 2)'.tr, report.glass2),
                    _buildDetailRow('કાચ ૩ (Glass 3)'.tr, report.glass3),
                    _buildDetailRow('કાચ ૪ (Glass 4)'.tr, report.glass4),
                    _buildDetailRow('ફેન્ડર ૧ ડ્રાઇવ (Fender Driver)'.tr, report.fenderDriver),
                    _buildDetailRow('ફેન્ડર ૨ ખાલી (Fender Passenger)'.tr, report.fenderPassenger),
                    _buildDetailRow('બોનેટ ૧ અંદરથી (Bonnet Inside)'.tr, report.bonnetInside),
                    _buildDetailRow('બોનેટ ૨ ઉપરથી (Bonnet Outside)'.tr, report.bonnetOutside),
                    _buildDetailRow('ગાડીમાં ટચઅપ'.tr, report.touchup.isEmpty ? 'નથી'.tr : report.touchup),
                  ],
                ),
                const SizedBox(height: 16),

                _buildCategorySection(
                  title: '૨. મિકેનિકલ અને એન્જિન (Engine Check)'.tr,
                  icon: Icons.construction,
                  items: [
                    _buildDetailRow('એન્જિન લાઇન (Engine Line)'.tr, report.engineLine.isEmpty ? 'N/A' : report.engineLine),
                    _buildDetailRow('એન્જિન ઓઇલ ચેક (Oil Check)'.tr, report.engineOilCheck),
                    _buildDetailRow('એન્જિન ધુમાડો (Engine Smoke)'.tr, report.engineSmoke),
                    _buildDetailRow('એન્જિન અવાજ (Engine Noise)'.tr, report.engineNoise),
                    _buildDetailRow('ગાડી ચાલુ કરવામાં (Starting)'.tr, report.startingCondition),
                  ],
                ),
                const SizedBox(height: 16),

                _buildCategorySection(
                  title: '૩. ડ્રાઇવિંગ અને કેબિન (Cabin & Driving)'.tr,
                  icon: Icons.alt_route,
                  items: [
                    _buildDetailRow('AC (એસી)'.tr, report.ac),
                    _buildDetailRow('ઇન્ટિરિયર (Interior)'.tr, report.interior),
                    _buildDetailRow('ચાલવામાં (Driving)'.tr, report.drivingCondition.isEmpty ? 'N/A' : report.drivingCondition),
                    _buildDetailRow('સસ્પેન્સ (Suspension)'.tr, report.suspension),
                    _buildDetailRow('પીકઅપ (Pickup)'.tr, report.pickup),
                    _buildDetailRow('બ્રેક (Brake)'.tr, report.brake),
                    _buildDetailRow('ગેર (Gear)'.tr, report.gear),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),

          // Bottom Action Panel
          _buildBottomActionPanel(),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(CarReport report) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary.withOpacity(0.85), theme.colorScheme.secondary.withOpacity(0.85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                report.model,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  report.createdAt.split(' ').first,
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Colors.white24),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildHeaderMetric(Icons.person, 'ઓનર'.tr, report.owner),
              _buildHeaderMetric(Icons.speed, 'કિલોમીટર'.tr, '${report.kilometers} km'),
              _buildHeaderMetric(Icons.security, 'વીમો (Vimo)'.tr, report.vimo),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOwnerInfoCard(CarReport report) {
    final theme = Theme.of(context);
    final name = report.ownerName.isEmpty ? 'નથી ભરેલ'.tr : report.ownerName;
    final mobile = report.ownerMobile.isEmpty ? 'નથી ભરેલ'.tr : report.ownerMobile;

    return Card(
      color: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'માલિકની માહિતી (આંતરિક માહિતી)'.tr,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'માલિકનું નામ:'.tr,
                  style: TextStyle(color: theme.hintColor, fontSize: 14),
                ),
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'મોબાઈલ નંબર:'.tr,
                  style: TextStyle(color: theme.hintColor, fontSize: 14),
                ),
                GestureDetector(
                  onTap: report.ownerMobile.isEmpty
                      ? null
                      : () {
                          Clipboard.setData(ClipboardData(text: report.ownerMobile));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('મોબાઈલ નંબર ક્લિપબોર્ડ પર કોપી કર્યો છે'.tr)),
                          );
                        },
                  child: Row(
                    children: [
                      Text(
                        mobile,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: report.ownerMobile.isEmpty ? theme.hintColor : theme.colorScheme.primary,
                          decoration: report.ownerMobile.isEmpty ? null : TextDecoration.underline,
                        ),
                      ),
                      if (report.ownerMobile.isNotEmpty) ...[
                        const SizedBox(width: 4),
                        Icon(Icons.copy, size: 14, color: theme.colorScheme.primary),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderMetric(IconData icon, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.white70),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value.isEmpty ? 'N/A' : value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildImageSlider(List<ReportImage> images) {
    return SizedBox(
      height: 130,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        itemBuilder: (context, index) {
          final img = images[index];
          return GestureDetector(
            onTap: () => _viewFullPhoto(img),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              width: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(
                      File(img.imagePath),
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        color: Colors.black54,
                        child: Text(
                          img.label,
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _viewFullPhoto(ReportImage image) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              backgroundColor: Colors.black87,
              title: Text(image.label, style: const TextStyle(color: Colors.white)),
              leading: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            InteractiveViewer(
              child: Image.file(
                File(image.imagePath),
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection({
    required String title,
    required IconData icon,
    required List<Widget> items,
  }) {
    final theme = Theme.of(context);
    return Card(
      color: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 2,
      child: ExpansionTile(
        initiallyExpanded: true,
        leading: Icon(icon, color: theme.colorScheme.primary),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Column(
              children: items,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    final theme = Theme.of(context);
    final isNegative = value == 'ખરાબ' || value.contains('ખરાબ') || value.contains('તૂટેલા') || value.contains('કાળો') || value.contains('સફેદ');
    final isPositive = value == 'ઓકે' || value == 'ચાલુ' || value == 'સાફ' || value == 'બરાબર' || value == 'નથી' || value.startsWith('ઓકે') || value.startsWith('સ્મૂથ');

    Color statusColor = theme.textTheme.bodyMedium?.color ?? Colors.black;
    if (isNegative) statusColor = Colors.redAccent;
    if (isPositive) statusColor = Colors.green;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: theme.hintColor, fontSize: 14),
          ),
          Text(
            value.isEmpty ? 'N/A' : value.tr,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionPanel() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: theme.dividerColor.withOpacity(0.1))),
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _isSharing ? null : _sharePdfReport,
              icon: _isSharing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.share, color: Colors.white),
              label: Text(
                _isSharing ? 'રિપોર્ટ બને છે...'.tr : 'વોટ્સએપ / ઈમેલ પર મોકલો (PDF)'.tr,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
