import 'package:eldcare/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:eldcare/auth/presentation/blocs/auth/auth_state.dart';
import 'package:eldcare/core/theme/colors.dart';
import 'package:eldcare/core/theme/font.dart';
import 'package:eldcare/pharmacy/blocs/shop/shop_bloc.dart';
import 'package:eldcare/pharmacy/model/shop.dart';
import 'package:eldcare/pharmacy/presentation/shop/mappicker.dart';
import 'package:eldcare/pharmacy/repository/shop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'package:lottie/lottie.dart';

class AddShopPage extends StatefulWidget {
  final ShopRepository shopRepository;
  const AddShopPage({super.key, required this.shopRepository});

  @override
  AddShopPageState createState() => AddShopPageState();
}

class AddShopPageState extends State<AddShopPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _licenseController = TextEditingController();
  final _locationController = TextEditingController();
  LatLng? _selectedLocation;
  String? _formattedAddress;
  late GoogleMapController _mapController;

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _licenseController.dispose();
    _locationController.dispose();

    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    // Check if location permissions are granted
    var status = await Permission.location.status;
    if (!status.isGranted) {
      // Request location permission
      status = await Permission.location.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permission is required to get your current location.'),
        ));
        return;
      }
    }

    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content:
            Text('Location services are disabled. Please enable the services'),
      ));
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _updateLocation(LatLng(position.latitude, position.longitude));
      _mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 15.0,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error getting location: $e'),
      ));
    }
  }

  Future<void> _updateLocation(LatLng location) async {
    setState(() {
      _selectedLocation = location;
    });

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        _formattedAddress =
            "${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
        _locationController.text = _formattedAddress!;
      }
    } catch (e) {
      print("Error during geocoding: $e");
    }
  }

  Future<void> _getCoordinatesFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        _updateLocation(LatLng(locations[0].latitude, locations[0].longitude));
      }
    } catch (e) {
      print("Error during geocoding: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ShopBloc(shopRepository: widget.shopRepository),
      child: Scaffold(
        backgroundColor: kPrimaryColor,
        appBar: AppBar(
          backgroundColor: kPrimaryColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title:
              const Text('Add New Shop', style: TextStyle(color: Colors.white)),
        ),
        body: BlocConsumer<ShopBloc, ShopState>(
          listener: (context, state) {
            if (state is ShopAddedState) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Shop submitted for verification'),
                  backgroundColor: kSuccessColor,
                ),
              );
              Navigator.pop(context);
            } else if (state is ShopErrorState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${state.error}'),
                  backgroundColor: kErrorColor,
                ),
              );
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'Add New Shop',
                          style: TextStyle(color: Colors.white, fontSize: 20),
                          maxLines: 2,
                        ),
                      ),
                      Lottie.asset(
                        'assets/animations/pharmacy2.json',
                        width: 60,
                        height: 60,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: const Offset(0, -3),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: _buildShopForm(context),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildShopForm(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField('Shop Name', _nameController, _validateName),
          const SizedBox(height: 20),
          _buildTextField(
              'Phone Number', _phoneController, validatePhoneNumber),
          const SizedBox(height: 20),
          _buildTextField('Email', _emailController, _validateEmail),
          const SizedBox(height: 20),
          _buildTextField(
              'License Number', _licenseController, _validateLicense),
          const SizedBox(height: 20),
          _buildLocationField(),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _submitForm(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              textStyle:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            child: const Text(
              'Submit for Verification',
              style: AppFonts.bodyText1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationField() {
    return TextFormField(
      controller: _locationController,
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'Location',
        suffixIcon: IconButton(
          icon: const Icon(Icons.location_on),
          onPressed: () async {
            // Check if location permissions are granted
            var status = await Permission.location.status;
            if (!status.isGranted) {
              // Request location permission
              status = await Permission.location.request();
              if (!status.isGranted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text(
                      'Location permission is required to get your current location.'),
                ));
                return;
              }
            }
            final selectedLocation = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MapPickerScreen(
                  initialLocation: _selectedLocation ?? const LatLng(0.0, 0.0),
                ),
              ),
            );
            if (selectedLocation != null) {
              _updateLocation(selectedLocation);
            }
          },
        ),
        suffixIconColor: kPrimaryColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      onTap: () async {
        await _getCurrentLocation();
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a location';
        }
        return null;
      },
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      String? Function(String?)? validator) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: kErrorColor,
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: kSuccessColor,
            width: 2.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: Colors.grey,
            width: 1.0,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: kErrorColor,
            width: 2.0,
          ),
        ),
      ),
      validator: validator,
    );
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Shop name is required';
    }
    if (!RegExp(r'^[a-zA-Z0-9\s]+$').hasMatch(value)) {
      return 'Invalid Shop name';
    }
    return null;
  }

  String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (!RegExp(r'^[6789]\d{9}$').hasMatch(value)) {
      return 'Invalid Indian phone number';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Invalid email address';
    }
    return null;
  }

  String? _validateLicense(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the license number';
    }
    return null;
  }

  void _submitForm(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      if (_selectedLocation == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please select a location'),
        ));
        return;
      }
      final authState = context.read<AuthBloc>().state;
      String? ownerId;
      if (authState is Authenticated) {
        ownerId = authState.user.uid;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('User is not authenticated'),
        ));
        return;
      }
      final shop = Shop(
        id: const Uuid().v4(),
        name: _nameController.text,
        phoneNumber: _phoneController.text,
        email: _emailController.text,
        ownerId: ownerId,
        licenseNumber: _licenseController.text,
        isVerified: false,
        createdAt: DateTime.now(),
        location:
            GeoPoint(_selectedLocation!.latitude, _selectedLocation!.longitude),
        address: _formattedAddress ?? _addressController.text,
      );

      context.read<ShopBloc>().add(AddShopEvent(shop));
    }
  }
}
