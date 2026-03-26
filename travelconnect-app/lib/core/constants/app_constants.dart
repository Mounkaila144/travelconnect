import 'package:google_maps_flutter/google_maps_flutter.dart';

class AppConstants {
  AppConstants._();

  static const LatLng defaultLocation = LatLng(35.6762, 139.6503);
  static const double defaultZoom = 12.0;
  static const double myLocationZoom = 15.0;
  static const int locationTimeoutSeconds = 10;
  static const int cameraDebounceMs = 300;
}
