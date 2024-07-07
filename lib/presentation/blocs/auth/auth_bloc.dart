import 'package:bloc/bloc.dart';
import 'package:eldcare/domain/entities/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthBloc() : super(AuthInitial()) {
    on<CheckLoginStatus>((event, emit) async {
      emit(AuthLoading());
      try {
        await Future.delayed(const Duration(seconds: 3)); // Simulate delay
        User? user = _auth.currentUser;

        if (user != null) {
          emit(AuthAuthenticated(user));
        } else {
          emit(UnAuthAuthenticated());
        }
      } catch (e) {
        emit(AuthError(message: 'Error checking login status'));
      }
    });
  }

  // @override
  // Stream<AuthState> mapEventToState(AuthEvent event) async* {
  //   if (event is CheckLoginStatus) {
  //     yield* _mapCheckLoginStatusToState(event);
  //   }
  //   // Handle other events here if needed
  // }

  // Stream<AuthState> _mapCheckLoginStatusToState(CheckLoginStatus event) async* {
  //   yield AuthLoading();
  //   try {
  //     await Future.delayed(const Duration(seconds: 3)); // Simulate delay
  //     User? user = _auth.currentUser;

  //     if (user != null) {
  //       yield AuthAuthenticated(user);
  //     } else {
  //       yield UnAuthAuthenticated();
  //     }
  //   } catch (e) {
  //     yield AuthError(message: 'Error checking login status');
  //   }
  // }
}
