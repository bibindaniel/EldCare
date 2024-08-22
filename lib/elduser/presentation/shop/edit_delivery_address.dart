import 'package:eldcare/elduser/models/address.dart';
import 'package:eldcare/elduser/presentation/shop/delivary_deatils_screen.dart';
import 'package:flutter/material.dart';
import 'package:eldcare/elduser/models/delivary_address.dart';
import 'package:eldcare/elduser/repository/delivery_adress_repo.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditAddressScreen extends StatefulWidget {
  final String userId;
  final DeliveryAddress address;
  final Function(DeliveryAddress) onAddressUpdated;

  const EditAddressScreen({
    Key? key,
    required this.userId,
    required this.address,
    required this.onAddressUpdated,
  }) : super(key: key);

  @override
  _EditAddressScreenState createState() => _EditAddressScreenState();
}

class _EditAddressScreenState extends State<EditAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _labelController;
  late TextEditingController _houseNameController;
  late TextEditingController _streetController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _postalCodeController;
  LatLng? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.address.label);
    _houseNameController =
        TextEditingController(text: widget.address.address.houseName);
    _streetController =
        TextEditingController(text: widget.address.address.street);
    _cityController = TextEditingController(text: widget.address.address.city);
    _stateController =
        TextEditingController(text: widget.address.address.state);
    _postalCodeController =
        TextEditingController(text: widget.address.address.postalCode);
    _selectedLocation = widget.address.address.location != null
        ? LatLng(widget.address.address.location!.latitude,
            widget.address.address.location!.longitude)
        : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Address'),
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
                onPressed: _updateAddress,
                child: const Text('Update Address'),
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

  void _updateAddress() async {
    if (_formKey.currentState!.validate()) {
      final updatedAddress = DeliveryAddress(
        id: widget.address.id,
        address: Address(
          id: widget.address.address.id,
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
        isDefault: widget.address.isDefault,
      );

      try {
        await DeliveryAddressRepository()
            .updateDeliveryAddress(widget.userId, updatedAddress);
        widget.onAddressUpdated(updatedAddress);
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Address updated successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update address: $e')),
        );
      }
    }
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
