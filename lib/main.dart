import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edupay_verify/core/theme/app_theme.dart';
import 'package:edupay_verify/core/services/storage_service.dart';
import 'package:edupay_verify/core/services/snackbar_service.dart';
import 'package:edupay_verify/core/services/connectivity_service.dart';
import 'package:edupay_verify/core/services/edupay_api_service.dart';
import 'package:edupay_verify/core/router/app_router.dart';
import 'package:edupay_verify/features/auth/providers/auth_provider.dart';
import 'package:edupay_verify/features/verification/providers/verification_provider.dart';
import 'package:edupay_verify/features/verification/presentation/bloc/verification_bloc.dart';
import 'package:edupay_verify/features/history/presentation/bloc/history_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget { 
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    final verificationService = ref.watch(verificationServiceProvider);
    final connectivityService = ref.watch(connectivityServiceProvider);
    final apiService = ref.watch(edupayApiServiceProvider);
    final authToken = ref.watch(
      authProvider.select((state) => state.admin?.authToken),
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider<VerificationBloc>(
          create: (context) => VerificationBloc(
            service: verificationService,
            connectivityService: connectivityService,
          ),
        ),
        BlocProvider<HistoryBloc>(
          create: (context) => HistoryBloc(
            apiService: apiService,
            readAuthToken: () => authToken,
          ),
        ),
      ],
      child: MaterialApp.router(
        title: 'Edupay Verification',
        theme: AppTheme.lightTheme,
        scaffoldMessengerKey: SnackbarService.scaffoldMessengerKey,
        debugShowCheckedModeBanner: false,
        routerConfig: router,
      ),
    );
  }
}
