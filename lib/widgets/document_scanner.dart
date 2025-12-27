import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:provider/provider.dart';
import 'package:projet/providers/user_provider.dart';
import 'package:projet/services/translation_service.dart';
import 'package:projet/widgets/ocr_service.dart';

class DocumentScanner extends StatefulWidget {
  const DocumentScanner({Key? key}) : super(key: key);

  @override
  State<DocumentScanner> createState() => _DocumentScannerState();
}

class _DocumentScannerState extends State<DocumentScanner> {
  final ImagePicker _picker = ImagePicker();
  final OCRService _ocrService = OCRService();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _translationKey = GlobalKey();

  File? _imageFile;
  String? _recognizedText;
  String? _translatedText;
  String? _editedTranslation;
  String? _translationError;
  bool _loading = false;
  bool _translating = false;
  TranslateLanguage _sourceLanguage = TranslateLanguage.french;
  TranslateLanguage _targetLanguage = TranslateLanguage.english;

  Future<void> _takePicture() async {
    setState(() {
      _loading = true;
      _recognizedText = null;
      _translatedText = null;
    });

    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (picked == null) {
        setState(() => _loading = false);
        return;
      }

      final file = File(picked.path);
      setState(() => _imageFile = file);

      final text = await _ocrService.scanDocument(picked.path);
      setState(() => _recognizedText = text);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error capturing image: $e')));
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _translateText() async {
    if (_recognizedText == null || _recognizedText!.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('No text to translate. Please scan a document first.')),
        );
      }
      return;
    }

    if (mounted) {
      setState(() {
        _translating = true;
        _translatedText = null;
        _translationError = null; // Clear previous errors
      });
    }

    try {
      print('Starting translation...');
      print('Source text: "$_recognizedText"');
      print('Source language: $_sourceLanguage (${_sourceLanguage.bcpCode})');
      print('Target language: $_targetLanguage (${_targetLanguage.bcpCode})');

      // Show downloading message if models need to be downloaded
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Downloading translation models...')),
        );
      }

      final translation = await TranslationService.translateText(
        context,
        _recognizedText!,
        _sourceLanguage,
        _targetLanguage,
      );

      print('Translation result: "$translation"');
      print('Translation length: ${translation.length}');

      if (mounted) {
        setState(() {
          _translatedText = translation;
          _translationError = null; // Clear any previous error
        });

        // Scroll to the translation section to show the translation
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_translationKey.currentContext != null) {
            Scrollable.ensureVisible(
              _translationKey.currentContext!,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
              alignment: 0.0, // Align to top
            );
          }
          // Also scroll to bottom to ensure visibility
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
          );
        });
      }

      if (mounted) {
        if (translation.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Translation completed successfully!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Translation completed but result is empty')),
          );
        }
      }
    } catch (e) {
      print('Translation error: $e');
      print('Error type: ${e.runtimeType}');
      if (mounted) {
        setState(() {
          _translationError = e.toString();
          _translatedText = null; // Clear any previous translation
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Translation failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _translating = false);
      }
    }
  }

  Future<void> _generatePdf() async {
    if (_imageFile == null || _recognizedText == null) return;
    setState(() => _loading = true);
    try {
      final pdfFile = await _ocrService.generateMedicalPdf(
        _imageFile!,
        _recognizedText!,
        _editedTranslation ?? _translatedText ?? '',
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('PDF saved: ${pdfFile.path}')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to generate PDF: $e')));
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _ocrService.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Document Scanner')),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: _loading ? null : _takePicture,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Take Picture'),
            ),
            const SizedBox(height: 8),
            if (_imageFile != null) ...[
              Container(
                height: 150,
                child: Image.file(_imageFile!, fit: BoxFit.cover),
              ),
              const SizedBox(height: 6),
            ],
            if (_loading) const LinearProgressIndicator(),
            if (_recognizedText != null) ...[
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Detected Text:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _loading ? null : _takePicture,
                    icon: const Icon(Icons.camera_alt, size: 16),
                    label: const Text('Rescan'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              SingleChildScrollView(child: Text(_recognizedText!)),
              const SizedBox(height: 8),
            ],
            Container(
              key: _translationKey,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Translation:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  if (_translating) ...[
                    const Center(child: CircularProgressIndicator()),
                  ] else if (_translatedText != null &&
                      _translatedText!.isNotEmpty) ...[
                    Container(
                      height: 80,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: SingleChildScrollView(
                        child: Text(
                          _translatedText!,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ] else if (_translationError != null) ...[
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Text(
                        'Translation error: $_translationError',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ] else if (_recognizedText == null) ...[
                    const Text(
                      'Scan a document first to translate',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ] else ...[
                    const Text(
                      'No translation available',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                  const SizedBox(height: 8),
                ],
              ),
            ),
            if (_translatedText != null) ...[
              const Text(
                'Edit Translation:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 2),
              TextField(
                controller: TextEditingController(text: _translatedText),
                maxLines: 1,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Edit translation here...',
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
                style: const TextStyle(fontSize: 12),
                onChanged: (value) {
                  setState(() => _editedTranslation = value);
                },
              ),
              const SizedBox(height: 4),
            ],
            if (_recognizedText != null) ...[
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade50, Colors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.shade100.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Card(
                  elevation: 0,
                  color: Colors.transparent,
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.language,
                              color: Theme.of(context).primaryColor,
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'Translation Settings',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Source',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(height: 1),
                                        DropdownButtonFormField<
                                            TranslateLanguage>(
                                          isDense: true,
                                          initialValue: _sourceLanguage,
                                          decoration: InputDecoration(
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 6, vertical: 4),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              borderSide: BorderSide(
                                                  color: Colors.grey.shade300),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              borderSide: BorderSide(
                                                  color: Colors.grey.shade300),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              borderSide: BorderSide(
                                                  color: Theme.of(context)
                                                      .primaryColor),
                                            ),
                                          ),
                                          items: TranslationService
                                                  .getAvailableSourceLanguages(
                                                      context)
                                              .map((lang) => DropdownMenuItem(
                                                    value: lang,
                                                    child: Text(
                                                        TranslationService
                                                            .getLanguageName(
                                                                lang)),
                                                  ))
                                              .toList(),
                                          onChanged: (value) {
                                            if (value != null) {
                                              setState(() =>
                                                  _sourceLanguage = value);
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .primaryColor
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.arrow_forward,
                                      color: Theme.of(context).primaryColor,
                                      size: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Target',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(height: 1),
                                        DropdownButtonFormField<
                                            TranslateLanguage>(
                                          isDense: true,
                                          initialValue: _targetLanguage,
                                          decoration: InputDecoration(
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 6, vertical: 4),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              borderSide: BorderSide(
                                                  color: Colors.grey.shade300),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              borderSide: BorderSide(
                                                  color: Colors.grey.shade300),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              borderSide: BorderSide(
                                                  color: Theme.of(context)
                                                      .primaryColor),
                                            ),
                                          ),
                                          items: TranslationService
                                                  .getAvailableTargetLanguages(
                                                      context)
                                              .map((lang) => DropdownMenuItem(
                                                    value: lang,
                                                    child: Row(
                                                      children: [
                                                        Text(TranslationService
                                                            .getLanguageName(
                                                                lang)),
                                                        if (TranslationService
                                                            .isPremiumTargetLanguage(
                                                                lang, context))
                                                          const SizedBox(
                                                              width: 3),
                                                        if (TranslationService
                                                            .isPremiumTargetLanguage(
                                                                lang, context))
                                                          const Icon(
                                                            Icons.star,
                                                            color: Colors.amber,
                                                            size: 10,
                                                          ),
                                                      ],
                                                    ),
                                                  ))
                                              .toList(),
                                          onChanged: (value) {
                                            if (value != null) {
                                              setState(() =>
                                                  _targetLanguage = value);
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).primaryColor,
                                Theme.of(context)
                                    .primaryColor
                                    .withValues(alpha: 0.8)
                              ],
                            ),
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context)
                                    .primaryColor
                                    .withValues(alpha: 0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: _translating ? null : _translateText,
                            icon: _translating
                                ? Container(
                                    width: 14,
                                    height: 14,
                                    padding: const EdgeInsets.all(1),
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  )
                                : const Icon(Icons.translate, size: 14),
                            label: Text(
                              _translating ? 'Translating...' : 'Translate Now',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
            ],
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: (_imageFile != null &&
                            _recognizedText != null &&
                            !_loading)
                        ? _generatePdf
                        : null,
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('Generate PDF'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }
}
