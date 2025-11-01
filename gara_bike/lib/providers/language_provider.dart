import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier {
  Locale _appLocale = const Locale('en');

  Locale get appLocale => _appLocale;

  LanguageProvider() {
    _loadLocale();
  }

  void _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    String languageCode = prefs.getString('languageCode') ?? 'en';
    _appLocale = Locale(languageCode);
    notifyListeners();
  }

  void changeLanguage(Locale newLocale) async {
    if (_appLocale == newLocale) return;

    final prefs = await SharedPreferences.getInstance();
    prefs.setString('languageCode', newLocale.languageCode);
    _appLocale = newLocale;
    notifyListeners();
  }
}
