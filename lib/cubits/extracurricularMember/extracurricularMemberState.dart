part of 'extracurricularMemberCubit.dart';

abstract class ExtracurricularMemberState {}

class ExtracurricularMemberInitial extends ExtracurricularMemberState {}

class ExtracurricularMemberLoading extends ExtracurricularMemberState {}

class ExtracurricularMemberSuccess extends ExtracurricularMemberState {
  final String message;
  final List<ExtracurricularMember>? members;

  ExtracurricularMemberSuccess(this.message, {this.members});
}

class ExtracurricularMemberFailure extends ExtracurricularMemberState {
  final String errorMessage;

  ExtracurricularMemberFailure(this.errorMessage);
}
