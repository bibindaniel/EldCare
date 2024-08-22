import 'package:equatable/equatable.dart';

abstract class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object> get props => [];
}

class FetchOrders extends OrderEvent {
  final String userId;

  const FetchOrders(this.userId);

  @override
  List<Object> get props => [userId];
}
