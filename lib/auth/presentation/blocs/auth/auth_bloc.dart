import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  AuthBloc() : super(AuthInitial()) {
    on<CheckLoginStatus>(_onCheckLoginStatus);
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<GoogleSignInEvent>(_onGoogleSignIn);
    on<ForgotPasswordEvent>(_onForgotPassword);
    on<SetUserRole>(_onSetUserRole);
    on<LogoutEvent>(_onLogout);
  }
  Future<void> _onCheckLoginStatus(
      CheckLoginStatus event, Emitter<AuthState> emit) async {
    final user = _auth.currentUser;
    // print(user?.email);
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data()!;

        if (userData['role'] == -1) {
          emit(RoleSelectionNeeded(user));
        } else {
          emit(Authenticated(user));
        }
      } else {
        emit(const AuthError('User data not found'));
      }
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      // Check if user data exists in Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists) {
        // Check if additional details are needed (e.g., role is not selected)
        final userData = userDoc.data()!;
        if (userData['role'] == -1) {
          // Role selection is needed, emit RoleSelectionNeeded
          emit(RoleSelectionNeeded(userCredential.user!));
        } else {
          // User authenticated with all details present
          emit(Authenticated(userCredential.user!));
        }
      } else {
        // Handle scenario where user document doesn't exist (shouldn't happen on login)
        emit(const AuthError('User data not found'));
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'An error occurred'));
    } catch (e) {
      emit(const AuthError('An unexpected error occurred'));
    }
  }

  Future<void> _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      await userCredential.user?.updateDisplayName(event.name);

      // Store basic user data in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'email': event.email,
        'name': event.name,
        'role': -1,
        'isProfileComplete': false,
      });

      emit(RoleSelectionNeeded(userCredential.user!));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onGoogleSignIn(
      GoogleSignInEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        emit(Unauthenticated());
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      // Check if user data exists in Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        // If user doesn't exist, create a new document
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'email': userCredential.user!.email,
          'name': userCredential.user!.displayName,
          'role': -1,
          'isProfileComplete': false,
        });
        emit(RoleSelectionNeeded(userCredential.user!));
      } else {
        // If user exists, check if role is set
        final userData = userDoc.data()!;
        if (userData['role'] == -1) {
          emit(RoleSelectionNeeded(userCredential.user!));
        } else {
          emit(Authenticated(userCredential.user!));
        }
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onForgotPassword(
      ForgotPasswordEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _auth.sendPasswordResetEmail(email: event.email);
      emit(Unauthenticated());
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'An error occurred'));
    }
  }

  Future<void> _onSetUserRole(
      SetUserRole event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(event.userId)
          .update({'role': event.role});

      final user = _auth.currentUser;
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await _auth.signOut();
    emit(Unauthenticated());
  }
}
