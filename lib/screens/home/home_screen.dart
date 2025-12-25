import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/constants.dart';
import '../../providers/user_provider.dart';
import '../../widgets/common_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isRefreshing = false;

  Future<void> _onRefresh() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);

    try {
      final userProvider = context.read<UserProvider>();
      await userProvider.refreshData();
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      drawer: _buildDrawer(context),
      floatingActionButton: _buildFAB(context),
      body: Builder(
        builder: (context) => SafeArea(
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            color: AppColors.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.paddingL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    _buildHeader(context).animate().fadeIn(duration: 400.ms),

                    const SizedBox(height: AppSizes.paddingL),

                    // Critical Info Card (Always visible)
                    _buildCriticalInfoCard(context)
                        .animate()
                        .fadeIn(duration: 500.ms, delay: 100.ms)
                        .slideY(begin: -0.1),

                    const SizedBox(height: AppSizes.paddingL),

                    // Quick Actions Row (QR + Emergency)
                    _buildQuickActions(context)
                        .animate()
                        .fadeIn(duration: 500.ms, delay: 200.ms),

                    const SizedBox(height: AppSizes.paddingL),

                    // Main Menu Cards
                    _buildMainMenuSection(context),

                    const SizedBox(height: AppSizes.paddingL),

                    // Recent Files Section
                    _buildRecentFilesSection(context)
                        .animate()
                        .fadeIn(duration: 500.ms, delay: 500.ms),

                    const SizedBox(height: AppSizes.paddingXL),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Menu button
        GestureDetector(
          onTap: () => Scaffold.of(context).openDrawer(),
          child: Container(
            width: 48,
            height: 48,
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
        // App Logo
        Image.asset(
          'assets/images/medpass_logo.png',
          height: 120,
          fit: BoxFit.contain,
        ),
        // Emergency Mode button
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/emergency-mode'),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.emergency,
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              boxShadow: [
                BoxShadow(
                  color: AppColors.emergency.withAlpha((0.3 * 255).round()),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.emergency_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCriticalInfoCard(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.user;
        final hasAllergies = user?.allergies.isNotEmpty ?? false;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSizes.paddingL),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: AppColors.primaryGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withAlpha((0.3 * 255).round()),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User greeting
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, ${user?.fullName.split(' ').first ?? 'User'}',
                        style: GoogleFonts.dmSans(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Your Health Pass',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withAlpha((0.8 * 255).round()),
                        ),
                      ),
                    ],
                  ),
                  // Premium badge
                  if (user?.isPremium == true)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.paddingS,
                        vertical: AppSizes.paddingXS,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha((0.2 * 255).round()),
                        borderRadius: BorderRadius.circular(AppSizes.radiusS),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'Premium',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              const SizedBox(height: AppSizes.paddingL),

              // Critical info row
              Row(
                children: [
                  // Blood Type
                  _buildCriticalInfoItem(
                    icon: Icons.bloodtype_rounded,
                    label: 'Blood',
                    value: user?.bloodType ?? 'N/A',
                    color: Colors.white,
                  ),
                  const SizedBox(width: AppSizes.paddingL),
                  // Allergies indicator
                  Expanded(
                    child: _buildCriticalInfoItem(
                      icon: Icons.warning_amber_rounded,
                      label: 'Allergies',
                      value: hasAllergies
                          ? '${user!.allergies.length} known'
                          : 'None',
                      color: hasAllergies ? AppColors.warning : Colors.white,
                      isWarning: hasAllergies,
                    ),
                  ),
                ],
              ),

              // Show allergies if any
              if (hasAllergies) ...[
                const SizedBox(height: AppSizes.paddingM),
                Container(
                  padding: const EdgeInsets.all(AppSizes.paddingS),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withAlpha((0.2 * 255).round()),
                    borderRadius: BorderRadius.circular(AppSizes.radiusS),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_rounded, color: AppColors.warning, size: 16),
                      const SizedBox(width: AppSizes.paddingS),
                      Expanded(
                        child: Text(
                          user!.allergies.join(', '),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: AppSizes.paddingL),

              // Emergency contact
              if (user?.emergencyContactPhone != null &&
                  user!.emergencyContactPhone!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(AppSizes.paddingS),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha((0.15 * 255).round()),
                    borderRadius: BorderRadius.circular(AppSizes.radiusS),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.phone_rounded, color: Colors.white, size: 16),
                      const SizedBox(width: AppSizes.paddingS),
                      Expanded(
                        child: Text(
                          'Emergency: ${user.emergencyContactName ?? ''} (${user.emergencyContactPhone})',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCriticalInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool isWarning = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: (isWarning ? AppColors.warning : Colors.white)
                .withAlpha((0.2 * 255).round()),
            borderRadius: BorderRadius.circular(AppSizes.radiusS),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: AppSizes.paddingS),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: Colors.white.withAlpha((0.7 * 255).round()),
              ),
            ),
            Text(
              value,
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return GestureDetector(
      onTap: () => _showQuickQRCode(context),
      child: Container(
        width: double.infinity,
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
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingS),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha((0.1 * 255).round()),
                borderRadius: BorderRadius.circular(AppSizes.radiusS),
              ),
              child: const Icon(
                Icons.qr_code_2_rounded,
                color: AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: AppSizes.paddingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Show QR Code',
                    style: GoogleFonts.dmSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  Text(
                    'Share your health profile instantly',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.textMuted,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainMenuSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Access',
          style: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ).animate().fadeIn(duration: 500.ms, delay: 300.ms),
        const SizedBox(height: AppSizes.paddingM),
        Row(
          children: [
            Expanded(
              child: _buildMenuCard(
                context,
                icon: Icons.folder_rounded,
                title: 'My Files',
                subtitle: 'Documents',
                color: AppColors.primary,
                onTap: () => Navigator.pushNamed(context, '/my-files'),
              ),
            ),
            const SizedBox(width: AppSizes.paddingM),
            Expanded(
              child: _buildMenuCard(
                context,
                icon: Icons.person_rounded,
                title: 'Profile',
                subtitle: 'View info',
                color: AppColors.accent,
                onTap: () => Navigator.pushNamed(context, '/profile'),
              ),
            ),
          ],
        ).animate().fadeIn(duration: 500.ms, delay: 350.ms),
        const SizedBox(height: AppSizes.paddingM),
        Row(
          children: [
            Expanded(
              child: _buildMenuCard(
                context,
                icon: Icons.credit_card_rounded,
                title: 'Health Card',
                subtitle: 'NFC Card',
                color: AppColors.medication,
                onTap: () => Navigator.pushNamed(context, '/personal-card'),
              ),
            ),
            const SizedBox(width: AppSizes.paddingM),
            Expanded(
              child: _buildMenuCard(
                context,
                icon: Icons.local_hospital_rounded,
                title: 'Emergency',
                subtitle: 'Contacts',
                color: AppColors.emergency,
                onTap: () => Navigator.pushNamed(context, '/emergency'),
              ),
            ),
          ],
        ).animate().fadeIn(duration: 500.ms, delay: 400.ms),
      ],
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingS),
              decoration: BoxDecoration(
                color: color.withAlpha((0.1 * 255).round()),
                borderRadius: BorderRadius.circular(AppSizes.radiusS),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: AppSizes.paddingM),
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
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentFilesSection(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final recentFiles = userProvider.medicalFiles.take(3).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Files',
                  style: GoogleFonts.dmSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/my-files'),
                  child: Text(
                    'See All',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.paddingM),
            if (recentFiles.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSizes.paddingXL),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSizes.radiusL),
                  border: Border.all(
                    color: AppColors.divider,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.folder_open_rounded,
                      size: 48,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(height: AppSizes.paddingM),
                    Text(
                      'No files yet',
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingXS),
                    Text(
                      'Add your first medical document',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...recentFiles.map((file) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.paddingS),
                    child: _buildRecentFileItem(context, file),
                  )),
          ],
        );
      },
    );
  }

  Widget _buildRecentFileItem(BuildContext context, dynamic file) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/file-viewer', arguments: file.category),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingS),
              decoration: BoxDecoration(
                color: AppColors.document.withAlpha((0.1 * 255).round()),
                borderRadius: BorderRadius.circular(AppSizes.radiusS),
              ),
              child: const Icon(
                Icons.description_rounded,
                color: AppColors.document,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSizes.paddingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    file.name,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    file.categoryName,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.textMuted,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showQuickQRCode(BuildContext context) {
    final user = context.read<UserProvider>().user;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: Container(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusXL)),
          ),
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
              const SizedBox(height: AppSizes.paddingM),
              Text(
                'Your Health Pass',
                style: GoogleFonts.dmSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: AppSizes.paddingM),
              Container(
                padding: const EdgeInsets.all(AppSizes.paddingM),
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(AppSizes.radiusL),
                ),
                child: QrImageView(
                  data: user?.id ?? 'medpass-user',
                  version: QrVersions.auto,
                  size: 160,
                  backgroundColor: Colors.white,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: AppColors.primary,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.paddingM),
              Text(
                'Scan to view medical profile',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSizes.paddingM),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/qr-code');
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSizes.paddingM),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppSizes.radiusL),
                  ),
                  child: Center(
                    child: Text(
                      'View Full Screen',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.paddingS),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAB(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        // TODO: Navigate to add document screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Add document feature coming soon'),
            backgroundColor: AppColors.primary,
          ),
        );
      },
      backgroundColor: AppColors.accent,
      elevation: 8,
      child: const Icon(
        Icons.add_rounded,
        color: Colors.white,
        size: 28,
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
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: AppColors.primaryGradient,
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
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: AppSizes.paddingXS),
                          Text(
                            user?.email ?? '',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withAlpha((0.8 * 255).round()),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
              icon: Icons.folder_outlined,
              title: 'My Files',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/my-files');
              },
            ),
            _buildDrawerItem(
              icon: Icons.credit_card_outlined,
              title: 'Billing & Plans',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/billing');
              },
            ),

            const Divider(
              color: AppColors.divider,
              indent: AppSizes.paddingL,
              endIndent: AppSizes.paddingL,
            ),

            _buildDrawerItem(
              icon: Icons.settings_outlined,
              title: 'Settings',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/settings');
              },
            ),
            _buildDrawerItem(
              icon: Icons.help_outline_rounded,
              title: 'Help & Support',
              onTap: () => Navigator.pop(context),
            ),

            const Spacer(),

            // Logout button
            Padding(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              child: Consumer<UserProvider>(
                builder: (context, userProvider, child) {
                  return GestureDetector(
                    onTap: () async {
                      final confirmed = await ConfirmDialog.showLogout(context);
                      if (confirmed && context.mounted) {
                        await userProvider.logout();
                        if (context.mounted) {
                          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                        }
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSizes.paddingM),
                      decoration: BoxDecoration(
                        color: AppColors.emergency.withAlpha((0.1 * 255).round()),
                        borderRadius: BorderRadius.circular(AppSizes.radiusL),
                        border: Border.all(
                          color: AppColors.emergency.withAlpha((0.3 * 255).round()),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.logout_rounded,
                            color: AppColors.emergency,
                            size: 20,
                          ),
                          const SizedBox(width: AppSizes.paddingS),
                          Text(
                            'Logout',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.emergency,
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
}
