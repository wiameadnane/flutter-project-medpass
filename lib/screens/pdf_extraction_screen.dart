import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../services/language_detection_service.dart';
import '../services/translation_service.dart';

class PdfExtractionScreen extends StatefulWidget {
  final String extractedText;
  final int pageCount;
  final String fileName;
  final String originalPdfPath;

  const PdfExtractionScreen({
    super.key,
    required this.extractedText,
    required this.pageCount,
    required this.fileName,
    required this.originalPdfPath,
  });

  @override
  State<PdfExtractionScreen> createState() => _PdfExtractionScreenState();
}

class _PdfExtractionScreenState extends State<PdfExtractionScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _translationKey = GlobalKey();
  final LanguageDetectionService _languageDetectionService =
      LanguageDetectionService();

  String? _translatedText;
  String? _editedTranslation;
  String? _translationError;
  bool _translating = false;
  bool _loading = false;

  TranslateLanguage _sourceLanguage = TranslateLanguage.french;
  TranslateLanguage _targetLanguage = TranslateLanguage.english;

  @override
  void initState() {
    super.initState();
    _detectSourceLanguage();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _languageDetectionService.dispose();
    super.dispose();
  }

  Future<void> _detectSourceLanguage() async {
    if (widget.extractedText.isEmpty) return;

    try {
      final detected = await _languageDetectionService.detectLanguage(
        widget.extractedText.substring(
          0,
          widget.extractedText.length > 500 ? 500 : widget.extractedText.length,
        ),
      );

      if (detected != null && mounted) {
        setState(() {
          _sourceLanguage = detected;
          if (detected == TranslateLanguage.english) {
            _targetLanguage = TranslateLanguage.french;
          } else {
            _targetLanguage = TranslateLanguage.english;
          }
        });
      }
    } catch (e) {
      debugPrint('Language detection failed: $e');
    }
  }

  Future<void> _translateText() async {
    if (widget.extractedText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No text to translate.')),
      );
      return;
    }

    setState(() {
      _translating = true;
      _translatedText = null;
      _translationError = null;
    });

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Downloading translation models...')),
      );

      final translation = await TranslationService.translateText(
        context,
        widget.extractedText,
        _sourceLanguage,
        _targetLanguage,
      );

      if (mounted) {
        setState(() {
          _translatedText = translation;
          _translationError = null;
        });

        // Scroll to the translation section
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_translationKey.currentContext != null) {
            Scrollable.ensureVisible(
              _translationKey.currentContext!,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
              alignment: 0.0,
            );
          }
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
          );
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Translation completed successfully!')),
        );
      }
    } catch (e) {
      debugPrint('Translation error: $e');
      if (mounted) {
        setState(() {
          _translationError = e.toString();
          _translatedText = null;
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
    if (widget.extractedText.isEmpty) return;

    setState(() => _loading = true);

    try {
      final pdf = pw.Document();
      final textToSave = _editedTranslation ?? _translatedText ?? '';
      final hasTranslation = textToSave.isNotEmpty;

      // Split text into chunks for pages
      final originalLines = widget.extractedText.split('\n');
      final translatedLines = hasTranslation ? textToSave.split('\n') : <String>[];
      const linesPerPage = 35;

      // Page 1: Original text (first part)
      final originalFirstPage = originalLines.take(linesPerPage).join('\n');
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Extracted Text - ${widget.fileName}',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  '${widget.pageCount} page(s) extracted',
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey700,
                  ),
                ),
                pw.Divider(color: PdfColors.grey400),
                pw.SizedBox(height: 8),
                pw.Text(
                  originalFirstPage,
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ],
            );
          },
        ),
      );

      // Additional pages for original text if needed
      for (int i = linesPerPage; i < originalLines.length; i += linesPerPage) {
        final pageLines = originalLines.skip(i).take(linesPerPage).join('\n');
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(40),
            build: (pw.Context context) {
              return pw.Text(
                pageLines,
                style: const pw.TextStyle(fontSize: 10),
              );
            },
          ),
        );
      }

      // Translation pages if available
      if (hasTranslation) {
        final translatedFirstPage = translatedLines.take(linesPerPage).join('\n');
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(40),
            build: (pw.Context context) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Translation (${TranslationService.getLanguageName(_sourceLanguage)} -> ${TranslationService.getLanguageName(_targetLanguage)})',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Divider(color: PdfColors.grey400),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    translatedFirstPage,
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ],
              );
            },
          ),
        );

        // Additional translation pages
        for (int i = linesPerPage; i < translatedLines.length; i += linesPerPage) {
          final pageLines = translatedLines.skip(i).take(linesPerPage).join('\n');
          pdf.addPage(
            pw.Page(
              pageFormat: PdfPageFormat.a4,
              margin: const pw.EdgeInsets.all(40),
              build: (pw.Context context) {
                return pw.Text(
                  pageLines,
                  style: const pw.TextStyle(fontSize: 10),
                );
              },
            ),
          );
        }
      }

      // Save PDF
      final tempDir = await getTemporaryDirectory();
      final baseName = widget.fileName.replaceAll(RegExp(r'\.pdf$', caseSensitive: false), '');
      final suffix = hasTranslation ? '_translated' : '_extracted';
      final outputPath = '${tempDir.path}/$baseName$suffix.pdf';

      final file = File(outputPath);
      await file.writeAsBytes(await pdf.save());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF saved: $baseName$suffix.pdf')),
        );

        // Offer to share
        final shouldShare = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('PDF Created'),
            content: const Text('Would you like to share the PDF?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('No'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Share'),
              ),
            ],
          ),
        );

        if (shouldShare == true) {
          await Share.shareXFiles([XFile(outputPath)]);
        }
      }
    } catch (e) {
      debugPrint('PDF generation error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate PDF: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('PDF: ${widget.fileName}')),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info card
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.description, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${widget.pageCount} page(s) extracted',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),

              // Detected text section
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Detected Text:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                constraints: const BoxConstraints(maxHeight: 150),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(widget.extractedText),
                ),
              ),
              const SizedBox(height: 8),

              // Translation section
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
                          child: SelectableText(
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
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ] else ...[
                      const Text(
                        'Configure languages below and tap "Translate Now"',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                    const SizedBox(height: 8),
                  ],
                ),
              ),

              // Edit translation if available
              if (_translatedText != null) ...[
                const SizedBox(height: 8),
                const Text(
                  'Edit Translation:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 2),
                TextField(
                  controller: TextEditingController(text: _translatedText),
                  maxLines: 3,
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

              // Translation settings card
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
                                        DropdownButtonFormField<TranslateLanguage>(
                                          isDense: true,
                                          value: _sourceLanguage,
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
                                        DropdownButtonFormField<TranslateLanguage>(
                                          isDense: true,
                                          value: _targetLanguage,
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

              // Generate PDF button
              if (_loading)
                const LinearProgressIndicator(),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: (widget.extractedText.isNotEmpty && !_loading)
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
