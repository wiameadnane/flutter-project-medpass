import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../providers/user_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final userProvider = context.read<UserProvider>();
    final success = await userProvider.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (success && mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(userProvider.error ?? 'Login failed'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.paddingL),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.backgroundLight,
                          borderRadius: BorderRadius.circular(AppSizes.radiusM),
                        ),
                        child: const Icon(
                          Icons.medical_services_rounded,
                          color: AppColors.primary,
                          size: 30,
                        ),
                      ),
                    ],
                  ).animate().fadeIn(duration: 500.ms),

                  const SizedBox(height: AppSizes.paddingXL),

                  // Title
                  Center(
                    child: Text(
                      AppStrings.login,
                      style: GoogleFonts.outfit(
                        fontSize: 40,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accent,
                      ),
                    ),
                  ).animate().fadeIn(duration: 500.ms, delay: 100.ms),

                  const SizedBox(height: AppSizes.paddingM),

                  // Illustration placeholder
                  Center(
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: AppColors.backgroundLight,
                        borderRadius: BorderRadius.circular(AppSizes.radiusL),
                      ),
                      child: Icon(
                        Icons.person_outline_rounded,
                        size: 100,
                        color: AppColors.primary.withOpacity(0.5),
                      ),
                    ),
                  ).animate().fadeIn(duration: 500.ms, delay: 200.ms).scale(begin: const Offset(0.9, 0.9)),

                  const SizedBox(height: AppSizes.paddingXL),

                  // Email field
                  CustomTextField(
                    label: AppStrings.email,
                    hint: 'example@email.com',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ).animate().fadeIn(duration: 500.ms, delay: 300.ms).slideX(begin: -0.1),

                  const SizedBox(height: AppSizes.paddingM),

                  // Password field
                  CustomTextField(
                    label: AppStrings.password,
                    hint: '••••••••••',
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ).animate().fadeIn(duration: 500.ms, delay: 400.ms).slideX(begin: -0.1),

                  const SizedBox(height: AppSizes.paddingXL),

                  // Login button
                  Consumer<UserProvider>(
                    builder: (context, userProvider, child) {
                      return CustomButton(
                        text: userProvider.isLoading ? 'Loading...' : AppStrings.login,
                        onPressed: userProvider.isLoading ? () {} : _handleLogin,
                        width: double.infinity,
                      );
                    },
                  ).animate().fadeIn(duration: 500.ms, delay: 500.ms).slideY(begin: 0.2),

                  const SizedBox(height: AppSizes.paddingXL),

                  // Divider
                  const Divider(color: AppColors.inputBackground),

                  const SizedBox(height: AppSizes.paddingM),

                  // Sign up link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppStrings.noAccount,
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: AppSizes.paddingXS),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacementNamed(context, '/signup');
                        },
                        child: Text(
                          AppStrings.signUp,
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(duration: 500.ms, delay: 600.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
