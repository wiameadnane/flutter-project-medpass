import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/medical_file_model.dart';

class UserProvider with ChangeNotifier {
  UserModel? _user;
  List<MedicalFileModel> _medicalFiles = [];
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  List<MedicalFileModel> get medicalFiles => _medicalFiles;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;

  // Auth methods
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // For demo purposes, accept any login
      _user = UserModel.demoUser.copyWith(email: email);
      _medicalFiles = MedicalFileModel.demoFiles;
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Login failed. Please try again.');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signUp({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Create new user
      _user = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
      );
      _medicalFiles = [];
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Sign up failed. Please try again.');
      _setLoading(false);
      return false;
    }
  }

  void logout() {
    _user = null;
    _medicalFiles = [];
    notifyListeners();
  }

  // Profile methods
  Future<bool> updateProfile({
    String? fullName,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? bloodType,
    double? height,
    double? weight,
    String? nationality,
    String? gender,
  }) async {
    if (_user == null) return false;

    _setLoading(true);
    _clearError();

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));

      _user = _user!.copyWith(
        fullName: fullName,
        phoneNumber: phoneNumber,
        dateOfBirth: dateOfBirth,
        bloodType: bloodType,
        height: height,
        weight: weight,
        nationality: nationality,
        gender: gender,
      );

      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Update failed. Please try again.');
      _setLoading(false);
      return false;
    }
  }

  // Medical files methods
  Future<bool> addMedicalFile(MedicalFileModel file) async {
    _setLoading(true);
    _clearError();

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));

      _medicalFiles.add(file);
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to add file. Please try again.');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> removeMedicalFile(String fileId) async {
    _setLoading(true);
    _clearError();

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));

      _medicalFiles.removeWhere((file) => file.id == fileId);
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to remove file. Please try again.');
      _setLoading(false);
      return false;
    }
  }

  List<MedicalFileModel> getFilesByCategory(FileCategory category) {
    return _medicalFiles.where((file) => file.category == category).toList();
  }

  List<MedicalFileModel> get importantFiles {
    return _medicalFiles.where((file) => file.isImportant).toList();
  }

  // Subscription methods
  Future<bool> upgradeToPremium() async {
    if (_user == null) return false;

    _setLoading(true);
    _clearError();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      _user = _user!.copyWith(isPremium: true);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Upgrade failed. Please try again.');
      _setLoading(false);
      return false;
    }
  }

  // Helper methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  // Demo login for quick testing
  void loginWithDemoUser() {
    _user = UserModel.demoUser;
    _medicalFiles = MedicalFileModel.demoFiles;
    notifyListeners();
  }
}
