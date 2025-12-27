import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants.dart';
import '../../models/medical_file_model.dart';
import '../../providers/user_provider.dart';

class FileViewerScreen extends StatelessWidget {
  const FileViewerScreen({super.key});

  Future<void> _openFile(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch browser';
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error opening file: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Récupération sécurisée de la catégorie via les arguments de route
    final category = ModalRoute.of(context)!.settings.arguments as FileCategory;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(_getCategoryTitle(category), style: GoogleFonts.dmSans()),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final files = userProvider.getFilesByCategory(category);

          if (files.isEmpty) {
            return Center(
              child: Text("No documents in this category",
                  style: GoogleFonts.inter(color: AppColors.textSecondary)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSizes.paddingM),
            itemCount: files.length,
            itemBuilder: (context, index) {
              final medicalFile = files[index]; // Changé pour correspondre au type

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  leading: const Icon(Icons.picture_as_pdf, color: Colors.redAccent, size: 30),
                  title: Text(medicalFile.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Uploaded: ${medicalFile.uploadedAt.day}/${medicalFile.uploadedAt.month}"),
                  trailing: const Icon(Icons.open_in_new, color: AppColors.primary),
                  onTap: () {
                    // CORRECTION ICI : Gestion du String? (Nullable)
                    if (medicalFile.fileUrl != null) {
                      _openFile(context, medicalFile.fileUrl!); // Le '!' force la String non-nulle
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("This demo file has no URL link")),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _getCategoryTitle(FileCategory category) {
    switch (category) {
      case FileCategory.allergyReport: return "Allergy Reports";
      case FileCategory.prescription: return "Prescriptions";
      case FileCategory.medicalAnalysis: return "Analysis";
      default: return "Other Documents";
    }
  }
}