import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../db/db_helper.dart';
import '../models/company.dart';
import '../models/user_model.dart';
import '../views/login_page.dart';
import '../views/blocked_page.dart';
import '../views/super_admin/super_admin_dashboard_page.dart';
import '../views/home_page.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  final DbHelper _dbHelper = DbHelper();

  final Rxn<User> firebaseUser = Rxn<User>();
  final Rxn<UserModel> currentUserModel = Rxn<UserModel>();
  final Rxn<Company> currentCompanyModel = Rxn<Company>();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  
  // Local verification details (for UI display and offline fallback)
  final RxString localRole = ''.obs;
  final RxString localCompanyId = ''.obs;
  final RxString localCompanyName = ''.obs;
  final RxString localLastVerifiedDate = ''.obs;
  final RxString blockedReason = ''.obs; // 'expired', 'deactivated', 'offline_limit'

  @override
  void onInit() {
    super.onInit();
    // Listen to Firebase Auth state changes
    firebaseUser.bindStream(_authService.authStateChanges);
    ever(firebaseUser, _handleAuthStateChanged);
  }

  // Handle Auth changes and check access
  Future<void> _handleAuthStateChanged(User? user) async {
    if (user == null) {
      // Clear local state
      await _clearLocalVerification();
      Get.offAll(() => const LoginPage());
    } else {
      await checkAccess(user);
    }
  }

  // Determine online status and run verification
  Future<void> checkAccess(User user) async {
    isLoading.value = true;
    errorMessage.value = '';
    
    final online = await isOnline();
    if (online) {
      await _verifyOnline(user);
    } else {
      await _verifyOffline(user);
    }
    isLoading.value = false;
  }

  // Check if internet connection is available
  Future<bool> isOnline() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 4));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  // Perform online verification against Firestore
  Future<void> _verifyOnline(User user) async {
    try {
      // 1. If user is Super Admin by email
      if (user.email == 'jaideep1210@gmail.com') {
        await _authService.seedSuperAdmin(user.uid, user.email!);
        
        currentUserModel.value = UserModel(
          uid: user.uid,
          email: user.email!,
          role: 'Super Admin',
          companyId: '',
        );

        // Save local verification status as Super Admin
        await _saveLocalVerification(
          role: 'Super Admin',
          companyId: '',
          companyName: 'Super Admin System',
        );

        Get.offAll(() => const SuperAdminDashboardPage());
        return;
      }

      // 2. Fetch user document
      final userDoc = await _authService.getUserData(user.uid);
      if (userDoc == null) {
        errorMessage.value = 'યુઝર એકાઉન્ટ માહિતી મળી નથી.';
        await logout();
        return;
      }

      currentUserModel.value = userDoc;

      // Check user role
      if (userDoc.role == 'Super Admin') {
        await _saveLocalVerification(
          role: 'Super Admin',
          companyId: '',
          companyName: 'Super Admin System',
        );
        Get.offAll(() => const SuperAdminDashboardPage());
        return;
      }

      // 3. Fetch Company details
      final companyDoc = await _authService.getCompanyData(userDoc.companyId);
      if (companyDoc == null) {
        errorMessage.value = 'કંપની માહિતી મળી નથી.';
        await logout();
        return;
      }

      currentCompanyModel.value = companyDoc;

      // 4. Validate Company Status and Expiry
      final now = DateTime.now();

      if (!companyDoc.isActive) {
        blockedReason.value = 'deactivated';
        Get.offAll(() => const BlockedPage());
        return;
      }

      if (now.isAfter(companyDoc.subscriptionExpiryDate)) {
        blockedReason.value = 'expired';
        Get.offAll(() => const BlockedPage());
        return;
      }

      // 5. Success! Save status locally
      await _saveLocalVerification(
        role: userDoc.role,
        companyId: companyDoc.companyId,
        companyName: companyDoc.companyName,
        purchaseScheme: companyDoc.purchaseScheme,
      );

      Get.offAll(() => const HomePage());
    } catch (e) {
      Get.log('Online verification error: $e');
      // If Firestore fails due to permission or networking issues during verification, fall back to offline verification
      await _verifyOffline(user);
    }
  }

  // Perform offline verification against SQFlite database
  Future<void> _verifyOffline(User user) async {
    final lastVerifiedStr = await _dbHelper.getSetting('lastVerifiedDate');
    final role = await _dbHelper.getSetting('userRole') ?? 'Staff User';
    final companyId = await _dbHelper.getSetting('companyId') ?? '';
    final companyName = await _dbHelper.getSetting('companyName') ?? '';

    if (lastVerifiedStr == null) {
      // Never verified online
      blockedReason.value = 'offline_limit';
      Get.offAll(() => const BlockedPage());
      return;
    }

    final lastVerifiedDate = DateTime.tryParse(lastVerifiedStr) ?? DateTime.fromMillisecondsSinceEpoch(0);
    final daysDifference = DateTime.now().difference(lastVerifiedDate).inDays;

    if (daysDifference >= 7) {
      blockedReason.value = 'offline_limit';
      Get.offAll(() => const BlockedPage());
      return;
    }

    // Set local variables for UI reference
    localRole.value = role;
    localCompanyId.value = companyId;
    localCompanyName.value = companyName;
    localLastVerifiedDate.value = lastVerifiedStr;

    // Load mock user metadata
    currentUserModel.value = UserModel(
      uid: user.uid,
      email: user.email ?? '',
      role: role,
      companyId: companyId,
    );

    Get.offAll(() => const HomePage());
  }

  // Login
  Future<void> login(String email, String password) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      errorMessage.value = 'કૃપા કરીને ઇમેઇલ અને પાસવર્ડ દાખલ કરો.';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      await _authService.signIn(email.trim(), password.trim());
      // The Firebase Auth listener will trigger and handle checking access
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        errorMessage.value = 'ઇમેઇલ અથવા પાસવર્ડ ખોટો છે.';
      } else if (e.code == 'network-request-failed') {
        errorMessage.value = 'નેટવર્ક કનેક્શન નથી. કૃપા કરીને ઓનલાઇન લોગીન કરો.';
      } else {
        errorMessage.value = e.message ?? 'લોગીન નિષ્ફળ ગયું.';
      }
      isLoading.value = false;
    } catch (e) {
      errorMessage.value = 'લોગીન કરતી વખતે ભૂલ થઈ: $e';
      isLoading.value = false;
    }
  }

  // Logout
  Future<void> logout() async {
    isLoading.value = true;
    try {
      await _authService.signOut();
      await _clearLocalVerification();
      currentUserModel.value = null;
      currentCompanyModel.value = null;
      blockedReason.value = '';
    } catch (e) {
      Get.log('Logout error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Save verification details to SQFlite settings table
  Future<void> _saveLocalVerification({
    required String role,
    required String companyId,
    required String companyName,
    String purchaseScheme = 'offline',
  }) async {
    final nowStr = DateTime.now().toIso8601String();
    await _dbHelper.saveSetting('lastVerifiedDate', nowStr);
    await _dbHelper.saveSetting('userRole', role);
    await _dbHelper.saveSetting('companyId', companyId);
    await _dbHelper.saveSetting('companyName', companyName);
    await _dbHelper.saveSetting('purchaseScheme', purchaseScheme);

    localRole.value = role;
    localCompanyId.value = companyId;
    localCompanyName.value = companyName;
    localLastVerifiedDate.value = nowStr;
  }

  // Clear local verification details
  Future<void> _clearLocalVerification() async {
    await _dbHelper.deleteSetting('lastVerifiedDate');
    await _dbHelper.deleteSetting('userRole');
    await _dbHelper.deleteSetting('companyId');
    await _dbHelper.deleteSetting('companyName');
    await _dbHelper.deleteSetting('purchaseScheme');

    localRole.value = '';
    localCompanyId.value = '';
    localCompanyName.value = '';
    localLastVerifiedDate.value = '';
  }
}
