import 'dart:io';
import 'dart:typed_data';
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../core/constants.dart';
import '../../models/medical_file_model.dart';
import '../../providers/user_provider.dart';
import '../../firebase_options.dart';

class UploadFileScreen extends StatefulWidget {
  const UploadFileScreen({super.key});

  @override
  State<UploadFileScreen> createState() => _UploadFileScreenState();
}

class _UploadFileScreenState extends State<UploadFileScreen> {
  FileCategory _category = FileCategory.other;
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  PlatformFile? _pickedFile;
  bool _isUploading = false;
  double _progress = -1.0; // -1 => indeterminate
  final List<String> _logs = [];
  int _lastTransferred = -1;
  Timer? _stallTimer;
  int _attempt = 0;
  final int _maxAttempts = 3;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(withData: kIsWeb);
    if (result == null) return;
    setState(() {
      _pickedFile = result.files.first;
      _nameController.text = _pickedFile?.name ?? '';
    });
  }

  Future<void> _upload() async {
    if (_pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a file to upload')),
      );
      return;
    }

    final userProvider = context.read<UserProvider>();
    final user = userProvider.firebaseUser;
    final uid = user?.uid ?? userProvider.user?.id;
    if (uid == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No user logged in')));
      return;
    }

    // wrap the upload in a retry loop — on web uploads can stall; try a few times
    setState(() {
      _isUploading = true;
      _progress = (kIsWeb || _pickedFile!.path == null) ? -1.0 : 0.0;
    });

    _attempt = 0;
    String? downloadUrl;
    final basename = _pickedFile!.name;

    while (_attempt < _maxAttempts) {
      _attempt++;
      final attemptMsg = 'Starting upload attempt #$_attempt/$_maxAttempts';
      debugPrint(attemptMsg);
      setState(() {
        _logs.insert(0, attemptMsg);
        if (_logs.length > 20) _logs.removeLast();
      });

      try {
        downloadUrl = await _performSingleUpload(uid, basename);
        // success
        break;
      } catch (e) {
        final em = 'Attempt #$_attempt failed: ${e.toString()}';
        debugPrint(em);
        setState(() {
          _logs.insert(0, em);
          if (_logs.length > 20) _logs.removeLast();
        });

        // If we've exhausted attempts, rethrow to outer catch
        if (_attempt >= _maxAttempts) {
          rethrow;
        }

        // wait a bit before retry
        await Future.delayed(Duration(seconds: 2 * _attempt));
      }
    }

    // After successful upload, save metadata
    try {
      if (downloadUrl == null) {
        throw Exception('Upload failed after $_maxAttempts attempts');
      }

      final model = MedicalFileModel(
        id: '',
        name: _nameController.text.isNotEmpty ? _nameController.text : basename,
        category: _category,
        description: _descController.text.isNotEmpty
            ? _descController.text
            : null,
        fileUrl: downloadUrl,
        uploadedAt: DateTime.now(),
      );

      final success = await userProvider.addMedicalFile(model);

      setState(() {
        _isUploading = false;
      });

      if (!mounted) return;

      final msg = success
          ? 'File metadata saved to Firestore.'
          : 'Failed to save file metadata: ${userProvider.error}';
      debugPrint(msg);
      setState(() {
        _logs.insert(0, msg);
        if (_logs.length > 20) _logs.removeLast();
      });

      if (success) {
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(userProvider.error ?? 'Upload failed')),
        );
      }
    } catch (e) {
      final msg = 'Upload error: ${e.toString()}';
      debugPrint(msg);
      setState(() {
        _isUploading = false;
        _logs.insert(0, msg);
        if (_logs.length > 20) _logs.removeLast();
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  Future<String> _performSingleUpload(String uid, String basename) async {
    // Build path and ref
    final storagePath =
      'users/$uid/medical_files/${DateTime.now().millisecondsSinceEpoch}_$basename';

    // Use explicitly configured storage bucket if available. This helps when
    // the FirebaseOptions.storageBucket value differs from the platform
    // default or when using a Google Cloud Storage bucket that was enabled
    // separately.
    final configuredBucket = DefaultFirebaseOptions.currentPlatform.storageBucket;
    final storage = (configuredBucket != null && configuredBucket.isNotEmpty)
      ? FirebaseStorage.instanceFor(bucket: 'gs://$configuredBucket')
      : FirebaseStorage.instance;

    final ref = storage.ref().child(storagePath);

    UploadTask uploadTask;
    // choose data source
    if (kIsWeb || _pickedFile!.path == null) {
      final Uint8List? bytes = _pickedFile!.bytes;
      if (bytes == null) {
        throw Exception('On web `path` is null — use `bytes` instead');
      }
      final contentType = _guessMimeType(basename);
      uploadTask = ref.putData(
        bytes,
        SettableMetadata(contentType: contentType),
      );
    } else {
      final file = File(_pickedFile!.path!);
      final contentType = _guessMimeType(basename);
      uploadTask = ref.putFile(
        file,
        SettableMetadata(contentType: contentType),
      );
    }

    // Reset stall tracking for this attempt
    _lastTransferred = -1;
    _stallTimer?.cancel();

    final Completer<TaskSnapshot> completer = Completer();

    // listen for snapshots
    final sub = uploadTask.snapshotEvents.listen(
      (event) {
        final msg =
            'upload snapshot: state=${event.state}, transferred=${event.bytesTransferred}, total=${event.totalBytes}';
        debugPrint(msg);
        if (mounted) {
          setState(() {
            _logs.insert(0, msg);
            if (_logs.length > 20) _logs.removeLast();
            _progress = (event.totalBytes > 0)
                ? (event.bytesTransferred / event.totalBytes)
                : -1.0;
          });
        }

        // If progress changed, reset stall timer
        if (event.bytesTransferred != _lastTransferred) {
          _lastTransferred = event.bytesTransferred;
          _stallTimer?.cancel();
          // longer stall window for web
          final stallSeconds = kIsWeb ? 20 : 8;
          _stallTimer = Timer(Duration(seconds: stallSeconds), () async {
            final stallMsg =
                'Upload stalled: no progress detected for ${stallSeconds}s (transferred=$_lastTransferred)';
            debugPrint(stallMsg);
            if (mounted) {
              setState(() {
                _logs.insert(0, stallMsg);
                if (_logs.length > 20) _logs.removeLast();
              });
              try {
                await uploadTask.cancel();
              } catch (_) {}
            }
          });
        }

        if (event.state == TaskState.canceled) {
          // bubble as error
          final err = FirebaseException(
            plugin: 'firebase_storage',
            code: 'canceled',
            message: 'Upload canceled',
          );
          if (!completer.isCompleted) completer.completeError(err);
        }
      },
      onError: (e) {
        if (!completer.isCompleted) completer.completeError(e);
      },
    );

    // Wait for completion with timeout
    try {
      final snapshot = await uploadTask.timeout(const Duration(minutes: 5));
      if (!completer.isCompleted) completer.complete(snapshot);
      final done = await completer.future;
      await sub.cancel();
      _stallTimer?.cancel();
      final url = await done.ref.getDownloadURL();
      return url;
    } catch (e) {
      _stallTimer?.cancel();
      try {
        await uploadTask.cancel();
      } catch (_) {}
      await sub.cancel();
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Document', style: GoogleFonts.dmSans()),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 900),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.paddingL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusL),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.paddingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DropdownButtonFormField<FileCategory>(
                        initialValue: _category,
                        items: FileCategory.values
                            .map((c) => DropdownMenuItem(
                                  value: c,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: _categoryColor(c),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: AppSizes.paddingS),
                                      Text(
                                        _categoryName(c),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(color: AppColors.textPrimary),
                                      ),
                                    ],
                                  ),
                                ))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _category = v ?? FileCategory.other),
                        decoration: const InputDecoration(labelText: 'Category'),
                        dropdownColor: AppColors.backgroundCard,
                        icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
                      ),
                      const SizedBox(height: AppSizes.paddingM),
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'File name'),
                      ),
                      const SizedBox(height: AppSizes.paddingM),
                      TextField(
                        controller: _descController,
                        decoration: const InputDecoration(
                          labelText: 'Description (optional)',
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: AppSizes.paddingM),

                      // File picker / preview row
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _pickFile,
                              icon: const Icon(Icons.attach_file),
                              label: Text(_pickedFile?.name ?? 'Choose file'),
                            ),
                          ),
                          const SizedBox(width: AppSizes.paddingS),
                          if (_pickedFile != null)
                            IconButton(
                              onPressed: () => setState(() => _pickedFile = null),
                              icon: const Icon(Icons.close, color: AppColors.textSecondary),
                              tooltip: 'Remove file',
                            ),
                        ],
                      ),

                      const SizedBox(height: AppSizes.paddingM),

                      // Upload progress row
                      if (_isUploading)
                        Row(
                          children: [
                            Expanded(
                              child: _progress >= 0
                                  ? LinearProgressIndicator(value: _progress, minHeight: 6)
                                  : const LinearProgressIndicator(minHeight: 6),
                            ),
                            const SizedBox(width: AppSizes.paddingM),
                            Chip(
                              backgroundColor: AppColors.primary.withAlpha((0.12 * 255).round()),
                              label: Text(
                                _progress >= 0
                                    ? '${(_progress * 100).toStringAsFixed(0)}%'
                                    : 'Uploading',
                                style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.primary),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.paddingM),

              // Logs — compact, scrollable
              if (_logs.isNotEmpty)
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxHeight: 160),
                  padding: const EdgeInsets.all(AppSizes.paddingS),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundGrey,
                    borderRadius: BorderRadius.circular(AppSizes.radiusS),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _logs.length,
                    separatorBuilder: (context, index) => const Divider(height: 8, color: AppColors.divider),
                    itemBuilder: (ctx, i) => Text(
                      _logs[i],
                      style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ),
                ),
                    const SizedBox(height: AppSizes.paddingM),

                    // Action button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isUploading ? null : _upload,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSizes.paddingM,
                          ),
                          child: Text(
                            _isUploading ? 'Uploading...' : 'Upload',
                            style: GoogleFonts.inter(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  String _categoryName(FileCategory c) {
    switch (c) {
      case FileCategory.allergyReport:
        return 'Allergy Report';
      case FileCategory.prescription:
        return 'Recent Prescriptions';
      case FileCategory.birthCertificate:
        return 'Birth Certificate';
      case FileCategory.medicalAnalysis:
        return 'Medical Analysis';
      case FileCategory.other:
        return 'Other';
    }
  }

  Color _categoryColor(FileCategory c) {
    switch (c) {
      case FileCategory.allergyReport:
        return AppColors.allergy;
      case FileCategory.prescription:
        return AppColors.medication;
      case FileCategory.birthCertificate:
        return AppColors.document;
      case FileCategory.medicalAnalysis:
        return AppColors.bloodType;
      case FileCategory.other:
        return AppColors.primary;
    }
  }

  String _guessMimeType(String filename) {
    final lower = filename.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    if (lower.endsWith('.gif')) return 'image/gif';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.bmp')) return 'image/bmp';
    if (lower.endsWith('.pdf')) return 'application/pdf';
    if (lower.endsWith('.txt')) return 'text/plain';
    return 'application/octet-stream';
  }
}
