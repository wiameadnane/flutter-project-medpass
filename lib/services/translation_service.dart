import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

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

  /// Get available source languages for the current user
  static List<TranslateLanguage> getAvailableSourceLanguages(
      BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final isPremium = userProvider.user?.isPremium ?? false;

    if (isPremium) {
      // Premium users can use all languages as source
      return [
        TranslateLanguage.french,
        TranslateLanguage.english,
        TranslateLanguage.spanish,
        TranslateLanguage.chinese,
        TranslateLanguage.german,
        TranslateLanguage.arabic,
      ];
    } else {
      // Freemium users can only use French as source (most common for medical docs)
      return [TranslateLanguage.french];
    }
  }

  /// Get available target languages for the current user
  static List<TranslateLanguage> getAvailableTargetLanguages(
      BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final isPremium = userProvider.user?.isPremium ?? false;

    if (isPremium) {
      // Premium users can translate to all languages
      return [
        TranslateLanguage.english,
        TranslateLanguage.french,
        TranslateLanguage.spanish,
        TranslateLanguage.chinese,
        TranslateLanguage.german,
        TranslateLanguage.arabic,
      ];
    } else {
      // Freemium users can only translate to English and French
      return [
        TranslateLanguage.english,
        TranslateLanguage.french,
      ];
    }
  }

  /// Check if a language is premium-only for target translations
  static bool isPremiumTargetLanguage(TranslateLanguage language) {
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
      builder: (context) => AlertDialog(
        title: const Text('Premium Feature'),
        content: const Text(
          'Translation to Spanish, Chinese, German, and Arabic is available with Premium subscription. '
          'Upgrade now to access all translation languages!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Navigate to subscription/upgrade screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Upgrade feature coming soon!')),
              );
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
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final isPremium = userProvider.user?.isPremium ?? false;

    // Check if user is trying to use premium-only target language
    if (!isPremium && isPremiumTargetLanguage(targetLanguage)) {
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
