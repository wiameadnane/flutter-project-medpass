import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants.dart';
import '../ocr_scan_screen.dart';

class MyFilesScreen extends StatelessWidget {
  const MyFilesScreen({super.key});

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
                  subtitle: 'Scan, capture or upload documents',
                  iconColor: AppColors.primary,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OCRScanScreen(),
                      settings: const RouteSettings(arguments: {'autoShowDialog': true}),
                    ),
                  ),
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
