import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_doc_scanner/flutter_doc_scanner.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:projet/core/constants.dart';
import 'package:projet/providers/user_provider.dart';
import 'package:projet/screens/files/upload_file_screen.dart';
import 'package:projet/services/image_enhancement_service.dart';
import 'package:projet/services/language_detection_service.dart';
import 'package:projet/services/translation_service.dart';
import 'package:projet/widgets/ocr_service.dart';

class OCRScanScreen extends StatefulWidget {
  const OCRScanScreen({super.key});

  @override
  State<OCRScanScreen> createState() => _OCRScanScreenState();
}

class _OCRScanScreenState extends State<OCRScanScreen> {
  final ImagePicker _picker = ImagePicker();
  final OCRService _ocrService = OCRService();
  final LanguageDetectionService _langDetectionService = LanguageDetectionService();

  File? _imageFile;
  File? _enhancedImageFile; // Enhanced version of the image for OCR
  String? _recognizedText;
  String? _translatedText;
  File? _generatedPdfFile;
  bool _loading = false;
  bool _enhancing = false;
  bool _translating = false;
  bool _saving = false;
  bool _detectingLanguage = false;
  TranslateLanguage? _sourceLanguage; // null means auto-detected
  TranslateLanguage? _detectedLanguage;
  TranslateLanguage _targetLanguage = TranslateLanguage.english;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Set target language to user's preferred language
      _setDefaultTargetLanguage();

      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final autoShowDialog = args?['autoShowDialog'] as bool? ?? false;
      if (autoShowDialog) {
        _showImageSourceDialog();
      }
    });
  }

  void _setDefaultTargetLanguage() {
    final userProvider = context.read<UserProvider>();
    final preferredCode = userProvider.user?.preferredLanguage ?? 'en';
    final preferredLang = LanguageDetectionService.codeToTranslateLanguage(preferredCode);
    if (preferredLang != null) {
      setState(() {
        _targetLanguage = preferredLang;
      });
    }
  }

  @override
  void dispose() {
    _ocrService.dispose();
    _langDetectionService.dispose();
    // Clean up temporary enhanced image
    ImageEnhancementService.cleanupEnhancedImage(_enhancedImageFile);
    super.dispose();
  }

  Future<bool> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isGranted) return true;

    if (status.isPermanentlyDenied && mounted) {
      _showPermissionDialog('Camera permission is required to take photos.');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Camera permission is required')),
      );
    }
    return false;
  }

  Future<bool> _requestGalleryPermission() async {
    Permission permission = Permission.photos;
    var status = await permission.request();

    if (status.isDenied || status.isPermanentlyDenied) {
      permission = Permission.storage;
      status = await permission.request();
    }

    if (status.isGranted || status.isLimited) return true;

    if (status.isPermanentlyDenied && mounted) {
      _showPermissionDialog('Storage permission is required to access gallery.');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Storage permission is required')),
      );
    }
    return false;
  }

  void _showPermissionDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  /// Scan document using ML Kit Document Scanner
  /// Provides: edge detection, perspective correction, cropping, enhancement
  Future<void> _scanWithDocScanner() async {
    final hasPermission = await _requestCameraPermission();
    if (!hasPermission) return;

    setState(() {
      _loading = true;
      _recognizedText = null;
      _translatedText = null;
      _generatedPdfFile = null;
      _detectedLanguage = null;
      _sourceLanguage = null;
      _enhancedImageFile = null;
    });

    try {
      // Use Flutter Doc Scanner (ML Kit Document Scanner API)
      // This provides: edge detection, perspective correction, cropping
      // Use getScannedDocumentAsImages to get image paths directly
      final dynamic scannedDocuments = await FlutterDocScanner().getScannedDocumentAsImages(
        page: 1, // Scan single page
      );

      // Debug: Log what we received
      debugPrint('FlutterDocScanner returned: $scannedDocuments');
      debugPrint('Type: ${scannedDocuments.runtimeType}');

      if (scannedDocuments == null) {
        setState(() => _loading = false);
        return;
      }

      // Get the scanned document path
      // The scanner can return: List<String>, String, or Map with pdfUri/images
      String? imagePath;

      if (scannedDocuments is List) {
        debugPrint('Is List with ${scannedDocuments.length} items');
        if (scannedDocuments.isNotEmpty) {
          imagePath = scannedDocuments.first?.toString();
          debugPrint('First item: $imagePath');
        }
      } else if (scannedDocuments is String) {
        imagePath = scannedDocuments;
      } else if (scannedDocuments is Map) {
        debugPrint('Is Map with keys: ${scannedDocuments.keys.toList()}');

        // Convert to string and extract file path directly
        // Format: {Uri: [Page{imageUri=file:///path/to/image.jpg}], Count: 1}
        final rawString = scannedDocuments.toString();
        debugPrint('Raw string: $rawString');

        // Look for file:/// pattern and extract the path
        final filePattern = RegExp(r'file:///([^\s\}\]]+\.(jpg|jpeg|png|pdf))');
        final match = filePattern.firstMatch(rawString);
        if (match != null) {
          imagePath = '/${match.group(1)}';
          debugPrint('Extracted from regex: $imagePath');
        }

        // If regex didn't work, try manual extraction
        if (imagePath == null && rawString.contains('file:///')) {
          final startIndex = rawString.indexOf('file:///');
          if (startIndex != -1) {
            var endIndex = rawString.indexOf('}', startIndex);
            if (endIndex == -1) endIndex = rawString.indexOf(']', startIndex);
            if (endIndex == -1) endIndex = rawString.length;

            final fileUri = rawString.substring(startIndex, endIndex);
            imagePath = fileUri.replaceFirst('file://', '');
            debugPrint('Extracted manually: $imagePath');
          }
        }
      }

      debugPrint('Final imagePath: $imagePath');

      if (imagePath == null || imagePath.isEmpty) {
        setState(() => _loading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No document scanned. Raw: $scannedDocuments')),
          );
        }
        return;
      }

      final file = File(imagePath);
      if (!await file.exists()) {
        setState(() => _loading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to access scanned image')),
          );
        }
        return;
      }

      setState(() => _imageFile = file);

      // Apply image enhancement for better OCR
      await _enhanceAndProcess(file);
    } on PlatformException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Scanner error: ${e.message}')),
        );
      }
      setState(() => _loading = false);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Scanning error: $e')),
        );
      }
      setState(() => _loading = false);
    }
  }

  /// Pick image from gallery (fallback option)
  Future<void> _pickFromGallery() async {
    final hasPermission = await _requestGalleryPermission();
    if (!hasPermission) return;

    setState(() {
      _loading = true;
      _recognizedText = null;
      _translatedText = null;
      _generatedPdfFile = null;
      _detectedLanguage = null;
      _sourceLanguage = null;
      _enhancedImageFile = null;
    });

    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );

      if (picked == null) {
        setState(() => _loading = false);
        return;
      }

      final file = File(picked.path);
      setState(() => _imageFile = file);

      // Apply image enhancement for better OCR
      await _enhanceAndProcess(file);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
      setState(() => _loading = false);
    }
  }

  /// Enhance image and run OCR
  Future<void> _enhanceAndProcess(File imageFile) async {
    try {
      setState(() => _enhancing = true);

      // Enhance the image for better OCR results
      final enhancedFile = await ImageEnhancementService.enhanceDocument(imageFile);
      setState(() => _enhancedImageFile = enhancedFile);

      setState(() => _enhancing = false);

      // Run OCR on the enhanced image
      final text = await _ocrService.scanDocument(enhancedFile.path);
      setState(() => _recognizedText = text);

      // Auto-detect language after OCR
      if (text.isNotEmpty) {
        await _detectLanguage(text);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Processing error: $e')),
        );
      }
    } finally {
      setState(() {
        _loading = false;
        _enhancing = false;
      });
    }
  }

  Future<void> _detectLanguage(String text) async {
    setState(() => _detectingLanguage = true);

    try {
      final detected = await _langDetectionService.detectLanguage(text);
      if (mounted) {
        setState(() {
          _detectedLanguage = detected;
          // If detected language is same as target, suggest switching target
          if (detected != null && detected == _targetLanguage) {
            // Auto-switch target to English if detected is same as target
            // (unless detected is already English, then switch to French)
            if (detected == TranslateLanguage.english) {
              _targetLanguage = TranslateLanguage.french;
            } else {
              _targetLanguage = TranslateLanguage.english;
            }
          }
        });
      }
    } catch (e) {
      print('Language detection error: $e');
    } finally {
      if (mounted) {
        setState(() => _detectingLanguage = false);
      }
    }
  }

  Future<void> _translateText() async {
    if (_recognizedText == null || _recognizedText!.isEmpty) return;

    // Use detected language if source is not manually selected
    final effectiveSourceLanguage = _sourceLanguage ?? _detectedLanguage ?? TranslateLanguage.english;

    // Prevent translation to same language
    if (effectiveSourceLanguage == _targetLanguage) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Source and target language cannot be the same')),
        );
      }
      return;
    }

    setState(() {
      _translating = true;
      _translatedText = null;
    });

    try {
      final translated = await TranslationService.translateText(
        context,
        _recognizedText!,
        effectiveSourceLanguage,
        _targetLanguage,
      );
      setState(() => _translatedText = translated);
    } catch (e) {
      if (mounted && !e.toString().contains('Premium feature required')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Translation failed: $e')),
        );
      }
    } finally {
      setState(() => _translating = false);
    }
  }

  Future<File?> _generatePdf() async {
    if (_imageFile == null || _recognizedText == null) return null;

    // Get language names for PDF
    final effectiveSourceLanguage = _sourceLanguage ?? _detectedLanguage ?? TranslateLanguage.english;
    final sourceLanguageName = LanguageDetectionService.getLanguageName(effectiveSourceLanguage);
    final targetLanguageName = LanguageDetectionService.getLanguageName(_targetLanguage);

    // Use enhanced image if available, otherwise fall back to original
    // This ensures the PDF contains the clean, processed document image
    final imageForPdf = _enhancedImageFile ?? _imageFile!;

    // Generate PDF with processed image, original text, and translation (if available)
    final pdfFile = await _ocrService.generateMedicalPdf(
      imageForPdf,
      _recognizedText!,
      _translatedText ?? 'No translation available',
      sourceLanguage: sourceLanguageName,
      targetLanguage: targetLanguageName,
    );

    setState(() => _generatedPdfFile = pdfFile);
    return pdfFile;
  }

  Future<void> _saveToMedPass() async {
    if (_imageFile == null || _recognizedText == null) return;

    setState(() => _saving = true);

    try {
      final pdfFile = _generatedPdfFile ?? await _generatePdf();
      if (pdfFile == null || !mounted) return;

      // Create PlatformFile for upload screen
      final platformFile = PlatformFile(
        name: 'scan_${DateTime.now().millisecondsSinceEpoch}.pdf',
        path: pdfFile.path,
        size: pdfFile.lengthSync(),
        bytes: pdfFile.readAsBytesSync(),
      );

      // Navigate to upload screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => UploadFileScreen(initialFile: platformFile),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save document: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _shareDocument() async {
    if (_imageFile == null || _recognizedText == null) return;

    setState(() => _saving = true);

    try {
      final pdfFile = _generatedPdfFile ?? await _generatePdf();
      if (pdfFile == null || !mounted) return;

      final xFile = XFile(pdfFile.path, mimeType: 'application/pdf');
      await Share.shareXFiles(
        [xFile],
        subject: 'Med-Pass Scan',
        text: 'Medical document scanned with Med-Pass',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to share document: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showSaveOptionsDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusL)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppSizes.paddingL),
              Text(
                'Save Document',
                style: GoogleFonts.dmSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: AppSizes.paddingS),
              Text(
                'Choose how to save your scanned document',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSizes.paddingL),
              _buildSaveOption(
                icon: Icons.cloud_upload_rounded,
                title: 'Save to Med-Pass',
                subtitle: 'Upload to your cloud storage',
                color: AppColors.primary,
                onTap: () {
                  Navigator.pop(context);
                  _saveToMedPass();
                },
              ),
              const SizedBox(height: AppSizes.paddingM),
              _buildSaveOption(
                icon: Icons.share_rounded,
                title: 'Share',
                subtitle: 'Send via email, WhatsApp, etc.',
                color: AppColors.accent,
                onTap: () {
                  Navigator.pop(context);
                  _shareDocument();
                },
              ),
              const SizedBox(height: AppSizes.paddingL),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSaveOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        decoration: BoxDecoration(
          color: color.withAlpha((0.05 * 255).round()),
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          border: Border.all(color: color.withAlpha((0.2 * 255).round())),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingS),
              decoration: BoxDecoration(
                color: color.withAlpha((0.1 * 255).round()),
                borderRadius: BorderRadius.circular(AppSizes.radiusS),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: AppSizes.paddingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 16),
          ],
        ),
      ),
    );
  }

  void _showImageSourceDialog() {
    // Directly open the document scanner - it has both camera and gallery built-in
    // This ensures all images get the same edge detection & perspective correction
    _scanWithDocScanner();
  }

  Widget _buildSourceOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        decoration: BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingS),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha((0.1 * 255).round()),
                borderRadius: BorderRadius.circular(AppSizes.radiusS),
              ),
              child: Icon(icon, color: AppColors.primary, size: 24),
            ),
            const SizedBox(height: AppSizes.paddingS),
            Text(title, style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark)),
            Text(subtitle, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textSecondary), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('Scan Document', style: GoogleFonts.dmSans(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Instructions
              _buildInstructionsCard(),
              const SizedBox(height: AppSizes.paddingL),

              // Scan Button (shown when no image)
              if (_imageFile == null && !_loading) _buildScanButton(),

              // Loading State
              if (_loading) _buildLoadingState(),

              // Results (shown after scan)
              if (_imageFile != null && !_loading) ...[
                _buildImagePreview(),
                const SizedBox(height: AppSizes.paddingM),
                _buildRescanButton(),
                if (_recognizedText != null) ...[
                  const SizedBox(height: AppSizes.paddingL),
                  _buildResultsCard(),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionsCard() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Scan a Document', style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textDark)),
          const SizedBox(height: AppSizes.paddingS),
          Text('Take a photo or choose from gallery to extract text from medical documents.',
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildScanButton() {
    return GestureDetector(
      onTap: _showImageSourceDialog,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSizes.paddingXL),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF1B4D6E), AppColors.accent], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          boxShadow: [BoxShadow(color: const Color(0xFF1B4D6E).withAlpha((0.3 * 255).round()), blurRadius: 15, offset: const Offset(0, 8))],
        ),
        child: Column(
          children: [
            const Icon(Icons.document_scanner_rounded, color: Colors.white, size: 48),
            const SizedBox(height: AppSizes.paddingM),
            Text('Start Scanning', style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
            Text('Auto edge detection & enhancement', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white.withAlpha((0.8 * 255).round()))),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    String loadingText = 'Processing image...';
    if (_enhancing) {
      loadingText = 'Enhancing document...';
    } else if (_imageFile != null && _recognizedText == null) {
      loadingText = 'Extracting text...';
    }

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppSizes.radiusL)),
      child: Column(
        children: [
          const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary)),
          const SizedBox(height: AppSizes.paddingM),
          Text(loadingText, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
          if (_enhancing) ...[
            const SizedBox(height: AppSizes.paddingS),
            Text(
              'Improving contrast & sharpness for better OCR',
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    // Show enhanced image if available, otherwise show original
    final displayImage = _enhancedImageFile ?? _imageFile!;

    return Column(
      children: [
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
            image: DecorationImage(image: FileImage(displayImage), fit: BoxFit.cover),
          ),
        ),
        if (_enhancedImageFile != null) ...[
          const SizedBox(height: AppSizes.paddingS),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.auto_fix_high, size: 14, color: AppColors.primary),
              const SizedBox(width: 4),
              Text(
                'Enhanced for better OCR',
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.primary),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildRescanButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _showImageSourceDialog,
        icon: const Icon(Icons.refresh_rounded),
        label: const Text('Rescan'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentDark,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusM)),
        ),
      ),
    );
  }

  Widget _buildResultsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Extracted Text Header
          Row(
            children: [
              const Icon(Icons.text_fields_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: AppSizes.paddingS),
              Text('Extracted Text', style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark)),
            ],
          ),
          const SizedBox(height: AppSizes.paddingM),

          // Extracted Text Content (scrollable)
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 120),
            child: SingleChildScrollView(
              child: Text(_recognizedText!, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textDark, height: 1.5)),
            ),
          ),
          const SizedBox(height: AppSizes.paddingM),

          // Language Selection
          _buildLanguageSelector(),
          const SizedBox(height: AppSizes.paddingM),

          // Translate Button
          _buildTranslateButton(),

          // Translated Text
          if (_translatedText != null) ...[
            const SizedBox(height: AppSizes.paddingM),
            _buildTranslatedText(),
          ],

          // Save Document Button
          const SizedBox(height: AppSizes.paddingL),
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _saving ? null : _showSaveOptionsDialog,
        icon: _saving
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.save_rounded),
        label: Text(_saving ? 'Processing...' : 'Save & Share'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentDark,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusM)),
        ),
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final sourceLanguages = TranslationService.getAvailableSourceLanguages(context);
        final targetLanguages = TranslationService.getAvailableTargetLanguages(context);

        // Build auto-detect display text
        String autoDetectText = 'Auto-detect';
        if (_detectingLanguage) {
          autoDetectText = 'Detecting...';
        } else if (_detectedLanguage != null) {
          autoDetectText = 'Auto (${LanguageDetectionService.getLanguageName(_detectedLanguage!)})';
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Detected language indicator
            if (_detectedLanguage != null && _sourceLanguage == null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha((0.1 * 255).round()),
                  borderRadius: BorderRadius.circular(AppSizes.radiusS),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_awesome, size: 14, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      'Detected: ${LanguageDetectionService.getLanguageName(_detectedLanguage!)}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),

            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<TranslateLanguage?>(
                    isDense: true,
                    isExpanded: true,
                    value: _sourceLanguage,
                    dropdownColor: Colors.white,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textDark,
                    ),
                    decoration: InputDecoration(
                      labelText: 'From',
                      labelStyle: GoogleFonts.inter(color: AppColors.textSecondary),
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    ),
                    selectedItemBuilder: (BuildContext context) {
                      return [
                        // Auto-detect option
                        Text(
                          autoDetectText,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(fontSize: 14, color: AppColors.textDark),
                        ),
                        // All source languages
                        ...sourceLanguages.map((lang) => Text(
                          TranslationService.getLanguageName(lang),
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(fontSize: 14, color: AppColors.textDark),
                        )),
                      ];
                    },
                    items: [
                      // Auto-detect option (null value)
                      DropdownMenuItem<TranslateLanguage?>(
                        value: null,
                        child: Row(
                          children: [
                            const Icon(Icons.auto_awesome, size: 14, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                autoDetectText,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // All available source languages
                      ...sourceLanguages.map((lang) {
                        return DropdownMenuItem<TranslateLanguage?>(
                          value: lang,
                          child: Text(
                            TranslationService.getLanguageName(lang),
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(color: AppColors.textDark),
                          ),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() => _sourceLanguage = value);
                    },
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(Icons.arrow_forward, color: AppColors.primary, size: 20),
                ),
                Expanded(
                  child: DropdownButtonFormField<TranslateLanguage>(
                    isDense: true,
                    isExpanded: true,
                    value: _targetLanguage,
                    dropdownColor: Colors.white,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textDark,
                    ),
                    decoration: InputDecoration(
                      labelText: 'To',
                      labelStyle: GoogleFonts.inter(color: AppColors.textSecondary),
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    ),
                    selectedItemBuilder: (BuildContext context) {
                      return targetLanguages.map((lang) => Text(
                        TranslationService.getLanguageName(lang),
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(fontSize: 14, color: AppColors.textDark),
                      )).toList();
                    },
                    items: targetLanguages.map((lang) {
                      final isPremium = TranslationService.isPremiumTargetLanguage(lang, context);
                      final userIsPremium = userProvider.user?.isPremium ?? false;
                      return DropdownMenuItem(
                        value: lang,
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                TranslationService.getLanguageName(lang),
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(color: AppColors.textDark),
                              ),
                            ),
                            if (isPremium && !userIsPremium)
                              const Padding(
                                padding: EdgeInsets.only(left: 4),
                                child: Icon(Icons.lock, size: 14, color: AppColors.primary),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        final isPremium = TranslationService.isPremiumTargetLanguage(value, context);
                        final userIsPremium = userProvider.user?.isPremium ?? false;
                        if (isPremium && !userIsPremium) {
                          TranslationService.showUpgradeDialog(context);
                        } else {
                          setState(() => _targetLanguage = value);
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildTranslateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _translating ? null : _translateText,
        icon: _translating
            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.translate),
        label: Text(_translating ? 'Translating...' : 'Translate'),
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
      ),
    );
  }

  Widget _buildTranslatedText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.g_translate_rounded, color: AppColors.primary, size: 20),
            const SizedBox(width: AppSizes.paddingS),
            Text('Translated Text', style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark)),
          ],
        ),
        const SizedBox(height: AppSizes.paddingS),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSizes.paddingS),
          decoration: BoxDecoration(
            color: AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(AppSizes.radiusS),
            border: Border.all(color: AppColors.divider),
          ),
          child: Text(_translatedText!, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textDark, height: 1.5)),
        ),
      ],
    );
  }
}
