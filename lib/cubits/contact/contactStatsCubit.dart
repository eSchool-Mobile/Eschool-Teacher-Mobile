import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eschool_saas_staff/data/repositories/contactRepository.dart';
import 'package:eschool_saas_staff/models/contact.dart';

// Contact Stats States
abstract class ContactStatsState {}

class ContactStatsInitial extends ContactStatsState {}

class ContactStatsLoading extends ContactStatsState {}

class ContactStatsSuccess extends ContactStatsState {
  final ContactStats stats;

  ContactStatsSuccess(this.stats);
}

class ContactStatsFailure extends ContactStatsState {
  final String errorMessage;

  ContactStatsFailure(this.errorMessage);
}

// Contact Stats Cubit
class ContactStatsCubit extends Cubit<ContactStatsState> {
  final ContactRepository _contactRepository;

  ContactStatsCubit(this._contactRepository) : super(ContactStatsInitial());

  Future<void> getContactStats() async {
    try {
      emit(ContactStatsLoading());

      final stats = await _contactRepository.getContactStats();

      emit(ContactStatsSuccess(stats));
    } catch (e) {
      emit(ContactStatsFailure(e.toString()));
    }
  }

  void refresh() {
    getContactStats();
  }
}
