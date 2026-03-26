import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';

import '../bloc/map_bloc.dart';
import '../bloc/map_event.dart';
import '../bloc/map_state.dart';

class MyLocationButton extends StatelessWidget {
  const MyLocationButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapBloc, MapState>(
      buildWhen: (previous, current) {
        if (current is MapLoaded && previous is MapLoaded) {
          return current.isMovingToLocation != previous.isMovingToLocation;
        }
        return false;
      },
      builder: (context, state) {
        final isLoading =
            state is MapLoaded && state.isMovingToLocation;

        return Padding(
          padding: const EdgeInsets.only(
            right: AppSpacing.lg,
            bottom: AppSpacing.xl,
          ),
          child: FloatingActionButton.small(
            heroTag: 'my_location_button',
            backgroundColor: AppColors.surfaceWhite,
            foregroundColor: AppColors.primary,
            elevation: 0,
            shape: const CircleBorder(),
            onPressed: isLoading
                ? null
                : () {
                    context.read<MapBloc>().add(const MoveToMyLocation());
                  },
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: AppShadows.card,
                    ),
                    child: const Icon(Icons.my_location),
                  ),
          ),
        );
      },
    );
  }
}
