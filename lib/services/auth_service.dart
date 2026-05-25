import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/company.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current logged-in user
  User? get currentUser => _auth.currentUser;

  // Sign in
  Future<UserCredential> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Send password reset email
  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Fetch user role and info
  Future<UserModel?> getUserData(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!, doc.id);
  }

  // Fetch company data
  Future<Company?> getCompanyData(String companyId) async {
    final doc = await _firestore.collection('companies').doc(companyId).get();
    if (!doc.exists) return null;
    return Company.fromMap(doc.data()!, doc.id);
  }

  // Seed Super Admin if not present
  Future<void> seedSuperAdmin(String uid, String email) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) {
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'email': email,
        'role': 'Super Admin',
        'companyId': '',
      });
    }
  }

  // Register a new company and create Company Admin credentials
  Future<void> registerCompany({
    required String companyId,
    required String companyName,
    required String ownerName,
    required String email,
    required String password,
    required DateTime expiryDate,
    required String purchaseScheme,
  }) async {
    // 1. Check if company or email already exists in Firestore users
    final emailQuery = await _firestore.collection('users').where('email', isEqualTo: email).get();
    if (emailQuery.docs.isNotEmpty) {
      throw Exception('અ ઇમેલ સાથેનો યુઝર પહેલેથી ઉપલબ્ધ છે.');
    }

    final companyDoc = await _firestore.collection('companies').doc(companyId).get();
    if (companyDoc.exists) {
      throw Exception('કંપની ID પહેલેથી નોંધાયેલ છે.');
    }

    // 2. Add company to Firestore
    await _firestore.collection('companies').doc(companyId).set({
      'companyId': companyId,
      'companyName': companyName,
      'ownerName': ownerName,
      'email': email,
      'isActive': true,
      'subscriptionStartDate': Timestamp.fromDate(DateTime.now()),
      'subscriptionExpiryDate': Timestamp.fromDate(expiryDate),
      'purchaseScheme': purchaseScheme,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // 3. Create secondary Firebase App to create user without signing out the Super Admin
    FirebaseApp tempApp = await Firebase.initializeApp(
      name: 'TempCompanyAdminApp_${DateTime.now().millisecondsSinceEpoch}',
      options: Firebase.app().options,
    );

    try {
      // Create Firebase Auth user
      final userCred = await FirebaseAuth.instanceFor(app: tempApp)
          .createUserWithEmailAndPassword(email: email, password: password);

      final uid = userCred.user!.uid;

      // 4. Create user record in Firestore users collection
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'email': email,
        'role': 'Company Admin',
        'companyId': companyId,
      });
    } catch (e) {
      // Cleanup Firestore company if auth registration failed
      await _firestore.collection('companies').doc(companyId).delete();
      rethrow;
    } finally {
      await tempApp.delete();
    }
  }

  // Activate / deactivate company
  Future<void> updateCompanyStatus(String companyId, bool isActive) async {
    await _firestore.collection('companies').doc(companyId).update({
      'isActive': isActive,
    });
  }

  // Update company purchase scheme
  Future<void> updatePurchaseScheme(String companyId, String scheme) async {
    await _firestore.collection('companies').doc(companyId).update({
      'purchaseScheme': scheme,
    });
  }

  // Extend subscription
  Future<void> extendSubscription(String companyId, DateTime newExpiryDate) async {
    await _firestore.collection('companies').doc(companyId).update({
      'subscriptionExpiryDate': Timestamp.fromDate(newExpiryDate),
    });
  }

  // Stream of all companies (for Super Admin dashboard)
  Stream<List<Company>> getCompaniesStream() {
    return _firestore
        .collection('companies')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Company.fromMap(doc.data(), doc.id)).toList();
    });
  }

  // Register a new staff user
  Future<void> registerStaff({
    required String name,
    required String mobile,
    required String email,
    required String password,
    required String companyId,
  }) async {
    // 1. Check if email already exists
    final emailQuery = await _firestore.collection('users').where('email', isEqualTo: email).get();
    if (emailQuery.docs.isNotEmpty) {
      throw Exception('આ ઇમેઇલ સાથેનો યુઝર પહેલેથી નોંધાયેલ છે.');
    }

    // 2. Create secondary Firebase App
    FirebaseApp tempApp = await Firebase.initializeApp(
      name: 'TempStaffApp_${DateTime.now().millisecondsSinceEpoch}',
      options: Firebase.app().options,
    );

    try {
      final userCred = await FirebaseAuth.instanceFor(app: tempApp)
          .createUserWithEmailAndPassword(email: email, password: password);
      final uid = userCred.user!.uid;

      // 3. Save to Firestore users collection
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'email': email,
        'role': 'staff',
        'companyId': companyId,
        'staffName': name,
        'mobileNumber': mobile,
        'password': password,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } finally {
      await tempApp.delete();
    }
  }

  // Update staff password in Firebase Auth and Firestore
  Future<void> updateStaffPassword({
    required String uid,
    required String email,
    required String oldPassword,
    required String newPassword,
  }) async {
    FirebaseApp tempApp = await Firebase.initializeApp(
      name: 'TempStaffReset_${DateTime.now().millisecondsSinceEpoch}',
      options: Firebase.app().options,
    );

    try {
      final authInstance = FirebaseAuth.instanceFor(app: tempApp);
      // Sign in as staff using stored old password
      final userCred = await authInstance.signInWithEmailAndPassword(
        email: email,
        password: oldPassword,
      );
      // Update password in Firebase Auth
      await userCred.user!.updatePassword(newPassword);
      
      // Update Firestore user document
      await _firestore.collection('users').doc(uid).update({
        'password': newPassword,
      });
    } finally {
      await tempApp.delete();
    }
  }

  // Toggle staff active status in Firestore
  Future<void> toggleStaffActiveStatus(String uid, bool isActive) async {
    await _firestore.collection('users').doc(uid).update({
      'isActive': isActive,
    });
  }

  // Update staff details in Firestore
  Future<void> updateStaffDetails({
    required String uid,
    required String name,
    required String mobile,
  }) async {
    await _firestore.collection('users').doc(uid).update({
      'staffName': name,
      'mobileNumber': mobile,
    });
  }
}
