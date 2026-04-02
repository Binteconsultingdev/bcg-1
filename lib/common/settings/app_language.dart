
import 'dart:ui';

enum AppLanguage {
  spanish,
  english,
}

extension AppLanguageValue on AppLanguage {
  String get locale {
    switch (this) {
      case AppLanguage.spanish:
        return 'es_ES';
      case AppLanguage.english:
        return 'en_US';
    }
  }

  String get assetPath {
    switch (this) {
      case AppLanguage.spanish:
        return 'assets/i18n/es.json';
      case AppLanguage.english:
        return 'assets/i18n/en.json';
    }
  }

  Locale get toLocale {
    switch (this) {
      case AppLanguage.spanish:
        return Locale('es', 'ES');
      case AppLanguage.english:
        return Locale('en', 'US');
    }
  }

  String get displayName {
    switch (this) {
      case AppLanguage.spanish:
        return 'Español';
      case AppLanguage.english:
        return 'English';
    }
  }

  static AppLanguage fromLocaleString(String locale) {
    switch (locale) {
      case 'es_ES':
        return AppLanguage.spanish;
      case 'en_US':
        return AppLanguage.english;
      default:
        return AppLanguage.spanish;
    }
  }
}