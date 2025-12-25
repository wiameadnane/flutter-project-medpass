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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.paddingL),
            child: Column(
              children: [
                // Header
                Row(
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
                ).animate().fadeIn(duration: 500.ms),

                const SizedBox(height: AppSizes.paddingXL),

                // Title
                Text(
                  AppStrings.myFiles,
                  style: GoogleFonts.dmSans(
                    fontSize: 36,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent,
                  ),
                ).animate().fadeIn(duration: 500.ms, delay: 100.ms),

                const SizedBox(height: AppSizes.paddingXL),

                // Menu cards
                MenuCard(
                      title: AppStrings.viewFiles,
                      subtitle: 'Browse all your medical files',
                      icon: Icons.folder_open_rounded,
                      onTap: () {
                        Navigator.pushNamed(context, '/files-list');
                      },
                      accentColor: AppColors.accent,
                    )
                    .animate()
                    .fadeIn(duration: 500.ms, delay: 200.ms)
                    .slideX(begin: -0.1),

                const SizedBox(height: AppSizes.paddingM),

                MenuCard(
                      title: AppStrings.uploadMore,
                      subtitle: 'Add new documents',
                      icon: Icons.cloud_upload_outlined,
                      onTap: () {
                        Navigator.pushNamed(context, '/upload-file');
                      },
                      accentColor: AppColors.primary,
                    )
                    .animate()
                    .fadeIn(duration: 500.ms, delay: 300.ms)
                    .slideX(begin: -0.1),

                const SizedBox(height: AppSizes.paddingM),

                MenuCard(
                      title: AppStrings.importantInfo,
                      subtitle: 'Critical health information',
                      icon: Icons.info_outline_rounded,
                      onTap: () {
                        Navigator.pushNamed(context, '/important-files');
                      },
                      accentColor: AppColors.primaryLight,
                    )
                    .animate()
                    .fadeIn(duration: 500.ms, delay: 400.ms)
                    .slideX(begin: -0.1),

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
                            color: AppColors.primary.withAlpha(
                              (0.5 * 255).round(),
                            ),
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
                    )
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 500.ms)
                    .scale(begin: const Offset(0.9, 0.9)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Upload dialog and helper removed (not used) to clean up analyzer warnings
}
