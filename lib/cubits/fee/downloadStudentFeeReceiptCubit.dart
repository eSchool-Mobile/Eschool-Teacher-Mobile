import 'dart:convert';
import 'dart:io';

import 'package:eschool_saas_staff/data/repositories/feeRepository.dart';
import 'package:eschool_saas_staff/utils/api.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';

abstract class DownloadStudentFeeReceiptState {}

class DownloadStudentFeeReceiptInitial extends DownloadStudentFeeReceiptState {}

class DownloadStudentFeeReceiptInProgress
    extends DownloadStudentFeeReceiptState {}

class DownloadStudentFeeReceiptSuccess extends DownloadStudentFeeReceiptState {
  final String downloadedFilePath;

  DownloadStudentFeeReceiptSuccess({required this.downloadedFilePath});
}

class DownloadStudentFeeReceiptFailure extends DownloadStudentFeeReceiptState {
  final String errorMessage;

  DownloadStudentFeeReceiptFailure(this.errorMessage);
}

class DownloadStudentFeeReceiptCubit
    extends Cubit<DownloadStudentFeeReceiptState> {
  final FeeRepository _feeRepository = FeeRepository();

  DownloadStudentFeeReceiptCubit() : super(DownloadStudentFeeReceiptInitial());

  void downloadStudentFeeReceipt({
    required List<int> paymentHistoryIds,
    required String studentName,
  }) async {
    try {
      emit(DownloadStudentFeeReceiptInProgress());

      print('===== STARTING RECEIPT DOWNLOAD PROCESS =====');
      print('Payment History IDs to process: $paymentHistoryIds');
      print('Student Name: $studentName');

      // Validate input
      if (paymentHistoryIds.isEmpty) {
        print('Error: Empty payment history IDs list');
        throw ApiException("No payment records selected");
      }

      // Generate unique filename incorporating timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path = (await getApplicationDocumentsDirectory()).path;
      final filePath = "$path/Student-Fees/$studentName-receipt-$timestamp.pdf";
      print('Target File Path: $filePath');

      // Create directory if it doesn't exist
      final directory = File(filePath).parent;
      if (!await directory.exists()) {
        print('Creating directory: ${directory.path}');
        await directory.create(recursive: true);
      }

      // Download receipt
      print('Requesting PDF generation from server...');
      final slipContent = await _feeRepository.downloadStudentFeeReceipt(
        paymentHistoryIds: paymentHistoryIds,
      );

      if (slipContent.isEmpty) {
        print('Error: Received empty PDF content from server');
        throw ApiException("No receipt data available");
      }

      print(
          'Successfully received PDF content. Length: ${slipContent.length} bytes');

      try {
        // Decode base64 to validate it's proper PDF data
        final bytes = base64Decode(slipContent);
        print('Successfully decoded base64 data. Size: ${bytes.length} bytes');

        // Write PDF file
        final file = File(filePath);
        await file.writeAsBytes(bytes);
        print('Successfully wrote PDF file to: $filePath');

        emit(DownloadStudentFeeReceiptSuccess(downloadedFilePath: filePath));
      } catch (e) {
        print('Error processing PDF data: $e');
        throw ApiException("Invalid PDF data received from server");
      }
    } catch (e) {
      print('===== ERROR DOWNLOADING PDF RECEIPT =====');
      print('Error type: ${e.runtimeType}');
      print('Error message: ${e.toString()}');

      // Generate appropriate error message based on error type
      String errorMessage;
      if (e is ApiException) {
        if (e.toString().contains("validation.array")) {
          errorMessage = "Format pembayaran tidak valid";
        } else if (e.toString().contains("No payment records")) {
          errorMessage = "Tidak ada riwayat pembayaran";
        } else if (e.toString().contains("Could not determine school")) {
          errorMessage = "Data sekolah tidak ditemukan";
        } else if (e.toString().contains("All payments must be")) {
          errorMessage = "Semua pembayaran harus dari siswa yang sama";
        } else {
          errorMessage = e.toString();
        }
      } else {
        errorMessage = "Terjadi kesalahan saat mengunduh struk";
      }

      emit(DownloadStudentFeeReceiptFailure(errorMessage));
    }
  }
}
