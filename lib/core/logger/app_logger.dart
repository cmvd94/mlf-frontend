import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum LogLevel { debug, info, warn, error }

class LogEntry {
  final DateTime timestamp;
  final LogLevel level;
  final String tag;
  final String message;
  final String? error;
  final String? stackTrace;

  const LogEntry({
    required this.timestamp,
    required this.level,
    required this.tag,
    required this.message,
    this.error,
    this.stackTrace,
  });

  String get formattedTime {
    final y = timestamp.year.toString().padLeft(4, '0');
    final m = timestamp.month.toString().padLeft(2, '0');
    final d = timestamp.day.toString().padLeft(2, '0');
    final h = timestamp.hour.toString().padLeft(2, '0');
    final min = timestamp.minute.toString().padLeft(2, '0');
    final s = timestamp.second.toString().padLeft(2, '0');
    final ms = timestamp.millisecond.toString().padLeft(3, '0');
    return '$y-$m-$d $h:$min:$s.$ms';
  }

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'level': level.name,
        'tag': tag,
        'message': message,
        if (error != null) 'error': error,
        if (stackTrace != null) 'stackTrace': stackTrace,
      };

  factory LogEntry.fromJson(Map<String, dynamic> json) => LogEntry(
        timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? '') ?? DateTime.now(),
        level: LogLevel.values.firstWhere(
          (l) => l.name == json['level'],
          orElse: () => LogLevel.info,
        ),
        tag: json['tag']?.toString() ?? 'App',
        message: json['message']?.toString() ?? '',
        error: json['error']?.toString(),
        stackTrace: json['stackTrace']?.toString(),
      );

  @override
  String toString() {
    final sb = StringBuffer();
    sb.writeln('[$formattedTime] [${level.name.toUpperCase()}] [$tag] $message');
    if (error != null) {
      sb.writeln('  Error: $error');
    }
    if (stackTrace != null && stackTrace!.isNotEmpty) {
      sb.writeln('  StackTrace:\n$stackTrace');
    }
    return sb.toString();
  }
}

class AppLogger extends ChangeNotifier {
  static final AppLogger _instance = AppLogger._internal();
  factory AppLogger() => _instance;
  AppLogger._internal();

  static const String _prefKey = 'mlf_frontend_logs';
  static const int _maxInMemoryLogs = 250;

  final List<LogEntry> _logs = [];
  List<LogEntry> get logs => List.unmodifiable(_logs);

  SharedPreferences? _prefs;

  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _loadPersistedLogs();
    } catch (_) {
      // Preferences not ready yet
    }
  }

  void _loadPersistedLogs() {
    if (_prefs == null) return;
    final raw = _prefs!.getStringList(_prefKey) ?? [];
    _logs.clear();
    for (final item in raw) {
      try {
        final map = jsonDecode(item) as Map<String, dynamic>;
        _logs.add(LogEntry.fromJson(map));
      } catch (_) {}
    }
    notifyListeners();
  }

  Future<void> _persistLogs() async {
    if (_prefs == null) return;
    try {
      final list = _logs.take(100).map((e) => jsonEncode(e.toJson())).toList();
      await _prefs!.setStringList(_prefKey, list);
    } catch (_) {}
  }

  void log({
    required LogLevel level,
    required String message,
    String tag = 'App',
    dynamic error,
    StackTrace? stackTrace,
  }) {
    final entry = LogEntry(
      timestamp: DateTime.now(),
      level: level,
      tag: tag,
      message: message,
      error: error?.toString(),
      stackTrace: stackTrace?.toString(),
    );

    _logs.insert(0, entry);
    if (_logs.length > _maxInMemoryLogs) {
      _logs.removeRange(_maxInMemoryLogs, _logs.length);
    }

    _printToTerminal(entry);
    _persistLogs();
    notifyListeners();
  }

  void d(String message, {String tag = 'Debug'}) =>
      log(level: LogLevel.debug, message: message, tag: tag);

  void i(String message, {String tag = 'Info'}) =>
      log(level: LogLevel.info, message: message, tag: tag);

  void w(String message, {String tag = 'Warn', dynamic error}) =>
      log(level: LogLevel.warn, message: message, tag: tag, error: error);

  void e(String message, {String tag = 'Error', dynamic error, StackTrace? stackTrace}) =>
      log(level: LogLevel.error, message: message, tag: tag, error: error, stackTrace: stackTrace);

  void _printToTerminal(LogEntry entry) {
    if (kReleaseMode && entry.level != LogLevel.error) return;

    final bannerLine = '═' * 70;
    final thinLine = '─' * 70;

    switch (entry.level) {
      case LogLevel.error:
        debugPrint('\n╔$bannerLine');
        debugPrint('║ [ERROR] [${entry.formattedTime}] [${entry.tag}]');
        debugPrint('║ Message: ${entry.message}');
        if (entry.error != null) {
          debugPrint('║ Error: ${entry.error}');
        }
        if (entry.stackTrace != null && entry.stackTrace!.isNotEmpty) {
          debugPrint('╟$thinLine');
          debugPrint('║ StackTrace:\n${entry.stackTrace}');
        }
        debugPrint('╚$bannerLine\n');
        break;

      case LogLevel.warn:
        debugPrint('[WARN] [${entry.formattedTime}] [${entry.tag}] ${entry.message}${entry.error != null ? " | ${entry.error}" : ""}');
        break;

      case LogLevel.info:
        debugPrint('[INFO] [${entry.formattedTime}] [${entry.tag}] ${entry.message}');
        break;

      case LogLevel.debug:
        debugPrint('[DEBUG] [${entry.formattedTime}] [${entry.tag}] ${entry.message}');
        break;
    }
  }

  String exportLogsText() {
    final sb = StringBuffer();
    sb.writeln('=== MLF Frontend Application Debug Log Export ===');
    sb.writeln('Exported At: ${DateTime.now().toIso8601String()}');
    sb.writeln('Total Log Entries: ${_logs.length}');
    sb.writeln('=================================================\n');

    for (final e in _logs.reversed) {
      sb.writeln(e.toString());
      sb.writeln('-------------------------------------------------');
    }
    return sb.toString();
  }

  Future<void> clearLogs() async {
    _logs.clear();
    if (_prefs != null) {
      await _prefs!.remove(_prefKey);
    }
    notifyListeners();
  }
}
