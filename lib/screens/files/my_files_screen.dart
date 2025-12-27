import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants.dart';
import '../ocr_scan_screen.dart';
import 'upload_file_screen.dart';

class MyFilesScreen extends StatelessWidget {
  const MyFilesScreen({super.key});

  void _showUploadOptionsDialog(BuildContext parentContext) {
    showModalBottomSheet(
      context: parentContext,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusL)),
      ),
      builder: (sheetContext) => SafeArea(
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
                'Add Document',
                style: GoogleFonts.dmSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: AppSizes.paddingS),
              Text(
                'Choose how to add your document',
                style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSizes.paddingL),

              // Scan Document Option
              _buildUploadOption(
                context: sheetContext,
                icon: Icons.document_scanner_rounded,
                title: 'Scan Document',
                subtitle: 'Camera scan with OCR & translation',
                color: AppColors.primary,
                onTap: () {
                  Navigator.pop(sheetContext);
                  Navigator.push(
                    parentContext,
                    MaterialPageRoute(
                      builder: (context) => const OCRScanScreen(),
                      settings: const RouteSettings(arguments: {'autoShowDialog': true}),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSizes.paddingM),

              // Upload PDF Option
              _buildUploadOption(
                context: sheetContext,
                icon: Icons.picture_as_pdf_rounded,
                title: 'Upload PDF',
                subtitle: 'Import existing PDF file directly',
                color: AppColors.accent,
                onTap: () async {
                  Navigator.pop(sheetContext);
                  await _pickAndUploadPdf(parentContext);
                },
              ),
              const SizedBox(height: AppSizes.paddingL),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadOption({
    required BuildContext context,
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
              child: Icon(icon, color: color, size: 28),
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
                      fontSize: 13,
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

  Future<void> _pickAndUploadPdf(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        // Navigate directly to upload screen with the PDF
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UploadFileScreen(initialFile: file),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking file: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Files Section
              _buildSectionHeader('Documents').animate().fadeIn(duration: 300.ms),
              const SizedBox(height: AppSizes.paddingS),
              _buildSettingsCard([
                _MenuTile(
                  icon: Icons.folder_open_rounded,
                  title: AppStrings.viewFiles,
                  subtitle: 'Browse all your medical files',
                  iconColor: AppColors.accent,
                  onTap: () => Navigator.pushNamed(context, '/files-list'),
                ),
                _MenuTile(
                  icon: Icons.star_rounded,
                  title: 'Important Files',
                  subtitle: 'Your starred documents',
                  iconColor: AppColors.warning,
                  onTap: () => Navigator.pushNamed(context, '/important-files'),
                ),
              ]).animate().fadeIn(duration: 300.ms, delay: 100.ms),

              const SizedBox(height: AppSizes.paddingL),

              // Upload Section
              _buildSectionHeader('Add New').animate().fadeIn(duration: 300.ms, delay: 150.ms),
              const SizedBox(height: AppSizes.paddingS),
              _buildSettingsCard([
                _MenuTile(
                  icon: Icons.add_photo_alternate_rounded,
                  title: AppStrings.uploadMore,
                  subtitle: 'Scan or upload documents',
                  iconColor: AppColors.primary,
                  onTap: () => _showUploadOptionsDialog(context),
                ),
              ]).animate().fadeIn(duration: 300.ms, delay: 200.ms),

              const SizedBox(height: AppSizes.paddingXL),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSizes.paddingS),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<_MenuTile> tiles) {
    return Container(
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
        children: tiles.map((tile) {
          final isLast = tiles.last == tile;
          return Column(
            children: [
              tile,
              if (!isLast)
                Divider(
                  height: 1,
                  indent: 56,
                  color: AppColors.inputBackground.withAlpha((0.5 * 255).round()),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color iconColor;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withAlpha((0.1 * 255).round()),
          borderRadius: BorderRadius.circular(AppSizes.radiusS),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.textDark,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: AppColors.textSecondary,
        size: 16,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingM,
        vertical: AppSizes.paddingS,
      ),
    );
  }
}
