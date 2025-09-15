import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;

/// Utility class for file compression operations
/// Handles image and document compression with quality preservation
class FileCompressionUtils {
  /// Default quality settings for different file sizes
  static const int _defaultQuality = 85;
  static const int _highQuality = 90;
  static const int _mediumQuality = 80;
  static const int _lowQuality = 70;

  /// Maximum file sizes in bytes
  static const int _smallFileThreshold = 1024 * 1024; // 1MB
  static const int _mediumFileThreshold = 5 * 1024 * 1024; // 5MB
  static const int _largeFileThreshold = 10 * 1024 * 1024; // 10MB

  /// Supported image formats
  static const List<String> _supportedImageFormats = [
    '.jpg',
    '.jpeg',
    '.png',
    '.webp',
    '.bmp',
    '.gif',
    '.tiff'
  ];

  /// Supported document formats
  static const List<String> _supportedDocumentFormats = [
    '.pdf',
    '.doc',
    '.docx',
    '.txt'
  ];

  /// Compress any file (image or document) based on its type and size
  ///
  /// Parameters:
  /// - [file]: The file to compress
  /// - [maxSizeInMB]: Maximum target size in MB (default: 2MB)
  /// - [customQuality]: Custom quality override (0-100)
  ///
  /// Returns: Compressed file or original file if compression not needed/possible
  static Future<File> compressFile({
    required File file,
    double maxSizeInMB = 2.0,
    int? customQuality,
  }) async {
    try {
      // Check if file exists
      if (!await file.exists()) {
        throw Exception('File does not exist');
      }

      final fileSize = await file.length();
      final maxSizeInBytes = (maxSizeInMB * 1024 * 1024).toInt();

      // If file is already smaller than target, return original
      if (fileSize <= maxSizeInBytes) {
        if (kDebugMode) {
          print(
              'File is already within size limit: ${_formatFileSize(fileSize)}');
        }
        return file;
      }

      final fileName = path.basename(file.path);
      final fileExtension = path.extension(fileName).toLowerCase();

      if (kDebugMode) {
        print('Compressing file: $fileName (${_formatFileSize(fileSize)})');
      }

      // Determine file type and compress accordingly
      if (_supportedImageFormats.contains(fileExtension)) {
        return await _compressImage(
          file: file,
          maxSizeInBytes: maxSizeInBytes,
          customQuality: customQuality,
        );
      } else if (_supportedDocumentFormats.contains(fileExtension)) {
        return await _compressDocument(
          file: file,
          maxSizeInBytes: maxSizeInBytes,
        );
      } else {
        if (kDebugMode) {
          print('Unsupported file format: $fileExtension');
        }
        return file; // Return original file if format not supported
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error compressing file: $e');
      }
      return file; // Return original file on error
    }
  }

  /// Compress image files with quality preservation
  static Future<File> _compressImage({
    required File file,
    required int maxSizeInBytes,
    int? customQuality,
  }) async {
    try {
      final fileSize = await file.length();
      int quality = customQuality ?? _calculateQuality(fileSize);

      // Generate output path
      final fileName = path.basenameWithoutExtension(file.path);
      final fileExtension = path.extension(file.path);
      final directory = path.dirname(file.path);
      final outputPath =
          path.join(directory, '${fileName}_compressed$fileExtension');

      File? compressedFile;
      int attempts = 0;
      const maxAttempts = 3;

      // Try compression with decreasing quality until size target is met
      while (attempts < maxAttempts) {
        final xFile = await FlutterImageCompress.compressAndGetFile(
          file.absolute.path,
          outputPath,
          quality: quality,
          minWidth: 800,
          minHeight: 600,
          keepExif: false,
        );
        
        compressedFile = xFile != null ? File(xFile.path) : null;

        if (compressedFile != null) {
          final compressedSize = await compressedFile.length();

          if (kDebugMode) {
            print(
                'Compression attempt ${attempts + 1}: ${_formatFileSize(compressedSize)} (quality: $quality)');
          }

          // Check if compressed size meets target
          if (compressedSize <= maxSizeInBytes) {
            if (kDebugMode) {
              print(
                  'Image compression successful: ${_formatFileSize(fileSize)} → ${_formatFileSize(compressedSize)}');
            }
            return compressedFile;
          }
        }

        // Reduce quality for next attempt
        quality = (quality * 0.8).round();
        attempts++;

        // Clean up failed attempt
        if (compressedFile != null && await compressedFile.exists()) {
          await compressedFile.delete();
        }
      }

      // If all attempts failed, try alternative compression method
      return await _alternativeImageCompression(file, maxSizeInBytes);
    } catch (e) {
      if (kDebugMode) {
        print('Error in image compression: $e');
      }
      return file;
    }
  }

