import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../providers/user_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/menu_card.dart';
import '../../services/firestore_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
                // Header with logo and profile
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
                    // Settings button
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/billing');
                      },
                      child: Container(
                        width: 45,
                        height: 45,
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
                          Icons.settings_outlined,
                          color: AppColors.textSecondary,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 500.ms),

                const SizedBox(height: AppSizes.paddingL),

                // Search bar
                const CustomSearchField().animate().fadeIn(duration: 500.ms, delay: 100.ms),

                const SizedBox(height: AppSizes.paddingL),

                // Profile card
                Consumer<UserProvider>(
                  builder: (context, userProvider, child) {
                    final user = userProvider.user;
                    return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/profile');
                      },
                      child: Container(
                        padding: const EdgeInsets.all(AppSizes.paddingM),
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
                            // Profile image placeholder
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: AppColors.backgroundLight,
                                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                              ),
                              child: Icon(
                                Icons.person_rounded,
                                size: 50,
                                color: AppColors.primary.withOpacity(0.5),
                              ),
                            ),
                            const SizedBox(width: AppSizes.paddingM),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user?.fullName ?? 'User',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                  const SizedBox(height: AppSizes.paddingXS),
                                  Text(
                                    AppStrings.clickToAccessProfile,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.accent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: AppColors.textSecondary,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ).animate().fadeIn(duration: 500.ms, delay: 200.ms).slideX(begin: -0.1),

                const SizedBox(height: AppSizes.paddingL),

                // Menu cards
                MenuCard(
                  title: AppStrings.myFiles,
                  icon: Icons.folder_rounded,
                  onTap: () {
                    Navigator.pushNamed(context, '/my-files');
                  },
                ).animate().fadeIn(duration: 500.ms, delay: 300.ms).slideX(begin: -0.1),

                const SizedBox(height: AppSizes.paddingM),

                MenuCard(
                  title: AppStrings.myQrCode,
                  icon: Icons.qr_code_rounded,
                  onTap: () {
                    Navigator.pushNamed(context, '/qr-code');
                  },
                  backgroundColor: AppColors.primaryLight,
                ).animate().fadeIn(duration: 500.ms, delay: 400.ms).slideX(begin: -0.1),

                const SizedBox(height: AppSizes.paddingM),

                MenuCard(
                  title: AppStrings.emergency,
                  icon: Icons.emergency_rounded,
                  onTap: () {
                    Navigator.pushNamed(context, '/emergency');
                  },
                  backgroundColor: AppColors.error.withOpacity(0.9),
                ).animate().fadeIn(duration: 500.ms, delay: 500.ms).slideX(begin: -0.1),

                const SizedBox(height: AppSizes.paddingM),

                MenuCard(
                  title: AppStrings.personalCard,
                  icon: Icons.credit_card_rounded,
                  onTap: () {
                    Navigator.pushNamed(context, '/personal-card');
                  },
                  backgroundColor: AppColors.accent,
                ).animate().fadeIn(duration: 500.ms, delay: 600.ms).slideX(begin: -0.1),

                const SizedBox(height: AppSizes.paddingXL),

                // Firestore test button (debug/testing only)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Running Firestore test...')),
                      );
                      try {
                        await FirestoreService.writeTestDoc();
                        final data = await FirestoreService.readTestDoc();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Success: ${data ?? 'no data'}')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Firestore error: $e')),
                        );
                      }
                    },
                    child: const Text('Test Firestore'),
                  ),
                ),

                // Bottom navigation placeholder
                _buildBottomNav(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home_rounded, 'Home', true, () {}),
          _buildNavItem(Icons.folder_rounded, 'Files', false, () {
            Navigator.pushNamed(context, '/my-files');
          }),
          _buildNavItem(Icons.qr_code_scanner_rounded, 'Scan', false, () {
            Navigator.pushNamed(context, '/qr-code');
          }),
          _buildNavItem(Icons.person_rounded, 'Profile', false, () {
            Navigator.pushNamed(context, '/profile');
          }),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 700.ms).slideY(begin: 0.3);
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? AppColors.primary : AppColors.textSecondary,
            size: 28,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: isActive ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
