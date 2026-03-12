import 'dart:ui' as ui;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fortuneslip/l10n/app_localizations.dart';

class Model {
  Model._();

  static const String _prefFortune1 = 'fortune1';
  static const String _prefFortune2 = 'fortune2';
  static const String _prefFortune3 = 'fortune3';
  static const String _prefFortune4 = 'fortune4';
  static const String _prefFortune5 = 'fortune5';
  static const String _prefFortune6 = 'fortune6';
  static const String _prefFortune7 = 'fortune7';
  static const String _prefRatio1 = 'ratio1';
  static const String _prefRatio2 = 'ratio2';
  static const String _prefRatio3 = 'ratio3';
  static const String _prefRatio4 = 'ratio4';
  static const String _prefRatio5 = 'ratio5';
  static const String _prefRatio6 = 'ratio6';
  static const String _prefRatio7 = 'ratio7';
  static const String _prefCountdownTime = 'countdownTime';
  static const String _prefSoundVolume = 'soundVolume';
  static const String _prefTtsEnabled = 'ttsEnabled';
  static const String _prefTtsVolume = 'ttsVolume';
  static const String _prefTtsVoiceId = 'ttsVoiceId';
  static const String _prefThemeNumber = 'themeNumber';
  static const String _prefLanguageCode = 'languageCode';

  static bool _ready = false;
  static String _fortune1 = '';
  static String _fortune2 = '';
  static String _fortune3 = '';
  static String _fortune4 = '';
  static String _fortune5 = '';
  static String _fortune6 = '';
  static String _fortune7 = '';
  static int _ratio1 = 1;
  static int _ratio2 = 1;
  static int _ratio3 = 1;
  static int _ratio4 = 1;
  static int _ratio5 = 1;
  static int _ratio6 = 1;
  static int _ratio7 = 1;
  static int _countdownTime = 0;
  static double _soundVolume = 1.0;
  static bool _ttsEnabled = true;
  static String _ttsVoiceId = '';
  static double _ttsVolume = 1.0;
  static int _themeNumber = 0;
  static String _languageCode = '';

  static String get fortune1 => _fortune1;
  static String get fortune2 => _fortune2;
  static String get fortune3 => _fortune3;
  static String get fortune4 => _fortune4;
  static String get fortune5 => _fortune5;
  static String get fortune6 => _fortune6;
  static String get fortune7 => _fortune7;
  static int get ratio1 => _ratio1;
  static int get ratio2 => _ratio2;
  static int get ratio3 => _ratio3;
  static int get ratio4 => _ratio4;
  static int get ratio5 => _ratio5;
  static int get ratio6 => _ratio6;
  static int get ratio7 => _ratio7;
  static int get countdownTime => _countdownTime;
  static double get soundVolume => _soundVolume;
  static bool get ttsEnabled => _ttsEnabled;
  static String get ttsVoiceId => _ttsVoiceId;
  static double get ttsVolume => _ttsVolume;
  static int get themeNumber => _themeNumber;
  static String get languageCode => _languageCode;

