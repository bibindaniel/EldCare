import 'dart:io';
import 'package:eldcare/elduser/models/delivary_address.dart';
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

  @override
  void initState() {
    super.initState();
    _loadUserId();

    _loadDefaultAddress();
    _loadPhoneNumber();
  }

  Future<void> _loadUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userId = user.uid;
      });
    }
  }

  Future<void> _loadDefaultAddress() async {
    if (_userId == null) return;
    final addresses = await _addressRepository.getDeliveryAddresses(_userId!);
    if (addresses.isNotEmpty) {
      setState(() {
        _selectedAddress = addresses.firstWhere((addr) => addr.isDefault,
            orElse: () => addresses.first);
      });
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
        if (state.cart.isEmpty && !state.isLoading && state.error == null) {
          _showOrderSuccessDialog(context);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: kWhiteColor),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text('Cart - ${widget.shopName}', style: AppFonts.headline3),
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
                                  style: AppFonts.headline4Dark),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 8),
                                  Text('Quantity: ${item.quantity}',
                                      style: AppFonts.bodyText2),
                                  const SizedBox(height: 4),
                                  Text(
                                      '₹${(item.price * item.quantity).toStringAsFixed(2)}',
                                      style: AppFonts.bodyText1Dark),
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Total:',
                                    style: AppFonts.headline3Dark),
                                Text(
                                  '₹${state.cart.fold(0.0, (sum, item) => sum + (item.price * item.quantity)).toStringAsFixed(2)}',
                                  style: AppFonts.headline1,
                                ),
                              ],
                            ),
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
      // Handle the case where the user ID is not available
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

    context.read<ShopMedicinesBloc>().add(PlaceOrder(
          userId: _userId!,
          shopId: widget.shopId,
          prescriptionFile: _prescriptionFile,
          deliveryAddress: _selectedAddress!,
          phoneNumber: _phoneNumber!,
        ));
  }

  void _showOrderSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Order Placed Successfully'),
          content:
              const Text('Your order has been placed and is being processed.'),
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

  // void _showOrderConfirmationDialog(
  //     BuildContext context, ShopMedicinesState state) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext dialogContext) {
  //       return AlertDialog(
  //         title: const Text('Confirm Order'),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             Text('Total Items: ${state.cart.length}'),
  //             Text(
  //                 'Total Amount: ₹${state.cart.fold(0.0, (sum, item) => sum + (item.price * item.quantity)).toStringAsFixed(2)}'),
  //             const SizedBox(height: 16),
  //             ElevatedButton(
  //               onPressed: _uploadPrescription,
  //               child: const Text('Upload Prescription'),
  //             ),
  //             const SizedBox(height: 16),
  //             const Text(
  //               'Note: Some medicines may require a prescription. The pharmacist may reject the order if a prescription is not provided when necessary.',
  //               style: TextStyle(color: Colors.red, fontSize: 12),
  //             ),
  //           ],
  //         ),
  //         actions: [
  //           TextButton(
  //             child: const Text('Cancel'),
  //             onPressed: () => Navigator.of(dialogContext).pop(),
  //           ),
  //           ElevatedButton(
  //             child: const Text('Proceed to Delivery Details'),
  //             onPressed: () {
  //               Navigator.of(dialogContext).pop();
  //               Navigator.push(
  //                 context,
  //                 MaterialPageRoute(
  //                   builder: (context) => DeliveryDetailsScreen(
  //                     shopId: widget.shopId,
  //                     shopName: widget.shopName,
  //                     totalAmount: state.cart.fold(0.0,
  //                         (sum, item) => sum + (item.price * item.quantity)),
  //                     userId: 'user_id',
  //                     prescriptionFile: _prescriptionFile,
  //                     cart: state.cart,
  //                   ),
  //                 ),
  //               );
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
}
