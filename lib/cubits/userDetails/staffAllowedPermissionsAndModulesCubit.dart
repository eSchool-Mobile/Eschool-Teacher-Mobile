import 'package:eschool_saas_staff/data/repositories/auth/userDetailsRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';

abstract class StaffAllowedPermissionsAndModulesState {}

class StaffAllowedPermissionsAndModulesInitial
    extends StaffAllowedPermissionsAndModulesState {}

class StaffAllowedPermissionsAndModulesFetchInProgress
    extends StaffAllowedPermissionsAndModulesState {}

class StaffAllowedPermissionsAndModulesFetchSuccess
    extends StaffAllowedPermissionsAndModulesState {
  final Map<String, String> enabledModules;
  final List<String> permissions;

  StaffAllowedPermissionsAndModulesFetchSuccess(
      {required this.enabledModules, required this.permissions});
}

class StaffAllowedPermissionsAndModulesFetchFailure
    extends StaffAllowedPermissionsAndModulesState {
  final String errorMessage;

  StaffAllowedPermissionsAndModulesFetchFailure(this.errorMessage);
}

class StaffAllowedPermissionsAndModulesCubit
    extends Cubit<StaffAllowedPermissionsAndModulesState> {
  final UserDetailsRepository _userDetailsRepository = UserDetailsRepository();

  StaffAllowedPermissionsAndModulesCubit()
      : super(StaffAllowedPermissionsAndModulesInitial());

  void getPermissionAndAllowedModules() async {
    try {
      emit(StaffAllowedPermissionsAndModulesFetchInProgress());
      final result =
          await _userDetailsRepository.getPermissionAndAllowedModules();

      // Log warning if permissions are empty (likely backend issue)
      if (result.enabledModules.isEmpty && result.permissions.isEmpty) {
        debugPrint('⚠️ WARNING: Received empty permissions from backend');
        debugPrint('⚠️ User access will be restricted until backend is fixed');
      }

      emit(StaffAllowedPermissionsAndModulesFetchSuccess(
          enabledModules: result.enabledModules,
          permissions: result.permissions));
    } catch (e) {
      emit(StaffAllowedPermissionsAndModulesFetchFailure(e.toString()));
    }
  }

  bool isModuleEnabled({required String moduleId}) {
    if (state is StaffAllowedPermissionsAndModulesFetchSuccess) {
      return (state as StaffAllowedPermissionsAndModulesFetchSuccess)
          .enabledModules
          .keys
          .toList()
          .contains(moduleId);
    }
    return false;
  }

  bool isPermissionGiven({required String permission}) {
    if (state is StaffAllowedPermissionsAndModulesFetchSuccess) {
      return (state as StaffAllowedPermissionsAndModulesFetchSuccess)
          .permissions
          .contains(permission);
    }
    return false;
  }
}
