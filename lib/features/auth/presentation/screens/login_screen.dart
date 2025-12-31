import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:edupay_verify/core/localization/app_strings.dart';
import 'package:edupay_verify/shared/widgets/app_button.dart';
import 'package:edupay_verify/shared/widgets/app_text_field.dart';
import 'package:edupay_verify/features/auth/providers/auth_provider.dart';
import 'package:edupay_verify/core/services/snackbar_service.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final success = await ref.read(authProvider.notifier).login(
          _usernameController.text,
          _passwordController.text,
        );

    if (!mounted) return;

    if (success) {
      SnackbarService.showSuccess(AppStrings.loginSuccessful);
    } else {
      final errorMessage = ref.read(authProvider).errorMessage;
      if (errorMessage != null) {
        SnackbarService.showError(errorMessage);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        HugeIcons.strokeRoundedUserShield02,
                        size: 64,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        AppStrings.adminLogin,
                        style: textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppStrings.verifyReceiptAuth,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 28),
                      AppTextField(
                        label: AppStrings.username,
                        controller: _usernameController,
                        keyboardType: TextInputType.text,
                      ),
                      const SizedBox(height: 20),
                      AppTextField(
                        label: AppStrings.password,
                        controller: _passwordController,
                        obscureText: true,
                        showPasswordToggle: true,
                        onSubmitted: (_) => _handleLogin(),
                      ),
                      const SizedBox(height: 8),
                      AppButton(
                        text: authState.isLoading
                            ? AppStrings.signingIn
                            : AppStrings.signIn,
                        onPressed: _handleLogin,
                        isLoading: authState.isLoading,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
