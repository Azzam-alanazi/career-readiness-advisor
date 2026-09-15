import 'dart:ui';

import 'package:career_readiness/features/profile/data/profile_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LocaleController extends Notifier<Locale> {
  @override
  Locale build() {
    // The student's own choice once made, kept on the device; until then the
    // device's language, when it is one the app speaks.
    final saved = ref.watch(profileStoreProvider).language();
    if (saved != null && (saved == 'ar' || saved == 'en')) return Locale(saved);
    final device = PlatformDispatcher.instance.locale.languageCode;
    return Locale(device == 'ar' ? 'ar' : 'en');
  }

  void toggle() => set(Locale(state.languageCode == 'ar' ? 'en' : 'ar'));

  void set(Locale locale) {
    state = locale;
    // A failed write costs only the remembered preference, not the switch.
    ref.read(profileStoreProvider).saveLanguage(locale.languageCode).ignore();
  }
}

final localeProvider =
    NotifierProvider<LocaleController, Locale>(LocaleController.new);
