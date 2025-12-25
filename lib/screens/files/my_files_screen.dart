import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants.dart';
import '../../widgets/menu_card.dart';

class MyFilesScreen extends StatelessWidget {
  const MyFilesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppStrings.myFiles,
          style: GoogleFonts.dmSans(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          child: Column(
            children: [
              // Menu cards
                MenuCard(
                  title: AppStrings.viewFiles,
                  subtitle: 'Browse all your medical files',
                  icon: Icons.folder_open_rounded,
                  onTap: () {
                    Navigator.pushNamed(context, '/files-list');
                  },
                  accentColor: AppColors.accent,
                ).animate().fadeIn(duration: 500.ms, delay: 200.ms).slideX(begin: -0.1),

                const SizedBox(height: AppSizes.paddingM),

                MenuCard(
                  title: AppStrings.uploadMore,
                  subtitle: 'Add new documents',
                  icon: Icons.cloud_upload_outlined,
                  onTap: () {
                    _showUploadDialog(context);
                  },
                  accentColor: AppColors.primary,
                ).animate().fadeIn(duration: 500.ms, delay: 300.ms).slideX(begin: -0.1),

                const SizedBox(height: AppSizes.paddingM),

                MenuCard(
                  title: AppStrings.importantInfo,
                  subtitle: 'Critical health information',
                  icon: Icons.info_outline_rounded,
                  onTap: () {
                    Navigator.pushNamed(context, '/important-files');
                  },
                  accentColor: AppColors.primaryLight,
                ).animate().fadeIn(duration: 500.ms, delay: 400.ms).slideX(begin: -0.1),

                const SizedBox(height: AppSizes.paddingXL * 2),

                // Illustration placeholder
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(AppSizes.radiusL),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.folder_special_rounded,
                        size: 80,
                        color: AppColors.primary.withAlpha((0.5 * 255).round()),
                      ),
                      const SizedBox(height: AppSizes.paddingM),
                      Text(
                        'Your Medical Records',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 600.ms, delay: 500.ms).scale(begin: const Offset(0.9, 0.9)),
            ],
          ),
        ),
      ),
    );
  }

  void _showUploadDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: AppSizes.paddingL,
              right: AppSizes.paddingL,
              top: AppSizes.paddingL,
              bottom: MediaQuery.of(context).viewInsets.bottom + AppSizes.paddingL,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.inputBackground,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: AppSizes.paddingL),
                Text(
                  'Upload Document',
                  style: GoogleFonts.dmSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: AppSizes.paddingL),
                _buildUploadOption(
                  context,
                  Icons.camera_alt_rounded,
                  'Take Photo',
                  'Capture document with camera',
                ),
                const SizedBox(height: AppSizes.paddingM),
                _buildUploadOption(
                  context,
                  Icons.photo_library_rounded,
                  'Choose from Gallery',
                  'Select image from your gallery',
                ),
                const SizedBox(height: AppSizes.paddingM),
                _buildUploadOption(
                  context,
                  Icons.insert_drive_file_rounded,
                  'Upload PDF',
                  'Select PDF from your files',
                ),
                const SizedBox(height: AppSizes.paddingM),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUploadOption(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$title - Coming soon'),
            backgroundColor: AppColors.primary,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        decoration: BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha((0.1 * 255).round()),
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
              child: Icon(icon, color: AppColors.primary, size: 24),
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
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: AppColors.textSecondary, size: 16),
          ],
        ),
      ),
    );
  }
}
