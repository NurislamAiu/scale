import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'language_event.dart';
part 'language_state.dart';

class LanguageBloc extends Bloc<LanguageEvent, LanguageState> {
  final SharedPreferences prefs;
  static const String _langKey = 'selected_language';

  LanguageBloc(this.prefs) : super(LanguageState(Locale(prefs.getString(_langKey) ?? 'ru'))) {
    on<LanguageChanged>((event, emit) {
      prefs.setString(_langKey, event.locale.languageCode);
      emit(LanguageState(event.locale));
    });
  }
}
