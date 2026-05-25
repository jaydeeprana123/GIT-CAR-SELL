import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String role;
  final String companyId;
  final String? staffName;
  final String? mobileNumber;
  final bool isActive;
  final DateTime? createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.role,
    required this.companyId,
    this.staffName,
    this.mobileNumber,
    this.isActive = true,
    this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String docId) {
    return UserModel(
      uid: docId,
      email: map['email'] ?? '',
      role: map['role'] ?? 'Staff User',
      companyId: map['companyId'] ?? '',
      staffName: map['staffName'] as String?,
      mobileNumber: map['mobileNumber'] as String?,
      isActive: map['isActive'] as bool? ?? true,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] is Timestamp
              ? (map['createdAt'] as Timestamp).toDate()
              : DateTime.tryParse(map['createdAt'].toString()))
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'role': role,
      'companyId': companyId,
      if (staffName != null) 'staffName': staffName,
      if (mobileNumber != null) 'mobileNumber': mobileNumber,
      'isActive': isActive,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
    };
  }
}
