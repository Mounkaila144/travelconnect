import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travelconnect_app/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../injection.dart';
import '../../../questions/domain/usecases/create_question.dart';
import '../../../questions/presentation/bloc/create_question_bloc.dart';
import '../../../questions/presentation/pages/create_question_page.dart';
import '../../domain/entities/map_position.dart';
import '../bloc/map_bloc.dart';
import '../bloc/map_event.dart';
import '../bloc/map_state.dart';
import '../widgets/location_permission_screen.dart';
import '../widgets/map_view.dart';
import '../widgets/my_location_button.dart';
import '../widgets/questions_loading_indicator.dart';
import '../widgets/questions_error_banner.dart';
import '../widgets/no_questions_indicator.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  @override
  void initState() {
    super.initState();
    context.read<MapBloc>().add(const InitializeMap());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<MapBloc, MapState>(
        listener: _onStateChanged,
        builder: (context, state) {
          if (state is MapLoading || state is MapInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is LocationPermissionRequired) {
            return LocationPermissionScreen(reason: state.reason);
          }

          if (state is MapError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.errorLight,
                        borderRadius: AppRadius.xxlAll,
                      ),
                      child: const Icon(
                        Icons.error_outline,
                        size: 40,
                        color: AppColors.error,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    ElevatedButton(
                      onPressed: () {
                        context.read<MapBloc>().add(const InitializeMap());
                      },
                      child: Text(AppLocalizations.of(context)!.map_retry),
                    ),
                  ],
                ),
              ),
            );
          }

          final MapPosition position;
          final bool hasPermission;

          if (state is MapLoaded) {
            position = state.currentPosition;
            hasPermission = state.hasLocationPermission;
          } else {
            // Should not reach here, but handle gracefully
            return const Center(child: CircularProgressIndicator());
          }

          return Stack(
            children: [
              MapView(
                initialPosition: position,
                hasLocationPermission: hasPermission,
              ),
              // Floating search bar at top
              Positioned(
                top: MediaQuery.of(context).padding.top + AppSpacing.sm,
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.pushNamed(context, '/search'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceWhite,
                      borderRadius: AppRadius.xxlAll,
                      border: Border.all(
                        color: AppColors.borderLight,
                        width: 0.5,
                      ),
                      boxShadow: AppShadows.card,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search,
                            color: AppColors.textTertiary, size: 20),
                        const SizedBox(width: AppSpacing.md),
                        Text(
                          AppLocalizations.of(context)!.map_search,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textTertiary,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Loading indicator for questions
              if (state is MapLoaded && state.isLoadingQuestions)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 68,
                  left: 0,
                  right: 0,
                  child: const Center(
                    child: QuestionsLoadingIndicator(),
                  ),
                ),
              // Error indicator for questions
              if (state is MapLoaded && state.questionsError != null)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 68,
                  left: AppSpacing.lg,
                  right: AppSpacing.lg,
                  child: QuestionsErrorBanner(
                    message: state.questionsError!,
                    onRetry: () {
                      context
                          .read<MapBloc>()
                          .add(const RefreshQuestions());
                    },
                  ),
                ),
              // Empty state indicator
              if (state is MapLoaded &&
                  !state.isLoadingQuestions &&
                  state.questions.isEmpty &&
                  state.questionsError == null)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 68,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: NoQuestionsIndicator(),
                  ),
                ),
              Positioned(
                bottom: AppSpacing.lg,
                right: AppSpacing.lg,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        shape: BoxShape.circle,
                        boxShadow: AppShadows.elevated,
                      ),
                      child: FloatingActionButton(
                        heroTag: 'create_question',
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        highlightElevation: 0,
                        onPressed: () => _openCreateQuestion(context),
                        child: const Icon(Icons.add),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const MyLocationButton(),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _openCreateQuestion(BuildContext context) {
    final mapState = context.read<MapBloc>().state;
    if (mapState is! MapLoaded) return;

    final lat = mapState.currentPosition.latitude;
    final lng = mapState.currentPosition.longitude;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => CreateQuestionBloc(
            createQuestion: sl<CreateQuestion>(),
            initialLatitude: lat,
            initialLongitude: lng,
          ),
          child: const CreateQuestionPage(),
        ),
      ),
    );
  }

  void _onStateChanged(BuildContext context, MapState state) {
    // LocationPermissionRequired and MapError are handled in the builder
    // as full-screen blocking views.
  }
}
