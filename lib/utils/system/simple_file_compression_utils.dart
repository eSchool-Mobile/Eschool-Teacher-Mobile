import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;

/// Utility class for file compression operations - Simplified version
/// Uses only dart:image library to avoid plugin issues
class SimpleFileCompressionUtils {
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

  /// Compress any file (focus on images)
  static Future<File> compressFile({
    required File file,
    double maxSizeInMB = 0.5, // Default target 500KB
    int? customQuality,
    bool forceCompress = true,
  }) async {
    try {
      // Check if file exists
      if (!await file.exists()) {
        throw Exception('File does not exist');
      }

      final fileSize = await file.length();
      final fileName = path.basename(file.path);
      final fileExtension = path.extension(fileName).toLowerCase();

      if (kDebugMode) {
        debugPrint('🔧 [SIMPLE COMPRESSION] Processing: $fileName');
        debugPrint('   📊 Original size: ${formatFileSize(fileSize)}');
        debugPrint('   🎯 Target: ${maxSizeInMB.toStringAsFixed(2)} MB');
      }

      // Check if it's an image
      if (!_supportedImageFormats.contains(fileExtension)) {
        if (kDebugMode) {
          debugPrint('   ⚠️  Not an image file, skipping compression');
        }
        return file;
      }

      // For images, always try to compress if forceCompress is true
      final maxSizeInBytes = (maxSizeInMB * 1024 * 1024).toInt();

      // Skip only if very small and not forced
      if (!forceCompress && fileSize < 100 * 1024) {
        if (kDebugMode) {
          debugPrint('   ⏭️  File very small, skipping compression');
        }
        return file;
      }

      return await _compressImage(file, maxSizeInBytes, customQuality,
          forceCompress: forceCompress);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [COMPRESSION ERROR] $e');
      }
      return file; // Return original file on error
    }
  }

  /// Compress image using dart:image library
  static Future<File> _compressImage(
      File file, int maxSizeInBytes, int? customQuality,
      {bool forceCompress = true}) async {
    try {
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) {
        if (kDebugMode) {
          debugPrint('   ❌ Failed to decode image');
        }
        return file;
      }

      if (kDebugMode) {
        debugPrint(
            '   🖼️  Original dimensions: ${image.width}x${image.height}');
      }

      // Smart compression with iterative approach for target size
      return await _compressImageIteratively(
          image, maxSizeInBytes, customQuality, file);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('   ❌ Compression failed: $e');
      }
      return file;
    }
  }

  /// Iteratively compress image until target size is reached
  static Future<File> _compressImageIteratively(img.Image image,
      int maxSizeInBytes, int? customQuality, File originalFile) async {
    try {
      final fileName = path.basenameWithoutExtension(originalFile.path);
      final directory = path.dirname(originalFile.path);
      final outputPath = path.join(directory, '${fileName}_compressed.jpg');

      // Start with aggressive but reasonable dimensions
      int targetWidth = image.width;
      int targetHeight = image.height;

      // Smart initial resize based on target size
      if (maxSizeInBytes < 1024 * 1024) {
        // Less than 1MB target
        // For small targets (like 500KB), be more aggressive
        if (image.width > 1280) {
          double ratio = 1280 / image.width;
          targetWidth = 1280;
          targetHeight = (image.height * ratio).round();
        } else if (image.width > 1024) {
          double ratio = 1024 / image.width;
          targetWidth = 1024;
          targetHeight = (image.height * ratio).round();
        }
      } else {
        // For larger targets, be less aggressive
        if (image.width > 1920) {
          double ratio = 1920 / image.width;
          targetWidth = 1920;
          targetHeight = (image.height * ratio).round();
        }
      }

      // Try different quality levels
      List<int> qualityLevels = customQuality != null
          ? [customQuality]
          : [85, 80, 75, 70, 65, 60]; // Start high, go lower if needed

      File? bestResult;
      int bestSize = 0;
      int bestQuality = 0;

      for (int quality in qualityLevels) {
        // Resize image
        img.Image resizedImage = img.copyResize(
          image,
          width: targetWidth,
          height: targetHeight,
          interpolation: img.Interpolation.cubic,
        );

        // Compress with current quality
        final compressedBytes = img.encodeJpg(resizedImage, quality: quality);

        if (kDebugMode) {
          debugPrint(
              '   🧪 Testing quality $quality%: ${formatFileSize(compressedBytes.length)}');
        }

        // If size is acceptable, use it
        if (compressedBytes.length <= maxSizeInBytes) {
          final tempFile = File(outputPath);
          await tempFile.writeAsBytes(compressedBytes);

          bestResult = tempFile;
          bestSize = compressedBytes.length;
          bestQuality = quality;
          break; // Found acceptable quality
        }

        // Store the smallest result as fallback
        if (bestResult == null || compressedBytes.length < bestSize) {
          final tempFile = File(outputPath);
          await tempFile.writeAsBytes(compressedBytes);
          bestResult = tempFile;
          bestSize = compressedBytes.length;
          bestQuality = quality;
        }
      }

      // If still too large, try smaller dimensions
      if (bestSize > maxSizeInBytes && targetWidth > 800) {
        if (kDebugMode) {
          debugPrint('   🔄 Still too large, trying smaller dimensions...');
        }

        // Reduce dimensions more aggressively
        targetWidth = (targetWidth * 0.8).round();
        targetHeight = (targetHeight * 0.8).round();

        img.Image smallerImage = img.copyResize(
          image,
          width: targetWidth,
          height: targetHeight,
          interpolation: img.Interpolation.cubic,
        );

        // Try with lower quality on smaller image
        for (int quality in [75, 70, 65]) {
          final compressedBytes = img.encodeJpg(smallerImage, quality: quality);

          if (compressedBytes.length <= maxSizeInBytes) {
            final tempFile = File(outputPath);
            await tempFile.writeAsBytes(compressedBytes);
            bestResult = tempFile;
            bestSize = compressedBytes.length;
            bestQuality = quality;
            break;
          }
        }
      }

      final originalSize = await originalFile.length();
      final compressionRatio = ((originalSize - bestSize) / originalSize * 100);

      if (kDebugMode) {
        debugPrint('   ✅ Compression successful!');
        debugPrint('   📊 Final size: ${formatFileSize(bestSize)}');
        debugPrint('   📉 Reduction: ${compressionRatio.toStringAsFixed(1)}%');
        debugPrint('   🖼️  Final dimensions: ${targetWidth}x$targetHeight');
        debugPrint('   🎨 Quality: $bestQuality%');
        if (bestSize <= maxSizeInBytes) {
          debugPrint('   🎯 Target achieved!');
        } else {
          debugPrint(
              '   ⚠️  Target not fully achieved, but this is the best compression possible');
        }
      }

      return bestResult ?? originalFile;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('   ❌ Compression failed: $e');
      }
      return originalFile;
    }
  }

  /// Format file size for display
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Check if file type is supported for compression
  static bool isCompressionSupported(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    return _supportedImageFormats.contains(extension);
  }

  /// Get file size in MB
  static Future<double> getFileSizeInMB(File file) async {
    final bytes = await file.length();
    return bytes / (1024 * 1024);
  }

  /// Batch compress multiple files
  static Future<List<File>> compressMultipleFiles({
    required List<File> files,
    double maxSizeInMB = 0.5, // Default target 500KB
    int? customQuality,
    bool forceCompress = true,
  }) async {
    List<File> compressedFiles = [];

    for (File file in files) {
      try {
        final compressedFile = await compressFile(
          file: file,
          maxSizeInMB: maxSizeInMB,
          customQuality: customQuality,
          forceCompress: forceCompress,
        );
        compressedFiles.add(compressedFile);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Error compressing file ${file.path}: $e');
        }
        compressedFiles.add(file); // Add original file if compression fails
      }
    }

    return compressedFiles;
  }
}
