import 'dart:io';
<<<<<<< HEAD
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
=======
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
>>>>>>> 3268ed02d21c8b5387ffb1bb218f054aaf1db5d9
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart'; // <--- INDISPENSABLE pour PdfColors
import 'package:pdf/widgets.dart' as pw;

class OCRService {
<<<<<<< HEAD
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

  /// Génère un PDF contenant l'image, le texte original et la traduction
  Future<File> generateMedicalPdf(
    File imageFile,
    String originalText,
    String translatedText,
  ) async {
=======
  final _textRecognizer = TextRecognizer();

  /// Extrait le texte d'une image via ML Kit
  Future<String> scanDocument(String path) async {
    final inputImage = InputImage.fromFilePath(path);
    final recognizedText = await _textRecognizer.processImage(inputImage);
    return recognizedText.text;
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
  Future<File> generateMedicalPdf(File imageFile, String originalText, String translatedText) async {
>>>>>>> 3268ed02d21c8b5387ffb1bb218f054aaf1db5d9
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
<<<<<<< HEAD
              pw.Text(
                "Med-Pass Medical Report",
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Text(
                "Original Document:",
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
=======
              pw.Text("Med-Pass Medical Report",
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.Divider(),
              pw.SizedBox(height: 10),

              pw.Text("Original Document:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
>>>>>>> 3268ed02d21c8b5387ffb1bb218f054aaf1db5d9
              pw.SizedBox(height: 5),
              pw.Center(
                child: pw.Image(
                  pw.MemoryImage(imageFile.readAsBytesSync()),
                  height: 350,
                ),
              ),
<<<<<<< HEAD
              pw.SizedBox(height: 20),
              pw.Text(
                "Detected French Text:",
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(originalText),
              pw.SizedBox(height: 20),
              pw.Text(
                "English Translation:",
                style: pw.TextStyle(
                  color: PdfColors
                      .blue, // <--- CORRIGÉ : Utilise PdfColors directement
                  fontWeight: pw.FontWeight.bold,
                ),
=======

              pw.SizedBox(height: 20),
              pw.Text("Detected French Text:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(originalText),

              pw.SizedBox(height: 20),
              pw.Text("English Translation:",
                  style: pw.TextStyle(
                      color: PdfColors.blue, // <--- CORRIGÉ : Utilise PdfColors directement
                      fontWeight: pw.FontWeight.bold
                  )
>>>>>>> 3268ed02d21c8b5387ffb1bb218f054aaf1db5d9
              ),
              pw.Paragraph(text: translatedText),
            ],
          );
        },
      ),
    );

    // Sauvegarde le fichier dans le répertoire temporaire du Samsung
    final output = await getApplicationDocumentsDirectory();
<<<<<<< HEAD
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
=======
    final file = File("${output.path}/medpass_scan_${DateTime.now().millisecondsSinceEpoch}.pdf");
    return await file.writeAsBytes(await pdf.save());
  }
}
>>>>>>> 3268ed02d21c8b5387ffb1bb218f054aaf1db5d9
