import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/system/file_compression_utils.dart';

/// Example widget showing how to use FileCompressionUtils
/// This can be used as reference for implementing file compression in your app
class FileCompressionExample extends StatefulWidget {
  const FileCompressionExample({super.key});

  @override
  State<FileCompressionExample> createState() => _FileCompressionExampleState();
}

class _FileCompressionExampleState extends State<FileCompressionExample> {
  List<File> selectedFiles = [];
  List<File> compressedFiles = [];
  bool isCompressing = false;
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('File Compression Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // File selection buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickImageFromGallery,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Pick Images'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickDocuments,
                    icon: const Icon(Icons.description),
                    label: const Text('Pick Documents'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Compression button
            ElevatedButton.icon(
              onPressed: selectedFiles.isNotEmpty && !isCompressing
                  ? _compressFiles
                  : null,
              icon: isCompressing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.compress),
              label: Text(isCompressing ? 'Compressing...' : 'Compress Files'),
            ),

            const SizedBox(height: 16),

            // File list
            Expanded(
              child: ListView(
                children: [
                  if (selectedFiles.isNotEmpty) ...[
                    const Text(
                      'Selected Files:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...selectedFiles.map((file) => _buildFileItem(file, false)),
                  ],
                  if (compressedFiles.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Compressed Files:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...compressedFiles
                        .map((file) => _buildFileItem(file, true)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Pick images from gallery
  Future<void> _pickImageFromGallery() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();

      if (images.isNotEmpty) {
        final List<File> imageFiles =
            images.map((xFile) => File(xFile.path)).toList();

        setState(() {
          selectedFiles.addAll(imageFiles);
        });

        _showSnackBar('${images.length} image(s) selected');
      }
    } catch (e) {
      _showSnackBar('Error picking images: $e');
    }
  }

  /// Pick documents using file picker
  Future<void> _pickDocuments() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'jpg', 'jpeg', 'png'],
      );

      if (result != null) {
        final List<File> files = result.paths
            .where((path) => path != null)
            .map((path) => File(path!))
            .toList();

        setState(() {
          selectedFiles.addAll(files);
        });

        _showSnackBar('${files.length} file(s) selected');
      }
    } catch (e) {
      _showSnackBar('Error picking files: $e');
    }
  }

  /// Compress selected files
  Future<void> _compressFiles() async {
    if (selectedFiles.isEmpty) return;

    setState(() {
      isCompressing = true;
      compressedFiles.clear();
    });

    try {
      // Compress files with 2MB target size and medium quality
      final compressed = await FileCompressionUtils.compressMultipleFiles(
        files: selectedFiles,
        maxSizeInMB: 2.0, // Target maximum size: 2MB
        customQuality: 85, // Custom quality (optional)
      );

      setState(() {
        compressedFiles = compressed;
        isCompressing = false;
      });

      _showSnackBar('Compression completed!');
    } catch (e) {
      setState(() {
        isCompressing = false;
      });
      _showSnackBar('Error during compression: $e');
    }
  }

  /// Build file item widget
  Widget _buildFileItem(File file, bool isCompressed) {
    return FutureBuilder<double>(
      future: FileCompressionUtils.getFileSizeInMB(file),
      builder: (context, snapshot) {
        final fileName = file.path.split('/').last;
        final fileSize = snapshot.hasData
            ? '${snapshot.data!.toStringAsFixed(2)} MB'
            : 'Loading...';
        final isSupported =
            FileCompressionUtils.isCompressionSupported(file.path);

        return Card(
          child: ListTile(
            leading: Icon(
              _getFileIcon(file.path),
              color: isCompressed ? Colors.green : Colors.blue,
            ),
            title: Text(fileName),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Size: $fileSize'),
                if (!isSupported)
                  const Text(
                    'Format not supported for compression',
                    style: TextStyle(color: Colors.orange, fontSize: 12),
                  ),
              ],
            ),
            trailing: isCompressed
                ? const Icon(Icons.check_circle, color: Colors.green)
                : null,
          ),
        );
      },
    );
  }

  /// Get appropriate icon for file type
  IconData _getFileIcon(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();

    switch (extension) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
        return Icons.image;
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'txt':
        return Icons.text_snippet;
      default:
        return Icons.insert_drive_file;
    }
  }

  /// Show snackbar message
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

/// Mixin for easy integration of file compression in existing widgets
/// Add this mixin to any widget that needs file compression functionality
mixin FileCompressionMixin {
  /// Compress a single file with default settings
  Future<File> compressFile(File file) async {
    return await FileCompressionUtils.compressFile(
      file: file,
      maxSizeInMB: 2.0, // Default 2MB limit
    );
  }

  /// Compress file with custom settings
  Future<File> compressFileWithSettings({
    required File file,
    double maxSizeInMB = 2.0,
    int? quality,
  }) async {
    return await FileCompressionUtils.compressFile(
      file: file,
      maxSizeInMB: maxSizeInMB,
      customQuality: quality,
    );
  }

  /// Compress multiple files at once
  Future<List<File>> compressMultipleFiles(List<File> files) async {
    return await FileCompressionUtils.compressMultipleFiles(
      files: files,
      maxSizeInMB: 2.0,
    );
  }

  /// Check if file needs compression
  Future<bool> shouldCompressFile(File file, {double maxSizeInMB = 2.0}) async {
    final sizeInMB = await FileCompressionUtils.getFileSizeInMB(file);
    return sizeInMB > maxSizeInMB &&
        FileCompressionUtils.isCompressionSupported(file.path);
  }
}

/// Example of using the mixin in a real widget
class ImageUploadWidget extends StatefulWidget {
  final Function(List<File>) onFilesSelected;

  const ImageUploadWidget({
    super.key,
    required this.onFilesSelected,
  });

  @override
  State<ImageUploadWidget> createState() => _ImageUploadWidgetState();
}

class _ImageUploadWidgetState extends State<ImageUploadWidget>
    with FileCompressionMixin {
  bool isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: isProcessing ? null : _handleImageSelection,
      icon: isProcessing
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.add_photo_alternate),
      label: Text(isProcessing ? 'Processing...' : 'Add Images'),
    );
  }

  Future<void> _handleImageSelection() async {
    setState(() => isProcessing = true);

    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage();

      if (images.isNotEmpty) {
        // Convert XFile to File
        final List<File> files =
            images.map((xFile) => File(xFile.path)).toList();

        // Compress all selected images
        final compressedFiles = await compressMultipleFiles(files);

        // Notify parent widget
        widget.onFilesSelected(compressedFiles);

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  '${compressedFiles.length} image(s) processed and ready for upload'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error processing images: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isProcessing = false);
      }
    }
  }
}
