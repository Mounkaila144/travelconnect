import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travelconnect_app/l10n/app_localizations.dart';
import 'package:travelconnect_app/core/theme/app_colors.dart';
import 'package:travelconnect_app/core/theme/app_theme.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/social_login_button.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.surfaceGradient,
        ),
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is Authenticated) {
              if (state.isNewUser || state.user.isNew) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/onboarding',
                  (route) => false,
                );
              } else {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/home',
                  (route) => false,
                );
              }
            } else if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // Logo icon in decorated circle container
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(25),
                      shape: BoxShape.circle,
                      boxShadow: AppShadows.elevated,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.flight_takeoff,
                      size: 100,
                      color: AppColors.primary,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  // App title
                  Text(
                    'TravelConnect',
                    style:
                        Theme.of(context).textTheme.displayMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // Subtitle
                  Text(
                    l10n.auth_connectToStart,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),

                  const Spacer(flex: 3),

                  // Social login buttons
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final isLoading = state is AuthLoading;
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SocialLoginButton(
                            label: l10n.auth_continueWithGoogle,
                            isLoading: isLoading,
                            icon: Image.network(
                              'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                              width: 24,
                              height: 24,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.g_mobiledata,
                                    size: 24);
                              },
                            ),
                            onPressed: () {
                              context.read<AuthBloc>().add(
                                    const SignInWithGoogleRequested(),
                                  );
                            },
                          ),
                          if (!kIsWeb &&
                              defaultTargetPlatform ==
                                  TargetPlatform.iOS) ...[
                            const SizedBox(height: AppSpacing.lg),
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: SignInWithAppleButton(
                                style: SignInWithAppleButtonStyle.black,
                                text: l10n.auth_continueWithApple,
                                onPressed: isLoading
                                    ? () {}
                                    : () {
                                        context.read<AuthBloc>().add(
                                              const SignInWithAppleRequested(),
                                            );
                                      },
                              ),
                            ),
                          ],
                        ],
                      );
                    },
                  ),

                  const Spacer(flex: 1),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
