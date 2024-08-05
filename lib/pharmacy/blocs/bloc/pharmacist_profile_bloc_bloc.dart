import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'pharmacist_profile_bloc_event.dart';
part 'pharmacist_profile_bloc_state.dart';

class PharmacistProfileBlocBloc extends Bloc<PharmacistProfileBlocEvent, PharmacistProfileBlocState> {
  PharmacistProfileBlocBloc() : super(PharmacistProfileBlocInitial()) {
    on<PharmacistProfileBlocEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
