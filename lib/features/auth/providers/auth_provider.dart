import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edupay_verify/core/services/storage_service.dart';
import 'package:edupay_verify/features/auth/models/admin_model.dart';

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
  AuthNotifier() : super(AuthState()) {
    checkSavedLogin();
  }

  Future<void> checkSavedLogin() async {
    final savedAdmin = StorageService.getAdmin();
    if (savedAdmin != null) {
      try {
        final adminJson = jsonDecode(savedAdmin) as Map<String, dynamic>;
        final admin = AdminModel.fromJson(adminJson);
        state = state.copyWith(
          isLoggedIn: true,
          admin: admin,
        );
      } catch (e) {
        await StorageService.removeAdmin();
      }
    }
  }

  Future<bool> login(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      state = state.copyWith(
        errorMessage: 'Please enter both username and password',
      );
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // Mock authentication - accept any credentials for demo
    final admin = AdminModel(
      id: 'ADM${DateTime.now().millisecondsSinceEpoch}',
      name: 'Admin User',
      username: username,
    );

    await StorageService.saveAdmin(jsonEncode(admin.toJson()));

    state = state.copyWith(
      isLoggedIn: true,
      admin: admin,
      isLoading: false,
    );

    return true;
  }

  Future<void> logout() async {
    await StorageService.removeAdmin();
    state = AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
