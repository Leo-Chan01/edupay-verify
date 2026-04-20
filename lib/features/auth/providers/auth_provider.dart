import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edupay_verify/core/localization/app_strings.dart';
import 'package:edupay_verify/core/services/edupay_api_service.dart';
import 'package:edupay_verify/core/services/storage_service.dart';
import 'package:edupay_verify/features/auth/data/models/admin_model.dart';

class AuthState {
  final bool isLoggedIn;
  final AdminModel? admin;
  final bool isLoading;
  final String? errorMessage;

  AuthState({
    this.isLoggedIn = false,
    this.admin,
    this.isLoading = false,
    this.errorMessage,
  });

  AuthState copyWith({
    bool? isLoggedIn,
    AdminModel? admin,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      admin: admin ?? this.admin,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._apiService) : super(AuthState()) {
    checkSavedLogin();
  }

  final EduPayApiService _apiService;

  Future<void> checkSavedLogin() async {
    final savedAdmin = StorageService.getAdmin();
    if (savedAdmin != null) {
      try {
        final adminJson = jsonDecode(savedAdmin) as Map<String, dynamic>;
        final admin = AdminModel.fromJson(adminJson);

        if (admin.authToken == null || admin.authToken!.isEmpty) {
          await StorageService.removeAdmin();
          return;
        }

        state = state.copyWith(isLoggedIn: true, admin: admin);
      } catch (_) {
        await StorageService.removeAdmin();
      }
    }
  }

  Future<bool> login(String username, String password) async {
    if (username.trim().isEmpty || password.trim().isEmpty) {
      state = state.copyWith(errorMessage: AppStrings.pleaseEnterCredentials);
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final admin = await _apiService.adminLogin(
        email: username.trim(),
        password: password,
      );

      await StorageService.saveAdmin(jsonEncode(admin.toJson()));

      state = state.copyWith(isLoggedIn: true, admin: admin, isLoading: false);

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  Future<void> logout() async {
    await StorageService.removeAdmin();
    state = AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final apiService = ref.watch(edupayApiServiceProvider);
  return AuthNotifier(apiService);
});
