import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../db/db_helper.dart';

class LocalizationController extends GetxController {
  final RxString currentLanguageCode = 'gu'.obs;
  final DbHelper _dbHelper = DbHelper();

  LocalizationController({required String initialLanguage}) {
    currentLanguageCode.value = initialLanguage;
  }

  // Get matching Locale object
  Locale get currentLocale => Locale(currentLanguageCode.value);

  // Get user-friendly name of the current language
  String get currentLanguageName {
    switch (currentLanguageCode.value) {
      case 'en':
        return 'English';
      case 'hi':
        return 'हिन्दी';
      case 'gu':
      default:
        return 'ગુજરાતી';
    }
  }

  // Update language, persist to database, and update GetX locale
  Future<void> changeLanguage(String langCode) async {
    if (langCode == currentLanguageCode.value) return;
    
    currentLanguageCode.value = langCode;
    await _dbHelper.saveSetting('languageCode', langCode);
    
    // Update the GetX locale dynamically
    await Get.updateLocale(Locale(langCode));
  }
}
