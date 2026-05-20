import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// Service de generation de recu PDF OZELSERVICES.
/// Utilise le package `pdf` + `printing` pour afficher et telecharger.
class ReceiptService {
  /// Genere et affiche un recu PDF apres paiement.
  static Future<void> generateAndShowReceipt({
    required String numeroCommande,
    required String typeService,
    required String nomClient,
    required String dateCommande,
    required List<Map<String, dynamic>> lignes,
    required double total,
    required String modePaiement,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // ── Header OZELSERVICES ──────────────────────────────────────
              pw.Container(
                width: double.infinity,
                color: PdfColor.fromHex('#FF6B35'),
                padding: const pw.EdgeInsets.all(20),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'OZELSERVICES BENIN',
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 20,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          'Tous les services du quotidien en 1 clic',
                          style: const pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    pw.Text(
                      'RECU DE PAIEMENT',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 24),

              // ── Infos commande ───────────────────────────────────────────
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'N° Commande : $numeroCommande',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text('Service : $typeService'),
                      pw.Text('Client : $nomClient'),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Date : $dateCommande'),
                      pw.SizedBox(height: 4),
                      pw.Text('Mode : $modePaiement'),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 10),

              // ── Tableau lignes ───────────────────────────────────────────
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                columnWidths: {
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FlexColumnWidth(1),
                },
                children: [
                  // Header tableau
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                        color: PdfColors.grey200),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Description',
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Montant',
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold),
                          textAlign: pw.TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  // Lignes
                  ...lignes.map(
                    (ligne) => pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                              ligne['description'] as String? ?? ''),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            '${ligne['montant']} FCFA',
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 12),

              // ── Total ────────────────────────────────────────────────────
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(14),
                  color: PdfColor.fromHex('#FFF3EE'),
                  child: pw.Text(
                    'TOTAL : ${total.toStringAsFixed(0)} FCFA',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromHex('#FF6B35'),
                    ),
                  ),
                ),
              ),
              pw.SizedBox(height: 32),

              // ── Footer ───────────────────────────────────────────────────
              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 8),
              pw.Center(
                child: pw.Text(
                  'Merci de votre confiance — OZELSERVICES BENIN\n'
                  'www.ozelservices.bj | +229 XX XX XX XX',
                  textAlign: pw.TextAlign.center,
                  style: const pw.TextStyle(
                    color: PdfColors.grey,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    // Afficher le PDF (previsualisation + telechargement)
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Recu_OZELSERVICES_$numeroCommande.pdf',
    );
  }
}
