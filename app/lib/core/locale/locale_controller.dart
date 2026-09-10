import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class LocaleController extends Notifier<Locale> {
  @override
  Locale build() {
    // Start in the device's language when it is one the app speaks.
    final device = PlatformDispatcher.instance.locale.languageCode;
    return Locale(device == 'ar' ? 'ar' : 'en');
  }

  void toggle() => state = Locale(state.languageCode == 'ar' ? 'en' : 'ar');
}

final localeProvider =
    NotifierProvider<LocaleController, Locale>(LocaleController.new);