  static Future<void> ensureReady() async {
    if (_ready) {
      return;
    }
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    //
    _fortune1 = prefs.getString(_prefFortune1) ?? '';
    _fortune2 = prefs.getString(_prefFortune2) ?? '';
    _fortune3 = prefs.getString(_prefFortune3) ?? '';
    _fortune4 = prefs.getString(_prefFortune4) ?? '';
    _fortune5 = prefs.getString(_prefFortune5) ?? '';
    _fortune6 = prefs.getString(_prefFortune6) ?? '';
    _fortune7 = prefs.getString(_prefFortune7) ?? '';
    _ratio1 = prefs.getInt(_prefRatio1) ?? 1;
    _ratio2 = prefs.getInt(_prefRatio2) ?? 3;
    _ratio3 = prefs.getInt(_prefRatio3) ?? 5;
    _ratio4 = prefs.getInt(_prefRatio4) ?? 5;
    _ratio5 = prefs.getInt(_prefRatio5) ?? 5;
    _ratio6 = prefs.getInt(_prefRatio6) ?? 1;
    _ratio7 = prefs.getInt(_prefRatio7) ?? 1;
    _countdownTime = prefs.getInt(_prefCountdownTime) ?? 0;
    _soundVolume = prefs.getDouble(_prefSoundVolume) ?? 1.0;
    _ttsEnabled = prefs.getBool(_prefTtsEnabled) ?? true;
    _ttsVoiceId = prefs.getString(_prefTtsVoiceId) ?? '';
    _ttsVolume = (prefs.getDouble(_prefTtsVolume) ?? 1.0).clamp(0.0,1.0);
    _themeNumber = (prefs.getInt(_prefThemeNumber) ?? 0).clamp(0, 2);
    _languageCode = prefs.getString(_prefLanguageCode) ?? ui.PlatformDispatcher.instance.locale.languageCode;
    _languageCode = _resolveLanguageCode(_languageCode);
    if (_fortune1 == '') {
      if (_languageCode == 'ja') {
        _fortune1 = '大吉:だいきち';
        _fortune2 = '吉:きち';
        _fortune3 = '中吉:ちゅうきち';
        _fortune4 = '小吉:しょうきち';
        _fortune5 = '末吉:すえきち';
        _fortune6 = '凶:きょう';
        _fortune7 = '大凶:だいきょう';
      } else {
        _fortune1 = 'Great blessing';
        _fortune2 = 'Blessing';
        _fortune3 = 'Middle blessing';
        _fortune4 = 'Small blessing';
        _fortune5 = 'Uncertain luck';
        _fortune6 = 'Curse';
        _fortune7 = 'Great curse';
      }
    }
    _ready = true;
  }

  static String _resolveLanguageCode(String code) {
    final supported = AppLocalizations.supportedLocales;
    if (supported.any((l) => l.languageCode == code)) {
      return code;
    } else {
      return '';
    }
  }

  static Future<void> setFortune1(String value) async {
    _fortune1 = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefFortune1, value);
  }

  static Future<void> setFortune2(String value) async {
    _fortune2 = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefFortune2, value);
  }

  static Future<void> setFortune3(String value) async {
    _fortune3 = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefFortune3, value);
  }

  static Future<void> setFortune4(String value) async {
    _fortune4 = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefFortune4, value);
  }

  static Future<void> setFortune5(String value) async {
    _fortune5 = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefFortune5, value);
  }

  static Future<void> setFortune6(String value) async {
    _fortune6 = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefFortune6, value);
  }

  static Future<void> setFortune7(String value) async {
    _fortune7 = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefFortune7, value);
  }

  static Future<void> setRatio1(int value) async {
    _ratio1 = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefRatio1, value);
  }

  static Future<void> setRatio2(int value) async {
    _ratio2 = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefRatio2, value);
  }

  static Future<void> setRatio3(int value) async {
    _ratio3 = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefRatio3, value);
  }

  static Future<void> setRatio4(int value) async {
    _ratio4 = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefRatio4, value);
  }

  static Future<void> setRatio5(int value) async {
    _ratio5 = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefRatio5, value);
  }

  static Future<void> setRatio6(int value) async {
    _ratio6 = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefRatio6, value);
  }

  static Future<void> setRatio7(int value) async {
    _ratio7 = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefRatio7, value);
  }

  static Future<void> setCountdownTime(int value) async {
    _countdownTime = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefCountdownTime, value);
  }

  static Future<void> setSoundVolume(double value) async {
    _soundVolume = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_prefSoundVolume, value);
  }

  static Future<void> setTtsEnabled(bool flag) async {
    _ttsEnabled = flag;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefTtsEnabled, flag);
  }

  static Future<void> setTtsVoiceId(String value) async {
    _ttsVoiceId = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefTtsVoiceId, value);
  }

  static Future<void> setTtsVolume(double value) async {
    _ttsVolume = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_prefTtsVolume, value);
  }

  static Future<void> setThemeNumber(int value) async {
    _themeNumber = value;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefThemeNumber, value);
  }

  static Future<void> setLanguageCode(String value) async {
    _languageCode = value;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefLanguageCode, value);
  }

}
