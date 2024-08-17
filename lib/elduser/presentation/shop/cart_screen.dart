import 'dart:io';
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
                              onPressed: state.isLoading
                                  ? null
                                  : () => _showOrderConfirmationDialog(
                                      context, state),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kPrimaryColor,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: state.isLoading
                                  ? CircularProgressIndicator(
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

  void _showOrderConfirmationDialog(
      BuildContext context, ShopMedicinesState state) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Order'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Please review your order:'),
              const SizedBox(height: 8),
              Text('Total Items: ${state.cart.length}'),
              Text(
                  'Total Amount: ₹${state.cart.fold(0.0, (sum, item) => sum + (item.price * item.quantity)).toStringAsFixed(2)}'),
              if (_prescriptionFile != null)
                Text(
                    'Prescription: ${_prescriptionFile!.path.split('/').last}'),
              const SizedBox(height: 16),
              const Text(
                'Note: Some medicines may require a prescription. The pharmacist may reject the order if a prescription is not provided when necessary.',
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ElevatedButton(
              child: const Text('Confirm Order'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the dialog
                context.read<ShopMedicinesBloc>().add(PlaceOrder(
                      userId: 'user_id', // Replace with actual user ID
                      shopId: widget.shopId,
                      prescriptionFile: _prescriptionFile,
                    ));
                Navigator.of(context).pop(); // Go back to the shop screen
              },
            ),
          ],
        );
      },
    );
  }
}
