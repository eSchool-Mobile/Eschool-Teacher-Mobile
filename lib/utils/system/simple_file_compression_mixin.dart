import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'simple_file_compression_utils.dart';

/// Mixin to provide file compression functionality to any widget
/// This version uses SimpleFileCompressionUtils to avoid plugin issues
mixin SimpleFileCompressionMixin {
  /// Pick and compress files with detailed logging
  Future<List<File>?> pickAndCompressFiles({
    FileType fileType = FileType.any,
    bool allowMultiple = true,
    List<String>? allowedExtensions,
    double maxSizeInMB = 0.5, // Default target 500KB
    int? customQuality,
    bool forceCompress = true,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('\n🚀 [FILE PICKER] Starting file selection and compression...');
        debugPrint('   📋 File type: $fileType');
        debugPrint('   📊 Max size: ${maxSizeInMB.toStringAsFixed(2)} MB');
        debugPrint('   💪 Force compress: $forceCompress');
      }

      // Pick files
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: fileType,
        allowMultiple: allowMultiple,
        allowedExtensions: allowedExtensions,
      );

      if (result == null) {
        if (kDebugMode) {
          debugPrint('   ❌ User cancelled file picker');
        }
        return null;
      }

      final List<File> selectedFiles = result.paths
          .where((path) => path != null)
          .map((path) => File(path!))
          .toList();

      if (selectedFiles.isEmpty) {
        if (kDebugMode) {
          debugPrint('   ❌ No files selected');
        }
        return null;
      }

      if (kDebugMode) {
        debugPrint('   ✅ Selected ${selectedFiles.length} file(s)');
        for (int i = 0; i < selectedFiles.length; i++) {
          final file = selectedFiles[i];
          final size = await file.length();
          debugPrint(
              '     📄 File ${i + 1}: ${file.path.split('/').last} (${SimpleFileCompressionUtils.formatFileSize(size)})');
        }
      }

      // Compress files
      if (kDebugMode) {
        debugPrint('\n🔄 [COMPRESSION] Processing files...');
      }

      List<File> compressedFiles = [];

      for (int i = 0; i < selectedFiles.length; i++) {
        final file = selectedFiles[i];

        if (kDebugMode) {
          debugPrint('\n   📁 Processing file ${i + 1}/${selectedFiles.length}');
        }

        try {
          final compressedFile = await SimpleFileCompressionUtils.compressFile(
            file: file,
            maxSizeInMB: maxSizeInMB,
            customQuality: customQuality,
            forceCompress: forceCompress,
          );

          compressedFiles.add(compressedFile);
        } catch (e) {
          if (kDebugMode) {
            debugPrint('   ❌ Error compressing file ${file.path}: $e');
          }
          compressedFiles.add(file); // Use original file if compression fails
        }
      }

      if (kDebugMode) {
        debugPrint('\n✅ [COMPRESSION SUMMARY]');
        debugPrint('   📊 Total files processed: ${selectedFiles.length}');
        debugPrint('   ✅ Successfully processed: ${compressedFiles.length}');

        // Calculate total size reduction
        int totalOriginalSize = 0;
        int totalCompressedSize = 0;

        for (int i = 0;
            i < selectedFiles.length && i < compressedFiles.length;
            i++) {
          totalOriginalSize += await selectedFiles[i].length();
          totalCompressedSize += await compressedFiles[i].length();
        }

        final totalReduction = totalOriginalSize > 0
            ? ((totalOriginalSize - totalCompressedSize) /
                totalOriginalSize *
                100)
            : 0.0;

        debugPrint(
            '   📊 Total original size: ${SimpleFileCompressionUtils.formatFileSize(totalOriginalSize)}');
        debugPrint(
            '   📊 Total compressed size: ${SimpleFileCompressionUtils.formatFileSize(totalCompressedSize)}');
        debugPrint('   📉 Total reduction: ${totalReduction.toStringAsFixed(1)}%');
        debugPrint('🎉 [COMPRESSION COMPLETE]\n');
      }

      return compressedFiles;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [CRITICAL ERROR] File picker and compression failed: $e');
      }
      return null;
    }
  }

  /// Pick and compress images specifically
  Future<List<File>?> pickAndCompressImages({
    bool allowMultiple = true,
    double maxSizeInMB = 0.5, // Default target 500KB
    int? customQuality,
    bool forceCompress = true,
  }) async {
    return await pickAndCompressFiles(
      fileType: FileType.image,
      allowMultiple: allowMultiple,
      maxSizeInMB: maxSizeInMB,
      customQuality: customQuality,
      forceCompress: forceCompress,
    );
  }

  /// Pick and compress single file
  Future<File?> pickAndCompressSingleFile({
    FileType fileType = FileType.any,
    List<String>? allowedExtensions,
    double maxSizeInMB = 0.5, // Default target 500KB
    int? customQuality,
    bool forceCompress = true,
  }) async {
    final files = await pickAndCompressFiles(
      fileType: fileType,
      allowMultiple: false,
      allowedExtensions: allowedExtensions,
      maxSizeInMB: maxSizeInMB,
      customQuality: customQuality,
      forceCompress: forceCompress,
    );

    return files?.isNotEmpty == true ? files!.first : null;
  }

  /// Compress existing files without picking
  Future<List<File>> compressExistingFiles({
    required List<File> files,
    double maxSizeInMB = 0.5, // Default target 500KB
    int? customQuality,
    bool forceCompress = true,
  }) async {
    if (kDebugMode) {
      debugPrint(
          '\n🔄 [EXISTING FILES COMPRESSION] Processing ${files.length} files...');
    }

    return await SimpleFileCompressionUtils.compressMultipleFiles(
      files: files,
      maxSizeInMB: maxSizeInMB,
      customQuality: customQuality,
      forceCompress: forceCompress,
    );
  }

  /// Show file compression info to user
  void showCompressionInfo(
    BuildContext context, {
    required int originalSize,
    required int compressedSize,
    required String fileName,
  }) {
    final reduction = ((originalSize - compressedSize) / originalSize * 100);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'File Compressed: $fileName',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
                'Original: ${SimpleFileCompressionUtils.formatFileSize(originalSize)}'),
            Text(
                'Compressed: ${SimpleFileCompressionUtils.formatFileSize(compressedSize)}'),
            Text('Reduction: ${reduction.toStringAsFixed(1)}%'),
          ],
        ),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
