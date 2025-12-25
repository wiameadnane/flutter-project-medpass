import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../models/medical_file_model.dart';
import '../../providers/user_provider.dart';

class FileViewerScreen extends StatelessWidget {
  final FileCategory category;

  const FileViewerScreen({super.key, required this.category});

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
          _getCategoryName(category),
          style: GoogleFonts.dmSans(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Document viewer
            Expanded(
              child: Consumer<UserProvider>(
                builder: (context, userProvider, child) {
                  final files = userProvider.getFilesByCategory(category);
                  if (files.isEmpty) {
                    return _buildEmptyState();
                  }
                  return _buildDocumentViewer(context, files.first);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.insert_drive_file_outlined,
            size: 80,
            color: AppColors.textSecondary.withAlpha((0.5 * 255).round()),
          ),
          const SizedBox(height: AppSizes.paddingM),
          Text(
            'No files in this category',
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentViewer(BuildContext context, MedicalFileModel file) {
    return Container(
      margin: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: const Color(0xFF525659),
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.3 * 255).round()),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Toolbar
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingM,
              vertical: AppSizes.paddingS,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF323639),
              borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusM)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.zoom_out, color: Colors.white, size: 20),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.zoom_in, color: Colors.white, size: 20),
                  onPressed: () {},
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.download, color: Colors.white, size: 20),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Download - Coming soon'),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.share, color: Colors.white, size: 20),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Share - Coming soon'),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Document content placeholder
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(AppSizes.paddingM),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSizes.radiusS),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.description_rounded,
                      size: 80,
                      color: AppColors.primary.withAlpha((0.5 * 255).round()),
                    ),
                    const SizedBox(height: AppSizes.paddingM),
                    Text(
                      file.name,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingS),
                    Text(
                      file.description ?? 'Document preview',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingL),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.paddingM,
                        vertical: AppSizes.paddingS,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundLight,
                        borderRadius: BorderRadius.circular(AppSizes.radiusM),
                      ),
                      child: Text(
                        'PDF Preview Placeholder',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 600.ms, delay: 300.ms),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 300.ms).slideY(begin: 0.1);
  }

  String _getCategoryName(FileCategory category) {
    switch (category) {
      case FileCategory.allergyReport:
        return AppStrings.allergyReport;
      case FileCategory.prescription:
        return AppStrings.recentPrescriptions;
      case FileCategory.birthCertificate:
        return AppStrings.birthCertificate;
      case FileCategory.medicalAnalysis:
        return AppStrings.medicalAnalysis;
      case FileCategory.other:
        return 'Other Documents';
    }
  }
}
