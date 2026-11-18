import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:delivery_app/core/constant/app_constants.dart';

class LocaleCubit extends Cubit<Locale> {
  LocaleCubit() : super(const Locale('en'));

  Future<void> loadSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCode = prefs.getString(AppConstants.keyAppLocale);
      if (savedCode == 'ur') {
        emit(const Locale('ur'));
      } else {
        emit(const Locale('en'));
      }
    } catch (_) {
      emit(const Locale('en'));
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (state.languageCode == locale.languageCode) return;
    emit(locale);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.keyAppLocale, locale.languageCode);
    } catch (_) {
      // Ignore storage failures in test/headless mode
    }
  }

  Future<void> toggleLocale() async {
    final next = state.languageCode == 'en'
        ? const Locale('ur')
        : const Locale('en');
    await setLocale(next);
  }
}
