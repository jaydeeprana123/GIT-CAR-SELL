class UserModel {
  final String uid;
  final String email;
  final String role;
  final String companyId;

  UserModel({
    required this.uid,
    required this.email,
    required this.role,
    required this.companyId,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String docId) {
    return UserModel(
      uid: docId,
      email: map['email'] ?? '',
      role: map['role'] ?? 'Staff User',
      companyId: map['companyId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'role': role,
      'companyId': companyId,
    };
  }
}
