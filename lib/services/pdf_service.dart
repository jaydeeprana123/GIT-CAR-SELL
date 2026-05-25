import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import '../models/car_report.dart';

class PdfService {
  static Future<File> generateReportPdf(CarReport report, {String? quotationPrice}) async {
    final pdf = pw.Document();

    // Load custom Mukta Vaani font for proper Gujarati unicode rendering in PDF
    pw.Font? regularFont;
    pw.Font? boldFont;
    try {
      final regularFontData = await rootBundle.load('assets/fonts/MuktaVaani-Regular.ttf');
      final boldFontData = await rootBundle.load('assets/fonts/MuktaVaani-Bold.ttf');
      regularFont = pw.Font.ttf(regularFontData);
      boldFont = pw.Font.ttf(boldFontData);
    } catch (e) {
      // Fallback if loading fails
    }

    final pw.ThemeData theme = pw.ThemeData.withFont(
      base: regularFont ?? pw.Font.helvetica(),
      bold: boldFont ?? pw.Font.helveticaBold(),
    );

    // Helper to build inspection detail row
    pw.Widget buildDetailRow(String label, String value) {
      return pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 4),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.SizedBox(
              width: 120,
              child: pw.Text(
                label,
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9, color: PdfColors.blueGrey800),
              ),
            ),
            pw.Text(':  ', style: const pw.TextStyle(fontSize: 9)),
            pw.Expanded(
              child: pw.Text(
                value.isEmpty ? 'N/A' : value,
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.black),
              ),
            ),
          ],
        ),
      );
    }

    // Helper to build grid layout out of list of items
    List<pw.Widget> buildGridRows(List<pw.Widget> items) {
      final List<pw.Widget> rows = [];
      for (var i = 0; i < items.length; i += 2) {
        final List<pw.Widget> rowChildren = [];
        rowChildren.add(pw.Expanded(child: items[i]));
        if (i + 1 < items.length) {
          rowChildren.add(pw.Expanded(child: items[i + 1]));
        } else {
          rowChildren.add(pw.Expanded(child: pw.SizedBox()));
        }
        rows.add(
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 2),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: rowChildren,
            ),
          ),
        );
      }
      return rows;
    }

    // Helper to group section title
    pw.Widget buildSectionHeader(String title) {
      return pw.Container(
        width: double.infinity,
        margin: const pw.EdgeInsets.only(top: 12, bottom: 6),
        padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: const pw.BoxDecoration(
          color: PdfColors.blueGrey100,
          borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
        ),
        child: pw.Text(
          title,
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, color: PdfColors.blueGrey900),
        ),
      );
    }

    // Build lists of images (Larger design for visual excellence)
    final List<pw.Widget> imageWidgets = [];
    for (final image in report.images) {
      final file = File(image.imagePath);
      if (await file.exists()) {
        try {
          final bytes = await file.readAsBytes();
          final pdfImage = pw.MemoryImage(bytes);
          imageWidgets.add(
            pw.Container(
              margin: const pw.EdgeInsets.all(4),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.blueGrey200, width: 1.5),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
              ),
              width: 245,
              height: 200,
              child: pw.Column(
                children: [
                  pw.Expanded(
                    child: pw.Image(pdfImage, fit: pw.BoxFit.cover),
                  ),
                  pw.Container(
                    width: double.infinity,
                    color: PdfColors.blueGrey50,
                    padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                    child: pw.Text(
                      image.label,
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 10,
                        color: PdfColors.blueGrey800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        } catch (e) {
          // Skip corrupt image
        }
      }
    }

    pdf.addPage(
      pw.MultiPage(
        theme: theme,
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Premium Business Header
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: const pw.BoxDecoration(
                color: PdfColors.blueGrey900,
                borderRadius: pw.BorderRadius.all(pw.Radius.circular(6)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      // Left: Owner
                      pw.Text(
                        'SAMIR RATHOD',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                      ),
                      // Center: Anwar Motors Business Name
                      pw.Text(
                        'અનવર મોટર્સ',
                        style: pw.TextStyle(
                          fontSize: 22,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.amber300,
                        ),
                      ),
                      // Right Column: Mobile Numbers
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text(
                            'M: 7984684350',
                            style: pw.TextStyle(
                              fontSize: 8,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.white,
                            ),
                          ),
                          pw.Text(
                            'M: 9558535734',
                            style: pw.TextStyle(
                              fontSize: 8,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 6),
                  pw.Divider(color: PdfColors.blueGrey700, thickness: 0.5),
                  pw.SizedBox(height: 4),
                  // Tagline
                  pw.Text(
                    'દરેક પ્રકારના ટુ અને ફોર વ્હીલર કમિશન પર લેનાર અને વેચનાર',
                    style: pw.TextStyle(
                      fontSize: 8.5,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                  pw.SizedBox(height: 2),
                  // Address
                  pw.Text(
                    'પંચવટી કેનાલ, રીફાઈનરી રોડ, ગોરવા - વડોદરા.',
                    style: pw.TextStyle(
                      fontSize: 7.5,
                      color: PdfColors.blueGrey200,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 12),

            // Report Details Row
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'ગાડીનું ઇન્સ્પેક્શન રિપોર્ટ (CAR INSPECTION REPORT)',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blueGrey800,
                      ),
                    ),
                    pw.Text(
                      'તારીખ: ${report.createdAt}',
                      style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                    ),
                  ],
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(vertical: 3, horizontal: 6),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.green50,
                    border: pw.Border.all(color: PdfColors.green600, width: 0.8),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
                  ),
                  child: pw.Text(
                    'વેરિફાઇડ (VERIFIED)',
                    style: pw.TextStyle(
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.green700,
                    ),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 6),
            pw.Divider(thickness: 1, color: PdfColors.blueGrey100, height: 1),
            pw.SizedBox(height: 10),

            // Basic Information
            buildSectionHeader('1. BASIC INFORMATION (બેઝિક માહિતી)'),
            ...buildGridRows([
              buildDetailRow('Model (મોડેલ)', report.model),
              buildDetailRow('Owner (ઓનર)', report.owner),
              buildDetailRow('Kilometers (કિલોમીટર)', report.kilometers),
              buildDetailRow('Insurance (વીમો)', report.vimo),
              if (quotationPrice != null && quotationPrice.isNotEmpty)
                buildDetailRow('Quotation Price (કિંમત)', 'Rs. $quotationPrice'),
            ]),

            // Exterior / Body Check
            buildSectionHeader('2. EXTERIOR & BODY CHECK (બોડી અને બહારનો ભાગ)'),
            ...buildGridRows([
              buildDetailRow('Body Pillar 1 (થાંભલી ૧)', report.bodyDent1),
              buildDetailRow('Body Pillar 2 (થાંભલી ૨)', report.bodyDent2),
              buildDetailRow('Body Pillar 3 (થાંભલી ૩)', report.bodyDent3),
              buildDetailRow('Body Pillar 4 (થાંભલી ૪)', report.bodyDent4),
              buildDetailRow('Dickey / Boot (ડેકી)', report.dickey),
              buildDetailRow('Door 1 (૧ દરવાજો)', report.door1),
              buildDetailRow('Door 2 (૨ દરવાજો)', report.door2),
              buildDetailRow('Door 3 (૩ દરવાજો)', report.door3),
              buildDetailRow('Door 4 (૪ દરવાજો)', report.door4),
              buildDetailRow('Glass 1 (૧ કાચ)', report.glass1),
              buildDetailRow('Glass 2 (૨ કાચ)', report.glass2),
              buildDetailRow('Glass 3 (૩ કાચ)', report.glass3),
              buildDetailRow('Glass 4 (૪ કાચ)', report.glass4),
              buildDetailRow('Fender Driver (ફેન્ડર ૧)', report.fenderDriver),
              buildDetailRow('Fender Passenger (ફેન્ડર ૨)', report.fenderPassenger),
              buildDetailRow('Bonnet Inside (બોનેટ અંદર)', report.bonnetInside),
              buildDetailRow('Bonnet Outside (બોનેટ ઉપર)', report.bonnetOutside),
              buildDetailRow('Touchup (કેટલો ટચઅપ)', report.touchup),
            ]),

            // Engine & Mechanical
            buildSectionHeader('3. ENGINE & MECHANICAL (મિકેનિકલ અને એન્જિન)'),
            ...buildGridRows([
              buildDetailRow('Engine Line (એન્જિન લાઇન)', report.engineLine),
              buildDetailRow('Engine Oil Check (ઓઇલ ચેક)', report.engineOilCheck),
              buildDetailRow('Engine Smoke (ધુમાડો)', report.engineSmoke),
              buildDetailRow('Engine Noise (અવાજ)', report.engineNoise),
              buildDetailRow('Starting Car (ચાલુ કરવામા)', report.startingCondition),
            ]),

            // Driving & Cabin
            buildSectionHeader('4. DRIVING & CABIN (ડ્રાઇવિંગ અને કેબિન)'),
            ...buildGridRows([
              buildDetailRow('Car Driving (ગાડી ચાલવામાં)', report.drivingCondition),
              buildDetailRow('Suspension (સસ્પેન્સ)', report.suspension),
              buildDetailRow('Pickup (પીકઅપ)', report.pickup),
              buildDetailRow('Brake (બ્રેક)', report.brake),
              buildDetailRow('Gear (ગેર)', report.gear),
              buildDetailRow('AC (એસી)', report.ac),
              buildDetailRow('Interior (ઇન્ટિરિયર)', report.interior),
            ]),

            // Attached Photos Section
            if (imageWidgets.isNotEmpty) ...[
              buildSectionHeader('5. ATTACHED PHOTOS (ફોટા)'),
              pw.Wrap(
                spacing: 10,
                runSpacing: 10,
                children: imageWidgets,
              ),
            ],
          ];
        },
      ),
    );

    // Save the PDF file to temporary storage
    final output = await getTemporaryDirectory();
    final fileName = 'Car_Report_${report.model.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File('${output.path}/$fileName');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  // Share generated PDF and labeled image files using share_plus
  static Future<void> shareReport(CarReport report, {required String shareMode, String? quotationPrice}) async {
    // Prepare image files if needed
    final List<XFile> imagesList = [];
    if (shareMode == 'mixed' || shareMode == 'sequential' || shareMode == 'photos_only') {
      final tempDir = await getTemporaryDirectory();
      for (int i = 0; i < report.images.length; i++) {
        final img = report.images[i];
        final originalFile = File(img.imagePath);
        if (await originalFile.exists()) {
          try {
            final extension = originalFile.path.split('.').last;
            // Generate generic names (e.g. image_1.jpg) to avoid exposing the custom photo label/name
            final finalFileName = 'image_${i + 1}.$extension';
            final tempImagePath = '${tempDir.path}/$finalFileName';
            
            final tempFile = await originalFile.copy(tempImagePath);
            imagesList.add(XFile(tempFile.path, name: finalFileName));
          } catch (e) {
            // Fallback to sharing the original file if copy fails
            final extension = originalFile.path.split('.').last;
            imagesList.add(XFile(img.imagePath, name: 'image_${i + 1}.$extension'));
          }
        }
      }
    }

    if (shareMode == 'photos_only') {
      if (imagesList.isNotEmpty) {
        await SharePlus.instance.share(
          ShareParams(
            files: imagesList,
            text: 'Photos of ${report.model}',
          ),
        );
      }
      return;
    }

    final pdfFile = await generateReportPdf(report, quotationPrice: quotationPrice);
    final pdfXFile = XFile(
      pdfFile.path,
      name: 'Car_Report_${report.model.replaceAll(' ', '_')}.pdf',
    );

    if (shareMode == 'sequential') {
      // 1. Share PDF first
      await SharePlus.instance.share(
        ShareParams(
          files: [pdfXFile],
          text: 'Inspection Report for ${report.model} - Owner: ${report.owner}',
          subject: 'Car Inspection Report: ${report.model}',
        ),
      );
      // 2. Share images second (after the first share intent completes or is dismissed)
      if (imagesList.isNotEmpty) {
        await Future.delayed(const Duration(milliseconds: 600));
        await SharePlus.instance.share(
          ShareParams(
            files: imagesList,
            text: 'Photos of ${report.model}',
          ),
        );
      }
    } else if (shareMode == 'mixed') {
      // Share PDF and images together in a single intent (ideal for Email)
      final List<XFile> allFiles = [pdfXFile, ...imagesList];
      await SharePlus.instance.share(
        ShareParams(
          files: allFiles,
          text: 'Inspection Report for ${report.model} - Owner: ${report.owner}',
          subject: 'Car Inspection Report: ${report.model}',
        ),
      );
    } else {
      // Share PDF only
      await SharePlus.instance.share(
        ShareParams(
          files: [pdfXFile],
          text: 'Inspection Report for ${report.model} - Owner: ${report.owner}',
          subject: 'Car Inspection Report: ${report.model}',
        ),
      );
    }
  }
}
