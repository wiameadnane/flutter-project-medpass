import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../providers/user_provider.dart';

/// Premium feature definitions
class PremiumFeatures {
  static const int freeFileLimit = 5;
  static const int premiumFileLimit = -1; // Unlimited

  static bool canUploadMoreFiles(int currentCount, bool isPremium) {
    if (isPremium) return true;
    return currentCount < freeFileLimit;
  }

  static bool canAccessCloudBackup(bool isPremium) => isPremium;
  static bool canAccessFamilySharing(bool isPremium) => isPremium;
  static bool canExportPdf(bool isPremium) => isPremium;
  static bool canAccessOfflineMode(bool isPremium) => isPremium;
  static bool canAccessMultiLanguage(bool isPremium) => isPremium;
}

/// Widget that shows content for premium users or a locked state for free users
class PremiumGate extends StatelessWidget {
  final Widget child;
  final String featureName;
  final String? description;
  final bool showUpgradeButton;

  const PremiumGate({
    super.key,
    required this.child,
    required this.featureName,
    this.description,
    this.showUpgradeButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        final isPremium = userProvider.user?.isPremium ?? false;

        if (isPremium) {
          return child;
        }

        return LockedFeatureWidget(
          featureName: featureName,
          description: description,
          showUpgradeButton: showUpgradeButton,
        );
      },
    );
  }
}

/// Shows a locked feature placeholder
class LockedFeatureWidget extends StatelessWidget {
  final String featureName;
  final String? description;
  final bool showUpgradeButton;

  const LockedFeatureWidget({
    super.key,
    required this.featureName,
    this.description,
    this.showUpgradeButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(
          color: AppColors.warning.withAlpha((0.3 * 255).round()),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.warning.withAlpha((0.1 * 255).round()),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_outline,
              color: AppColors.warning,
              size: 40,
            ),
          ),
          const SizedBox(height: AppSizes.paddingM),
          Text(
            featureName,
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.paddingS),
          Text(
            description ?? 'This feature is available for Premium members.',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          if (showUpgradeButton) ...[
            const SizedBox(height: AppSizes.paddingL),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/billing'),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingL,
                  vertical: AppSizes.paddingM,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.warning, Color(0xFFFFB347)],
                  ),
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.warning.withAlpha((0.3 * 255).round()),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: AppSizes.paddingS),
                    Text(
                      'Upgrade to Premium',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Premium badge widget
class PremiumBadge extends StatelessWidget {
  final bool isPremium;
  final double size;

  const PremiumBadge({
    super.key,
    required this.isPremium,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    if (!isPremium) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(size * 0.15),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.warning, Color(0xFFFFB347)],
        ),
        borderRadius: BorderRadius.circular(size * 0.25),
      ),
      child: Icon(
        Icons.star_rounded,
        color: Colors.white,
        size: size * 0.6,
      ),
    );
  }
}

/// File limit indicator for free users
class FileLimitIndicator extends StatelessWidget {
  final int currentCount;
  final int maxCount;

  const FileLimitIndicator({
    super.key,
    required this.currentCount,
    required this.maxCount,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = maxCount > 0 ? (currentCount / maxCount).clamp(0.0, 1.0) : 0.0;
    final isNearLimit = percentage >= 0.8;
    final isAtLimit = currentCount >= maxCount;

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: isAtLimit
            ? AppColors.error.withAlpha((0.1 * 255).round())
            : isNearLimit
                ? AppColors.warning.withAlpha((0.1 * 255).round())
                : AppColors.primary.withAlpha((0.1 * 255).round()),
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'File Storage',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              Text(
                '$currentCount / $maxCount files',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isAtLimit
                      ? AppColors.error
                      : isNearLimit
                          ? AppColors.warning
                          : AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingS),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.white,
              valueColor: AlwaysStoppedAnimation<Color>(
                isAtLimit
                    ? AppColors.error
                    : isNearLimit
                        ? AppColors.warning
                        : AppColors.primary,
              ),
              minHeight: 8,
            ),
          ),
          if (isAtLimit) ...[
            const SizedBox(height: AppSizes.paddingS),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/billing'),
              child: Text(
                'Upgrade to Premium for unlimited storage',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.warning,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Upgrade prompt banner
class UpgradeBanner extends StatelessWidget {
  const UpgradeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        final isPremium = userProvider.user?.isPremium ?? false;

        if (isPremium) return const SizedBox.shrink();

        return GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/billing'),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: AppSizes.paddingS),
            padding: const EdgeInsets.all(AppSizes.paddingM),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.warning.withAlpha((0.9 * 255).round()),
                  const Color(0xFFFFB347),
                ],
              ),
              borderRadius: BorderRadius.circular(AppSizes.radiusL),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSizes.paddingS),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha((0.2 * 255).round()),
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  ),
                  child: const Icon(
                    Icons.star_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSizes.paddingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Upgrade to Premium',
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Unlock unlimited storage & more features',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withAlpha((0.9 * 255).round()),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 16,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
