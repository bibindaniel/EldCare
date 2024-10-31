import 'package:eldcare/admin/repository/shop_repositry.dart';
import 'package:eldcare/pharmacy/model/shop.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';

part 'shop_event.dart';
part 'shop_state.dart';

class AdminShopBloc extends Bloc<AdminShopEvent, AdminShopState> {
  final ShopRepository shopRepository;

  AdminShopBloc({required this.shopRepository}) : super(AdminShopInitial()) {
    on<AdminLoadShops>(_onLoadShops);
    on<AdminApproveShop>(_onApproveShop);
    on<AdminRejectShop>(_onRejectShop);
  }

  void _onLoadShops(AdminLoadShops event, Emitter<AdminShopState> emit) async {
    emit(AdminShopLoading());
    try {
      final shops = await shopRepository.getAllShops();
      final pendingShops = shops.where((shop) => !shop.isVerified).toList();
      final verifiedShops = shops.where((shop) => shop.isVerified).toList();
      emit(AdminShopLoaded(shops: verifiedShops, pendingShops: pendingShops));
    } catch (e) {
      emit(AdminShopError(e.toString()));
    }
  }

  void _onApproveShop(
      AdminApproveShop event, Emitter<AdminShopState> emit) async {
    try {
      await shopRepository.approveShop(event.shopId);
      await _sendEmail(
        to: event.shop.email,
        subject: 'Shop Request Approved',
        body: 'Your shop request has been approved.',
      );
      add(AdminLoadShops());
    } catch (e) {
      emit(AdminShopError(e.toString()));
    }
  }

  void _onRejectShop(
      AdminRejectShop event, Emitter<AdminShopState> emit) async {
    try {
      await shopRepository.rejectShop(event.shopId);
      await _sendEmail(
        to: event.shop.email,
        subject: 'Shop Request Rejected',
        body: 'Your shop request has been rejected.',
      );
      add(AdminLoadShops());
    } catch (e) {
      emit(AdminShopError(e.toString()));
    }
  }

  Future<void> _sendEmail(
      {required String to,
      required String subject,
      required String body}) async {
    final Email email = Email(
      body: body,
      subject: subject,
      recipients: [to],
      isHTML: false,
    );

    try {
      await FlutterEmailSender.send(email);
    } catch (e) {
      print('Error sending email: $e');
    }
  }
}
