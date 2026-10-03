import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppMode { traveler, captain }

class AppModeController extends Notifier<AppMode> {
  @override
  AppMode build() => AppMode.traveler;

  void setMode(AppMode mode) => state = mode;
}

final appModeProvider =
    NotifierProvider<AppModeController, AppMode>(AppModeController.new);

class ThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.dark;

  void toggle() {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }
}

final themeModeProvider =
    NotifierProvider<ThemeModeController, ThemeMode>(ThemeModeController.new);
