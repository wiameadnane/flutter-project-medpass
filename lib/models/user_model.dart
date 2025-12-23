import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;

class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String? profileImageUrl;
  final DateTime? dateOfBirth;
  final String? bloodType;
  final double? height; // in cm
  final double? weight; // in kg
  final String? nationality;
  final String? gender;
  final bool isPremium;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.profileImageUrl,
    this.dateOfBirth,
    this.bloodType,
    this.height,
    this.weight,
    this.nationality,
    this.gender,
    this.isPremium = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  String get formattedDateOfBirth {
    if (dateOfBirth == null) return '';
    return '${dateOfBirth!.day.toString().padLeft(2, '0')}/${dateOfBirth!.month.toString().padLeft(2, '0')}/${dateOfBirth!.year}';
  }

  String get formattedHeight {
    if (height == null) return '';
    return '${height!.toInt()} cm';
  }

  String get formattedWeight {
    if (weight == null) return '';
    return '${weight!.toInt()} Kg';
  }

  UserModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? profileImageUrl,
    DateTime? dateOfBirth,
    String? bloodType,
    double? height,
    double? weight,
    String? nationality,
    String? gender,
    bool? isPremium,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      bloodType: bloodType ?? this.bloodType,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      nationality: nationality ?? this.nationality,
      gender: gender ?? this.gender,
      isPremium: isPremium ?? this.isPremium,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'profile_image_url': profileImageUrl,
      'date_of_birth': dateOfBirth != null ? Timestamp.fromDate(dateOfBirth!) : null,
      'blood_type': bloodType,
      'height': height,
      'weight': weight,
      'country_of_origin': nationality,
      'gender': gender,
      'is_premium': isPremium,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    DateTime? dob;
    final dobVal = json['date_of_birth'] ?? json['dateOfBirth'];
    if (dobVal != null) {
      if (dobVal is Timestamp) dob = dobVal.toDate();
      else if (dobVal is String) dob = DateTime.tryParse(dobVal);
    }

    DateTime created = DateTime.now();
    final createdVal = json['created_at'] ?? json['createdAt'];
    if (createdVal != null) {
      if (createdVal is Timestamp) created = createdVal.toDate();
      else if (createdVal is String) created = DateTime.tryParse(createdVal) ?? created;
    }

    String idVal = json['id'] ?? json['uid'] ?? (json['documentId'] ?? '');
    String fullNameVal = json['full_name'] ?? json['fullName'] ?? '';
    String emailVal = json['email'] ?? '';

    double? h;
    final hVal = json['height'] ?? json['height_cm'];
    if (hVal is int) h = hVal.toDouble();
    else if (hVal is double) h = hVal;

    double? w;
    final wVal = json['weight'] ?? json['weight_kg'];
    if (wVal is int) w = wVal.toDouble();
    else if (wVal is double) w = wVal;

    return UserModel(
      id: idVal as String,
      fullName: fullNameVal as String,
      email: emailVal as String,
      phoneNumber: (json['phone_number'] ?? json['phoneNumber']) as String?,
      profileImageUrl: (json['profile_image_url'] ?? json['profileImageUrl']) as String?,
      dateOfBirth: dob,
      bloodType: (json['blood_type'] ?? json['bloodType']) as String?,
      height: h,
      weight: w,
      nationality: (json['country_of_origin'] ?? json['nationality']) as String?,
      gender: (json['gender']) as String?,
      isPremium: (json['is_premium'] ?? json['isPremium']) as bool? ?? false,
      createdAt: created,
    );
  }

  // Demo user for testing
  static UserModel get demoUser => UserModel(
        id: '21101001',
        fullName: 'Israa Aqdora',
        email: 'israaaqdora@outlook.fr',
        phoneNumber: '0693339086',
        dateOfBirth: DateTime(2003, 11, 19),
        bloodType: 'O+',
        height: 157,
        weight: 61,
        nationality: 'Moroccan',
        gender: 'Female',
        isPremium: false,
      );
}
