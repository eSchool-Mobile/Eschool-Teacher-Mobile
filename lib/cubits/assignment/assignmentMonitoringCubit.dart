import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eschool_saas_staff/data/models/assignmentMonitoring.dart';
import 'package:eschool_saas_staff/data/repositories/assignmentMonitoringRepository.dart';
import 'package:equatable/equatable.dart';

// States
abstract class AssignmentMonitoringState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AssignmentMonitoringInitial extends AssignmentMonitoringState {}

class AssignmentMonitoringLoading extends AssignmentMonitoringState {}

class AssignmentMonitoringSuccess extends AssignmentMonitoringState {
  final AssignmentMonitoringData monitoringData;
  final int currentPage;
  final int totalPages;
  final String? submissionStatus;
  final String? startDate;
  final String? endDate;

  AssignmentMonitoringSuccess({
    required this.monitoringData,
    required this.currentPage,
    required this.totalPages,
    this.submissionStatus,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [
        monitoringData,
        currentPage,
        totalPages,
        submissionStatus,
        startDate,
        endDate
      ];
}

class AssignmentMonitoringFailure extends AssignmentMonitoringState {
  final String errorMessage;

  AssignmentMonitoringFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}

// Cubit
class AssignmentMonitoringCubit extends Cubit<AssignmentMonitoringState> {
  final AssignmentMonitoringRepository _assignmentMonitoringRepository;

  AssignmentMonitoringCubit({
    required AssignmentMonitoringRepository assignmentMonitoringRepository,
  })  : _assignmentMonitoringRepository = assignmentMonitoringRepository,
        super(AssignmentMonitoringInitial());

  Future<void> getAssignmentMonitoring({
    String? submissionStatus,
    String? startDate,
    String? endDate,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      emit(AssignmentMonitoringLoading());

      final result =
          await _assignmentMonitoringRepository.getAssignmentMonitoring(
        submissionStatus: submissionStatus,
        startDate: startDate,
        endDate: endDate,
        page: page,
        limit: limit,
      );

      final responseData = result['data'] as AssignmentMonitoringResponse;
      final totalPages = (responseData.data.total / limit).ceil();

      emit(AssignmentMonitoringSuccess(
        monitoringData: responseData.data,
        currentPage: page,
        totalPages: totalPages,
        submissionStatus: submissionStatus,
        startDate: startDate,
        endDate: endDate,
      ));
    } catch (e) {
      emit(AssignmentMonitoringFailure(e.toString()));
    }
  }
}
