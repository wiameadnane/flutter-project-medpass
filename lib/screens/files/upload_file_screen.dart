import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../core/constants.dart';
import '../../models/medical_file_model.dart';
import '../../providers/user_provider.dart';

class UploadFileScreen extends StatefulWidget {
  final PlatformFile initialFile;

  const UploadFileScreen({super.key, required this.initialFile});

  @override
  State<UploadFileScreen> createState() => _UploadFileScreenState();
}

class _UploadFileScreenState extends State<UploadFileScreen> {
  FileCategory _category = FileCategory.other;
  late TextEditingController _nameController;
  final _descController = TextEditingController();
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialFile.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _upload() async {
    final userProvider = context.read<UserProvider>();
    final uid = userProvider.firebaseUser?.uid ?? userProvider.user?.id;

    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("User not logged in")));
      return;
    }

    setState(() => _isUploading = true);

    try {
      final basename = widget.initialFile.name;
      final storagePath = 'users/$uid/medical_files/${DateTime.now().millisecondsSinceEpoch}_$basename';
      final ref = FirebaseStorage.instance.ref().child(storagePath);

      UploadTask uploadTask;
      if (kIsWeb || widget.initialFile.path == null) {
        uploadTask = ref.putData(widget.initialFile.bytes!, SettableMetadata(contentType: _guessMimeType(basename)));
      } else {
        uploadTask = ref.putFile(File(widget.initialFile.path!), SettableMetadata(contentType: _guessMimeType(basename)));
      }

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      final model = MedicalFileModel(
        id: '', // La clé sera générée par Firestore
        name: _nameController.text.trim(),
        category: _category,
        description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
        fileUrl: downloadUrl,
        uploadedAt: DateTime.now(),
      );

      await userProvider.addMedicalFile(model);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _isUploading = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Upload Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Document Details', style: GoogleFonts.dmSans()),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusL)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.paddingM),
                child: Column(
                  children: [
                    DropdownButtonFormField<FileCategory>(
                      value: _category,
                      items: FileCategory.values.map((c) => DropdownMenuItem(value: c, child: Text(_categoryName(c)))).toList(),
                      onChanged: (v) => setState(() => _category = v ?? FileCategory.other),
                      decoration: const InputDecoration(labelText: 'Category'),
                    ),
                    const SizedBox(height: 15),
                    TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Display Name')),
                    const SizedBox(height: 15),
                    TextField(controller: _descController, decoration: const InputDecoration(labelText: 'Description (optional)'), maxLines: 2),
                    const SizedBox(height: 20),
                    _buildPreviewTile(),
                    if (_isUploading) const Padding(padding: EdgeInsets.only(top: 20), child: LinearProgressIndicator()),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isUploading ? null : _upload,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 55),
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(_isUploading ? 'Uploading...' : 'Confirm & Save', style: const TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewTile() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.backgroundLight, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          const Icon(Icons.insert_drive_file, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(child: Text(widget.initialFile.name, style: const TextStyle(fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  String _categoryName(FileCategory c) {
    switch (c) {
      case FileCategory.allergyReport: return 'Allergy Report';
      case FileCategory.prescription: return 'Prescription';
      case FileCategory.medicalAnalysis: return 'Medical Analysis';
      default: return 'Other';
    }
  }

  String _guessMimeType(String filename) => filename.toLowerCase().endsWith('.pdf') ? 'application/pdf' : 'image/jpeg';
}