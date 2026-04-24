import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eschool_saas_staff/data/repositories/chat/contactRepository.dart';
import 'package:eschool_saas_staff/models/contact.dart';

// Contact Detail States
abstract class ContactDetailState {}

class ContactDetailInitial extends ContactDetailState {}

class ContactDetailLoading extends ContactDetailState {}

class ContactDetailSuccess extends ContactDetailState {
  final Contact contact;

  ContactDetailSuccess(this.contact);
}

class ContactDetailFailure extends ContactDetailState {
  final String errorMessage;

  ContactDetailFailure(this.errorMessage);
}

// Contact Detail Cubit
class ContactDetailCubit extends Cubit<ContactDetailState> {
  final ContactRepository _contactRepository;

  ContactDetailCubit(this._contactRepository) : super(ContactDetailInitial());

  Future<void> getContactDetail(int contactId) async {
    try {
      emit(ContactDetailLoading());

      final contact = await _contactRepository.getContactDetail(contactId);

      emit(ContactDetailSuccess(contact));
    } catch (e) {
      emit(ContactDetailFailure(e.toString()));
    }
  }

  Future<void> replyToContact(int contactId, String reply) async {
    try {
      final currentState = state;
      if (currentState is ContactDetailSuccess) {
        emit(ContactDetailLoading());

        final updatedContact =
            await _contactRepository.replyToContact(contactId, reply);

        emit(ContactDetailSuccess(updatedContact));
      }
    } catch (e) {
      emit(ContactDetailFailure(e.toString()));
    }
  }

  Future<void> updateContactStatus(int contactId, String status) async {
    try {
      final currentState = state;
      if (currentState is ContactDetailSuccess) {
        emit(ContactDetailLoading());

        final updatedContact =
            await _contactRepository.updateContactStatus(contactId, status);

        emit(ContactDetailSuccess(updatedContact));
      }
    } catch (e) {
      emit(ContactDetailFailure(e.toString()));
    }
  }

  Contact? getCurrentContact() {
    final currentState = state;
    if (currentState is ContactDetailSuccess) {
      return currentState.contact;
    }
    return null;
  }
}
