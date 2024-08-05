part of 'pharmacist_profile_bloc_bloc.dart';

sealed class PharmacistProfileBlocState extends Equatable {
  const PharmacistProfileBlocState();
  
  @override
  List<Object> get props => [];
}

final class PharmacistProfileBlocInitial extends PharmacistProfileBlocState {}
