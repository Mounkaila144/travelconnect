import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travelconnect_app/l10n/app_localizations.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/notification_zone_bloc.dart';
import '../bloc/notification_zone_event.dart';
import '../bloc/notification_zone_state.dart';

class NotificationZonePage extends StatefulWidget {
  const NotificationZonePage({super.key});

  @override
  State<NotificationZonePage> createState() => _NotificationZonePageState();
}

class _NotificationZonePageState extends State<NotificationZonePage> {
  GoogleMapController? _mapController;
  LatLng _center = const LatLng(35.6762, 139.6503);
  double _radiusKm = 10.0;

  @override
  void initState() {
    super.initState();
    context.read<NotificationZoneBloc>().add(const LoadNotificationZone());
  }

  Set<Circle> get _circles => {
        Circle(
          circleId: const CircleId('notification_zone'),
          center: _center,
          radius: _radiusKm * 1000,
          strokeWidth: 2,
          strokeColor: Theme.of(context).colorScheme.primary,
          fillColor:
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
        ),
      };

  Set<Marker> get _markers => {
        Marker(
          markerId: const MarkerId('zone_center'),
          position: _center,
          draggable: true,
          onDragEnd: (newPosition) {
            setState(() {
              _center = newPosition;
            });
          },
        ),
      };

  Future<void> _useCurrentLocation() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _center = LatLng(position.latitude, position.longitude);
      });
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(_center),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.notificationZone_locationError),
          ),
        );
      }
    }
  }

  void _saveZone() {
    context.read<NotificationZoneBloc>().add(
          SaveNotificationZone(
            latitude: _center.latitude,
            longitude: _center.longitude,
            radiusKm: _radiusKm.round(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return BlocConsumer<NotificationZoneBloc, NotificationZoneState>(
      listener: (context, state) {
        if (state is NotificationZoneLoaded) {
          if (state.latitude != null && state.longitude != null) {
            setState(() {
              _center = LatLng(state.latitude!, state.longitude!);
              _radiusKm = (state.radiusKm ?? 10).toDouble();
            });
            _mapController?.animateCamera(
              CameraUpdate.newLatLng(_center),
            );
          }
        } else if (state is NotificationZoneSaved) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.notificationZone_saved),
            ),
          );
        } else if (state is NotificationZoneError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.notificationZone_title),
            actions: [
              TextButton(
                onPressed: state is NotificationZoneSaving ? null : _saveZone,
                child: state is NotificationZoneSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.notificationZone_save),
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _center,
                    zoom: 12,
                  ),
                  circles: _circles,
                  markers: _markers,
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                  onTap: (latLng) {
                    setState(() {
                      _center = latLng;
                    });
                  },
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppRadius.xl),
                    topRight: Radius.circular(AppRadius.xl),
                  ),
                  boxShadow: AppShadows.elevated,
                ),
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.xl,
                  AppSpacing.lg,
                  AppSpacing.lg + MediaQuery.of(context).padding.bottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.notificationZone_radiusKm(_radiusKm.round()),
                          style: theme.textTheme.titleMedium,
                        ),
                        TextButton.icon(
                          icon: const Icon(Icons.my_location),
                          label: Text(l10n.notificationZone_myLocation),
                          onPressed: _useCurrentLocation,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Slider(
                      value: _radiusKm,
                      min: 1,
                      max: 50,
                      divisions: 49,
                      label: '${_radiusKm.round()} km',
                      onChanged: (value) {
                        setState(() {
                          _radiusKm = value;
                        });
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      l10n.notificationZone_instructions,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
