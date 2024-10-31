import 'package:eldcare/pharmacy/model/pharmacist_order.dart';
import 'package:equatable/equatable.dart';

abstract class PharmacistOrderState extends Equatable {
  const PharmacistOrderState();

  @override
  List<Object> get props => [];
}

class PharmacistOrderInitial extends PharmacistOrderState {}

class PharmacistOrderLoading extends PharmacistOrderState {}

class PharmacistOrderLoaded extends PharmacistOrderState {
  final List<PharmacistOrderModel> orders;

  const PharmacistOrderLoaded(this.orders);

  @override
  List<Object> get props => [orders];
}

class PharmacistOrderError extends PharmacistOrderState {
  final String message;

  const PharmacistOrderError(this.message);

  @override
  List<Object> get props => [message];
}
