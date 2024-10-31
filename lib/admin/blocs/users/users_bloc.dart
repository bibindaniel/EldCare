import 'package:eldcare/admin/repository/users.dart';
import 'package:eldcare/elduser/models/user_profile.dart';
import 'package:eldcare/pharmacy/model/pharmacist.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'users_event.dart';
part 'users_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository userRepository;

  UserBloc(this.userRepository) : super(UserInitial()) {
    on<FetchUsers>(_onFetchUsers);
    on<FetchUserById>(_onFetchUserById);
  }
  Future<void> _onFetchUsers(FetchUsers event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      final elderlyUsers = await userRepository.getElderlyUsers();
      final pharmacists = await userRepository.getPharmacists();
      print(
          'Fetched pharmacists: ${pharmacists.map((p) => p.toMap()).toList()}'); // Updated debug log
      emit(UserLoaded(elderlyUsers: elderlyUsers, pharmacists: pharmacists));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> _onFetchUserById(
      FetchUserById event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      final user = await userRepository.getUserById(event.userId);
      emit(UserDetailLoaded(user));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  // This method can be used to get user details without changing the bloc's state
  Future<UserProfile?> getUserDetails(String userId) async {
    try {
      return await userRepository.getUserById(userId);
    } catch (e) {
      print('Error fetching user details: $e');
      return null;
    }
  }
}
