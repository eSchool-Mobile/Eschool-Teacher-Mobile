import 'dart:io';
import 'package:dio/dio.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/api.dart';

class ErrorMessageUtils {
  /// Mengkonversi error teknis menjadi pesan yang ramah untuk user
  static String getReadableErrorMessage(dynamic error) {
    if (error is ApiException) {
      return _handleApiException(error);
    }

    if (error is DioException) {
      return _handleDioException(error);
    }

    if (error is SocketException) {
      return _handleSocketException(error);
    }

    if (error is String) {
      return _handleStringError(error);
    }

    // Fallback untuk error yang tidak dikenal
    return unknownErrorKey;
  }

  /// Menangani ApiException dengan pesan yang ramah
  static String _handleApiException(ApiException error) {
    return _handleStringError(error.errorMessage);
  }

  /// Menangani DioException dengan pesan yang ramah
  static String _handleDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return timeoutErrorKey;

      case DioExceptionType.badResponse:
        // Server merespons dengan error (4xx, 5xx)
        if (error.response?.statusCode != null) {
          final statusCode = error.response!.statusCode!;
          if (statusCode >= 500) {
            return serverMaintenanceKey;
          } else if (statusCode >= 400) {
            return requestFailedKey;
          }
        }
        return serverNotReachableKey;

      case DioExceptionType.cancel:
        return "Permintaan dibatalkan";

      case DioExceptionType.connectionError:
        // Cek apakah ini masalah DNS/hostname lookup
        if (error.error is SocketException) {
          return _handleSocketException(error.error as SocketException);
        }
        return connectionErrorKey;

      case DioExceptionType.badCertificate:
        return "Sertifikat keamanan tidak valid";

      case DioExceptionType.unknown:
        if (error.error is SocketException) {
          return _handleSocketException(error.error as SocketException);
        }
        return connectionErrorKey;
    }
  }

  /// Menangani SocketException dengan pesan yang ramah
  static String _handleSocketException(SocketException error) {
    final message = error.message.toLowerCase();

    if (message.contains('failed host lookup') ||
        message.contains('no address associated with hostname')) {
      return serverNotReachableKey;
    }

    if (message.contains('network is unreachable') ||
        message.contains('no route to host')) {
      return pleaseCheckConnectionKey;
    }

    if (message.contains('connection refused')) {
      return serverMaintenanceKey;
    }

    if (message.contains('connection timed out')) {
      return timeoutErrorKey;
    }

    // Fallback untuk socket errors lainnya
    return connectionErrorKey;
  }

  /// Menangani error dalam bentuk string
  static String _handleStringError(String error) {
    final lowerError = error.toLowerCase();

    // Handle specific server errors with more user-friendly messages
    if (error.contains('Server error: Database query issue')) {
      return 'Terjadi masalah pada database server. Silakan hubungi administrator.';
    }

    if (error.contains('Technical error in') &&
        error.contains('validation.in')) {
      return 'Data yang dimasukkan tidak valid. Silakan periksa kembali form dan pastikan semua informasi sudah benar.';
    }

    if (error.contains('Technical error in')) {
      return 'Terjadi kesalahan teknis saat memproses permintaan. Silakan coba lagi atau hubungi administrator jika masalah berlanjut.';
    }

    if (error.contains('Server encountered an error') ||
        lowerError.contains('error occurred')) {
      return 'Server mengalami gangguan. Silakan coba lagi atau hubungi administrator.';
    }

    if (error.contains('Undefined variable') ||
        lowerError.contains('server details')) {
      return 'Terjadi kesalahan pada server. Silakan coba lagi atau hubungi administrator.';
    }

    // Cek berbagai pattern error yang umum
    if (lowerError.contains('connection') && lowerError.contains('error')) {
      return connectionErrorKey;
    }

    if (lowerError.contains('failed host lookup') ||
        lowerError.contains('no address associated')) {
      return serverNotReachableKey;
    }

    if (lowerError.contains('timeout')) {
      return timeoutErrorKey;
    }

    if (lowerError.contains('dio') && lowerError.contains('exception')) {
      return connectionErrorKey;
    }

    if (lowerError.contains('socket') && lowerError.contains('exception')) {
      return connectionErrorKey;
    }

    // Jika pesan sudah dalam format yang baik (tidak mengandung kata kunci teknis)
    if (!_containsTechnicalTerms(lowerError)) {
      return error; // Return pesan asli jika sudah user-friendly
    }

    // Fallback
    return requestFailedKey;
  }

  /// Mengecek apakah string mengandung istilah teknis
  static bool _containsTechnicalTerms(String message) {
    final technicalTerms = [
      'dioexception',
      'socketexception',
      'failed host lookup',
      'errno',
      'os error',
      'stack trace',
      'exception',
      'error:',
      'at line',
      'null check operator',
    ];

    return technicalTerms.any((term) => message.contains(term));
  }

  /// Mendapatkan pesan detail untuk developer (jika diperlukan untuk debugging)
  static String getTechnicalErrorMessage(dynamic error) {
    return error.toString();
  }
}