  /// Alternative image compression using dart:image library
  static Future<File> _alternativeImageCompression(
      File file, int maxSizeInBytes) async {
    try {
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) return file;

      // Calculate new dimensions
      int width = image.width;
      int height = image.height;

      // Reduce dimensions if file is too large
      while (bytes.length > maxSizeInBytes && width > 400 && height > 300) {
        width = (width * 0.8).round();
        height = (height * 0.8).round();
      }

      // Resize and compress
      final resized = img.copyResize(image, width: width, height: height);
      final compressedBytes = img.encodeJpg(resized, quality: _mediumQuality);

      // Save compressed file
      final fileName = path.basenameWithoutExtension(file.path);
      final directory = path.dirname(file.path);
      final outputPath = path.join(directory, '${fileName}_compressed.jpg');

      final compressedFile = File(outputPath);
      await compressedFile.writeAsBytes(compressedBytes);

      if (kDebugMode) {
        final originalSize = await file.length();
        final compressedSize = await compressedFile.length();
        print(
            'Alternative compression: ${_formatFileSize(originalSize)} → ${_formatFileSize(compressedSize)}');
      }

      return compressedFile;
    } catch (e) {
      if (kDebugMode) {
        print('Error in alternative compression: $e');
      }
      return file;
    }
  }

  /// Compress document files (currently basic implementation)
  static Future<File> _compressDocument({
    required File file,
    required int maxSizeInBytes,
  }) async {
    try {
      // For now, return original file as document compression requires specialized libraries
      // This can be extended with PDF compression libraries like pdf_compressor
      if (kDebugMode) {
        print(
            'Document compression not yet implemented for ${path.extension(file.path)}');
      }
      return file;
    } catch (e) {
      if (kDebugMode) {
        print('Error in document compression: $e');
      }
      return file;
    }
  }

  /// Calculate appropriate quality based on file size
  static int _calculateQuality(int fileSize) {
    if (fileSize <= _smallFileThreshold) {
      return _highQuality; // High quality for small files
    } else if (fileSize <= _mediumFileThreshold) {
      return _defaultQuality; // Default quality for medium files
    } else if (fileSize <= _largeFileThreshold) {
      return _mediumQuality; // Medium quality for large files
    } else {
      return _lowQuality; // Lower quality for very large files
    }
  }

  /// Format file size for display
  static String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Check if file type is supported for compression
  static bool isCompressionSupported(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    return _supportedImageFormats.contains(extension) ||
        _supportedDocumentFormats.contains(extension);
  }

  /// Get file size in MB
  static Future<double> getFileSizeInMB(File file) async {
    final bytes = await file.length();
    return bytes / (1024 * 1024);
  }

  /// Batch compress multiple files
  static Future<List<File>> compressMultipleFiles({
    required List<File> files,
    double maxSizeInMB = 2.0,
    int? customQuality,
  }) async {
    List<File> compressedFiles = [];

    for (File file in files) {
      try {
        final compressedFile = await compressFile(
          file: file,
          maxSizeInMB: maxSizeInMB,
          customQuality: customQuality,
        );
        compressedFiles.add(compressedFile);
      } catch (e) {
        if (kDebugMode) {
          print('Error compressing file ${file.path}: $e');
        }
        compressedFiles.add(file); // Add original file if compression fails
      }
    }

    return compressedFiles;
  }
}
