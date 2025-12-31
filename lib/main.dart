import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edupay_verify/core/theme/app_theme.dart';
import 'package:edupay_verify/core/services/storage_service.dart';
import 'package:edupay_verify/core/services/snackbar_service.dart';
import 'package:edupay_verify/core/router/app_router.dart';

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

    return MaterialApp.router(
      title: 'EduPay Receipt Check',
      theme: AppTheme.lightTheme,
      scaffoldMessengerKey: SnackbarService.scaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
