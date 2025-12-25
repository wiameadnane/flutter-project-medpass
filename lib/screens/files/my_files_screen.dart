import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants.dart';
import '../../widgets/menu_card.dart';
import '../../widgets/ocr_service.dart';
import '../files/upload_file_screen.dart';

class MyFilesScreen extends StatelessWidget {
  const MyFilesScreen({super.key});

  // Affiche le menu de sélection immédiatement
  void _showUploadOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusL)),
      ),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.primary),
              title: const Text('Pick from Gallery'),
              onTap: () async {
                Navigator.pop(ctx);
                final result = await FilePicker.platform.pickFiles();
                if (result != null) {
                  _navigateToForm(context, result.files.first);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primary),
              title: const Text('Scan with Camera (AI)'),
              onTap: () async {
                Navigator.pop(ctx);
                _handleAIScan(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Gère le scan IA complet
  Future<void> _handleAIScan(BuildContext context) async {
    final picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);
    if (photo == null) return;

    // Loader pendant le traitement IA sur le Samsung
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final ocr = OCRService();
      final rawText = await ocr.scanDocument(photo.path);
      final translated = await ocr.translateResult(rawText);
      final pdfFile = await ocr.generateMedicalPdf(File(photo.path), rawText, translated);

      if (!context.mounted) return;
      Navigator.pop(context); // Ferme le loader

      final platformFile = PlatformFile(
        name: pdfFile.path.split('/').last,
        path: pdfFile.path,
        size: pdfFile.lengthSync(),
        bytes: pdfFile.readAsBytesSync(),
      );

      _navigateToForm(context, platformFile);
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  void _navigateToForm(BuildContext context, PlatformFile file) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UploadFileScreen(initialFile: file),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.paddingL),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 45, height: 45,
                        decoration: BoxDecoration(
                          color: AppColors.backgroundLight,
                          borderRadius: BorderRadius.circular(AppSizes.radiusM),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primary, size: 22),
                      ),
                    ),
                    Container(
                      width: 50, height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.backgroundLight,
                        borderRadius: BorderRadius.circular(AppSizes.radiusM),
                      ),
                      child: const Icon(Icons.medical_services_rounded, color: AppColors.primary, size: 30),
                    ),
                  ],
                ).animate().fadeIn(duration: 500.ms),

                const SizedBox(height: AppSizes.paddingXL),
                Text(AppStrings.myFiles, style: GoogleFonts.dmSans(fontSize: 36, fontWeight: FontWeight.w600, color: AppColors.accent)).animate().fadeIn(duration: 500.ms, delay: 100.ms),
                const SizedBox(height: AppSizes.paddingXL),

                MenuCard(
                  title: AppStrings.viewFiles,
                  subtitle: 'Browse all your medical files',
                  icon: Icons.folder_open_rounded,
                  onTap: () => Navigator.pushNamed(context, '/files-list'),
                  accentColor: AppColors.accent,
                ).animate().fadeIn(duration: 500.ms, delay: 200.ms).slideX(begin: -0.1),

                const SizedBox(height: AppSizes.paddingM),

                // LA CARTE MODIFIÉE
                MenuCard(
                  title: AppStrings.uploadMore,
                  subtitle: 'Add new documents',
                  icon: Icons.cloud_upload_outlined,
                  onTap: () => _showUploadOptions(context),
                  accentColor: AppColors.primary,
                ).animate().fadeIn(duration: 500.ms, delay: 300.ms).slideX(begin: -0.1),

                const SizedBox(height: AppSizes.paddingM),

                MenuCard(
                  title: AppStrings.importantInfo,
                  subtitle: 'Critical health information',
                  icon: Icons.info_outline_rounded,
                  onTap: () => Navigator.pushNamed(context, '/important-files'),
                  accentColor: AppColors.primaryLight,
                ).animate().fadeIn(duration: 500.ms, delay: 400.ms).slideX(begin: -0.1),

                const SizedBox(height: AppSizes.paddingXL * 2),

                Container(
                  width: 200, height: 200,
                  decoration: BoxDecoration(color: AppColors.backgroundLight, borderRadius: BorderRadius.circular(AppSizes.radiusL)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.folder_special_rounded, size: 80, color: AppColors.primary.withAlpha((0.5 * 255).round())),
                      const SizedBox(height: AppSizes.paddingM),
                      Text('Your Medical Records', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
                    ],
                  ),
                ).animate().fadeIn(duration: 600.ms, delay: 500.ms).scale(begin: const Offset(0.9, 0.9)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}