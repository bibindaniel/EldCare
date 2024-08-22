import 'dart:io';
import 'package:eldcare/config.dart';
import 'package:eldcare/elduser/models/delivary_address.dart';
import 'package:eldcare/elduser/models/order.dart';
import 'package:eldcare/elduser/presentation/order/order_details.dart';
import 'package:eldcare/elduser/presentation/shop/delivary_deatils_screen.dart';
import 'package:eldcare/elduser/repository/delivery_adress_repo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eldcare/elduser/blocs/shopmedicines/shop_medicines_bloc.dart';
import 'package:eldcare/core/theme/colors.dart';
import 'package:eldcare/core/theme/font.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class CartScreen extends StatefulWidget {
  final String shopId;
  final String shopName;

  const CartScreen({super.key, required this.shopId, required this.shopName});

  @override
  CartScreenState createState() => CartScreenState();
}

class CartScreenState extends State<CartScreen> {
  File? _prescriptionFile;
  final ImagePicker _picker = ImagePicker();
  DeliveryAddress? _selectedAddress;
  final DeliveryAddressRepository _addressRepository =
      DeliveryAddressRepository();
  String? _phoneNumber;
  String? _userId;
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _loadUserId();
    _loadDefaultAddress();
    _loadPhoneNumber();
    _initializeRazorpay();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _initializeRazorpay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    context.read<ShopMedicinesBloc>().add(PlaceOrder(
          userId: _userId!,
          shopId: widget.shopId,
          deliveryAddress: _selectedAddress!,
          phoneNumber: _phoneNumber!,
          prescriptionFile: _prescriptionFile,
          paymentId: response.paymentId!,
        ));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payment successful! Order is being processed.'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    // Navigate to the OrderDetailsScreen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => OrderDetailsScreen(
          order: MedicineOrder(
            id: context.read<ShopMedicinesBloc>().state.pendingOrderId ?? '',
            userId: _userId!,
            shopId: widget.shopId,
            items: context.read<ShopMedicinesBloc>().state.cart,
            totalAmount: context.read<ShopMedicinesBloc>().state.cart.fold(
                      0.0,
                      (sum, item) => sum + (item.price * item.quantity),
                    ) +
                (context.read<ShopMedicinesBloc>().state.deliveryCharge ?? 0),
            status: 'Order Placed',
            createdAt: DateTime.now(),
            deliveryAddress: _selectedAddress!,
            phoneNumber: _phoneNumber!,
            paymentId: response.paymentId!,
          ),
        ),
      ),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Handle payment failure
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment failed: ${response.message}')),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Handle external wallet
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('External wallet selected: ${response.walletName}')),
    );
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  Future<void> _loadUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userId = user.uid;
      });
      await _loadDefaultAddress();
      await _loadPhoneNumber();
    }
  }

  Future<void> _loadDefaultAddress() async {
    if (_userId == null) return;
    final addresses = await _addressRepository.getDeliveryAddresses(_userId!);
    if (addresses.isNotEmpty) {
      final defaultAddress = addresses.firstWhere((addr) => addr.isDefault,
          orElse: () => addresses.first);
      setState(() {
        _selectedAddress = defaultAddress;
      });
      // Calculate delivery charge for the default address
      context.read<ShopMedicinesBloc>().add(CalculateDeliveryCharge(
            shopId: widget.shopId,
            deliveryAddress: defaultAddress,
          ));
    }
  }

  Future<void> _loadPhoneNumber() async {
    // TODO: Implement loading phone number from user profile
    setState(() {
      _phoneNumber =
          '+1234567890'; // Replace with actual phone number from user profile
    });
  }

  Future<void> _uploadPrescription() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  _getImageFromGallery();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Take a Photo'),
                onTap: () {
                  _getImageFromCamera();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.file_present),
                title: const Text('Upload PDF'),
                onTap: () {
                  _getPDF();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _getImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _prescriptionFile = File(image.path);
      });
    }
  }

  Future<void> _getImageFromCamera() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        _prescriptionFile = File(photo.path);
      });
    }
  }

  Future<void> _getPDF() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        _prescriptionFile = File(result.files.single.path!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ShopMedicinesBloc, ShopMedicinesState>(
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: kErrorColor,
            ),
          );
        }
        if (state.prescriptionUploaded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Prescription uploaded successfully',
              ),
              backgroundColor: kSuccessColor,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: kWhiteColor),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text('Cart - ${widget.shopName}',
                style: AppFonts.headline3Light),
            backgroundColor: kPrimaryColor,
          ),
          body: state.cart.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.shopping_cart_outlined,
                          size: 100, color: Colors.grey),
                      const SizedBox(height: 20),
                      Text('Your cart is empty',
                          style:
                              AppFonts.headline2.copyWith(color: kBlackColor)),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: state.cart.length,
                        itemBuilder: (context, index) {
                          final item = state.cart[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              title: Text(item.medicineName,
                                  style: AppFonts.headline4),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 8),
                                  Text('Quantity: ${item.quantity}',
                                      style: AppFonts.bodyText2),
                                  const SizedBox(height: 4),
                                  Text(
                                      '₹${(item.price * item.quantity).toStringAsFixed(2)}',
                                      style: AppFonts.bodyText1),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.remove_circle_outline,
                                    color: kPrimaryColor),
                                onPressed: () {
                                  context
                                      .read<ShopMedicinesBloc>()
                                      .add(RemoveFromCart(item));
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Card(
                      margin: const EdgeInsets.all(16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ElevatedButton.icon(
                              icon: Icon(_prescriptionFile != null
                                  ? Icons.check
                                  : Icons.upload_file),
                              label: Text(
                                _prescriptionFile != null
                                    ? 'Prescription Selected'
                                    : 'Upload Prescription (Optional)',
                                style: AppFonts.button,
                              ),
                              onPressed:
                                  state.isLoading ? null : _uploadPrescription,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _prescriptionFile != null
                                    ? Colors.green
                                    : kPrimaryColor,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                            if (_prescriptionFile != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  'File: ${_prescriptionFile!.path.split('/').last}',
                                  style: AppFonts.bodyText2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            const SizedBox(height: 16),
                            const SizedBox(height: 16),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Expanded(
                                  flex: 3,
                                  child: Text('Subtotal:',
                                      style: AppFonts.headline3),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      '₹${state.cart.fold(0.0, (sum, item) => sum + (item.price * item.quantity)).toStringAsFixed(2)}',
                                      style: AppFonts.headline1,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (state.deliveryCharge != null) ...[
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Expanded(
                                    flex: 3,
                                    child: Text('Delivery Charge:',
                                        style: AppFonts.headline3),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        state.deliveryCharge! > 0
                                            ? '₹${state.deliveryCharge!.toStringAsFixed(2)}'
                                            : 'Free',
                                        style: AppFonts.headline1,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Expanded(
                                    flex: 3,
                                    child: Text('Total:',
                                        style: AppFonts.headline3),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        '₹${(state.cart.fold(0.0, (sum, item) => sum + (item.price * item.quantity)) + state.deliveryCharge!).toStringAsFixed(2)}',
                                        style: AppFonts.headline1.copyWith(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () =>
                                  _navigateToDeliveryDetails(context, state),
                              child: Text(_selectedAddress == null
                                  ? 'Select Delivery Address'
                                  : 'Change Delivery Address'),
                            ),
                            if (_selectedAddress != null)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  'Delivery to: ${_selectedAddress!.label}',
                                  style: AppFonts.bodyText2,
                                ),
                              ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: state.isLoading
                                  ? null
                                  : () => _placeOrder(context, state),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kPrimaryColor,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: state.isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white)
                                  : const Text('Place Order',
                                      style: AppFonts.button),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  void _navigateToDeliveryDetails(
      BuildContext context, ShopMedicinesState state) {
    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not authenticated')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DeliveryDetailsScreen(
          shopId: widget.shopId,
          shopName: widget.shopName,
          totalAmount: state.cart
              .fold(0.0, (sum, item) => sum + (item.price * item.quantity)),
          userId: _userId!,
          prescriptionFile: _prescriptionFile,
          cart: state.cart,
          onAddressSelected: (address) {
            setState(() {
              _selectedAddress = address;
            });
            context.read<ShopMedicinesBloc>().add(CalculateDeliveryCharge(
                  shopId: widget.shopId,
                  deliveryAddress: address,
                ));
          },
        ),
      ),
    );
  }

  void _showChangePhoneNumberDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newPhoneNumber = _phoneNumber ?? '';
        return AlertDialog(
          title: const Text('Change Phone Number'),
          content: TextField(
            decoration:
                const InputDecoration(hintText: "Enter new phone number"),
            onChanged: (value) {
              newPhoneNumber = value;
            },
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                setState(() {
                  _phoneNumber = newPhoneNumber;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _placeOrder(BuildContext context, ShopMedicinesState state) {
    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not authenticated')),
      );
      return;
    }
    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a delivery address')),
      );
      return;
    }
    if (_phoneNumber == null || _phoneNumber!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a contact number')),
      );
      return;
    }

    final totalAmount = state.cart
            .fold(0.0, (sum, item) => sum + (item.price * item.quantity)) +
        (state.deliveryCharge ?? 0);

    var options = {
      'key': Config.razorpayKey,
      'amount': (totalAmount * 100).toInt(),
      'name': 'EldCare Medicines',
      'description': 'Medicine Order',
      'prefill': {'contact': _phoneNumber, 'email': 'customer@example.com'},
    };

    Future.delayed(Duration.zero, () {
      try {
        _razorpay.open(options);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    });
  }

  void _showOrderSuccessDialog(BuildContext context) {
    final state = context.read<ShopMedicinesBloc>().state;
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Order Placed Successfully'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Your order has been placed and is being processed.'),
              const SizedBox(height: 16),
              Text('Order ID: ${state.pendingOrderId ?? 'N/A'}'),
              const SizedBox(height: 8),
              Text(
                'Total Amount: ₹${(state.cart.fold(0.0, (sum, item) => sum + (item.price * item.quantity)) + (state.deliveryCharge ?? 0)).toStringAsFixed(2)}',
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the dialog
                Navigator.of(context).pop(); // Go back to the shop screen
              },
            ),
          ],
        );
      },
    );
  }
}
