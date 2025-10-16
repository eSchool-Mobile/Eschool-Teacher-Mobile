import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eschool_saas_staff/data/repositories/contactRepository.dart';
import 'package:eschool_saas_staff/models/contact.dart';

// Submit Contact States
abstract class SubmitContactState {}

class SubmitContactInitial extends SubmitContactState {}

class SubmitContactLoading extends SubmitContactState {}

class SubmitContactSuccess extends SubmitContactState {
  final Contact contact;

  SubmitContactSuccess(this.contact);
}

class SubmitContactFailure extends SubmitContactState {
  final String errorMessage;

  SubmitContactFailure(this.errorMessage);
}

// Submit Contact Cubit
class SubmitContactCubit extends Cubit<SubmitContactState> {
  final ContactRepository _contactRepository;

  SubmitContactCubit(this._contactRepository) : super(SubmitContactInitial());

  Future<void> submitContact(SubmitContactRequest request) async {
    try {
      emit(SubmitContactLoading());

      final contact = await _contactRepository.submitContact(request);

      emit(SubmitContactSuccess(contact));
    } catch (e) {
      emit(SubmitContactFailure(e.toString()));
    }
  }

  void reset() {
    emit(SubmitContactInitial());
  }
}
