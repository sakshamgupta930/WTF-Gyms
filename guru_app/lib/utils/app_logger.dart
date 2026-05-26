import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class LogEntry {
  final DateTime timestamp;
  final String tag;
  final String message;
  final String level; // 'INFO', 'WARN', 'ERROR'

  LogEntry({
    required this.timestamp,
    required this.tag,
    required this.message,
    this.level = 'INFO',
  });

  @override
  String toString() {
    final timeStr = timestamp.toIso8601String().substring(11, 19);
    return '[$timeStr] [$tag] [$level] $message';
  }
}

class AppLogger {
  static final List<LogEntry> _logs = [];
  static const int maxLogs = 50;
  static VoidCallback? onLogAdded;

  static List<LogEntry> get logs => List.unmodifiable(_logs);

  static void log(String tag, String message, {String level = 'INFO'}) {
    final entry = LogEntry(
      timestamp: DateTime.now(),
      tag: tag.toUpperCase(),
      message: message,
      level: level,
    );
    _logs.add(entry);
    if (_logs.length > maxLogs) {
      _logs.removeAt(0);
    }
    if (kDebugMode) {
      print(entry.toString());
    }
    if (onLogAdded != null) {
      onLogAdded!();
    }
  }

  static void info(String tag, String message) => log(tag, message, level: 'INFO');
  static void warn(String tag, String message) => log(tag, message, level: 'WARN');
  static void error(String tag, String message) => log(tag, message, level: 'ERROR');

  static void clear() {
    _logs.clear();
    if (onLogAdded != null) {
      onLogAdded!();
    }
  }
}

Color exportColorForTag(String tag) {
  switch (tag.toUpperCase()) {
    case 'CHAT':
      return const Color(0xFF1769E0);
    case 'RTC':
      return const Color(0xFFE50914);
    case 'SCHEDULE':
      return const Color(0xFFF79009);
    case 'AUTH':
      return const Color(0xFF12B76A);
    default:
      return const Color(0xFF6B7280);
  }
}
