import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/constants.dart';
import 'core/theme.dart';
import 'models/medical_file_model.dart';
import 'providers/user_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/onboarding_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/billing/billing_screen.dart';
import 'screens/billing/payment_screen.dart';
import 'screens/emergency/emergency_screen.dart';
import 'screens/emergency/emergency_mode_screen.dart';
import 'screens/files/file_viewer_screen.dart';
import 'screens/files/files_list_screen.dart';
import 'screens/files/my_files_screen.dart';
import 'screens/files/upload_file_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/home/personal_card_screen.dart';
import 'screens/home/qr_code_screen.dart';
import 'screens/profile/edit_profile_screen.dart';
import 'screens/profile/personal_info_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/search/search_screen.dart';
import 'screens/settings/settings_screen.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase and surface any init error so UI can show it
  String? firebaseInitError;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e, st) {
    firebaseInitError = '$e';
    debugPrint('Firebase initialization error: $e');
    debugPrint(st.toString());
  }

  // Set system UI
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(MedPassApp(firebaseInitError: firebaseInitError));
}

class MedPassApp extends StatelessWidget {
  final String? firebaseInitError;

  const MedPassApp({super.key, this.firebaseInitError});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => UserProvider())],
      child: MaterialApp(
        title: 'Med-Pass',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: AuthWrapper(firebaseInitError: firebaseInitError),
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/':
              return _buildPageRoute(const AuthWrapper());
            case '/onboarding':
              return _buildPageRoute(const OnboardingScreen());
            case '/login':
              return _buildPageRoute(const LoginScreen());
            case '/signup':
              return _buildPageRoute(const SignUpScreen());
            case '/home':
              return _buildPageRoute(const HomeScreen());
            case '/profile':
              return _buildPageRoute(const ProfileScreen());
            case '/personal-info':
              return _buildPageRoute(const PersonalInfoScreen());
            case '/edit-profile':
              return _buildPageRoute(const EditProfileScreen());
            case '/create-profile':
              return _buildPageRoute(const EditProfileScreen(isCreating: true));
            case '/my-files':
              return _buildPageRoute(const MyFilesScreen());
            case '/upload-file':
              return _buildPageRoute(const UploadFileScreen());
            case '/files-list':
              return _buildPageRoute(const FilesListScreen());
            case '/file-viewer':
              final category = settings.arguments as FileCategory;
              return _buildPageRoute(FileViewerScreen(category: category));
            case '/important-files':
              return _buildPageRoute(const FilesListScreen());
            case '/qr-code':
              return _buildPageRoute(const QrCodeScreen());
            case '/emergency':
              return _buildPageRoute(const EmergencyScreen());
            case '/emergency-mode':
              return _buildPageRoute(const EmergencyModeScreen());
            case '/personal-card':
              return _buildPageRoute(const PersonalCardScreen());
            case '/billing':
              return _buildPageRoute(const BillingScreen());
            case '/payment':
              return _buildPageRoute(const PaymentScreen());
            case '/settings':
              return _buildPageRoute(const SettingsScreen());
            case '/search':
              return _buildPageRoute(const SearchScreen());
            default:
              return _buildPageRoute(const AuthWrapper());
          }
        },
      ),
    );
  }

  static PageRouteBuilder _buildPageRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        return SlideTransition(position: animation.drive(tween), child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}

/// Wrapper that handles authentication state and shows appropriate screen
class AuthWrapper extends StatefulWidget {
  final String? firebaseInitError;

  const AuthWrapper({super.key, this.firebaseInitError});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    final userProvider = context.read<UserProvider>();
    await userProvider.initialize();

    if (mounted) {
      setState(() {
        _isInitializing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.firebaseInitError != null) {
      return FirebaseInitErrorScreen(message: widget.firebaseInitError!);
    }

    if (_isInitializing) {
      return const SplashScreen();
    }

    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        if (userProvider.isLoggedIn) {
          return const HomeScreen();
        }
        return const OnboardingScreen();
      },
    );
  }
}

/// Splash screen shown while initializing
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppSizes.radiusL),
              ),
              child: const Icon(
                Icons.medical_services_rounded,
                color: Colors.white,
                size: 60,
              ),
            ),
            const SizedBox(height: AppSizes.paddingL),
            // App name
            Text(
              'Med-Pass',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.paddingXL),
            // Loading indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}

/// Simple error screen shown when Firebase fails to initialize.
class FirebaseInitErrorScreen extends StatelessWidget {
  final String message;

  const FirebaseInitErrorScreen({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.paddingL),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 80,
                  color: Colors.red,
                ),
                const SizedBox(height: AppSizes.paddingL),
                Text(
                  'Firebase initialization failed',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSizes.paddingM),
                Text(message, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
