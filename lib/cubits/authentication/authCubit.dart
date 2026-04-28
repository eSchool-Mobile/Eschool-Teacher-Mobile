import 'package:eschool_saas_staff/data/models/payroll/staffSalary.dart';
import 'package:eschool_saas_staff/data/models/auth/userDetails.dart';
import 'package:eschool_saas_staff/data/repositories/auth/authRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class Unauthenticated extends AuthState {}

class Authenticated extends AuthState {
  final UserDetails userDetails;

  Authenticated({required this.userDetails});
}

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository = AuthRepository();

  AuthCubit() : super(AuthInitial()) {
    _checkIsAuthenticated();
  }

  void _checkIsAuthenticated() {
    if (AuthRepository.getIsLogIn()) {
      emit(
        Authenticated(userDetails: AuthRepository.getUserDetails()),
      );
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> authenticateUser({
    required String authToken,
    required UserDetails userDetails,
    required String schoolCode,
    List<Map<String, dynamic>>? schools,
  }) async {
    //
    authRepository.schoolCode = schoolCode;
    authRepository.setAuthToken(authToken);
    authRepository.setUserDetails(userDetails);
    authRepository.setIsLogIn(true);

    // Store schools data if provided
    if (schools != null) {
      debugPrint('DEBUG: AuthCubit.authenticateUser - storing schools: $schools');
      debugPrint(
          'DEBUG: AuthCubit.authenticateUser - schools length: ${schools.length}');
      await authRepository.setSchoolsData(schools);
      debugPrint('DEBUG: AuthCubit.authenticateUser - schools stored successfully');
    } else {
      debugPrint('DEBUG: AuthCubit.authenticateUser - schools is null');
    }

    //emit new state
    emit(
      Authenticated(userDetails: userDetails),
    );
  }

  UserDetails getUserDetails() {
    if (state is Authenticated) {
      return (state as Authenticated).userDetails;
    }
    return UserDetails.fromJson({});
  }

  bool isTeacher() {
    if (state is Authenticated) {
      return (state as Authenticated).userDetails.teacher?.id != null;
    }
    return false;
  }

  Future<List<Map<String, dynamic>>> getSchoolsData() async {
    return await authRepository.getSchoolsData();
  }

  void signOut() {
    authRepository.signOutUser();
    emit(Unauthenticated());
  }

  void updateuserDetail(UserDetails userdetails) {
    UserDetails currentUserDetails = (state as Authenticated).userDetails;

    currentUserDetails = currentUserDetails.copyWith(
        firstName: userdetails.firstName,
        // lastName: userdetails.lastName,
        mobile: userdetails.mobile,
        email: userdetails.email,
        dob: userdetails.dob,
        currentAddress: userdetails.currentAddress,
        permanentAddress: userdetails.permanentAddress,
        gender: userdetails.gender,
        image: userdetails.image,
        fullName: userdetails.fullName);
    authRepository.setUserDetails(currentUserDetails);

    emit(Authenticated(userDetails: currentUserDetails));
  }

  List<StaffSalary> getAllowances() {
    if (state is Authenticated) {
      final UserDetails userDetails = (state as Authenticated).userDetails;

      return isTeacher()
          ? (userDetails.teacher?.staffSalaries ?? []).where((staffSalary) {
              return (staffSalary.payRollSetting?.isAllowance() ?? false);
            }).toList()
          : (userDetails.staff?.staffSalaries ?? [])
              .where((staffSalary) =>
                  (staffSalary.payRollSetting?.isAllowance() ?? false))
              .toList();
    }
    return [];
  }

  List<StaffSalary> getDeductions() {
    if (state is Authenticated) {
      final UserDetails userDetails = (state as Authenticated).userDetails;
      return isTeacher()
          ? (userDetails.teacher?.staffSalaries ?? [])
              .where((staffSalary) =>
                  (staffSalary.payRollSetting?.isDeduction() ?? false))
              .toList()
          : (userDetails.staff?.staffSalaries ?? [])
              .where((staffSalary) =>
                  (staffSalary.payRollSetting?.isDeduction() ?? false))
              .toList();
    }
    return [];
  }
}

