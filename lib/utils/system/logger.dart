import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

/// Simple structured logger to standardize application logs.
/// Each log is a single JSON line to ease searching / parsing.
/// Fields:
///  ts        ISO8601 timestamp
///  level     DEBUG | INFO | WARN | ERROR
///  scope     Logical scope (e.g. Class.method)
///  message   Short human readable message
///  data      Optional extra contextual map (params, response, etc.)
///  error     Error string (if any)
///  stack     Truncated stack trace (if any)
class AppLogger {
  static const int _maxStackLength = 2000; // chars

  static void _log({
    required String level,
    required String scope,
    required String message,
    Map<String, dynamic>? data,
    Object? error,
    StackTrace? stack,
  }) {
    if (!kDebugMode) return; // Only log in debug/profile builds

    String? stackStr;
    if (stack != null) {
      stackStr = stack.toString();
      if (stackStr.length > _maxStackLength) {
        stackStr = '${stackStr.substring(0, _maxStackLength)}...<truncated>';
      }
    }

    final logMap = <String, dynamic>{
      'ts': DateTime.now().toIso8601String(),
      'level': level,
      'scope': scope,
      'message': message,
      if (data != null && data.isNotEmpty) 'data': _serialize(data),
      if (error != null) 'error': error.toString(),
      if (stackStr != null) 'stack': stackStr,
    };

    final encoded = jsonEncode(logMap);
    // ignore: avoid_print
    debugPrint(encoded.toString());
  }

  static dynamic _serialize(dynamic value) {
    try {
      if (value == null) return null;
      if (value is num || value is bool || value is String) return value;
      if (value is Iterable) return value.map(_serialize).toList();
      if (value is Map) {
        return value.map((k, v) => MapEntry(k.toString(), _serialize(v)));
      }
      return value.toString();
    } catch (_) {
      return '<<unserializable>>';
    }
  }

  static void debug(String scope, String message,
          {Map<String, dynamic>? data}) =>
      _log(level: 'DEBUG', scope: scope, message: message, data: data);

  static void info(String scope, String message,
          {Map<String, dynamic>? data}) =>
      _log(level: 'INFO', scope: scope, message: message, data: data);

  static void warn(String scope, String message,
          {Map<String, dynamic>? data, Object? error, StackTrace? stack}) =>
      _log(
          level: 'WARN',
          scope: scope,
          message: message,
          data: data,
          error: error,
          stack: stack);

  static void error(String scope, String message,
          {Map<String, dynamic>? data, Object? error, StackTrace? stack}) =>
      _log(
          level: 'ERROR',
          scope: scope,
          message: message,
          data: data,
          error: error,
          stack: stack);
}

/// Khusus untuk logging Firebase Cloud Messaging
/// Memformat log RemoteMessage dengan informasi lengkap untuk debugging
void logRemoteMessageAndroid(RemoteMessage message, {String tag = 'FCM'}) {
  if (!kDebugMode) return;

  final messageData = <String, dynamic>{
    'messageId': message.messageId,
    'from': message.from,
    'collapseKey': message.collapseKey,
    'category': message.category,
    'messageType': message.messageType,
    'ttl': message.ttl,
    'sentTime': message.sentTime?.toIso8601String(),
    'data': message.data,
  };

  // Notification payload
  if (message.notification != null) {
    messageData['notification'] = {
      'title': message.notification?.title,
      'body': message.notification?.body,
      'android': message.notification?.android != null
          ? {
              'channelId': message.notification?.android?.channelId,
              'clickAction': message.notification?.android?.clickAction,
              'color': message.notification?.android?.color,
              'count': message.notification?.android?.count,
              'imageUrl': message.notification?.android?.imageUrl,
              'priority': message.notification?.android?.priority.toString(),
              'smallIcon': message.notification?.android?.smallIcon,
              'sound': message.notification?.android?.sound,
              'tag': message.notification?.android?.tag,
              'ticker': message.notification?.android?.ticker,
              'visibility':
                  message.notification?.android?.visibility.toString(),
            }
          : null,
      'apple': message.notification?.apple != null
          ? {
              'badge': message.notification?.apple?.badge,
              'subtitle': message.notification?.apple?.subtitle,
              'imageUrl': message.notification?.apple?.imageUrl,
              'sound': message.notification?.apple?.sound != null
                  ? {
                      'critical': message.notification?.apple?.sound?.critical,
                      'name': message.notification?.apple?.sound?.name,
                      'volume': message.notification?.apple?.sound?.volume,
                    }
                  : null,
            }
          : null,
    };
  }

  AppLogger.info(
    tag,
    'Firebase Cloud Messaging received',
    data: messageData,
  );
}
