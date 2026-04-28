import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eschool_saas_staff/data/repositories/extracurricular/extracurricularMemberRepository.dart';
import 'package:eschool_saas_staff/data/models/extracurricular/extracurricularMember.dart';
import 'package:flutter/foundation.dart';

part 'extracurricularMemberState.dart';

class ExtracurricularMemberCubit extends Cubit<ExtracurricularMemberState> {
  final ExtracurricularMemberRepository _repository;

  ExtracurricularMemberCubit(this._repository)
      : super(ExtracurricularMemberInitial());

  // Get all extracurricular members
  Future<void> getExtracurricularMembers() async {
    try {
      emit(ExtracurricularMemberLoading());

      final members = await _repository.getExtracurricularMembers();

      debugPrint(
          '🔍 [MEMBER CUBIT] Received ${members.length} members from repository');

      emit(ExtracurricularMemberSuccess('Data berhasil dimuat',
          members: members));
    } catch (e) {
      debugPrint('❌ [MEMBER CUBIT] Error: $e');
      emit(ExtracurricularMemberFailure(e.toString()));
    }
  }

  // Get members by status (filter)
  Future<void> getMembersByStatus(String status) async {
    try {
      emit(ExtracurricularMemberLoading());

      final members = await _repository.getMembersByStatus(status);

      emit(ExtracurricularMemberSuccess('Data berhasil dimuat',
          members: members));
    } catch (e) {
      emit(ExtracurricularMemberFailure(e.toString()));
    }
  }

  // Get members by extracurricular ID
  Future<void> getMembersByExtracurricular(int extracurricularId) async {
    try {
      emit(ExtracurricularMemberLoading());

      final members =
          await _repository.getMembersByExtracurricular(extracurricularId);

      emit(ExtracurricularMemberSuccess('Data berhasil dimuat',
          members: members));
    } catch (e) {
      emit(ExtracurricularMemberFailure(e.toString()));
    }
  }

  // Approve member
  Future<void> approveMember(int memberId) async {
    try {
      emit(ExtracurricularMemberLoading());

      await _repository.approveMember(memberId);

      // Refresh data after approve
      final members = await _repository.getExtracurricularMembers();
      emit(ExtracurricularMemberSuccess('Anggota berhasil disetujui',
          members: members));
    } catch (e) {
      emit(ExtracurricularMemberFailure(e.toString()));
    }
  }

  // Reject member
  Future<void> rejectMember(int memberId) async {
    try {
      emit(ExtracurricularMemberLoading());

      await _repository.rejectMember(memberId);

      // Refresh data after reject
      final members = await _repository.getExtracurricularMembers();
      emit(ExtracurricularMemberSuccess('Anggota berhasil ditolak',
          members: members));
    } catch (e) {
      emit(ExtracurricularMemberFailure(e.toString()));
    }
  }

  // Filter members by status locally (without API call)
  void filterMembersByStatus(
      List<ExtracurricularMember> allMembers, String? statusFilter) {
    try {
      List<ExtracurricularMember> filteredMembers;

      if (statusFilter == null || statusFilter.isEmpty) {
        filteredMembers = allMembers;
      } else {
        filteredMembers = allMembers
            .where((member) => member.status == statusFilter)
            .toList();
      }

      emit(ExtracurricularMemberSuccess('Data berhasil difilter',
          members: filteredMembers));
    } catch (e) {
      emit(ExtracurricularMemberFailure(e.toString()));
    }
  }

  // Search members by name or NISN
  void searchMembers(List<ExtracurricularMember> allMembers, String query) {
    try {
      if (query.isEmpty) {
        emit(ExtracurricularMemberSuccess('Data berhasil dimuat',
            members: allMembers));
        return;
      }

      final filteredMembers = allMembers.where((member) {
        final name = member.studentName?.toLowerCase() ?? '';
        final nisn = member.studentNisn?.toLowerCase() ?? '';
        final className = member.className?.toLowerCase() ?? '';
        final searchQuery = query.toLowerCase();

        return name.contains(searchQuery) ||
            nisn.contains(searchQuery) ||
            className.contains(searchQuery);
      }).toList();

      emit(ExtracurricularMemberSuccess('Data berhasil dicari',
          members: filteredMembers));
    } catch (e) {
      emit(ExtracurricularMemberFailure(e.toString()));
    }
  }

  // Reset state to initial
  void resetState() {
    emit(ExtracurricularMemberInitial());
  }

  // Clear any error or success state
  void clearState() {
    emit(ExtracurricularMemberInitial());
  }
}
