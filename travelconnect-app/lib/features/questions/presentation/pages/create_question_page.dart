import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travelconnect_app/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../map/presentation/bloc/map_bloc.dart';
import '../../../map/presentation/bloc/map_event.dart' as map_events;
import '../bloc/create_question_bloc.dart';
import '../bloc/create_question_event.dart';
import '../bloc/create_question_state.dart';
import '../widgets/location_picker_widget.dart';

class CreateQuestionPage extends StatefulWidget {
  const CreateQuestionPage({super.key});

  @override
  State<CreateQuestionPage> createState() => _CreateQuestionPageState();
}

class _CreateQuestionPageState extends State<CreateQuestionPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.createQuestion_title),
      ),
      body: BlocConsumer<CreateQuestionBloc, CreateQuestionState>(
        listener: _onStateChanged,
        builder: (context, state) {
          final isSubmitting = state is CreateQuestionSubmitting;

          String? titleError;
          String? descriptionError;
          double latitude = 0;
          double longitude = 0;

          if (state is CreateQuestionFormEditing) {
            titleError = state.titleError;
            descriptionError = state.descriptionError;
            latitude = state.latitude;
            longitude = state.longitude;
          }

          final bool isValid;
          if (state is CreateQuestionFormEditing) {
            isValid = state.isValid;
          } else {
            isValid = false;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title field
                TextField(
                  controller: _titleController,
                  enabled: !isSubmitting,
                  maxLength: 100,
                  decoration: InputDecoration(
                    labelText: l10n.createQuestion_titleLabel,
                    hintText: l10n.createQuestion_titleHint,
                    errorText: titleError,
                  ),
                  onChanged: (value) {
                    context
                        .read<CreateQuestionBloc>()
                        .add(TitleChanged(value));
                  },
                ),
                const SizedBox(height: AppSpacing.lg),

                // Description field
                TextField(
                  controller: _descriptionController,
                  enabled: !isSubmitting,
                  maxLength: 500,
                  maxLines: 3,
                  minLines: 3,
                  decoration: InputDecoration(
                    labelText: l10n.createQuestion_description,
                    hintText: l10n.createQuestion_descriptionHint,
                    errorText: descriptionError,
                  ),
                  onChanged: (value) {
                    context
                        .read<CreateQuestionBloc>()
                        .add(DescriptionChanged(value));
                  },
                ),
                const SizedBox(height: AppSpacing.lg),

                // Location section
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceWhite,
                    borderRadius: AppRadius.lgAll,
                    border: Border.all(
                      color: AppColors.borderLight,
                      width: 0.5,
                    ),
                    boxShadow: AppShadows.subtle,
                  ),
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withAlpha(25),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.location_on,
                              color: AppColors.accent,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Text(
                              latitude != 0
                                  ? '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}'
                                  : l10n.createQuestion_currentLocation,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      OutlinedButton.icon(
                        onPressed: isSubmitting
                            ? null
                            : () => _openLocationPicker(
                                context, latitude, longitude),
                        icon: const Icon(Icons.edit_location_alt),
                        label: Text(l10n.createQuestion_adjustLocation),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Submit button
                Container(
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: isValid && !isSubmitting
                        ? AppColors.primaryGradient
                        : null,
                    color: isValid && !isSubmitting
                        ? null
                        : AppColors.surfaceDim,
                    borderRadius: AppRadius.mdAll,
                  ),
                  child: ElevatedButton(
                    onPressed: isValid && !isSubmitting
                        ? () {
                            context
                                .read<CreateQuestionBloc>()
                                .add(const SubmitQuestion());
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      disabledBackgroundColor: Colors.transparent,
                      disabledForegroundColor: AppColors.textTertiary,
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.mdAll,
                      ),
                    ),
                    child: isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.textOnPrimary,
                            ),
                          )
                        : Text(
                            l10n.createQuestion_publish,
                            style: TextStyle(
                              color: isValid
                                  ? AppColors.textOnPrimary
                                  : AppColors.textTertiary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _onStateChanged(BuildContext context, CreateQuestionState state) {
    final l10n = AppLocalizations.of(context)!;

    if (state is CreateQuestionSuccess) {
      _addQuestionToMap(context, state);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.createQuestion_success),
          backgroundColor: AppColors.success,
        ),
      );

      Navigator.pop(context);
    } else if (state is CreateQuestionError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: AppColors.error,
        ),
      );

      // Re-emit form state so user can retry
      context.read<CreateQuestionBloc>().add(
            TitleChanged(_titleController.text),
          );
    }
  }

  void _addQuestionToMap(BuildContext context, CreateQuestionSuccess state) {
    try {
      final mapBloc = context.read<MapBloc>();
      mapBloc.add(map_events.AddQuestionToMap(state.question));
    } catch (_) {
      // MapBloc might not be in context if navigated away
    }
  }

  void _openLocationPicker(
    BuildContext context,
    double latitude,
    double longitude,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LocationPickerWidget(
          initialLatitude: latitude,
          initialLongitude: longitude,
          onLocationSelected: (latLng) {
            context.read<CreateQuestionBloc>().add(
                  LocationChanged(latLng.latitude, latLng.longitude),
                );
          },
        ),
      ),
    );
  }
}
