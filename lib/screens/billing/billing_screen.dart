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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppStrings.billingPlan,
          style: GoogleFonts.dmSans(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        top: false, // AppBar already handles the top
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.paddingL),
          child: Column(
            children: [
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

                // Subscribe / Cancel button
                Consumer<UserProvider>(
                  builder: (context, userProvider, child) {
                    final isPremium = userProvider.user?.isPremium ?? false;
                    if (isPremium) {
                      return Column(
                        children: [
                          // Premium status badge
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(AppSizes.paddingM),
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              borderRadius: BorderRadius.circular(AppSizes.radiusL),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.verified_rounded, color: Colors.white, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'You are a Premium member',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSizes.paddingM),
                          // Cancel subscription button
                          GestureDetector(
                            onTap: userProvider.isLoading ? null : () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Cancel Subscription?'),
                                  content: const Text(
                                    'You will lose access to premium features including:\n'
                                    '• Unlimited storage\n'
                                    '• All translation languages\n'
                                    '• Offline mode\n'
                                    '• Family profiles',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('Keep Premium'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                                      child: const Text('Cancel Subscription'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                final success = await userProvider.cancelPremium();
                                if (success && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Subscription cancelled'),
                                      backgroundColor: AppColors.textSecondary,
                                    ),
                                  );
                                }
                              }
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(AppSizes.paddingM),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(AppSizes.radiusL),
                                border: Border.all(color: Colors.red.shade300, width: 2),
                              ),
                              child: Center(
                                child: Text(
                                  userProvider.isLoading ? 'Processing...' : 'Cancel Subscription',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.red.shade400,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
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
