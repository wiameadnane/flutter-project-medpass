import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/language_detection_service.dart';

/// Translation service that handles premium/freemium restrictions
class TranslationService {
  static const Map<TranslateLanguage, String> _languageNames = {
    TranslateLanguage.english: 'English',
    TranslateLanguage.french: 'French',
    TranslateLanguage.spanish: 'Spanish',
    TranslateLanguage.chinese: 'Chinese',
    TranslateLanguage.german: 'German',
    TranslateLanguage.arabic: 'Arabic',
  };

  /// All supported languages
  static const List<TranslateLanguage> allLanguages = [
    TranslateLanguage.english,
    TranslateLanguage.french,
    TranslateLanguage.arabic,
    TranslateLanguage.spanish,
    TranslateLanguage.german,
    TranslateLanguage.chinese,
  ];

  /// Get available source languages for the current user
  /// Free users: All languages (auto-detect works for any)
  /// Premium users: All languages
  static List<TranslateLanguage> getAvailableSourceLanguages(
      BuildContext context) {
    // All users can have any source language (auto-detected)
    return allLanguages;
  }

  /// Get available target languages for the current user
  /// Free users: Preferred language + English (or French if preferred is English)
  /// Premium users: All languages
  static List<TranslateLanguage> getAvailableTargetLanguages(
      BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final isPremium = userProvider.user?.isPremium ?? false;

    if (isPremium) {
      // Premium users can translate to all languages
      return allLanguages;
    } else {
      // Free users: preferred language + English (or French if preferred is English)
      final preferredCode = userProvider.user?.preferredLanguage ?? 'en';
      final preferredLang = LanguageDetectionService.codeToTranslateLanguage(preferredCode)
          ?? TranslateLanguage.english;

      final Set<TranslateLanguage> freeLanguages = {preferredLang};

      // Add English as fallback (or French if preferred is English)
      if (preferredLang == TranslateLanguage.english) {
        freeLanguages.add(TranslateLanguage.french);
      } else {
        freeLanguages.add(TranslateLanguage.english);
      }

      return freeLanguages.toList();
    }
  }

  /// Check if a language is premium-only for target translations for this user
  static bool isPremiumTargetLanguage(TranslateLanguage language, BuildContext context) {
    final availableTargets = getAvailableTargetLanguages(context);
    return !availableTargets.contains(language);
  }

  /// Legacy check - kept for compatibility
  static bool isPremiumTargetLanguageLegacy(TranslateLanguage language) {
    return language == TranslateLanguage.spanish ||
        language == TranslateLanguage.chinese ||
        language == TranslateLanguage.german ||
        language == TranslateLanguage.arabic;
  }

  /// Get display name for a language
  static String getLanguageName(TranslateLanguage language) {
    return _languageNames[language] ?? language.name;
  }

  /// Show upgrade dialog for premium features
  static Future<void> showUpgradeDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Premium Feature'),
        content: const Text(
          'Translation to additional languages is available with Premium subscription. '
          'Upgrade now to access all translation languages!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pushNamed(context, '/billing');
            },
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );
  }

  /// Check if translation models are available and download if needed
  static Future<String?> ensureModelsDownloaded(
    TranslateLanguage sourceLanguage,
    TranslateLanguage targetLanguage,
  ) async {
    try {
      final modelManager = OnDeviceTranslatorModelManager();
      final sourceDownloaded =
          await modelManager.isModelDownloaded(sourceLanguage.bcpCode);
      final targetDownloaded =
          await modelManager.isModelDownloaded(targetLanguage.bcpCode);

      print('Source model downloaded: $sourceDownloaded');
      print('Target model downloaded: $targetDownloaded');

      if (!sourceDownloaded) {
        print('Downloading source language model: ${sourceLanguage.bcpCode}');
        await modelManager.downloadModel(sourceLanguage.bcpCode);
        print('Source model download completed');
      }

      if (!targetDownloaded) {
        print('Downloading target language model: ${targetLanguage.bcpCode}');
        await modelManager.downloadModel(targetLanguage.bcpCode);
        print('Target model download completed');
      }

      return null; // Success
    } catch (e) {
      print('Error downloading models: $e');
      return 'Failed to download translation models. Please check your internet connection and try again. Error: $e';
    }
  }

  /// Translate text with premium restrictions check
  static Future<String> translateText(
    BuildContext context,
    String text,
    TranslateLanguage sourceLanguage,
    TranslateLanguage targetLanguage,
  ) async {
    // Check if user is trying to use premium-only target language
    if (isPremiumTargetLanguage(targetLanguage, context)) {
      await showUpgradeDialog(context);
      throw Exception('Premium feature required');
    }

    // Ensure models are downloaded before translation
    final downloadError =
        await ensureModelsDownloaded(sourceLanguage, targetLanguage);
    if (downloadError != null) {
      throw Exception(downloadError);
    }

    OnDeviceTranslator? translator;
    try {
      translator = OnDeviceTranslator(
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
      );
      final translation = await translator.translateText(text);
      return translation;
    } catch (e) {
      print('Translation error: $e');
      rethrow;
    } finally {
      try {
        await translator?.close();
      } catch (_) {}
    }
  }
}
