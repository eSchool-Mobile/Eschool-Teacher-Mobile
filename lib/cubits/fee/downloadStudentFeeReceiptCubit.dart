import 'dart:convert';
import 'dart:io';

import 'package:eschool_saas_staff/data/repositories/feeRepository.dart';
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

  void downloadStudentFeeReceipt(
      {required int studentId,
      required int feeId,
      required String studentName}) async {
    try {
      emit(DownloadStudentFeeReceiptInProgress());

      String filePath = "";
      final path = (await getApplicationDocumentsDirectory()).path;
      filePath = "$path/Student-Fees/$studentName-$feeId.pdf";

      print('===== DOWNLOADING RECEIPT PDF =====');
      print('Student ID: $studentId');
      print('Fee ID: $feeId');
      print('Student Name: $studentName');
      print('File Path: $filePath');

      final File file = File(filePath);

      final slipContent = await _feeRepository.downloadStudentFeeReceipt(
          studentId: studentId, feeId: feeId);

      print('Receipt content length: ${slipContent.length} bytes');

      await file.create(recursive: true);
      await file.writeAsBytes(base64Decode(slipContent));

      print('===== PDF RECEIPT DOWNLOADED SUCCESSFULLY =====');
      print('Saved to: $filePath');

      emit(DownloadStudentFeeReceiptSuccess(downloadedFilePath: filePath));
    } catch (e) {
      print('===== ERROR DOWNLOADING PDF RECEIPT =====');
      print('Error: ${e.toString()}');
      emit(DownloadStudentFeeReceiptFailure(defaultErrorMessageKey));
    }
  }
}
