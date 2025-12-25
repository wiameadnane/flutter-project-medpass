Manual Firebase integration steps

1) Download platform config files from Firebase Console
   - Android: `google-services.json` (Project settings > Your apps > Android)
   - iOS: `GoogleService-Info.plist` (Project settings > Your apps > iOS)

2) Place files in the project
   - Put `google-services.json` in `android/app/`
   - Put `GoogleService-Info.plist` in `ios/Runner/` (add to Xcode Runner target if needed)

3) Android Gradle changes (Kotlin DSL)
   - In `android/build.gradle.kts` add Google repository (should already exist):
     repositories { google(); mavenCentral() }
   - Add the Google services classpath in `android/build.gradle` (Groovy) or use plugin management.

   If your project uses Gradle Groovy (older projects), add to `android/build.gradle`:
     buildscript {
       dependencies {
         classpath 'com.google.gms:google-services:4.3.15'
       }
     }

   For Kotlin DSL, the recommended approach is to add the plugin in `plugins` or via `buildSrc`/pluginManagement. If you're unsure, you can instead add the plugin application only in `android/app/build.gradle.kts` by adding at the bottom:
     apply(plugin = "com.google.gms.google-services")

   Note: If you run into Gradle errors, I can add the exact changes for your Gradle Kotlin DSL files after you upload `google-services.json`.

4) iOS changes
   - Ensure `GoogleService-Info.plist` is inside `ios/Runner/` and included in the Runner target.
   - Run `cd ios && pod install` (or open the workspace in Xcode and build).

5) Dart initialization (already added)
   - `firebase_core` is added to `pubspec.yaml` and `Firebase.initializeApp()` is called in `lib/main.dart`.
   - If initialization fails, check console for error details and ensure the platform files are present.

6) Optional: use `flutterfire configure` to generate `firebase_options.dart` and automatically register apps.
   - CLI on this machine had trouble listing projects; if you want me to retry CLI automation, tell me and provide access or allow me to debug `firebase-debug.log`.

If you upload `google-services.json` and `GoogleService-Info.plist` here, I'll place them in the project and update Gradle files for you, then run a test build.
