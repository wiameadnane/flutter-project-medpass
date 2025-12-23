import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../providers/user_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class EditProfileScreen extends StatefulWidget {
  final bool isCreating;

  const EditProfileScreen({super.key, this.isCreating = false});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _dobController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _countryController;

  String? _selectedBloodType;
  String? _selectedGender;
  DateTime? _selectedDate;

  final List<String> _bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  final List<String> _genders = ['Male', 'Female', 'Other'];

  @override
  void initState() {
    super.initState();
    final user = context.read<UserProvider>().user;
    _dobController = TextEditingController(text: user?.formattedDateOfBirth ?? '');
    _heightController = TextEditingController(
      text: user?.height != null ? user!.height!.toInt().toString() : '',
    );
    _weightController = TextEditingController(
      text: user?.weight != null ? user!.weight!.toInt().toString() : '',
    );
    _countryController = TextEditingController(text: user?.nationality ?? '');
    _selectedBloodType = user?.bloodType;
    _selectedGender = user?.gender;
    _selectedDate = user?.dateOfBirth;
  }

  @override
  void dispose() {
    _dobController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dobController.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final userProvider = context.read<UserProvider>();
    final success = await userProvider.updateProfile(
      dateOfBirth: _selectedDate,
      bloodType: _selectedBloodType,
      height: double.tryParse(_heightController.text),
      weight: double.tryParse(_weightController.text),
      nationality: _countryController.text.trim(),
      gender: _selectedGender,
    );

    if (success && mounted) {
      if (widget.isCreating) {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      } else {
        Navigator.pop(context);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: widget.isCreating
          ? null
          : AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: AppColors.textDark),
                onPressed: () => Navigator.pop(context),
              ),
            ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.paddingL),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.isCreating) ...[
                    // Logo
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
                    ).animate().fadeIn(duration: 500.ms),

                    const SizedBox(height: AppSizes.paddingL),
                  ],

                  // Title
                  Center(
                    child: Text(
                      widget.isCreating ? AppStrings.createProfile : 'Edit Profile',
                      style: GoogleFonts.outfit(
                        fontSize: 36,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accent,
                      ),
                    ),
                  ).animate().fadeIn(duration: 500.ms, delay: 100.ms),

                  const SizedBox(height: AppSizes.paddingM),

                  // User name
                  Consumer<UserProvider>(
                    builder: (context, userProvider, child) {
                      return Center(
                        child: Text(
                          userProvider.user?.fullName ?? 'User',
                          style: GoogleFonts.dmSans(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                      );
                    },
                  ).animate().fadeIn(duration: 500.ms, delay: 150.ms),

                  const SizedBox(height: AppSizes.paddingM),

                  // Personal Info header
                  Text(
                    AppStrings.personalInfo,
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textDark,
                    ),
                  ).animate().fadeIn(duration: 500.ms, delay: 200.ms),

                  const SizedBox(height: AppSizes.paddingS),
                  const Divider(color: AppColors.divider),
                  const SizedBox(height: AppSizes.paddingM),

                  // Date of birth
                  CustomTextField(
                    label: AppStrings.dateOfBirth,
                    hint: 'DD/MM/YYYY',
                    controller: _dobController,
                    readOnly: true,
                    onTap: _selectDate,
                    suffixIcon: const Icon(Icons.calendar_today, color: AppColors.textSecondary),
                  ).animate().fadeIn(duration: 500.ms, delay: 250.ms),

                  const SizedBox(height: AppSizes.paddingM),

                  // Blood Type dropdown
                  _buildDropdownField(
                    label: 'Blood Type',
                    value: _selectedBloodType,
                    items: _bloodTypes,
                    onChanged: (value) {
                      setState(() {
                        _selectedBloodType = value;
                      });
                    },
                  ).animate().fadeIn(duration: 500.ms, delay: 300.ms),

                  const SizedBox(height: AppSizes.paddingM),

                  // Height
                  CustomTextField(
                    label: AppStrings.height,
                    hint: '170',
                    controller: _heightController,
                    keyboardType: TextInputType.number,
                    suffixIcon: Padding(
                      padding: const EdgeInsets.all(AppSizes.paddingM),
                      child: Text(
                        'cm',
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ).animate().fadeIn(duration: 500.ms, delay: 350.ms),

                  const SizedBox(height: AppSizes.paddingM),

                  // Weight
                  CustomTextField(
                    label: AppStrings.weight,
                    hint: '65',
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    suffixIcon: Padding(
                      padding: const EdgeInsets.all(AppSizes.paddingM),
                      child: Text(
                        'kg',
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ).animate().fadeIn(duration: 500.ms, delay: 400.ms),

                  const SizedBox(height: AppSizes.paddingM),

                  // Country of origin
                  CustomTextField(
                    label: AppStrings.countryOfOrigin,
                    hint: 'Morocco',
                    controller: _countryController,
                  ).animate().fadeIn(duration: 500.ms, delay: 450.ms),

                  const SizedBox(height: AppSizes.paddingM),

                  // Gender dropdown
                  _buildDropdownField(
                    label: AppStrings.gender,
                    value: _selectedGender,
                    items: _genders,
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value;
                      });
                    },
                  ).animate().fadeIn(duration: 500.ms, delay: 500.ms),

                  const SizedBox(height: AppSizes.paddingXL),

                  // Save button
                  Consumer<UserProvider>(
                    builder: (context, userProvider, child) {
                      return CustomButton(
                        text: userProvider.isLoading ? 'Saving...' : AppStrings.save,
                        onPressed: userProvider.isLoading ? () {} : _handleSave,
                        width: double.infinity,
                      );
                    },
                  ).animate().fadeIn(duration: 500.ms, delay: 550.ms),

                  const SizedBox(height: AppSizes.paddingXL),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppSizes.paddingS, bottom: AppSizes.paddingS),
          child: Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
          decoration: BoxDecoration(
            color: AppColors.inputBackground,
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              hint: Text(
                'Select $label',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary.withAlpha((0.5 * 255).round()),
                ),
              ),
              icon: const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textPrimary,
                    ),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
