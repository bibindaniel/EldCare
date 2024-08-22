import 'package:eldcare/admin/model/delivery_charges.dart';
import 'package:eldcare/admin/repository/delivery_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'delivery_charges_event.dart';
part 'delivery_charges_state.dart';

class DeliveryChargesBloc
    extends Bloc<DeliveryChargesEvent, DeliveryChargesState> {
  final DeliveryChargesRepository repository;

  DeliveryChargesBloc({required this.repository})
      : super(DeliveryChargesInitial()) {
    on<LoadDeliveryCharges>(_onLoadDeliveryCharges);
    on<SaveDeliveryCharges>(_onSaveDeliveryCharges);
  }

  void _onLoadDeliveryCharges(
      LoadDeliveryCharges event, Emitter<DeliveryChargesState> emit) async {
    emit(DeliveryChargesLoading());
    try {
      final charges = await repository.getDeliveryCharges();
      emit(DeliveryChargesLoaded(charges));
    } catch (e) {
      emit(DeliveryChargesError('Failed to load delivery charges'));
    }
  }

  void _onSaveDeliveryCharges(
      SaveDeliveryCharges event, Emitter<DeliveryChargesState> emit) async {
    emit(DeliveryChargesLoading());
    try {
      final charges = DeliveryChargesModel(
        baseCharge: event.baseCharge,
        perKmCharge: event.perKmCharge,
        minimumOrderValue: event.minimumOrderValue,
      );
      await repository.saveDeliveryCharges(charges);
      emit(DeliveryChargesSaved());
      emit(DeliveryChargesLoaded(charges));
    } catch (e) {
      emit(DeliveryChargesError('Failed to save delivery charges'));
    }
  }
}
