import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eschool_saas_staff/data/models/extracurricular.dart';
import 'package:eschool_saas_staff/data/repositories/extracurricularRepository.dart';
import 'package:eschool_saas_staff/data/models/user.dart';

abstract class ExtracurricularState {}

class ExtracurricularInitial extends ExtracurricularState {}

class ExtracurricularLoading extends ExtracurricularState {}

class ExtracurricularSuccess extends ExtracurricularState {
  final List<Extracurricular> extracurriculars;
  final List<Extracurricular> archivedExtracurriculars;

  ExtracurricularSuccess({
    required this.extracurriculars,
    required this.archivedExtracurriculars,
  });
}

class TeachersStaffLoading extends ExtracurricularState {}

class TeachersStaffSuccess extends ExtracurricularState {
  final List<User> users;

  TeachersStaffSuccess(this.users);
}

class TeachersStaffFailure extends ExtracurricularState {
  final String errorMessage;

  TeachersStaffFailure(this.errorMessage);
}

class ExtracurricularFailure extends ExtracurricularState {
  final String errorMessage;

  ExtracurricularFailure(this.errorMessage);
}

class ExtracurricularCubit extends Cubit<ExtracurricularState> {
  final ExtracurricularRepository _extracurricularRepository;

  ExtracurricularCubit(this._extracurricularRepository)
      : super(ExtracurricularInitial());

  // Get active extracurriculars
  Future<void> getExtracurriculars() async {
    print('🚀 [EXTRACURRICULAR CUBIT] Fetching extracurriculars...');
    emit(ExtracurricularLoading());
    try {
      final extracurriculars =
          await _extracurricularRepository.getExtracurriculars();
      final currentState = state;
      final archivedExtracurriculars = currentState is ExtracurricularSuccess
          ? currentState.archivedExtracurriculars
          : <Extracurricular>[];

      print(
          '✅ [EXTRACURRICULAR CUBIT] Success: ${extracurriculars.length} active extracurriculars');
      emit(ExtracurricularSuccess(
        extracurriculars: extracurriculars,
        archivedExtracurriculars: archivedExtracurriculars,
      ));
    } catch (e) {
      print('❌ [EXTRACURRICULAR CUBIT] Error: $e');
      emit(ExtracurricularFailure(e.toString()));
    }
  }

  // Get archived extracurriculars
  Future<void> getArchivedExtracurriculars() async {
    print('🗂️ [EXTRACURRICULAR CUBIT] Fetching archived extracurriculars...');
    emit(ExtracurricularLoading());
    try {
      final archivedExtracurriculars =
          await _extracurricularRepository.getArchivedExtracurriculars();
      final currentState = state;
      final extracurriculars = currentState is ExtracurricularSuccess
          ? currentState.extracurriculars
          : <Extracurricular>[];

      print(
          '✅ [EXTRACURRICULAR CUBIT] Success: ${archivedExtracurriculars.length} archived extracurriculars');
      emit(ExtracurricularSuccess(
        extracurriculars: extracurriculars,
        archivedExtracurriculars: archivedExtracurriculars,
      ));
    } catch (e) {
      print('❌ [EXTRACURRICULAR CUBIT] Archived fetch failed: $e');
      emit(ExtracurricularFailure(e.toString()));
    }
  }

  // Create extracurricular
  Future<void> createExtracurricular({
    required String name,
    required String description,
    required int coachId,
  }) async {
    print('➕ [EXTRACURRICULAR CUBIT] Creating: $name');
    try {
      await _extracurricularRepository.createExtracurricular(
        name: name,
        description: description,
        coachId: coachId,
      );
      print('✅ [EXTRACURRICULAR CUBIT] Created successfully');
      await getExtracurriculars();
    } catch (e) {
      print('❌ [EXTRACURRICULAR CUBIT] Create failed: $e');
      emit(ExtracurricularFailure(e.toString()));
      rethrow;
    }
  }

  // Update extracurricular
  Future<void> updateExtracurricular({
    required int id,
    required String name,
    required String description,
    required int coachId,
  }) async {
    print('✏️ [EXTRACURRICULAR CUBIT] Updating ID $id: $name');
    try {
      await _extracurricularRepository.updateExtracurricular(
        id: id,
        name: name,
        description: description,
        coachId: coachId,
      );
      print('✅ [EXTRACURRICULAR CUBIT] Updated successfully');
      await getExtracurriculars();
    } catch (e) {
      print('❌ [EXTRACURRICULAR CUBIT] Update failed: $e');
      emit(ExtracurricularFailure(e.toString()));
      rethrow;
    }
  }

  // Delete (Archive) extracurricular
  Future<void> deleteExtracurricular(int id) async {
    print('🗂️ [EXTRACURRICULAR CUBIT] Archiving ID: $id');
    try {
      await _extracurricularRepository.deleteExtracurricular(id);
      print('✅ [EXTRACURRICULAR CUBIT] Archived successfully');
      await getExtracurriculars();
    } catch (e) {
      print('❌ [EXTRACURRICULAR CUBIT] Archive failed: $e');
      emit(ExtracurricularFailure(e.toString()));
      rethrow;
    }
  }

  // Restore extracurricular
  Future<void> restoreExtracurricular(int id) async {
    try {
      await _extracurricularRepository.restoreExtracurricular(id);
      await getArchivedExtracurriculars();
      await getExtracurriculars();
    } catch (e) {
      emit(ExtracurricularFailure(e.toString()));
      rethrow;
    }
  }

  // Force delete extracurricular
  Future<void> forceDeleteExtracurricular(int id) async {
    try {
      await _extracurricularRepository.forceDeleteExtracurricular(id);
      await getArchivedExtracurriculars();
    } catch (e) {
      emit(ExtracurricularFailure(e.toString()));
      rethrow;
    }
  }

  // Get teachers and staff list
  Future<void> getTeachersStaffList() async {
    print('🔍 [EXTRACURRICULAR CUBIT] Fetching teachers/staff list...');
    emit(TeachersStaffLoading());
    try {
      final users = await _extracurricularRepository.getTeachersStaffList();
      print('✅ [EXTRACURRICULAR CUBIT] Success: ${users.length} users');
      emit(TeachersStaffSuccess(users));
    } catch (e) {
      print('❌ [EXTRACURRICULAR CUBIT] Error: $e');
      emit(TeachersStaffFailure(e.toString()));
    }
  }
}
