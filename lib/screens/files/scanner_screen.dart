import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../widgets/ocr_service.dart';


class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final OCRService _ocrService = OCRService();
  String _displayText = "Prêt pour le scan médical...";
  bool _isProcessing = false;

  Future<void> _scanNow() async {
    final ImagePicker picker = ImagePicker();
    // Ouvre l'appareil photo du téléphone
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);

    if (photo != null) {
      setState(() => _isProcessing = true);
      try {
        // Étape 1 : Reconnaissance de texte (OCR)
        String text = await _ocrService.scanDocument(photo.path);

        // Étape 2 : Traduction automatique
        String translated = await _ocrService.translateResult(text);

        setState(() {
          _displayText = "Texte détecté :\n$text\n\nTraduction (EN) :\n$translated";
        });
      } catch (e) {
        setState(() => _displayText = "Erreur : $e");
      } finally {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scanner Med-Pass")),
      body: Center(
        child: _isProcessing
            ? const CircularProgressIndicator()
            : Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(child: Text(_displayText)),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _scanNow,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.camera_alt, color: Colors.white),
      ),
    );
  }
}