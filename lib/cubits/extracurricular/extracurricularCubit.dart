import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eschool_saas_staff/data/models/extracurricular.dart';
import 'package:eschool_saas_staff/data/repositories/extracurricularRepository.dart';

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
    print('🚀 [EXTRACURRICULAR CUBIT] getExtracurriculars called');
    emit(ExtracurricularLoading());
    try {
      print(
          '📡 [EXTRACURRICULAR CUBIT] Calling repository.getExtracurriculars()');
      final extracurriculars =
          await _extracurricularRepository.getExtracurriculars();
      final currentState = state;
      final archivedExtracurriculars = currentState is ExtracurricularSuccess
          ? currentState.archivedExtracurriculars
          : <Extracurricular>[];

      print(
          '✅ [EXTRACURRICULAR CUBIT] Successfully loaded ${extracurriculars.length} extracurriculars');
      emit(ExtracurricularSuccess(
        extracurriculars: extracurriculars,
        archivedExtracurriculars: archivedExtracurriculars,
      ));
    } catch (e) {
      print('❌ [EXTRACURRICULAR CUBIT] Error in getExtracurriculars: $e');
      print('❌ [EXTRACURRICULAR CUBIT] Error type: ${e.runtimeType}');
      emit(ExtracurricularFailure(e.toString()));
    }
  }

  // Get archived extracurriculars
  Future<void> getArchivedExtracurriculars() async {
    emit(ExtracurricularLoading());
    try {
      final archivedExtracurriculars =
          await _extracurricularRepository.getArchivedExtracurriculars();
      final currentState = state;
      final extracurriculars = currentState is ExtracurricularSuccess
          ? currentState.extracurriculars
          : <Extracurricular>[];

      emit(ExtracurricularSuccess(
        extracurriculars: extracurriculars,
        archivedExtracurriculars: archivedExtracurriculars,
      ));
    } catch (e) {
      emit(ExtracurricularFailure(e.toString()));
    }
  }

  // Create extracurricular
  Future<void> createExtracurricular({
    required String name,
    required String description,
    required int coachId,
  }) async {
    try {
      await _extracurricularRepository.createExtracurricular(
        name: name,
        description: description,
        coachId: coachId,
      );
      await getExtracurriculars();
    } catch (e) {
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
    try {
      await _extracurricularRepository.updateExtracurricular(
        id: id,
        name: name,
        description: description,
        coachId: coachId,
      );
      await getExtracurriculars();
    } catch (e) {
      emit(ExtracurricularFailure(e.toString()));
      rethrow;
    }
  }

  // Delete (Archive) extracurricular
  Future<void> deleteExtracurricular(int id) async {
    try {
      await _extracurricularRepository.deleteExtracurricular(id);
      await getExtracurriculars();
    } catch (e) {
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
}
