import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppEnvironment {
  local,
  dev,
  prod;

  String get displayName {
    switch (this) {
      case AppEnvironment.local:
        return 'Local';
      case AppEnvironment.dev:
        return 'Development';
      case AppEnvironment.prod:
        return 'Production';
    }
  }

  String get defaultBaseUrl {
    switch (this) {
      case AppEnvironment.local:
        if (kIsWeb) {
          return 'http://localhost:3500';
        } else if (defaultTargetPlatform == TargetPlatform.android) {
          return 'http://10.0.2.2:3500';
        } else {
          return 'http://localhost:3500';
        }
      case AppEnvironment.dev:
        return 'https://dev-api.mlf.internal/api/v1';
      case AppEnvironment.prod:
        return 'https://api.mlf.internal/api/v1';
    }
  }

  static AppEnvironment fromString(String value) {
    switch (value.toLowerCase()) {
      case 'prod':
      case 'production':
        return AppEnvironment.prod;
      case 'dev':
      case 'development':
        return AppEnvironment.dev;
      case 'local':
      default:
        return AppEnvironment.local;
    }
  }
}

class EnvConfig extends ChangeNotifier {
  static const String _prefEnvKey = 'mlf_selected_environment';
  static const String _prefCustomUrlKey = 'mlf_custom_base_url';

  static final EnvConfig _instance = EnvConfig._internal();
  factory EnvConfig() => _instance;
  EnvConfig._internal();

  AppEnvironment _environment = AppEnvironment.local;
  String? _customBaseUrl;
  SharedPreferences? _prefs;

  AppEnvironment get environment => _environment;

  String get baseUrl {
    if (_customBaseUrl != null && _customBaseUrl!.isNotEmpty) {
      return _customBaseUrl!;
    }
    return _environment.defaultBaseUrl;
  }

  String? get customBaseUrl => _customBaseUrl;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();

    final savedEnv = _prefs?.getString(_prefEnvKey);
    if (savedEnv != null) {
      _environment = AppEnvironment.fromString(savedEnv);
    } else {
      const compileTimeEnv = String.fromEnvironment('ENV', defaultValue: 'local');
      _environment = AppEnvironment.fromString(compileTimeEnv);
    }

    _customBaseUrl = _prefs?.getString(_prefCustomUrlKey);
    notifyListeners();
  }

  Future<void> setEnvironment(AppEnvironment env) async {
    _environment = env;
    _customBaseUrl = null;
    await _prefs?.setString(_prefEnvKey, env.name);
    await _prefs?.remove(_prefCustomUrlKey);
    notifyListeners();
  }

  Future<void> setCustomBaseUrl(String url) async {
    _customBaseUrl = url.trim();
    if (_customBaseUrl!.isEmpty) {
      _customBaseUrl = null;
      await _prefs?.remove(_prefCustomUrlKey);
    } else {
      await _prefs?.setString(_prefCustomUrlKey, _customBaseUrl!);
    }
    notifyListeners();
  }
}
