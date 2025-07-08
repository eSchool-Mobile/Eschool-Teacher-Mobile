import 'dart:io';
import 'package:dio/dio.dart';
import 'package:eschool_saas_staff/data/models/studyMaterial.dart';
import 'package:eschool_saas_staff/data/repositories/studyMaterialRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

abstract class DownloadFileState {}

class DownloadFileInitial extends DownloadFileState {}

class DownloadFileInProgress extends DownloadFileState {
  final double uploadedPercentage;

  DownloadFileInProgress(this.uploadedPercentage);
}

class DownloadFileSuccess extends DownloadFileState {
  final String downloadedFileUrl;

  DownloadFileSuccess(this.downloadedFileUrl);
}

class DownloadFileProcessCanceled extends DownloadFileState {}

class DownloadFileFailure extends DownloadFileState {
  final String errorMessage;

  DownloadFileFailure(this.errorMessage);
}

class DownloadFileCubit extends Cubit<DownloadFileState> {
  final StudyMaterialRepository _studyMaterialRepository =
      StudyMaterialRepository();
  final CancelToken _cancelToken = CancelToken();

  DownloadFileCubit() : super(DownloadFileInitial());

  void _downloadedFilePercentage(double percentage) {
    emit(DownloadFileInProgress(percentage));
  }

  /// Mendapatkan direktori downloads untuk Android atau dokumen untuk platform lain
  Future<String> _getDownloadsDirectory() async {
    if (Platform.isAndroid) {
      // Untuk Android, gunakan direktori eksternal
      try {
        final directory = await getExternalStorageDirectory();
        if (directory != null) {
          // Membuat path ke folder Downloads
          final downloadsPath = '/storage/emulated/0/Download';
          final downloadsDir = Directory(downloadsPath);
          if (await downloadsDir.exists()) {
            return downloadsPath;
          } else {
            // Fallback ke external storage directory
            return directory.path;
          }
        }
      } catch (e) {
        print("Error getting external storage: $e");
      }
      // Fallback ke application documents directory
      final appDir = await getApplicationDocumentsDirectory();
      return appDir.path;
    } else {
      // Untuk platform lain (iOS, etc)
      final directory = await getApplicationDocumentsDirectory();
      return directory.path;
    }
  }

  Future<void> writeFileFromTempStorage({
    required String sourcePath,
    required String destinationPath,
  }) async {
    try {
      final tempFile = File(sourcePath);
      if (!await tempFile.exists()) {
        throw Exception("File sementara tidak ditemukan di: $sourcePath");
      }
      print("File temp ditemukan, ukuran: ${await tempFile.length()} bytes");

      final byteData = await tempFile.readAsBytes();
      final downloadedFile = File(destinationPath);

      final directory = downloadedFile.parent;
      if (!await directory.exists()) {
        await directory.create(recursive: true);
        print("Direktori tujuan dibuat: ${directory.path}");
      }

      await downloadedFile.writeAsBytes(
        byteData.buffer
            .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
      );
      print("File berhasil ditulis ke: $destinationPath");
    } catch (e) {
      print("Error saat menulis file dari temp: $e");
      rethrow;
    }
  }

  Future<void> downloadFile({
    required StudyMaterial studyMaterial,
  }) async {
    emit(DownloadFileInProgress(0.0));
    try {
      // Cek izin berdasarkan versi Android
      if (Platform.isAndroid) {
        final androidVersion = await _getAndroidVersion();
        if (androidVersion >= 30) {
          // Android 11+
          final permission = await Permission.manageExternalStorage.request();
          if (!permission.isGranted) {
            print("Izin MANAGE_EXTERNAL_STORAGE ditolak");
            throw Exception("Izin untuk mengakses memori eksternal ditolak");
          }
          print("Izin MANAGE_EXTERNAL_STORAGE diberikan");
        } else {
          // Android 10 ke bawah
          final permission = await Permission.storage.request();
          if (!permission.isGranted) {
            print("Izin penyimpanan ditolak");
            throw Exception("Izin untuk mengakses memori eksternal ditolak");
          }
          print("Izin penyimpanan diberikan");
        }
      }

      // Simpan file sementara
      final Directory tempDir = await getTemporaryDirectory();
      final tempFileSavePath =
          "${tempDir.path}/${studyMaterial.fileName}.${studyMaterial.fileExtension}";

      if (await File(tempFileSavePath).exists()) {
        print("File temp sudah ada: $tempFileSavePath");
        final fileSize = await File(tempFileSavePath).length();
        if (fileSize > 0) {
          String downloadFilePath = await _getDownloadsDirectory();

          downloadFilePath =
              "$downloadFilePath/${studyMaterial.fileName}.${studyMaterial.fileExtension}";

          await writeFileFromTempStorage(
            sourcePath: tempFileSavePath,
            destinationPath: downloadFilePath,
          );

          emit(DownloadFileSuccess(downloadFilePath));
          return;
        } else {
          print("File temp kosong, menghapus dan mengunduh ulang");
          await File(tempFileSavePath).delete();
        }
      }

      print("Mulai mengunduh file dari: ${studyMaterial.fileUrl}");
      await _studyMaterialRepository.downloadStudyMaterialFile(
        cancelToken: _cancelToken,
        savePath: tempFileSavePath,
        updateDownloadedPercentage: _downloadedFilePercentage,
        url: studyMaterial.fileUrl,
      );

      // Selalu simpan ke memori eksternal untuk Android
      String downloadFilePath = await _getDownloadsDirectory();

      downloadFilePath =
          "$downloadFilePath/${studyMaterial.fileName}.${studyMaterial.fileExtension}";

      await writeFileFromTempStorage(
        sourcePath: tempFileSavePath,
        destinationPath: downloadFilePath,
      );

      emit(DownloadFileSuccess(downloadFilePath));
    } catch (e) {
      if (_cancelToken.isCancelled) {
        print("Proses unduhan dibatalkan");
        emit(DownloadFileProcessCanceled());
      } else {
        print("Error saat mengunduh file: $e");
        emit(DownloadFileFailure(e.toString())); // Gunakan pesan error spesifik
      }
    }
  }

  void cancelDownloadProcess() {
    print("Membatalkan proses unduhan");
    _cancelToken.cancel();
  }

  Future<int> _getAndroidVersion() async {
    try {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      return androidInfo.version.sdkInt;
    } catch (e) {
      print("Gagal mendapatkan versi Android: $e");
      return 0;
    }
  }
}

// class StudyMaterialRepository {
//   final Dio _dio = Dio();

//   Future<void> downloadStudyMaterialFile({
//     required String url,
//     required String savePath,
//     required Function(double) updateDownloadedPercentage,
//     required CancelToken cancelToken,
//   }) async {
//     int attempts = 0;
//     const maxAttempts = 3;

//     while (attempts < maxAttempts) {
//       try {
//         print("Mencoba mengunduh dari $url (Percobaan ${attempts + 1}/$maxAttempts)");
//         await _dio.download(
//           url,
//           savePath,
//           cancelToken: cancelToken,
//           onReceiveProgress: (received, total) {
//             if (total != -1) {
//               updateDownloadedPercentage((received / total) * 100);
//             }
//           },
//         );
//         print("Unduhan berhasil ke: $savePath");
//         break;
//       } catch (e) {
//         attempts++;
//         if (attempts == maxAttempts) {
//           print("Gagal setelah $maxAttempts percobaan: $e");
//           rethrow;
//         }
//         print("Gagal mengunduh, mencoba lagi setelah 1 detik: $e");
//         await Future.delayed(const Duration(seconds: 1));
//       }
//     }
//   }
// }
