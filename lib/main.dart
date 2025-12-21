import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/theme.dart';
import 'models/medical_file_model.dart';
import 'providers/user_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/onboarding_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/billing/billing_screen.dart';
import 'screens/billing/payment_screen.dart';
import 'screens/emergency/emergency_screen.dart';
import 'screens/files/file_viewer_screen.dart';
import 'screens/files/files_list_screen.dart';
import 'screens/files/my_files_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/home/personal_card_screen.dart';
import 'screens/home/qr_code_screen.dart';
import 'screens/profile/edit_profile_screen.dart';
import 'screens/profile/personal_info_screen.dart';
import 'screens/profile/profile_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
  runApp(const MedPassApp());
}

class MedPassApp extends StatelessWidget {
  const MedPassApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        title: 'Med-Pass',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/':
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
            case '/personal-card':
              return _buildPageRoute(const PersonalCardScreen());
            case '/billing':
              return _buildPageRoute(const BillingScreen());
            case '/payment':
              return _buildPageRoute(const PaymentScreen());
            default:
              return _buildPageRoute(const OnboardingScreen());
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

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
