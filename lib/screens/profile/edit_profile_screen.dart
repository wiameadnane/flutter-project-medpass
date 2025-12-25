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

  // Personal Info Controllers
  late TextEditingController _dobController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _countryController;

  // Emergency Contact Controllers
  late TextEditingController _emergencyNameController;
  late TextEditingController _emergencyPhoneController;
  late TextEditingController _emergencyRelationController;

  // Allergies & Conditions Controllers
  late TextEditingController _allergiesController;
  late TextEditingController _conditionsController;
  late TextEditingController _medicationsController;

  String? _selectedBloodType;
  String? _selectedGender;
  DateTime? _selectedDate;

  final List<String> _bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  final List<String> _genders = ['Male', 'Female', 'Other'];

  @override
  void initState() {
    super.initState();
    final user = context.read<UserProvider>().user;

    // Personal Info
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

    // Emergency Contact
    _emergencyNameController = TextEditingController(text: user?.emergencyContactName ?? '');
    _emergencyPhoneController = TextEditingController(text: user?.emergencyContactPhone ?? '');
    _emergencyRelationController = TextEditingController(text: user?.emergencyContactRelation ?? '');

    // Allergies & Conditions (comma-separated)
    _allergiesController = TextEditingController(
      text: user?.allergies.join(', ') ?? '',
    );
    _conditionsController = TextEditingController(
      text: user?.medicalConditions.join(', ') ?? '',
    );
    _medicationsController = TextEditingController(
      text: user?.currentMedications.join(', ') ?? '',
    );
  }

  @override
  void dispose() {
    _dobController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _countryController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    _emergencyRelationController.dispose();
    _allergiesController.dispose();
    _conditionsController.dispose();
    _medicationsController.dispose();
    super.dispose();
  }

  List<String> _parseCommaSeparated(String text) {
    if (text.trim().isEmpty) return [];
    return text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
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

    // Validate critical info for new profiles
    if (widget.isCreating && _selectedBloodType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your blood type - this is critical for emergencies'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final userProvider = context.read<UserProvider>();
    final success = await userProvider.updateProfile(
      dateOfBirth: _selectedDate,
      bloodType: _selectedBloodType,
      height: double.tryParse(_heightController.text),
      weight: double.tryParse(_weightController.text),
      nationality: _countryController.text.trim(),
      gender: _selectedGender,
      emergencyContactName: _emergencyNameController.text.trim(),
      emergencyContactPhone: _emergencyPhoneController.text.trim(),
      emergencyContactRelation: _emergencyRelationController.text.trim(),
      allergies: _parseCommaSeparated(_allergiesController.text),
      medicalConditions: _parseCommaSeparated(_conditionsController.text),
      currentMedications: _parseCommaSeparated(_medicationsController.text),
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
      backgroundColor: AppColors.backgroundLight,
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
                    Center(
                      child: Image.asset(
                        'assets/images/medpass_logo.png',
                        height: 120,
                        fit: BoxFit.contain,
                      ),
                    ).animate().fadeIn(duration: 500.ms),
                    const SizedBox(height: AppSizes.paddingL),
                  ],

                  // Title
                  Center(
                    child: Text(
                      widget.isCreating ? 'Complete Your Profile' : 'Edit Profile',
                      style: GoogleFonts.dmSans(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                  ).animate().fadeIn(duration: 500.ms, delay: 100.ms),

                  if (widget.isCreating) ...[
                    const SizedBox(height: AppSizes.paddingS),
                    Center(
                      child: Text(
                        'This information helps medical professionals in emergencies',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ).animate().fadeIn(duration: 500.ms, delay: 150.ms),
                  ],

                  const SizedBox(height: AppSizes.paddingXL),

                  // ==========================================
                  // CRITICAL MEDICAL INFO (Priority Section)
                  // ==========================================
                  _buildSectionHeader(
                    'Critical Medical Info',
                    Icons.emergency_rounded,
                    AppColors.emergency,
                    isRequired: true,
                  ).animate().fadeIn(duration: 500.ms, delay: 200.ms),

                  const SizedBox(height: AppSizes.paddingM),

                  // Blood Type (Required)
                  _buildDropdownField(
                    label: 'Blood Type *',
                    value: _selectedBloodType,
                    items: _bloodTypes,
                    icon: Icons.bloodtype_rounded,
                    iconColor: AppColors.bloodType,
                    onChanged: (value) {
                      setState(() {
                        _selectedBloodType = value;
                      });
                    },
                  ).animate().fadeIn(duration: 500.ms, delay: 250.ms),

                  const SizedBox(height: AppSizes.paddingM),

                  // Allergies
                  _buildTextFieldWithIcon(
                    label: 'Allergies',
                    hint: 'e.g., Penicillin, Peanuts, Latex',
                    controller: _allergiesController,
                    icon: Icons.warning_amber_rounded,
                    iconColor: AppColors.allergy,
                    helperText: 'Separate multiple allergies with commas',
                  ).animate().fadeIn(duration: 500.ms, delay: 300.ms),

                  const SizedBox(height: AppSizes.paddingM),

                  // Medical Conditions
                  _buildTextFieldWithIcon(
                    label: 'Medical Conditions',
                    hint: 'e.g., Diabetes, Asthma, Heart Disease',
                    controller: _conditionsController,
                    icon: Icons.medical_information_rounded,
                    iconColor: AppColors.primary,
                    helperText: 'Separate multiple conditions with commas',
                  ).animate().fadeIn(duration: 500.ms, delay: 350.ms),

                  const SizedBox(height: AppSizes.paddingM),

                  // Current Medications
                  _buildTextFieldWithIcon(
                    label: 'Current Medications',
                    hint: 'e.g., Aspirin, Insulin, Ventolin',
                    controller: _medicationsController,
                    icon: Icons.medication_rounded,
                    iconColor: AppColors.medication,
                    helperText: 'Separate multiple medications with commas',
                  ).animate().fadeIn(duration: 500.ms, delay: 400.ms),

                  const SizedBox(height: AppSizes.paddingXL),

                  // ==========================================
                  // EMERGENCY CONTACT
                  // ==========================================
                  _buildSectionHeader(
                    'Emergency Contact',
                    Icons.contact_phone_rounded,
                    AppColors.accent,
                  ).animate().fadeIn(duration: 500.ms, delay: 450.ms),

                  const SizedBox(height: AppSizes.paddingM),

                  CustomTextField(
                    label: 'Contact Name',
                    hint: 'John Doe',
                    controller: _emergencyNameController,
                  ).animate().fadeIn(duration: 500.ms, delay: 500.ms),

                  const SizedBox(height: AppSizes.paddingM),

                  CustomTextField(
                    label: 'Contact Phone',
                    hint: '+1 234 567 8900',
                    controller: _emergencyPhoneController,
                    keyboardType: TextInputType.phone,
                  ).animate().fadeIn(duration: 500.ms, delay: 550.ms),

                  const SizedBox(height: AppSizes.paddingM),

                  CustomTextField(
                    label: 'Relationship',
                    hint: 'e.g., Spouse, Parent, Sibling',
                    controller: _emergencyRelationController,
                  ).animate().fadeIn(duration: 500.ms, delay: 600.ms),

                  const SizedBox(height: AppSizes.paddingXL),

                  // ==========================================
                  // PERSONAL INFO
                  // ==========================================
                  _buildSectionHeader(
                    'Personal Information',
                    Icons.person_rounded,
                    AppColors.primary,
                  ).animate().fadeIn(duration: 500.ms, delay: 650.ms),

                  const SizedBox(height: AppSizes.paddingM),

                  // Date of Birth
                  CustomTextField(
                    label: 'Date of Birth',
                    hint: 'DD/MM/YYYY',
                    controller: _dobController,
                    readOnly: true,
                    onTap: _selectDate,
                    suffixIcon: const Icon(Icons.calendar_today, color: AppColors.textSecondary),
                  ).animate().fadeIn(duration: 500.ms, delay: 700.ms),

                  const SizedBox(height: AppSizes.paddingM),

                  // Gender
                  _buildDropdownField(
                    label: 'Gender',
                    value: _selectedGender,
                    items: _genders,
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value;
                      });
                    },
                  ).animate().fadeIn(duration: 500.ms, delay: 750.ms),

                  const SizedBox(height: AppSizes.paddingM),

                  // Height & Weight Row
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          label: 'Height',
                          hint: '170',
                          controller: _heightController,
                          keyboardType: TextInputType.number,
                          suffixIcon: Padding(
                            padding: const EdgeInsets.all(AppSizes.paddingM),
                            child: Text(
                              'cm',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSizes.paddingM),
                      Expanded(
                        child: CustomTextField(
                          label: 'Weight',
                          hint: '65',
                          controller: _weightController,
                          keyboardType: TextInputType.number,
                          suffixIcon: Padding(
                            padding: const EdgeInsets.all(AppSizes.paddingM),
                            child: Text(
                              'kg',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(duration: 500.ms, delay: 800.ms),

                  const SizedBox(height: AppSizes.paddingM),

                  // Nationality
                  CustomTextField(
                    label: 'Nationality',
                    hint: 'Morocco',
                    controller: _countryController,
                  ).animate().fadeIn(duration: 500.ms, delay: 850.ms),

                  const SizedBox(height: AppSizes.paddingXL),

                  // Save Button
                  Consumer<UserProvider>(
                    builder: (context, userProvider, child) {
                      return CustomButton(
                        text: userProvider.isLoading
                            ? 'Saving...'
                            : (widget.isCreating ? 'Complete Profile' : 'Save Changes'),
                        onPressed: userProvider.isLoading ? () {} : _handleSave,
                        width: double.infinity,
                      );
                    },
                  ).animate().fadeIn(duration: 500.ms, delay: 900.ms),

                  if (!widget.isCreating) ...[
                    const SizedBox(height: AppSizes.paddingM),
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: AppSizes.paddingXL),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color, {bool isRequired = false}) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: color.withAlpha((0.1 * 255).round()),
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(
          color: color.withAlpha((0.3 * 255).round()),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: AppSizes.paddingS),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.dmSans(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (isRequired) ...[
            const SizedBox(width: AppSizes.paddingS),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingS,
                vertical: AppSizes.paddingXS,
              ),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(AppSizes.radiusS),
              ),
              child: Text(
                'REQUIRED',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTextFieldWithIcon({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    required Color iconColor,
    String? helperText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: AppSizes.paddingS),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.paddingS),
        TextFormField(
          controller: controller,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textMuted,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(AppSizes.paddingM),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusL),
              borderSide: BorderSide(color: AppColors.inputBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusL),
              borderSide: BorderSide(color: AppColors.inputBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusL),
              borderSide: BorderSide(color: iconColor, width: 2),
            ),
          ),
        ),
        if (helperText != null) ...[
          const SizedBox(height: AppSizes.paddingXS),
          Text(
            helperText,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
    IconData? icon,
    Color? iconColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: iconColor ?? AppColors.textSecondary, size: 20),
              const SizedBox(width: AppSizes.paddingS),
            ],
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.paddingS),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
            border: Border.all(color: AppColors.inputBorder),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              hint: Text(
                'Select $label',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textMuted,
                ),
              ),
              icon: const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: GoogleFonts.inter(
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
