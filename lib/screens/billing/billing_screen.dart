import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../providers/user_provider.dart';

class BillingScreen extends StatelessWidget {
  const BillingScreen({super.key});

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
                    Image.asset(
                      'assets/images/medpass_logo.png',
                      height: 120,
                      fit: BoxFit.contain,
                    ),
                  ],
                ).animate().fadeIn(duration: 500.ms),

                const SizedBox(height: AppSizes.paddingXL),

                // Title
                Text(
                  AppStrings.billingPlan,
                  style: GoogleFonts.dmSans(
                    fontSize: 36,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent,
                  ),
                ).animate().fadeIn(duration: 500.ms, delay: 100.ms),

                const SizedBox(height: AppSizes.paddingXL),

                // Free plan card
                Consumer<UserProvider>(
                  builder: (context, userProvider, child) {
                    final isPremium = userProvider.user?.isPremium ?? false;
                    return _buildPlanCard(
                      context,
                      title: 'FREE',
                      price: '\$0',
                      period: '/MON',
                      isCurrentPlan: !isPremium,
                      borderColor: AppColors.primary,
                      features: [
                        'Create your digital medical record',
                        'Manually enter your medical data',
                        'Get a unique health QR code',
                        'Translate automatically into 2 languages',
                        'Share with one healthcare professional at a time',
                      ],
                    );
                  },
                ).animate().fadeIn(duration: 500.ms, delay: 200.ms).slideX(begin: -0.1),

                const SizedBox(height: AppSizes.paddingL),

                // Premium plan card
                Consumer<UserProvider>(
                  builder: (context, userProvider, child) {
                    final isPremium = userProvider.user?.isPremium ?? false;
                    return _buildPlanCard(
                      context,
                      title: 'PREMIUM',
                      price: '\$12',
                      period: '/MON',
                      isCurrentPlan: isPremium,
                      borderColor: AppColors.warning,
                      isPremium: true,
                      features: [
                        'Everything in Freemium, plus:',
                        'Unlimited attachment storage',
                        'Offline mode',
                        'Automatic translations in 10+ languages',
                        'Secure sharing with multiple healthcare professionals',
                        'Multi-profile access (family, children, etc.)',
                        'Priority "medical emergency" mode',
                        'Encrypted cloud backup + multi-device sync',
                        'Automatic notifications for health info updates',
                        'Priority online support',
                      ],
                    );
                  },
                ).animate().fadeIn(duration: 500.ms, delay: 300.ms).slideX(begin: -0.1),

                const SizedBox(height: AppSizes.paddingL),

                // Subscribe button
                Consumer<UserProvider>(
                  builder: (context, userProvider, child) {
                    final isPremium = userProvider.user?.isPremium ?? false;
                    if (isPremium) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSizes.paddingM),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(AppSizes.radiusL),
                        ),
                        child: Center(
                          child: Text(
                            'You are a Premium member',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    }
                    return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/payment');
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSizes.paddingM),
                        decoration: BoxDecoration(
                          color: AppColors.warning,
                          borderRadius: BorderRadius.circular(AppSizes.radiusL),
                        ),
                        child: Center(
                          child: Text(
                            AppStrings.subscribeToPremium,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ).animate().fadeIn(duration: 500.ms, delay: 400.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard(
    BuildContext context, {
    required String title,
    required String price,
    required String period,
    required bool isCurrentPlan,
    required Color borderColor,
    required List<String> features,
    bool isPremium = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: borderColor, width: 3),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  if (isPremium) ...[
                    const SizedBox(width: AppSizes.paddingS),
                    Icon(Icons.star_rounded, color: AppColors.warning, size: 20),
                  ],
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    price,
                    style: GoogleFonts.dmSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  Text(
                    period,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (isCurrentPlan) ...[
            const SizedBox(height: AppSizes.paddingS),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingS,
                vertical: AppSizes.paddingXS,
              ),
              decoration: BoxDecoration(
                color: AppColors.accent.withAlpha((0.1 * 255).round()),
                borderRadius: BorderRadius.circular(AppSizes.radiusS),
              ),
              child: Text(
                AppStrings.current,
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accent,
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSizes.paddingM),
          const Divider(color: AppColors.inputBackground),
          const SizedBox(height: AppSizes.paddingM),
          ...features.map((feature) => _buildFeatureItem(feature, isPremium)),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text, bool isPremium) {
    final isHeader = text.endsWith(':');
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.paddingS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isHeader)
            Icon(
              Icons.check_circle_rounded,
              color: isPremium ? AppColors.warning : AppColors.accent,
              size: 16,
            ),
          if (!isHeader) const SizedBox(width: AppSizes.paddingS),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: isHeader ? FontWeight.w600 : FontWeight.w400,
                color: AppColors.textDark,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
