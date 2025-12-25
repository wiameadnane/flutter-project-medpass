import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../models/medical_file_model.dart';
import '../../providers/user_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class FileViewerScreen extends StatelessWidget {
  final FileCategory category;

  const FileViewerScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 1000),
              child: Column(
                children: [
                  // Header
                  Padding(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color: AppColors.backgroundLight,
                        borderRadius: BorderRadius.circular(AppSizes.radiusM),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ),
                  ),
                  // Logo
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundLight,
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    ),
                    child: const Icon(
                      Icons.medical_services_rounded,
                      color: AppColors.primary,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 500.ms),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingL,
              ),
              child: Text(
                AppStrings.allFilesInOneSpace,
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accent,
                ),
              ),
            ).animate().fadeIn(duration: 500.ms, delay: 100.ms),

            const SizedBox(height: AppSizes.paddingM),

            // Category title
            Container(
              margin: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingL,
                vertical: AppSizes.paddingS,
              ),
              decoration: BoxDecoration(
                color: _getCategoryColor(category),
                borderRadius: BorderRadius.circular(AppSizes.radiusL),
              ),
              child: Text(
                _getCategoryName(category),
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ).animate().fadeIn(duration: 500.ms, delay: 200.ms),

            const SizedBox(height: AppSizes.paddingL),

            // Document viewer
                  Expanded(
                    child: Consumer<UserProvider>(
                      builder: (context, userProvider, child) {
                        final files = userProvider.getFilesByCategory(category);
                        if (files.isEmpty) {
                          return _buildEmptyState();
                        }
                        // Center the list on wide screens
                        return Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 900),
                            child: _buildFilesList(context, files),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildFilesList(BuildContext context, List<MedicalFileModel> files) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      itemCount: files.length,
      itemBuilder: (context, index) {
        final file = files[index];
        return Card(
          margin: const EdgeInsets.only(bottom: AppSizes.paddingM),
          child: ListTile(
            leading: _buildThumbnail(file),
            title: Text(
              file.name,
              style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(file.description ?? '', style: GoogleFonts.inter()),
            trailing: Icon(Icons.open_in_new_rounded),
            onTap: () => _openFilePreview(context, file),
          ),
        );
      },
    );
  }

  Widget _buildThumbnail(MedicalFileModel file) {
    if (file.fileUrl != null && file.isImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        child: Image.network(
          file.fileUrl!,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            width: 56,
            height: 56,
            color: Colors.grey[200],
            child: const Icon(Icons.broken_image, color: Colors.grey),
          ),
        ),
      );
    }

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
      child: const Icon(
        Icons.insert_drive_file_outlined,
        color: AppColors.textSecondary,
      ),
    );
  }

  void _openFilePreview(BuildContext context, MedicalFileModel file) {
    if (file.fileUrl != null && file.isImage) {
      showDialog(
        context: context,
        builder: (dialogContext) => Dialog(
          insetPadding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(dialogContext).size.width * 0.95,
              maxHeight: MediaQuery.of(dialogContext).size.height * 0.85,
            ),
            child: Stack(
              children: [
                InteractiveViewer(
                  child: Image.network(file.fileUrl!, fit: BoxFit.contain),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: CircleAvatar(
                    backgroundColor: Colors.white.withAlpha((0.9 * 255).round()),
                    child: IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textDark),
                      onPressed: () => Navigator.pop(dialogContext),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      return;
    }

    // Non-image files: show info / placeholder
    // If we have a file URL, offer to open it with an external app/browser.
    if (file.fileUrl != null) {
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(file.name),
          content: Text(file.description ?? 'Open this file in an external viewer.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                final messenger = ScaffoldMessenger.of(context);
                final uri = Uri.tryParse(file.fileUrl!);
                if (uri == null) {
                  messenger.showSnackBar(const SnackBar(content: Text('Invalid file URL')));
                  return;
                }

                try {
                  final can = await canLaunchUrl(uri);
                  if (!can) {
                    messenger.showSnackBar(const SnackBar(content: Text('Cannot open file URL')));
                    return;
                  }
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } catch (e) {
                  messenger.showSnackBar(SnackBar(content: Text('Failed to open file: ${e.toString()}')));
                }
              },
              child: const Text('Open'),
            ),
          ],
        ),
      );
      return;
    }

    // No URL available: show basic info
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(file.name),
        content: Text(
          file.description ?? 'No preview available for this file type.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
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

  // Removed unused document viewer helper to clean up analyzer warnings

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

  Color _getCategoryColor(FileCategory category) {
    switch (category) {
      case FileCategory.allergyReport:
        return AppColors.warning;
      case FileCategory.prescription:
        return AppColors.accent;
      case FileCategory.birthCertificate:
        return AppColors.primary;
      case FileCategory.medicalAnalysis:
        return AppColors.primaryLight;
      case FileCategory.other:
        return AppColors.textSecondary;
    }
  }
}
