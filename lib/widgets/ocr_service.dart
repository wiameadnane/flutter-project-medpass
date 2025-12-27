import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart'; // <--- INDISPENSABLE pour PdfColors
import 'package:pdf/widgets.dart' as pw;

class OCRService {
  late final TextRecognizer _textRecognizer;

  OCRService() {
    try {
      _textRecognizer = TextRecognizer();
    } catch (e) {
      debugPrint('OCRService: failed to create TextRecognizer: $e');
      rethrow;
    }
  }

  /// Extrait le texte d'une image via ML Kit
  Future<String> scanDocument(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) {
        throw Exception('Image file not found at path: $path');
      }

      final inputImage = InputImage.fromFilePath(path);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      // Debug logging to see what text is being recognized
      debugPrint('OCR Result: "${recognizedText.text}"');
      debugPrint('Text blocks: ${recognizedText.blocks.length}');

      // Log individual text blocks for debugging
      for (var i = 0; i < recognizedText.blocks.length; i++) {
        final block = recognizedText.blocks[i];
        debugPrint('Block $i: "${block.text}"');
        for (var j = 0; j < block.lines.length; j++) {
          final line = block.lines[j];
          debugPrint('  Line $j: "${line.text}"');
        }
      }

      return recognizedText.text;
    } catch (e, st) {
      debugPrint('OCRService.scanDocument failed: $e');
      debugPrint(st.toString());
      rethrow;
    }
  }

  /// Traduit le texte du Français vers l'Anglais
  Future<String> translateResult(String text) async {
    final translator = OnDeviceTranslator(
      sourceLanguage: TranslateLanguage.french,
      targetLanguage: TranslateLanguage.english,
    );
    final translation = await translator.translateText(text);
    await translator.close();
    return translation;
  }

  /// Génère un PDF contenant l'image, le texte original et la traduction
  Future<File> generateMedicalPdf(
    File imageFile,
    String originalText,
    String translatedText, {
    String sourceLanguage = 'Original',
    String targetLanguage = 'Translated',
  }) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final dateStr = '${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute.toString().padLeft(2, '0')}';
    final imageBytes = imageFile.readAsBytesSync();

    // Page 1: Image
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Med-Pass',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue800,
                      ),
                    ),
                    pw.Text(
                      'Medical Document Report',
                      style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
                    ),
                  ],
                ),
                pw.Text(dateStr, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey500)),
              ],
            ),
            pw.SizedBox(height: 8),
            pw.Divider(color: PdfColors.grey300),
            pw.SizedBox(height: 16),

            // Scanned Image
            pw.Text(
              'Scanned Document',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800),
            ),
            pw.SizedBox(height: 8),
            pw.Center(
              child: pw.Image(
                pw.MemoryImage(imageBytes),
                height: 300,
                fit: pw.BoxFit.contain,
              ),
            ),
            pw.SizedBox(height: 16),

            // Original Text (limited)
            pw.Text(
              'Original Text ($sourceLanguage)',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              originalText.length > 500 ? '${originalText.substring(0, 500)}...' : originalText,
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
            ),

            pw.Spacer(),
            pw.Divider(color: PdfColors.grey300),
            pw.Text(
              'Med-Pass - Your Medical Passport | Page 1',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
            ),
          ],
        ),
      ),
    );

    // Page 2: Full text and translation
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Original Text ($sourceLanguage)',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.orange800),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              originalText,
              style: const pw.TextStyle(fontSize: 10, lineSpacing: 1.4, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 20),

            if (translatedText.isNotEmpty && translatedText != 'No translation available') ...[
              pw.Text(
                'Translation ($targetLanguage)',
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                translatedText,
                style: const pw.TextStyle(fontSize: 10, lineSpacing: 1.4, color: PdfColors.grey800),
              ),
            ],

            pw.Spacer(),

            // Disclaimer
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              color: PdfColors.amber50,
              child: pw.Text(
                'Disclaimer: This document was generated by Med-Pass using AI-powered OCR and translation. '
                'Please verify important medical information with a healthcare professional.',
                style: const pw.TextStyle(fontSize: 8, color: PdfColors.amber900),
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Divider(color: PdfColors.grey300),
            pw.Text(
              'Med-Pass - Your Medical Passport | Page 2',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
            ),
          ],
        ),
      ),
    );

    // Save the file
    final output = await getApplicationDocumentsDirectory();
    final file = File(
      "${output.path}/medpass_scan_${DateTime.now().millisecondsSinceEpoch}.pdf",
    );
    return await file.writeAsBytes(await pdf.save());
  }

  /// Dispose recognizer when done (optional helper)
  Future<void> dispose() async {
    try {
      await _textRecognizer.close();
    } catch (_) {}
  }
}
