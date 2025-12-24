import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../providers/user_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/menu_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      drawer: _buildDrawer(context),
      body: Builder(
        builder: (context) => SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              child: Column(
                children: [
                  // Header with menu and logo
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Menu button (left side)
                      GestureDetector(
                        onTap: () {
                          Scaffold.of(context).openDrawer();
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
                            Icons.menu_rounded,
                            color: AppColors.textSecondary,
                            size: 24,
                          ),
                        ),
                      ),
                      // Logo (right side)
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
                    ],
                  ).animate().fadeIn(duration: 500.ms),

                  const SizedBox(height: AppSizes.paddingL),

                  // Search bar
                  const CustomSearchField().animate().fadeIn(duration: 500.ms, delay: 100.ms),

                  const SizedBox(height: AppSizes.paddingL),

                  // Welcome card
                  Consumer<UserProvider>(
                    builder: (context, userProvider, child) {
                      final user = userProvider.user;
                      return Container(
                        padding: const EdgeInsets.all(AppSizes.paddingL),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFA5BBCF),
                              Colors.white,
                              Color(0xFFA5BBCF),
                            ],
                            stops: [0.0, 0.5, 1.0],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(AppSizes.radiusL),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFA5BBCF).withAlpha((0.4 * 255).round()),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withAlpha((0.15 * 255).round()),
                                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                                  ),
                                  child: const Icon(
                                    Icons.favorite_rounded,
                                    color: AppColors.primary,
                                    size: 28,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSizes.paddingM,
                                    vertical: AppSizes.paddingS,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withAlpha((0.15 * 255).round()),
                                    borderRadius: BorderRadius.circular(AppSizes.radiusL),
                                  ),
                                  child: Text(
                                    user?.isPremium == true ? 'Premium' : 'Free Plan',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSizes.paddingM),
                            Text(
                              'Welcome${user?.fullName != null ? ', ${user!.fullName.split(' ').first}' : ''}!',
                              style: GoogleFonts.dmSans(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryDark,
                              ),
                            ),
                            const SizedBox(height: AppSizes.paddingXS),
                            Text(
                              'Your Medical Space',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: AppSizes.paddingS),
                            Text(
                              'All your health records in one secure place',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ).animate().fadeIn(duration: 500.ms, delay: 200.ms).slideY(begin: -0.1),

                  const SizedBox(height: AppSizes.paddingL),

                  // Menu cards - Professional medical design
                  MenuCard(
                    title: AppStrings.myFiles,
                    subtitle: 'View and manage your documents',
                    icon: Icons.folder_outlined,
                    onTap: () {
                      Navigator.pushNamed(context, '/my-files');
                    },
                    accentColor: AppColors.primary,
                  ).animate().fadeIn(duration: 500.ms, delay: 300.ms).slideX(begin: -0.1),

                  const SizedBox(height: AppSizes.paddingM),

                  MenuCard(
                    title: AppStrings.myQrCode,
                    subtitle: 'Share your health pass',
                    icon: Icons.qr_code_2_rounded,
                    onTap: () {
                      Navigator.pushNamed(context, '/qr-code');
                    },
                    accentColor: const Color(0xFF5B8FB9),
                  ).animate().fadeIn(duration: 500.ms, delay: 400.ms).slideX(begin: -0.1),

                  const SizedBox(height: AppSizes.paddingM),

                  MenuCard(
                    title: AppStrings.emergency,
                    subtitle: 'Quick access in emergencies',
                    icon: Icons.emergency_outlined,
                    onTap: () {
                      Navigator.pushNamed(context, '/emergency');
                    },
                    accentColor: const Color(0xFFD9534F),
                  ).animate().fadeIn(duration: 500.ms, delay: 500.ms).slideX(begin: -0.1),

                  const SizedBox(height: AppSizes.paddingM),

                  MenuCard(
                    title: AppStrings.personalCard,
                    subtitle: 'Your medical ID card',
                    icon: Icons.badge_outlined,
                    onTap: () {
                      Navigator.pushNamed(context, '/personal-card');
                    },
                    accentColor: AppColors.accent,
                  ).animate().fadeIn(duration: 500.ms, delay: 600.ms).slideX(begin: -0.1),

                  const SizedBox(height: AppSizes.paddingXL),

                  // Bottom navigation placeholder
                  _buildBottomNav(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(AppSizes.radiusL)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Drawer Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSizes.paddingL),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha((0.2 * 255).round()),
                      borderRadius: BorderRadius.circular(AppSizes.radiusL),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingM),
                  Consumer<UserProvider>(
                    builder: (context, userProvider, child) {
                      final user = userProvider.user;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.fullName ?? 'User',
                            style: GoogleFonts.dmSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: AppSizes.paddingXS),
                          Text(
                            user?.email ?? '',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withAlpha((0.8 * 255).round()),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSizes.paddingM),

            // Menu Items
            _buildDrawerItem(
              icon: Icons.person_outline_rounded,
              title: 'My Profile',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/profile');
              },
            ),

            _buildDrawerItem(
              icon: Icons.edit_outlined,
              title: 'Edit Profile',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/edit-profile');
              },
            ),

            _buildDrawerItem(
              icon: Icons.credit_card_outlined,
              title: 'Billing Info',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/billing');
              },
            ),

            const Divider(
              color: AppColors.inputBackground,
              indent: AppSizes.paddingL,
              endIndent: AppSizes.paddingL,
            ),

            _buildDrawerItem(
              icon: Icons.settings_outlined,
              title: 'Settings',
              onTap: () {
                Navigator.pop(context);
              },
            ),

            _buildDrawerItem(
              icon: Icons.help_outline_rounded,
              title: 'Help & Support',
              onTap: () {
                Navigator.pop(context);
              },
            ),

            const Spacer(),

            // Logout button
            Padding(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              child: Consumer<UserProvider>(
                builder: (context, userProvider, child) {
                  return GestureDetector(
                    onTap: () {
                      userProvider.logout();
                      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSizes.paddingM),
                      decoration: BoxDecoration(
                        color: AppColors.error.withAlpha((0.1 * 255).round()),
                        borderRadius: BorderRadius.circular(AppSizes.radiusL),
                        border: Border.all(
                          color: AppColors.error.withAlpha((0.3 * 255).round()),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.logout_rounded,
                            color: AppColors.error,
                            size: 20,
                          ),
                          const SizedBox(width: AppSizes.paddingS),
                          Text(
                            'Logout',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 24),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.textDark,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: AppColors.textSecondary,
        size: 16,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingM),
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
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
          child: Row(
            children: [
              _buildNavItem(Icons.home_rounded, 'Home', true, () {}),
              const SizedBox(width: AppSizes.paddingL),
              _buildNavItem(Icons.folder_rounded, 'Files', false, () {
                Navigator.pushNamed(context, '/my-files');
              }),
              const SizedBox(width: AppSizes.paddingL),
              _buildNavItem(Icons.qr_code_scanner_rounded, 'Scan', false, () {
                Navigator.pushNamed(context, '/qr-code');
              }),
              const SizedBox(width: AppSizes.paddingL),
              _buildNavItem(Icons.person_rounded, 'Profile', false, () {
                Navigator.pushNamed(context, '/profile');
              }),
              const SizedBox(width: AppSizes.paddingL),
              _buildNavItem(Icons.emergency_rounded, 'Emergency', false, () {
                Navigator.pushNamed(context, '/emergency');
              }),
              const SizedBox(width: AppSizes.paddingL),
              _buildNavItem(Icons.credit_card_rounded, 'Card', false, () {
                Navigator.pushNamed(context, '/personal-card');
              }),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 700.ms).slideY(begin: 0.3);
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingM,
          vertical: AppSizes.paddingS,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withAlpha((0.1 * 255).round())
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        ),
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
      ),
    );
  }
}
