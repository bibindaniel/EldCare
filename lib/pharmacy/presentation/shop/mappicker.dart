import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPickerScreen extends StatefulWidget {
  final LatLng initialLocation;

  const MapPickerScreen({super.key, required this.initialLocation});

  @override
  MapPickerScreenState createState() => MapPickerScreenState();
}

class MapPickerScreenState extends State<MapPickerScreen> {
  late CameraPosition _initialCameraPosition;
  Marker? _selectedMarker;

  @override
  void initState() {
    super.initState();
    _initialCameraPosition = CameraPosition(
      target: widget.initialLocation,
      zoom: 15.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(_selectedMarker?.position);
            },
            child: const Text('Select'),
          ),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: _initialCameraPosition,
        onMapCreated: (controller) {
          _addMarker(widget.initialLocation);
        },
        onTap: (latLng) {
          _addMarker(latLng);
        },
        markers: _selectedMarker != null ? {_selectedMarker!} : {},
      ),
    );
  }

  void _addMarker(LatLng latLng) {
    setState(() {
      _selectedMarker = Marker(
        markerId: const MarkerId('selected_location'),
        position: latLng,
      );
    });
  }
}
