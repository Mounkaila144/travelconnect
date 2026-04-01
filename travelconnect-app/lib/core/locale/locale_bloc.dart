import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'locale_event.dart';
import 'locale_state.dart';

class LocaleBloc extends Bloc<LocaleEvent, LocaleState> {
  final SharedPreferences _prefs;
  static const _key = 'app_locale';
  static const _supportedLanguages = {'fr', 'en', 'ja'};

  LocaleBloc({required SharedPreferences prefs})
      : _prefs = prefs,
        super(const LocaleState(Locale('fr'))) {
    on<LoadSavedLocale>(_onLoadSavedLocale);
    on<ChangeLocale>(_onChangeLocale);
  }

  void _onLoadSavedLocale(LoadSavedLocale event, Emitter<LocaleState> emit) {
    final saved = _prefs.getString(_key);
    if (saved != null) {
      emit(LocaleState(Locale(saved)));
    } else {
      // First launch: use the device language if supported, otherwise fall back to French
      final deviceLocale = PlatformDispatcher.instance.locale;
      final lang = deviceLocale.languageCode;
      final resolved =
          _supportedLanguages.contains(lang) ? lang : 'fr';
      emit(LocaleState(Locale(resolved)));
    }
  }

  Future<void> _onChangeLocale(
    ChangeLocale event,
    Emitter<LocaleState> emit,
  ) async {
    await _prefs.setString(_key, event.locale.languageCode);
    emit(LocaleState(event.locale));
  }
}
