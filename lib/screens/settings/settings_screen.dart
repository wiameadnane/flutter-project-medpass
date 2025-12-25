import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants.dart';
import '../../widgets/common_widgets.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
          'Settings',
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
              // Account Section
              _buildSectionHeader('Account').animate().fadeIn(duration: 300.ms),
              const SizedBox(height: AppSizes.paddingS),
              _buildSettingsCard([
                _SettingsTile(
                  icon: Icons.person_outline,
                  title: 'Edit Profile',
                  onTap: () => Navigator.pushNamed(context, '/edit-profile'),
                ),
                _SettingsTile(
                  icon: Icons.lock_outline,
                  title: 'Change Password',
                  onTap: () => _showChangePasswordDialog(context),
                ),
                _SettingsTile(
                  icon: Icons.email_outlined,
                  title: 'Email Preferences',
                  onTap: () => _showComingSoon(context),
                ),
              ]).animate().fadeIn(duration: 300.ms, delay: 100.ms),

              const SizedBox(height: AppSizes.paddingL),

              // Preferences Section
              _buildSectionHeader(
                'Preferences',
              ).animate().fadeIn(duration: 300.ms, delay: 150.ms),
              const SizedBox(height: AppSizes.paddingS),
              _buildSettingsCard([
                _SettingsTile(
                  icon: Icons.language,
                  title: 'Language',
                  trailing: Text(
                    'English',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  onTap: () => _showLanguageDialog(context),
                ),
                _SettingsTile(
                  icon: Icons.straighten,
                  title: 'Units',
                  trailing: Text(
                    'Metric',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  onTap: () => _showUnitsDialog(context),
                ),
                _SettingsTile(
                  icon: Icons.dark_mode_outlined,
                  title: 'Theme',
                  trailing: Text(
                    'Light',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  onTap: () => _showThemeDialog(context),
                ),
              ]).animate().fadeIn(duration: 300.ms, delay: 200.ms),

              const SizedBox(height: AppSizes.paddingL),

              // Privacy & Security Section
              _buildSectionHeader(
                'Privacy & Security',
              ).animate().fadeIn(duration: 300.ms, delay: 250.ms),
              const SizedBox(height: AppSizes.paddingS),
              _buildSettingsCard([
                _SettingsTile(
                  icon: Icons.fingerprint,
                  title: 'Biometric Lock',
                  trailing: Switch(
                    value: false,
                    onChanged: (value) => _showComingSoon(context),
                    activeThumbColor: AppColors.primary,
                  ),
                  onTap: () => _showComingSoon(context),
                ),
                _SettingsTile(
                  icon: Icons.shield_outlined,
                  title: 'Data Sharing',
                  onTap: () => _showComingSoon(context),
                ),
                _SettingsTile(
                  icon: Icons.download_outlined,
                  title: 'Export My Data',
                  onTap: () => _showComingSoon(context),
                ),
              ]).animate().fadeIn(duration: 300.ms, delay: 300.ms),

              const SizedBox(height: AppSizes.paddingL),

              // Notifications Section
              _buildSectionHeader(
                'Notifications',
              ).animate().fadeIn(duration: 300.ms, delay: 350.ms),
              const SizedBox(height: AppSizes.paddingS),
              _buildSettingsCard([
                _SettingsTile(
                  icon: Icons.medication_outlined,
                  title: 'Medication Reminders',
                  trailing: Switch(
                    value: true,
                    onChanged: (value) {},
                    activeThumbColor: AppColors.primary,
                  ),
                  onTap: () {},
                ),
                _SettingsTile(
                  icon: Icons.calendar_today_outlined,
                  title: 'Appointment Alerts',
                  trailing: Switch(
                    value: true,
                    onChanged: (value) {},
                    activeThumbColor: AppColors.primary,
                  ),
                  onTap: () {},
                ),
                _SettingsTile(
                  icon: Icons.system_update_outlined,
                  title: 'App Updates',
                  trailing: Switch(
                    value: false,
                    onChanged: (value) {},
                    activeThumbColor: AppColors.primary,
                  ),
                  onTap: () {},
                ),
              ]).animate().fadeIn(duration: 300.ms, delay: 400.ms),

              const SizedBox(height: AppSizes.paddingL),

              // About Section
              _buildSectionHeader(
                'About',
              ).animate().fadeIn(duration: 300.ms, delay: 450.ms),
              const SizedBox(height: AppSizes.paddingS),
              _buildSettingsCard([
                _SettingsTile(
                  icon: Icons.info_outline,
                  title: 'App Version',
                  trailing: Text(
                    '1.0.0',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  onTap: () {},
                ),
                _SettingsTile(
                  icon: Icons.description_outlined,
                  title: 'Terms of Service',
                  onTap: () => _showComingSoon(context),
                ),
                _SettingsTile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  onTap: () => _showComingSoon(context),
                ),
              ]).animate().fadeIn(duration: 300.ms, delay: 500.ms),

              const SizedBox(height: AppSizes.paddingL),

              // Danger Zone
              _buildSectionHeader(
                'Danger Zone',
                isDestructive: true,
              ).animate().fadeIn(duration: 300.ms, delay: 550.ms),
              const SizedBox(height: AppSizes.paddingS),
              _buildSettingsCard([
                _SettingsTile(
                  icon: Icons.delete_outline,
                  title: 'Delete Account',
                  iconColor: AppColors.error,
                  textColor: AppColors.error,
                  onTap: () => _showDeleteAccountDialog(context),
                ),
              ]).animate().fadeIn(duration: 300.ms, delay: 600.ms),

              const SizedBox(height: AppSizes.paddingXL),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {bool isDestructive = false}) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSizes.paddingS),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isDestructive ? AppColors.error : AppColors.textSecondary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<_SettingsTile> tiles) {
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
                  color: AppColors.inputBackground.withAlpha(
                    (0.5 * 255).round(),
                  ),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
        ),
        title: Text(
          'Change Password',
          style: GoogleFonts.dmSans(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: AppSizes.paddingM),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: AppSizes.paddingM),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm New Password',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              AppSnackBar.showSuccess(context, 'Password changed successfully');
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
        ),
        title: Text(
          'Select Language',
          style: GoogleFonts.dmSans(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption(context, 'English', true),
            _buildLanguageOption(context, 'French', false),
            _buildLanguageOption(context, 'Arabic', false),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    String language,
    bool isSelected,
  ) {
    return ListTile(
      title: Text(language),
      trailing: isSelected
          ? const Icon(Icons.check, color: AppColors.primary)
          : null,
      onTap: () {
        Navigator.pop(context);
        AppSnackBar.show(
          context: context,
          message: 'Language set to $language',
        );
      },
    );
  }

  void _showUnitsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
        ),
        title: Text(
          'Select Units',
          style: GoogleFonts.dmSans(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Metric (cm, kg)'),
              trailing: const Icon(Icons.check, color: AppColors.primary),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('Imperial (ft, lb)'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
        ),
        title: Text(
          'Select Theme',
          style: GoogleFonts.dmSans(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.light_mode),
              title: const Text('Light'),
              trailing: const Icon(Icons.check, color: AppColors.primary),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text('Dark'),
              onTap: () {
                Navigator.pop(context);
                _showComingSoon(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.phone_android),
              title: const Text('System'),
              onTap: () {
                Navigator.pop(context);
                _showComingSoon(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Delete Account',
      message:
          'Are you sure you want to delete your account? This action is permanent and cannot be undone. All your data will be lost.',
      confirmText: 'Delete',
      confirmColor: AppColors.error,
      icon: Icons.warning_amber_rounded,
    );

    if (confirmed && context.mounted) {
      AppSnackBar.show(
        context: context,
        message:
            'Account deletion requested. You will receive a confirmation email.',
      );
    }
  }

  void _showComingSoon(BuildContext context) {
    AppSnackBar.show(context: context, message: 'Coming soon!');
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.trailing,
    required this.onTap,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? AppColors.primary, size: 24),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textColor ?? AppColors.textDark,
        ),
      ),
      trailing:
          trailing ??
          const Icon(
            Icons.arrow_forward_ios,
            color: AppColors.textSecondary,
            size: 16,
          ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingM,
        vertical: AppSizes.paddingXS,
      ),
    );
  }
}
