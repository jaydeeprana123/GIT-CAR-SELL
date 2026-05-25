import 'package:cloud_firestore/cloud_firestore.dart';

class Company {
  final String companyId;
  final String companyName;
  final String ownerName;
  final String email;
  final bool isActive;
  final DateTime subscriptionStartDate;
  final DateTime subscriptionExpiryDate;
  final String purchaseScheme; // 'online' or 'offline'
  final DateTime createdAt;

  Company({
    required this.companyId,
    required this.companyName,
    required this.ownerName,
    required this.email,
    required this.isActive,
    required this.subscriptionStartDate,
    required this.subscriptionExpiryDate,
    required this.purchaseScheme,
    required this.createdAt,
  });

  factory Company.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parseDateTime(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is Timestamp) return value.toDate();
      if (value is String) {
        return DateTime.tryParse(value) ?? DateTime.now();
      }
      return DateTime.now();
    }

    return Company(
      companyId: docId,
      companyName: map['companyName'] ?? '',
      ownerName: map['ownerName'] ?? '',
      email: map['email'] ?? '',
      isActive: map['isActive'] ?? false,
      subscriptionStartDate: parseDateTime(map['subscriptionStartDate']),
      subscriptionExpiryDate: parseDateTime(map['subscriptionExpiryDate']),
      purchaseScheme: map['purchaseScheme'] ?? 'offline',
      createdAt: parseDateTime(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'companyId': companyId,
      'companyName': companyName,
      'ownerName': ownerName,
      'email': email,
      'isActive': isActive,
      'subscriptionStartDate': Timestamp.fromDate(subscriptionStartDate),
      'subscriptionExpiryDate': Timestamp.fromDate(subscriptionExpiryDate),
      'purchaseScheme': purchaseScheme,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
