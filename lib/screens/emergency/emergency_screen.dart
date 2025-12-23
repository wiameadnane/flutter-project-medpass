import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants.dart';

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    try {
      await launchUrl(launchUri);
    } catch (e) {
      debugPrint('Could not launch $launchUri');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
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
                    // Logo
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppSizes.radiusM),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadow,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.medical_services_rounded,
                        color: AppColors.primary,
                        size: 30,
                      ),
                    ),
                    // Back button
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.paddingM,
                          vertical: AppSizes.paddingS,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppSizes.radiusL),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.shadow,
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.arrow_back_ios, size: 16, color: AppColors.textDark),
                            const SizedBox(width: 4),
                            Text(
                              AppStrings.goBack,
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 500.ms),

                const SizedBox(height: AppSizes.paddingXL),

                // Title
                Text(
                  AppStrings.emergencyGuide,
                  style: GoogleFonts.outfit(
                    fontSize: 36,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent,
                  ),
                ).animate().fadeIn(duration: 500.ms, delay: 100.ms),

                const SizedBox(height: AppSizes.paddingXL),

                // Emergency contacts
                _buildEmergencyCard(
                  context,
                  'SAMU',
                  '15',
                  Icons.local_hospital_rounded,
                  AppColors.error,
                  'Medical Emergency Services',
                ).animate().fadeIn(duration: 500.ms, delay: 200.ms).slideX(begin: -0.1),

                const SizedBox(height: AppSizes.paddingM),

                _buildEmergencyCard(
                  context,
                  'Police',
                  '17',
                  Icons.local_police_rounded,
                  AppColors.primary,
                  'Police Emergency',
                ).animate().fadeIn(duration: 500.ms, delay: 300.ms).slideX(begin: -0.1),

                const SizedBox(height: AppSizes.paddingM),

                _buildEmergencyCard(
                  context,
                  'Firefighters',
                  '18',
                  Icons.local_fire_department_rounded,
                  Colors.orange,
                  'Fire & Rescue Services',
                ).animate().fadeIn(duration: 500.ms, delay: 400.ms).slideX(begin: -0.1),

                const SizedBox(height: AppSizes.paddingM),

                _buildEmergencyCard(
                  context,
                  'European Emergency',
                  '112',
                  Icons.emergency_rounded,
                  AppColors.accent,
                  'Universal Emergency Number',
                ).animate().fadeIn(duration: 500.ms, delay: 500.ms).slideX(begin: -0.1),

                const SizedBox(height: AppSizes.paddingXL),

                // Info card
                Container(
                  padding: const EdgeInsets.all(AppSizes.paddingL),
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
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 40,
                        color: AppColors.primary.withAlpha((0.7 * 255).round()),
                      ),
                      const SizedBox(height: AppSizes.paddingM),
                      Text(
                        'In case of emergency',
                        style: GoogleFonts.dmSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: AppSizes.paddingS),
                      Text(
                        'Stay calm and provide clear information about your location and the nature of the emergency.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 600.ms, delay: 600.ms).scale(begin: const Offset(0.95, 0.95)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmergencyCard(
    BuildContext context,
    String name,
    String number,
    IconData icon,
    Color color,
    String description,
  ) {
    return GestureDetector(
      onTap: () => _makePhoneCall(number),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingL),
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
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withAlpha((0.1 * 255).round()),
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: AppSizes.paddingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.dmSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  Text(
                    description,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingM,
                vertical: AppSizes.paddingS,
              ),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
              child: Text(
                number,
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
