import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:projet/core/constants.dart';
import 'package:projet/providers/user_provider.dart';
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

  File? _imageFile;
  String? _recognizedText;
  String? _translatedText;
  bool _loading = false;
  bool _translating = false;
  TranslateLanguage _sourceLanguage = TranslateLanguage.french;
  TranslateLanguage _targetLanguage = TranslateLanguage.english;

  @override
  void initState() {
    super.initState();
    // Check if we should auto-show dialog
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final autoShowDialog = args?['autoShowDialog'] as bool? ?? false;
      if (autoShowDialog) {
        _showImageSourceDialog();
      }
    });
  }

  @override
  void dispose() {
    _ocrService.dispose();
    super.dispose();
  }

  Future<bool> _requestPermissions() async {
    final cameraStatus = await Permission.camera.request();
    final storageStatus = await Permission.storage.request();

    if (cameraStatus.isGranted && storageStatus.isGranted) {
      return true;
    }

    if (cameraStatus.isPermanentlyDenied || storageStatus.isPermanentlyDenied) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Permissions Required'),
            content: const Text(
              'Camera and storage permissions are required to scan documents. Please enable them in settings.',
            ),
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
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permissions are required to scan documents'),
          ),
        );
      }
    }

    return false;
  }

  Future<void> _pickImage(ImageSource source) async {
    final hasPermissions = await _requestPermissions();
    if (!hasPermissions) return;

    setState(() {
      _loading = true;
      _recognizedText = null;
      _translatedText = null;
    });

    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        imageQuality: 100, // Higher quality for better OCR
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
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _translateText() async {
    if (_recognizedText == null || _recognizedText!.isEmpty) return;

    setState(() {
      _translating = true;
      _translatedText = null;
    });

    try {
      final translated = await TranslationService.translateText(
        context,
        _recognizedText!,
        _sourceLanguage,
        _targetLanguage,
      );
      setState(() => _translatedText = translated);
    } catch (e) {
      if (mounted && e.toString() != 'Premium feature required') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Translation failed: $e')),
        );
      }
    } finally {
      setState(() => _translating = false);
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusL),
        ),
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
                'Select Image Source',
                style: GoogleFonts.dmSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: AppSizes.paddingL),
              Row(
                children: [
                  Expanded(
                    child: _buildSourceOption(
                      icon: Icons.camera_alt_rounded,
                      title: 'Camera',
                      subtitle: 'Take a new photo',
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.camera);
                      },
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingM),
                  Expanded(
                    child: _buildSourceOption(
                      icon: Icons.photo_library_rounded,
                      title: 'Gallery',
                      subtitle: 'Choose from gallery',
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.gallery);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.paddingL),
            ],
          ),
        ),
      ),
    );
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
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
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
        title: Text(
          'Scan Document',
          style: GoogleFonts.dmSans(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Instructions
                      Container(
                        padding: const EdgeInsets.all(AppSizes.paddingM),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppSizes.radiusL),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.shadow,
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Scan a Document',
                              style: GoogleFonts.dmSans(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: AppSizes.paddingS),
                            Text(
                              'Take a photo or choose from gallery to extract text from medical documents.',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSizes.paddingL),

                      // Scan Button
                      if (_imageFile == null)
                        GestureDetector(
                          onTap: _loading ? null : _showImageSourceDialog,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(AppSizes.paddingXL),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: AppColors.primaryGradient,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius:
                                  BorderRadius.circular(AppSizes.radiusL),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withAlpha(
                                    (0.3 * 255).round(),
                                  ),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.document_scanner_rounded,
                                  color: Colors.white,
                                  size: 48,
                                ),
                                const SizedBox(height: AppSizes.paddingM),
                                Text(
                                  'Start Scanning',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'Camera or Gallery',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white
                                        .withAlpha((0.8 * 255).round()),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Loading State
                      if (_loading) ...[
                        const SizedBox(height: AppSizes.paddingL),
                        Container(
                          padding: const EdgeInsets.all(AppSizes.paddingM),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusL),
                          ),
                          child: Column(
                            children: [
                              const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: AppSizes.paddingM),
                              Text(
                                'Processing image...',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Image Preview and Results
                      if (_imageFile != null && !_loading) ...[
                        const SizedBox(height: AppSizes.paddingL),
                        Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusL),
                            image: DecorationImage(
                              image: FileImage(_imageFile!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSizes.paddingM),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _showImageSourceDialog,
                                icon: const Icon(Icons.refresh_rounded),
                                label: const Text('Rescan'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.accent,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppSizes.radiusM,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Extracted Text
                        if (_recognizedText != null) ...[
                          const SizedBox(height: AppSizes.paddingL),
                          Container(
                            width: double.infinity,
                            constraints: const BoxConstraints(
                                minHeight: 200, maxHeight: 400),
                            padding: const EdgeInsets.all(AppSizes.paddingM),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.circular(AppSizes.radiusL),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.shadow,
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.text_fields_rounded,
                                      color: AppColors.primary,
                                      size: 20,
                                    ),
                                    const SizedBox(width: AppSizes.paddingS),
                                    Text(
                                      'Extracted Text',
                                      style: GoogleFonts.dmSans(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSizes.paddingM),
                                ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(maxHeight: 200),
                                  child: SingleChildScrollView(
                                    child: Text(
                                      _recognizedText!,
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.textDark,
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: AppSizes.paddingM),
                                // Language Selection and Translate Button
                                Consumer<UserProvider>(
                                  builder: (context, userProvider, child) {
                                    final availableSourceLanguages =
                                        TranslationService
                                            .getAvailableSourceLanguages(
                                                context);
                                    final availableTargetLanguages =
                                        TranslationService
                                            .getAvailableTargetLanguages(
                                                context);

                                    return Column(
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: DropdownButtonFormField<
                                                  TranslateLanguage>(
                                                isDense: true,
                                                value: _sourceLanguage,
                                                decoration:
                                                    const InputDecoration(
                                                  labelText: 'From',
                                                  border: OutlineInputBorder(),
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                          horizontal: 12,
                                                          vertical: 8),
                                                ),
                                                items: availableSourceLanguages
                                                    .map((language) {
                                                  return DropdownMenuItem(
                                                    value: language,
                                                    child: Text(
                                                        TranslationService
                                                            .getLanguageName(
                                                                language)),
                                                  );
                                                }).toList(),
                                                onChanged: (value) {
                                                  if (value != null) {
                                                    setState(() =>
                                                        _sourceLanguage =
                                                            value);
                                                  }
                                                },
                                              ),
                                            ),
                                            const SizedBox(
                                                width: AppSizes.paddingS),
                                            Icon(Icons.arrow_forward,
                                                color: AppColors.primary),
                                            const SizedBox(
                                                width: AppSizes.paddingS),
                                            Expanded(
                                              child: DropdownButtonFormField<
                                                  TranslateLanguage>(
                                                isDense: true,
                                                value: _targetLanguage,
                                                decoration:
                                                    const InputDecoration(
                                                  labelText: 'To',
                                                  border: OutlineInputBorder(),
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                          horizontal: 12,
                                                          vertical: 8),
                                                ),
                                                items: availableTargetLanguages
                                                    .map((language) {
                                                  final isPremium =
                                                      TranslationService
                                                          .isPremiumTargetLanguage(
                                                              language);
                                                  final userIsPremium =
                                                      userProvider.user
                                                              ?.isPremium ??
                                                          false;

                                                  return DropdownMenuItem(
                                                    value: language,
                                                    child: Row(
                                                      children: [
                                                        Text(TranslationService
                                                            .getLanguageName(
                                                                language)),
                                                        if (isPremium &&
                                                            !userIsPremium) ...[
                                                          const SizedBox(
                                                              width: 8),
                                                          Icon(Icons.lock,
                                                              size: 16,
                                                              color: AppColors
                                                                  .primary),
                                                        ],
                                                      ],
                                                    ),
                                                  );
                                                }).toList(),
                                                onChanged: (value) {
                                                  if (value != null) {
                                                    final isPremium =
                                                        TranslationService
                                                            .isPremiumTargetLanguage(
                                                                value);
                                                    final userIsPremium =
                                                        userProvider.user
                                                                ?.isPremium ??
                                                            false;

                                                    if (isPremium &&
                                                        !userIsPremium) {
                                                      TranslationService
                                                          .showUpgradeDialog(
                                                              context);
                                                    } else {
                                                      setState(() =>
                                                          _targetLanguage =
                                                              value);
                                                    }
                                                  }
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                            height: AppSizes.paddingM),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton.icon(
                                            onPressed: _translating
                                                ? null
                                                : _translateText,
                                            icon: _translating
                                                ? const SizedBox(
                                                    width: 16,
                                                    height: 16,
                                                    child:
                                                        CircularProgressIndicator(
                                                            strokeWidth: 2),
                                                  )
                                                : const Icon(Icons.translate),
                                            label: Text(_translating
                                                ? 'Translating...'
                                                : 'Translate'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  AppColors.primary,
                                              foregroundColor: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                                // Translated Text
                                if (_translatedText != null) ...[
                                  const SizedBox(height: AppSizes.paddingM),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.g_translate_rounded,
                                        color: AppColors.primary,
                                        size: 20,
                                      ),
                                      const SizedBox(width: AppSizes.paddingS),
                                      Text(
                                        'Translated Text',
                                        style: GoogleFonts.dmSans(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSizes.paddingS),
                                  Container(
                                    width: double.infinity,
                                    padding:
                                        const EdgeInsets.all(AppSizes.paddingS),
                                    decoration: BoxDecoration(
                                      color: AppColors.backgroundLight,
                                      borderRadius: BorderRadius.circular(
                                          AppSizes.radiusS),
                                      border:
                                          Border.all(color: AppColors.divider),
                                    ),
                                    child: Text(
                                      _translatedText!,
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.textDark,
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
