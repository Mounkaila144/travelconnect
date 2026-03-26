import 'dart:async';

import 'package:flutter/material.dart';
import 'package:travelconnect_app/l10n/app_localizations.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationPickerWidget extends StatefulWidget {
  final double initialLatitude;
  final double initialLongitude;
  final ValueChanged<LatLng> onLocationSelected;

  const LocationPickerWidget({
    super.key,
    required this.initialLatitude,
    required this.initialLongitude,
    required this.onLocationSelected,
  });

  @override
  State<LocationPickerWidget> createState() => _LocationPickerWidgetState();
}

class _LocationPickerWidgetState extends State<LocationPickerWidget> {
  late double _latitude;
  late double _longitude;
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _latitude = widget.initialLatitude;
    _longitude = widget.initialLongitude;
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.locationPicker_title),
        actions: [
          TextButton(
            onPressed: () {
              widget.onLocationSelected(LatLng(_latitude, _longitude));
              Navigator.pop(context);
            },
            child: Text(l10n.locationPicker_confirm),
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(_latitude, _longitude),
              zoom: 15.0,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
            },
            onCameraMove: (position) {
              setState(() {
                _latitude = position.target.latitude;
                _longitude = position.target.longitude;
              });
            },
            onCameraIdle: () {
              widget.onLocationSelected(LatLng(_latitude, _longitude));
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: true,
          ),
          // Center crosshair marker
          const Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 48),
              child: Icon(
                Icons.add_location,
                size: 48,
                color: Colors.red,
              ),
            ),
          ),
          // Coordinate display at bottom
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  '${_latitude.toStringAsFixed(6)}, ${_longitude.toStringAsFixed(6)}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
