import 'dart:convert';
import 'dart:io';

import 'package:eschool_saas_staff/data/repositories/payRollRepository.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';

abstract class DownloadPayRollSlipState {}

class DownloadPayRollSlipInitial extends DownloadPayRollSlipState {}

class DownloadPayRollSlipInProgress extends DownloadPayRollSlipState {}

class DownloadPayRollSlipSuccess extends DownloadPayRollSlipState {
  final String downloadedFilePath;

  DownloadPayRollSlipSuccess({required this.downloadedFilePath});
}

class DownloadPayRollSlipFailure extends DownloadPayRollSlipState {
  final String errorMessage;

  DownloadPayRollSlipFailure(this.errorMessage);
}

class DownloadPayRollSlipCubit extends Cubit<DownloadPayRollSlipState> {
  final PayRollRepository _payRollRepository = PayRollRepository();

  DownloadPayRollSlipCubit() : super(DownloadPayRollSlipInitial());

  void downloadPayRollSlip(
      {required int payRollId, required String payRollSlipTitle}) async {
    try {
      emit(DownloadPayRollSlipInProgress());

      print("=== DOWNLOAD PAYROLL PROCESS STARTED ===");
      print("Payroll ID: $payRollId");
      print("Payroll Title: $payRollSlipTitle");

      String filePath = "";
      final path = (await getApplicationDocumentsDirectory()).path;
      filePath = "$path/Salary-Slips/$payRollSlipTitle-$payRollId.pdf";

      print("Target file path: $filePath");

      final File file = File(filePath);

      print("Requesting slip content from repository...");
      final slipContent =
          await _payRollRepository.downloadPayRollSlip(payRollId: payRollId);

      print("Slip content received. Base64 data length: ${slipContent.length}");

      try {
        await file.create(recursive: true);
        final bytes = base64Decode(slipContent);
        print("Successfully decoded base64 data. Size: ${bytes.length} bytes");

        await file.writeAsBytes(bytes);
        print("File successfully written to: $filePath");

        emit(DownloadPayRollSlipSuccess(downloadedFilePath: filePath));
      } catch (fileError) {
        print("Error writing file: $fileError");
        throw fileError;
      }
    } catch (e) {
      print("=== DOWNLOAD PAYROLL ERROR ===");
      print("Error: ${e.toString()}");
      emit(DownloadPayRollSlipFailure(defaultErrorMessageKey));
    }
  }
}
