import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eldcare/elduser/models/address.dart';
import 'package:eldcare/elduser/presentation/shop/edit_delivery_address.dart';
import 'package:flutter/material.dart';
import 'package:eldcare/elduser/models/delivary_address.dart';
import 'package:eldcare/elduser/repository/delivery_adress_repo.dart';
import 'package:eldcare/core/theme/colors.dart';
import 'package:eldcare/core/theme/font.dart';
import 'package:eldcare/elduser/models/order.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class DeliveryDetailsScreen extends StatefulWidget {
  final String shopId;
  final String shopName;
  final double totalAmount;
  final String userId;
  final File? prescriptionFile;
  final List<OrderItem> cart;
  final Function(DeliveryAddress) onAddressSelected;

  const DeliveryDetailsScreen({
    super.key,
    required this.shopId,
    required this.shopName,
    required this.totalAmount,
    required this.userId,
    this.prescriptionFile,
    required this.cart,
    required this.onAddressSelected,
  });

  @override
  DeliveryDetailsScreenState createState() => DeliveryDetailsScreenState();
}

class DeliveryDetailsScreenState extends State<DeliveryDetailsScreen> {
  final DeliveryAddressRepository _addressRepository =
      DeliveryAddressRepository();
  List<DeliveryAddress> _addresses = [];
  DeliveryAddress? _selectedAddress;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    final addresses =
        await _addressRepository.getDeliveryAddresses(widget.userId);
    setState(() {
      _addresses = addresses;
      _selectedAddress = addresses.isNotEmpty
          ? addresses.firstWhere((addr) => addr.isDefault,
              orElse: () => addresses.first)
          : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Delivery Details', style: AppFonts.headline2Light),
        backgroundColor: kPrimaryColor,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _addresses.length + 1,
              itemBuilder: (context, index) {
                if (index == _addresses.length) {
                  return ListTile(
                    leading: const Icon(Icons.add),
                    title: const Text('Add New Address'),
                    onTap: () => _navigateToAddNewAddress(context),
                  );
                }
                final address = _addresses[index];
                return RadioListTile<DeliveryAddress>(
                  title: Text(address.label),
                  subtitle: Text(address.toString()),
                  value: address,
                  groupValue: _selectedAddress,
                  onChanged: (DeliveryAddress? value) {
                    setState(() {
                      _selectedAddress = value;
                    });
                  },
                  secondary: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editAddress(context, address),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _removeAddress(address),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _selectedAddress != null
                  ? () {
                      widget.onAddressSelected(_selectedAddress!);
                      Navigator.pop(context);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Confirm Address'),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToAddNewAddress(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddNewAddressScreen(
          userId: widget.userId,
          onAddressAdded: (newAddress) {
            setState(() {
              _addresses.add(newAddress);
              _selectedAddress = newAddress;
            });
          },
        ),
      ),
    );
  }

  void _editAddress(BuildContext context, DeliveryAddress address) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditAddressScreen(
          userId: widget.userId,
          address: address,
          onAddressUpdated: (updatedAddress) {
            setState(() {
              final index =
                  _addresses.indexWhere((a) => a.id == updatedAddress.id);
              if (index != -1) {
                _addresses[index] = updatedAddress;
                if (_selectedAddress?.id == updatedAddress.id) {
                  _selectedAddress = updatedAddress;
                }
              }
            });
          },
        ),
      ),
    );
  }

  void _removeAddress(DeliveryAddress address) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove Address'),
          content: const Text('Are you sure you want to remove this address?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Remove'),
              onPressed: () async {
                await _addressRepository.removeDeliveryAddress(
                    widget.userId, address.id);
                setState(() {
                  _addresses.removeWhere((a) => a.id == address.id);
                  if (_selectedAddress?.id == address.id) {
                    _selectedAddress =
                        _addresses.isNotEmpty ? _addresses.first : null;
                  }
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class AddNewAddressScreen extends StatefulWidget {
  final String userId;
  final Function(DeliveryAddress) onAddressAdded;

  const AddNewAddressScreen({
    super.key,
    required this.userId,
    required this.onAddressAdded,
  });

  @override
  _AddNewAddressScreenState createState() => _AddNewAddressScreenState();
}

class _AddNewAddressScreenState extends State<AddNewAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController();
  final _houseNameController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _postalCodeController = TextEditingController();
  LatLng? _selectedLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Address'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _labelController,
                decoration: const InputDecoration(labelText: 'Address Label'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an address label';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _houseNameController,
                decoration:
                    const InputDecoration(labelText: 'House Name/Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter house name/number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _streetController,
                decoration: const InputDecoration(labelText: 'Street'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter street name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: 'City'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter city name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _stateController,
                decoration: const InputDecoration(labelText: 'State'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter state name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _postalCodeController,
                decoration: const InputDecoration(labelText: 'Postal Code'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter postal code';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _showLocationOptions,
                child: const Text('Choose Location'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveNewAddress,
                child: const Text('Save Address'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLocationOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.my_location),
                title: const Text('Use Current Location'),
                onTap: () {
                  Navigator.pop(context);
                  _getCurrentLocation();
                },
              ),
              ListTile(
                leading: const Icon(Icons.map),
                title: const Text('Choose on Map'),
                onTap: () {
                  Navigator.pop(context);
                  _showLocationPicker();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _getCurrentLocation() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;

    try {
      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _selectedLocation = LatLng(position.latitude, position.longitude);
      });
      _getAddressFromLatLng(_selectedLocation!);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _streetController.text = '${place.street}';
          _cityController.text = '${place.locality}';
          _stateController.text = '${place.administrativeArea}';
          _postalCodeController.text = '${place.postalCode}';
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _showLocationPicker() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;

    final Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapScreen(
          initialPosition: LatLng(position.latitude, position.longitude),
        ),
      ),
    );

    if (result != null && result is LatLng) {
      setState(() {
        _selectedLocation = result;
      });
      _getAddressFromLatLng(_selectedLocation!);
    }
  }

  void _saveNewAddress() async {
    if (_formKey.currentState!.validate()) {
      final newAddress = DeliveryAddress(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        address: Address(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          houseName: _houseNameController.text,
          street: _streetController.text,
          city: _cityController.text,
          state: _stateController.text,
          postalCode: _postalCodeController.text,
          location: _selectedLocation != null
              ? GeoPoint(
                  _selectedLocation!.latitude, _selectedLocation!.longitude)
              : null,
        ),
        label: _labelController.text,
        isDefault: false,
      );

      await DeliveryAddressRepository()
          .addDeliveryAddress(widget.userId, newAddress);
      widget.onAddressAdded(newAddress);
      Navigator.of(context).pop();
    }
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  @override
  void dispose() {
    _labelController.dispose();
    _houseNameController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }
}

class MapScreen extends StatefulWidget {
  final LatLng initialPosition;

  const MapScreen({Key? key, required this.initialPosition}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late LatLng _selectedLocation;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialPosition;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Location'),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: widget.initialPosition,
          zoom: 15,
        ),
        onTap: (LatLng location) {
          setState(() {
            _selectedLocation = location;
          });
        },
        markers: {
          Marker(
            markerId: const MarkerId('selected_location'),
            position: _selectedLocation,
          ),
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pop(_selectedLocation);
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}
