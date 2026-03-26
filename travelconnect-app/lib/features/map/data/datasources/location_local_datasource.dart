import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart'
    as permission_handler;

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/map_position.dart';
import '../../domain/repositories/location_repository.dart';

abstract class LocationLocalDataSource {
  Future<LocationPermissionStatus> checkPermission();
  Future<LocationPermissionStatus> requestPermission();
  Future<MapPosition> getCurrentLocation();
  Future<bool> isLocationServiceEnabled();
  Future<bool> openAppSettings();
  Future<bool> openLocationSettings();
}

class LocationLocalDataSourceImpl implements LocationLocalDataSource {
  MapPosition? _lastKnownLocation;

  @override
  Future<LocationPermissionStatus> checkPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationPermissionStatus.serviceDisabled;
    }

    final status = await permission_handler.Permission.location.status;
    return _mapPermissionStatus(status);
  }

  @override
  Future<LocationPermissionStatus> requestPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationPermissionStatus.serviceDisabled;
    }

    final status = await permission_handler.Permission.location.request();
    return _mapPermissionStatus(status);
  }

  @override
  Future<MapPosition> getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(
          seconds: AppConstants.locationTimeoutSeconds,
        ),
      );

      _lastKnownLocation = MapPosition(
        latitude: position.latitude,
        longitude: position.longitude,
        zoom: AppConstants.myLocationZoom,
      );

      return _lastKnownLocation!;
    } on TimeoutException {
      if (_lastKnownLocation != null) return _lastKnownLocation!;
      rethrow;
    } on LocationServiceDisabledException {
      if (_lastKnownLocation != null) return _lastKnownLocation!;
      rethrow;
    } catch (e) {
      if (_lastKnownLocation != null) return _lastKnownLocation!;
      rethrow;
    }
  }

  @override
  Future<bool> isLocationServiceEnabled() async {
    return Geolocator.isLocationServiceEnabled();
  }

  @override
  Future<bool> openAppSettings() async {
    return permission_handler.openAppSettings();
  }

  @override
  Future<bool> openLocationSettings() async {
    return Geolocator.openLocationSettings();
  }

  LocationPermissionStatus _mapPermissionStatus(
    permission_handler.PermissionStatus status,
  ) {
    if (status.isGranted || status.isLimited) {
      return LocationPermissionStatus.granted;
    } else if (status.isPermanentlyDenied) {
      return LocationPermissionStatus.deniedPermanently;
    } else {
      return LocationPermissionStatus.denied;
    }
  }
}
