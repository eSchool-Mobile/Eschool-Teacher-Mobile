import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eschool_saas_staff/data/repositories/contactRepository.dart';
import 'package:eschool_saas_staff/models/contact.dart';

// Contact List States
abstract class ContactListState {}

class ContactListInitial extends ContactListState {}

class ContactListLoading extends ContactListState {}

class ContactListSuccess extends ContactListState {
  final List<Contact> contacts;
  final int currentPage;
  final int totalPages;
  final int total;
  final bool hasMore;

  ContactListSuccess({
    required this.contacts,
    required this.currentPage,
    required this.totalPages,
    required this.total,
    required this.hasMore,
  });
}

class ContactListFailure extends ContactListState {
  final String errorMessage;

  ContactListFailure(this.errorMessage);
}

// Contact List Cubit
class ContactListCubit extends Cubit<ContactListState> {
  final ContactRepository _contactRepository;

  List<Contact> _allContacts = [];
  int _currentPage = 1;
  int _totalPages = 1;
  int _total = 0;
  String? _currentType;
  String? _currentStatus;
  String? _currentSearch;
  String? _currentSort;

  ContactListCubit(this._contactRepository) : super(ContactListInitial());

  Future<void> getContacts({
    String? type,
    String? status,
    String? search,
    String? sort,
    bool refresh = false,
  }) async {
    try {
      if (refresh) {
        _currentPage = 1;
        _allContacts.clear();
        emit(ContactListLoading());
      }

      _currentType = type;
      _currentStatus = status;
      _currentSearch = search;
      _currentSort = sort ?? 'created_at:desc';

      final result = await _contactRepository.getContacts(
        type: _currentType,
        status: _currentStatus,
        search: _currentSearch,
        sort: _currentSort,
        page: _currentPage,
        perPage: 15,
      );

      final contacts = result['contacts'] as List<Contact>;
      _total = result['total'] as int;
      _totalPages = result['lastPage'] as int;

      if (refresh) {
        _allContacts = contacts;
      } else {
        _allContacts.addAll(contacts);
      }

      emit(ContactListSuccess(
        contacts: List.from(_allContacts),
        currentPage: _currentPage,
        totalPages: _totalPages,
        total: _total,
        hasMore: _currentPage < _totalPages,
      ));
    } catch (e) {
      emit(ContactListFailure(e.toString()));
    }
  }

  Future<void> loadMore() async {
    if (_currentPage < _totalPages) {
      _currentPage++;
      await getContacts(
        type: _currentType,
        status: _currentStatus,
        search: _currentSearch,
        sort: _currentSort,
      );
    }
  }

  Future<void> refresh() async {
    await getContacts(
      type: _currentType,
      status: _currentStatus,
      search: _currentSearch,
      sort: _currentSort,
      refresh: true,
    );
  }

  void updateContactInList(Contact updatedContact) {
    final index = _allContacts.indexWhere((c) => c.id == updatedContact.id);
    if (index != -1) {
      _allContacts[index] = updatedContact;
      if (state is ContactListSuccess) {
        final currentState = state as ContactListSuccess;
        emit(ContactListSuccess(
          contacts: List.from(_allContacts),
          currentPage: currentState.currentPage,
          totalPages: currentState.totalPages,
          total: currentState.total,
          hasMore: currentState.hasMore,
        ));
      }
    }
  }

  void removeContactFromList(int contactId) {
    _allContacts.removeWhere((c) => c.id == contactId);
    _total = _total > 0 ? _total - 1 : 0;

    if (state is ContactListSuccess) {
      final currentState = state as ContactListSuccess;
      emit(ContactListSuccess(
        contacts: List.from(_allContacts),
        currentPage: currentState.currentPage,
        totalPages: currentState.totalPages,
        total: _total,
        hasMore: currentState.hasMore,
      ));
    }
  }
}
