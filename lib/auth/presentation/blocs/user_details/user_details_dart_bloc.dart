import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eldcare/auth/domain/entities/user_details.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'user_details_dart_event.dart';
part 'user_details_dart_state.dart';

class UserDetailsDartBloc
    extends Bloc<UserDetailsDartEvent, UserDetailsDartState> {
  UserDetailsDartBloc() : super(UserDetailsDartInitial()) {
    on<SubmitUserDetails>(_onSubmitUserDetails);
  }
  void _onSubmitUserDetails(
    SubmitUserDetails event,
    Emitter<UserDetailsDartState> emit,
  ) async {
    emit(UserDetailsDartLoading());
    try {
      // Get the current user's ID
      String userId = FirebaseAuth.instance.currentUser!.uid;

      // Update the Firestore document for the current user
      final userDetailsMap = {
        'role': event.userDetails.role.toString(),
        'age': event.userDetails.age,
        'phone': event.userDetails.phone,
        'houseName': event.userDetails.houseName,
        'street': event.userDetails.street,
        'city': event.userDetails.city,
        'state': event.userDetails.state,
        'postalCode': event.userDetails.postalCode,
        'bloodType': event.userDetails.bloodType,
        'specialization': event.userDetails.specialization,
        'licenseNumber': event.userDetails.licenseNumber,
        'pharmacyShops': event.userDetails.pharmacyShops
            ?.map((shop) => {
                  'name': shop.name,
                  'address': shop.address,
                  'licenseNumber': shop.licenseNumber,
                  'phoneNumber': shop.phoneNumber,
                })
            .toList(),
      };

      // Remove null values
      userDetailsMap.removeWhere((key, value) => value == null);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update(userDetailsMap);

      emit(UserDetailsDartSuccess(event.userDetails));
    } catch (e) {
      emit(UserDetailsDartFailure(e.toString()));
    }
  }
}
