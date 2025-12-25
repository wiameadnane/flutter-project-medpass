import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../models/medical_file_model.dart';
import '../../providers/user_provider.dart';
import '../../widgets/premium_widgets.dart';

class FilesListScreen extends StatefulWidget {
  const FilesListScreen({super.key});

  @override
  State<FilesListScreen> createState() => _FilesListScreenState();
}

class _FilesListScreenState extends State<FilesListScreen> {
  Future<void> _onRefresh() async {
    final userProvider = context.read<UserProvider>();
    await userProvider.refreshData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          color: AppColors.primary,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(0),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
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
                          AppStrings.allFilesInOneSpace,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.dmSans(
                            fontSize: 32,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accent,
                          ),
                        ).animate().fadeIn(duration: 500.ms, delay: 100.ms),

                        const SizedBox(height: AppSizes.paddingXL),

                        // Files list
                        Consumer<UserProvider>(
                          builder: (context, userProvider, child) {
                            final files = userProvider.medicalFiles;
                            final isPremium = userProvider.user?.isPremium ?? false;

                            return Column(
                              children: [
                                // File limit indicator for free users
                                if (!isPremium) ...[
                                  FileLimitIndicator(
                                    currentCount: files.length,
                                    maxCount: PremiumFeatures.freeFileLimit,
                                  ),
                                  const SizedBox(height: AppSizes.paddingL),
                                ],

                                if (files.isEmpty)
                                  _buildEmptyState()
                                else
                                  LayoutBuilder(builder: (ctx, box) {
                                    final isWide = box.maxWidth > 800;
                                    final cards = FileCategory.values
                                        .map((category) => _buildFileCard(
                                              context,
                                              category,
                                              userProvider.getFilesByCategory(category),
                                            ))
                                        .toList();

                                    if (isWide) {
                                      return GridView.count(
                                        crossAxisCount: 2,
                                        crossAxisSpacing: AppSizes.paddingM,
                                        mainAxisSpacing: AppSizes.paddingM,
                                        childAspectRatio: 3.2,
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        children: cards,
                                      );
                                    }

                                    return Column(children: cards);
                                  }),
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: AppSizes.paddingXL),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingXL),
      child: Column(
        children: [
          Icon(
            Icons.folder_off_rounded,
            size: 80,
            color: AppColors.textSecondary.withAlpha((0.5 * 255).round()),
          ),
          const SizedBox(height: AppSizes.paddingM),
          Text(
            'No files yet',
            style: GoogleFonts.dmSans(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSizes.paddingS),
          Text(
            'Upload your first medical document',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileCard(
    BuildContext context,
    FileCategory category,
    List<MedicalFileModel> files,
  ) {
    IconData icon;
    Color color;

    switch (category) {
      case FileCategory.allergyReport:
        icon = Icons.warning_amber_rounded;
        color = AppColors.warning;
        break;
      case FileCategory.prescription:
        icon = Icons.receipt_long_rounded;
        color = AppColors.accent;
        break;
      case FileCategory.birthCertificate:
        icon = Icons.description_rounded;
        color = AppColors.primary;
        break;
      case FileCategory.medicalAnalysis:
        icon = Icons.science_rounded;
        color = AppColors.primaryLight;
        break;
      case FileCategory.other:
        icon = Icons.folder_rounded;
        color = AppColors.textSecondary;
        break;
    }

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/file-viewer',
          arguments: category,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSizes.paddingM),
        padding: const EdgeInsets.all(AppSizes.paddingM),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingS),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha((0.2 * 255).round()),
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: AppSizes.paddingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getCategoryName(category),
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  if (files.isNotEmpty)
                    Text(
                      '${files.length} file${files.length > 1 ? 's' : ''}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withAlpha((0.8 * 255).round()),
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withAlpha((0.7 * 255).round()),
              size: 18,
            ),
          ],
        ),
      ).animate().fadeIn(duration: 500.ms, delay: Duration(milliseconds: 200 + (category.index * 100))).slideX(begin: -0.1),
    );
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
