enum FileCategory {
  allergyReport,
  prescription,
  birthCertificate,
  medicalAnalysis,
  other,
}

class MedicalFileModel {
  final String id;
  final String name;
  final FileCategory category;
  final String? description;
  final String? fileUrl;
  final DateTime uploadedAt;
  final bool isImportant;

  MedicalFileModel({
    required this.id,
    required this.name,
    required this.category,
    this.description,
    this.fileUrl,
    DateTime? uploadedAt,
    this.isImportant = false,
  }) : uploadedAt = uploadedAt ?? DateTime.now();

  String get categoryName {
    switch (category) {
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

  MedicalFileModel copyWith({
    String? id,
    String? name,
    FileCategory? category,
    String? description,
    String? fileUrl,
    DateTime? uploadedAt,
    bool? isImportant,
  }) {
    return MedicalFileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      fileUrl: fileUrl ?? this.fileUrl,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      isImportant: isImportant ?? this.isImportant,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category.index,
      'description': description,
      'fileUrl': fileUrl,
      'uploadedAt': uploadedAt.toIso8601String(),
      'isImportant': isImportant,
    };
  }

  bool get isImage {
    final url = (fileUrl ?? name).toLowerCase();
    return url.endsWith('.png') ||
        url.endsWith('.jpg') ||
        url.endsWith('.jpeg') ||
        url.endsWith('.gif') ||
        url.endsWith('.webp') ||
        url.endsWith('.bmp');
  }

  factory MedicalFileModel.fromJson(Map<String, dynamic> json) {
    return MedicalFileModel(
      id: json['id'] as String,
      name: json['name'] as String,
      category: FileCategory.values[json['category'] as int],
      description: json['description'] as String?,
      fileUrl: json['fileUrl'] as String?,
      uploadedAt: DateTime.parse(json['uploadedAt'] as String),
      isImportant: json['isImportant'] as bool? ?? false,
    );
  }

  // Demo files for testing
  static List<MedicalFileModel> get demoFiles => [
    MedicalFileModel(
      id: '1',
      name: 'Allergy Report 2024',
      category: FileCategory.allergyReport,
      description: 'Annual allergy test results',
      isImportant: true,
    ),
    MedicalFileModel(
      id: '2',
      name: 'Prescription - November 2024',
      category: FileCategory.prescription,
      description: 'Monthly medication prescription',
    ),
    MedicalFileModel(
      id: '3',
      name: 'Birth Certificate',
      category: FileCategory.birthCertificate,
      description: 'Official birth certificate',
      isImportant: true,
    ),
    MedicalFileModel(
      id: '4',
      name: 'Blood Test Results',
      category: FileCategory.medicalAnalysis,
      description: 'Complete blood count analysis',
    ),
  ];
}

class EmergencyContact {
  final String name;
  final String number;
  final String iconPath;

  const EmergencyContact({
    required this.name,
    required this.number,
    required this.iconPath,
  });

  static List<EmergencyContact> get defaultContacts => [
    const EmergencyContact(name: 'SAMU', number: '15', iconPath: 'ambulance'),
    const EmergencyContact(name: 'Police', number: '17', iconPath: 'shield'),
    const EmergencyContact(
      name: 'Firefighters',
      number: '18',
      iconPath: 'fire',
    ),
    const EmergencyContact(
      name: 'European Emergency',
      number: '112',
      iconPath: 'emergency',
    ),
  ];
}
