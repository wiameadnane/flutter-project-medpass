import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart'; // <--- INDISPENSABLE pour PdfColors
import 'package:pdf/widgets.dart' as pw;

class OCRService {
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
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("Med-Pass Medical Report",
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.Divider(),
              pw.SizedBox(height: 10),

              pw.Text("Original Document:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 5),
              pw.Center(
                child: pw.Image(
                  pw.MemoryImage(imageFile.readAsBytesSync()),
                  height: 350,
                ),
              ),

              pw.SizedBox(height: 20),
              pw.Text("Detected French Text:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(originalText),

              pw.SizedBox(height: 20),
              pw.Text("English Translation:",
                  style: pw.TextStyle(
                      color: PdfColors.blue, // <--- CORRIGÉ : Utilise PdfColors directement
                      fontWeight: pw.FontWeight.bold
                  )
              ),
              pw.Paragraph(text: translatedText),
            ],
          );
        },
      ),
    );

    // Sauvegarde le fichier dans le répertoire temporaire du Samsung
    final output = await getApplicationDocumentsDirectory();
    final file = File("${output.path}/medpass_scan_${DateTime.now().millisecondsSinceEpoch}.pdf");
    return await file.writeAsBytes(await pdf.save());
  }
}