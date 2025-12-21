import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF12517F);
  static const Color primaryLight = Color(0xFF4A7398);
  static const Color primaryDark = Color(0xFF07426C);

  // Accent Colors
  static const Color accent = Color(0xFF1DA078);
  static const Color accentLight = Color(0xFF459173);

  // Background Colors
  static const Color background = Colors.white;
  static const Color backgroundLight = Color(0xFFF3F9FE);
  static const Color backgroundGrey = Color(0xFFF4F4F4);

  // Text Colors
  static const Color textPrimary = Color(0xFF36454F);
  static const Color textSecondary = Color(0xFF7F7F7F);
  static const Color textDark = Colors.black;
  static const Color textLight = Colors.white;

  // Input Colors
  static const Color inputBackground = Color(0xFFD3D3D3);
  static const Color inputBorder = Color(0xFFE0E0E0);

  // Status Colors
  static const Color success = Color(0xFF1DA078);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFCFAF00);

  // Other
  static const Color divider = Color(0xFFA3A3A3);
  static const Color shadow = Color(0x11000000);
  static const Color blueOverlay = Color(0x6D017AEB);
}

class AppSizes {
  // Padding
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;
  static const double paddingXXL = 48.0;

  // Border Radius
  static const double radiusS = 6.0;
  static const double radiusM = 10.0;
  static const double radiusL = 20.0;
  static const double radiusXL = 25.0;
  static const double radiusCircle = 100.0;

  // Icon Sizes
  static const double iconS = 16.0;
  static const double iconM = 24.0;
  static const double iconL = 32.0;
  static const double iconXL = 48.0;

  // Button Heights
  static const double buttonHeight = 60.0;
  static const double buttonHeightSmall = 46.0;

  // Input Height
  static const double inputHeight = 46.0;
}

class AppStrings {
  static const String appName = 'Med-Pass';
  static const String tagline = 'Travel Light with Medpass';
  static const String description = 'Your Medical Passport in your pocket.\nEasy, quick and secure access to all your medical records.';

  // Auth
  static const String login = 'Log In';
  static const String signUp = 'Sign Up';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String fullName = 'Full Name';
  static const String phoneNumber = 'Phone number';
  static const String noAccount = 'No account?';
  static const String haveAccount = 'Already have an account?';

  // Profile
  static const String profile = 'Profile';
  static const String personalInfo = 'PERSONAL INFO';
  static const String createProfile = 'Create your profile';
  static const String dateOfBirth = 'Date of birth';
  static const String height = 'Height';
  static const String weight = 'Weight';
  static const String countryOfOrigin = 'Country of origin';
  static const String gender = 'Gender';
  static const String bloodType = 'Blood Type';
  static const String nationality = 'Nationality';
  static const String userId = 'USER ID';
  static const String save = 'Save';
  static const String edit = 'EDIT';

  // Dashboard
  static const String search = 'Search';
  static const String myFiles = 'My files';
  static const String myQrCode = 'My QR code';
  static const String emergency = 'Emergency';
  static const String personalCard = 'Personal Card';
  static const String clickToAccessProfile = 'Click to access your profile';

  // Files
  static const String viewFiles = 'View files';
  static const String uploadMore = 'Upload more';
  static const String importantInfo = 'Important informations';
  static const String allFilesInOneSpace = 'All your files in one space';
  static const String allergyReport = 'Allergy Report';
  static const String recentPrescriptions = 'Recent Prescriptions';
  static const String birthCertificate = 'Birth Certificate';
  static const String medicalAnalysis = 'Medical Analysis';
  static const String goBack = 'Go back';

  // Emergency
  static const String emergencyGuide = 'Emergency Guide';

  // Billing
  static const String billingPlan = 'Billing Plan';
  static const String free = 'FREE';
  static const String premium = 'PREMIUM';
  static const String current = 'CURRENT';
  static const String subscribeToPremium = 'Subscribe to premium';
  static const String proceedToPay = 'Proceed to pay';

  // Health Pass
  static const String myHealthPass = 'My Health Pass';

  // Coming Soon
  static const String comingSoon = 'Coming Soon...';
}
