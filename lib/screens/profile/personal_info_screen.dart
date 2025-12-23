import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../providers/user_provider.dart';

class PersonalInfoScreen extends StatelessWidget {
  const PersonalInfoScreen({super.key});

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
          AppStrings.profile,
          style: GoogleFonts.dmSans(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: AppColors.textDark,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/edit-profile');
            },
            child: Container(
              margin: const EdgeInsets.only(right: AppSizes.paddingM),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingM,
                vertical: AppSizes.paddingS,
              ),
              decoration: BoxDecoration(
                color: AppColors.backgroundGrey,
                borderRadius: BorderRadius.circular(AppSizes.radiusCircle),
              ),
              child: Text(
                AppStrings.edit,
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final user = userProvider.user;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.paddingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User name
                Center(
                  child: Text(
                    user?.fullName ?? 'User',
                    style: GoogleFonts.dmSans(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                ).animate().fadeIn(duration: 500.ms),

                const SizedBox(height: AppSizes.paddingL),

                // Personal Info section header
                Text(
                  AppStrings.personalInfo,
                  style: GoogleFonts.dmSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textDark,
                  ),
                ).animate().fadeIn(duration: 500.ms, delay: 100.ms),

                const SizedBox(height: AppSizes.paddingS),
                const Divider(color: AppColors.divider),
                const SizedBox(height: AppSizes.paddingM),

                // Info items
                _buildInfoRow(
                  'DATE OF BIRTH',
                  user?.formattedDateOfBirth ?? 'Not set',
                ).animate().fadeIn(duration: 500.ms, delay: 150.ms),

                const SizedBox(height: AppSizes.paddingM),

                _buildInfoRow(
                  AppStrings.userId.toUpperCase(),
                  user?.id ?? 'N/A',
                ).animate().fadeIn(duration: 500.ms, delay: 200.ms),

                const SizedBox(height: AppSizes.paddingXL),

                // Health metrics
                _buildHealthMetric(
                  Icons.bloodtype_rounded,
                  'Blood Type',
                  user?.bloodType ?? 'Not set',
                  AppColors.error.withAlpha((0.1 * 255).round()),
                ).animate().fadeIn(duration: 500.ms, delay: 250.ms),

                const SizedBox(height: AppSizes.paddingM),

                _buildHealthMetric(
                  Icons.fitness_center_rounded,
                  'Weight',
                  user?.formattedWeight ?? 'Not set',
                  AppColors.accent.withAlpha((0.1 * 255).round()),
                ).animate().fadeIn(duration: 500.ms, delay: 300.ms),

                const SizedBox(height: AppSizes.paddingM),

                _buildHealthMetric(
                  Icons.height_rounded,
                  'Height',
                  user?.formattedHeight ?? 'Not set',
                  AppColors.primary.withAlpha((0.1 * 255).round()),
                ).animate().fadeIn(duration: 500.ms, delay: 350.ms),

                const SizedBox(height: AppSizes.paddingM),

                _buildHealthMetric(
                  Icons.flag_rounded,
                  'Nationality',
                  user?.nationality ?? 'Not set',
                  AppColors.warning.withAlpha((0.1 * 255).round()),
                ).animate().fadeIn(duration: 500.ms, delay: 400.ms),

                const SizedBox(height: AppSizes.paddingM),

                _buildHealthMetric(
                  Icons.person_rounded,
                  'Gender',
                  user?.gender ?? 'Not set',
                  AppColors.primaryLight.withAlpha((0.1 * 255).round()),
                ).animate().fadeIn(duration: 500.ms, delay: 450.ms),

                const SizedBox(height: AppSizes.paddingXL),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textDark,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildHealthMetric(IconData icon, String label, String value, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingS),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
            child: Icon(icon, size: 24, color: AppColors.textDark),
          ),
          const SizedBox(width: AppSizes.paddingM),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.dmSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
