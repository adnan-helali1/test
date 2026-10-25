import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const localePreferenceKey = 'dar_nasri_locale';

class LocaleController extends Notifier<Locale> {
  @override
  Locale build() => const Locale('ar');

  Future<void> restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(localePreferenceKey);
      if (code == 'ar' || code == 'en' || code == 'tr') {
        state = Locale(code!);
      }
    } catch (_) {
      state = const Locale('ar');
    }
  }

  Future<void> setCode(String code) async {
    if (code != 'ar' && code != 'en' && code != 'tr') return;
    state = Locale(code);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(localePreferenceKey, code);
    } catch (_) {
      // The in-memory locale still switches for this session.
    }
  }
}

final localeProvider = NotifierProvider<LocaleController, Locale>(
  LocaleController.new,
);
