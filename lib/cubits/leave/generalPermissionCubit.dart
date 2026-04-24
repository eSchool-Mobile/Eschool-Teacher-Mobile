import 'package:eschool_saas_staff/data/models/auth/permissionDetails.dart';
import 'package:eschool_saas_staff/data/repositories/auth/permissionRepository.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class GeneralPermissionState {}

class GeneralPermissionInitial extends GeneralPermissionState {}

class GeneralPermissionFetchInProgress extends GeneralPermissionState {}

class GeneralPermissionFetchSuccess extends GeneralPermissionState {
  final List<PermissionDetails> leaves;

  GeneralPermissionFetchSuccess({required this.leaves});
}

class GeneralPermissionFetchFailure extends GeneralPermissionState {
  final String errorMessage;

  GeneralPermissionFetchFailure(this.errorMessage);
}

class GeneralPermissionCubit extends Cubit<GeneralPermissionState> {
  final PermissionRepository _permissionRepository = PermissionRepository();

  GeneralPermissionCubit() : super(GeneralPermissionInitial());

  void getGeneralLeaves(
      {required LeaveDayType leaveDayType, DateTime? date}) async {
    try {
      emit(GeneralPermissionFetchInProgress());

      emit(GeneralPermissionFetchSuccess(
          leaves: await _permissionRepository.getPermission(
              leaveDayType: leaveDayType, date: date)));
    } catch (e) {
      emit(GeneralPermissionFetchFailure(e.toString()));
    }
  }
}
