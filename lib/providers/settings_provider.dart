import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

enum ViewMode { grid, list }
enum SortOrder { nameAsc, nameDesc, dateCreated }

class SettingsProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  Locale? _locale;
  bool _keepScreenOn = true;
  ViewMode _viewMode = ViewMode.grid;
  SortOrder _decksSortOrder = SortOrder.nameAsc;
  SortOrder _cardsSortOrder = SortOrder.dateCreated;

  ThemeMode get themeMode => _themeMode;
  Locale? get locale => _locale;
  bool get keepScreenOn => _keepScreenOn;
  ViewMode get viewMode => _viewMode;
  SortOrder get decksSortOrder => _decksSortOrder;
  SortOrder get cardsSortOrder => _cardsSortOrder;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeString = prefs.getString('themeMode') ?? 'system';
    _themeMode = _themeModeFromString(themeModeString);

    final localeString = prefs.getString('locale');
    if (localeString != null && localeString != 'system') {
      _locale = Locale(localeString);
    }

    _keepScreenOn = prefs.getBool('keepScreenOn') ?? true;
    await _applyWakelockSetting();

    final viewModeString = prefs.getString('viewMode') ?? 'grid';
    _viewMode = viewModeString == 'list' ? ViewMode.list : ViewMode.grid;

    _decksSortOrder = _sortOrderFromString(prefs.getString('decksSortOrder') ?? 'nameAsc');
    _cardsSortOrder = _sortOrderFromString(prefs.getString('cardsSortOrder') ?? 'dateCreated');

    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', _themeModeToString(mode));
  }

  ThemeMode _themeModeFromString(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      default:
        return 'system';
    }
  }

  Future<void> setLocale(Locale? locale) async {
    _locale = locale;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.setString('locale', 'system');
    } else {
      await prefs.setString('locale', locale.languageCode);
    }
  }

  Future<void> setKeepScreenOn(bool value) async {
    _keepScreenOn = value;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('keepScreenOn', value);
    
    await _applyWakelockSetting();
  }

  Future<void> _applyWakelockSetting() async {
    if (Platform.isAndroid || Platform.isIOS) {
      if (_keepScreenOn) {
        await WakelockPlus.enable();
      } else {
        await WakelockPlus.disable();
      }
    }
  }

  Future<void> setViewMode(ViewMode mode) async {
    _viewMode = mode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('viewMode', mode == ViewMode.grid ? 'grid' : 'list');
  }

  Future<void> setDecksSortOrder(SortOrder order) async {
    _decksSortOrder = order;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('decksSortOrder', _sortOrderToString(order));
  }

  Future<void> setCardsSortOrder(SortOrder order) async {
    _cardsSortOrder = order;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cardsSortOrder', _sortOrderToString(order));
  }

  SortOrder _sortOrderFromString(String value) {
    switch (value) {
      case 'nameAsc':
        return SortOrder.nameAsc;
      case 'nameDesc':
        return SortOrder.nameDesc;
      case 'dateCreated':
        return SortOrder.dateCreated;
      default:
        return SortOrder.nameAsc;
    }
  }

  String _sortOrderToString(SortOrder order) {
    switch (order) {
      case SortOrder.nameAsc:
        return 'nameAsc';
      case SortOrder.nameDesc:
        return 'nameDesc';
      case SortOrder.dateCreated:
        return 'dateCreated';
    }
  }
}
