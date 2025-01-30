import 'package:eschool_saas_staff/data/repositories/assignmentRepository.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class CreateAssignmentState {}

class CreateAssignmentInitial extends CreateAssignmentState {}

class CreateAssignmentInProcess extends CreateAssignmentState {}

class CreateAssignmentSuccess extends CreateAssignmentState {}

class CreateAssignmentFailure extends CreateAssignmentState {
  final String errorMessage;
  CreateAssignmentFailure({
    required this.errorMessage,
  });
}

class CreateAssignmentCubit extends Cubit<CreateAssignmentState> {
  final AssignmentRepository _assignmentRepository = AssignmentRepository();

  CreateAssignmentCubit() : super(CreateAssignmentInitial());

 Future<void> createAssignment({
  required int classSectionId,
  required int classSubjectId,
  required String name,
  required String description,
  required String dateTime,
  required String startDate, 
  required String endDate, 
  required String points,
  required String minPoints,
  required String maxFile,
  required bool resubmission,
  required String extraDayForResubmission,
  List<PlatformFile>? file,
  required List<String> acceptedFile,
  required String text,
}) async {
  emit(CreateAssignmentInProcess());
  try {
    await _assignmentRepository.createAssignment(
      classSectionId: classSectionId,
      classSubjectId: classSubjectId,
      name: name,
      description: description,
      dateTime: dateTime,
      startDate: startDate, 
      endDate: endDate, 
      points: int.parse(points.isEmpty ? "0" : points),
      minPoints: int.parse(minPoints.isEmpty ? "0" : minPoints),
      maxFile: int.parse(maxFile.isEmpty ? "0" : maxFile),
      resubmission: resubmission,
      extraDayForResubmission:
          int.parse(extraDayForResubmission.isEmpty ? "0" : extraDayForResubmission),
      filePaths: file,
      acceptedFile: acceptedFile,
      text: text,
    );
    emit(CreateAssignmentSuccess());
  } catch (e) {
    emit(CreateAssignmentFailure(errorMessage: e.toString()));
  }
}
}
