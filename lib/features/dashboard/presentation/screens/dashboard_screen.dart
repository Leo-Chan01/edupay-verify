import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:edupay_verify/core/localization/app_strings.dart';
import 'package:edupay_verify/core/services/connectivity_service.dart';
import 'package:edupay_verify/shared/widgets/status_indicator.dart';
import 'package:edupay_verify/features/auth/providers/auth_provider.dart';
import 'package:edupay_verify/core/services/snackbar_service.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;

  const DashboardScreen({
    super.key,
    required this.navigationShell,
  });

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _hasShownOfflineMessage = false;

  void _onNavigationTap(int index) {
    if (index == 3) {
      // Logout
      ref.read(authProvider.notifier).logout();
      SnackbarService.showSuccess(AppStrings.loggedOut);
    } else {
      widget.navigationShell.goBranch(
        index,
        initialLocation: index == widget.navigationShell.currentIndex,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final connectivityAsync = ref.watch(connectivityStreamProvider);
    
    final isOnline = connectivityAsync.when(
      data: (online) {
        if (!online && !_hasShownOfflineMessage) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            SnackbarService.showWarning(AppStrings.workingOffline);
            _hasShownOfflineMessage = true;
          });
        } else if (online) {
          _hasShownOfflineMessage = false;
        }
        return online;
      },
      loading: () => true,
      error: (_, __) => false,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appTitle),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: StatusIndicator(
              isOnline: isOnline,
              statusText: isOnline ? AppStrings.online : AppStrings.offline,
            ),
          ),
        ],
      ),
      body: widget.navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: widget.navigationShell.currentIndex,
        onTap: _onNavigationTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(HugeIcons.strokeRoundedHome01),
            label: AppStrings.home,
          ),
          BottomNavigationBarItem(
            icon: Icon(HugeIcons.strokeRoundedDatabase),
            label: AppStrings.offlineManagement,
          ),
          BottomNavigationBarItem(
            icon: Icon(HugeIcons.strokeRoundedClock03),
            label: AppStrings.history,
          ),
          BottomNavigationBarItem(
            icon: Icon(HugeIcons.strokeRoundedLogout02),
            label: AppStrings.logout,
          ),
        ],
      ),
    );
  }
}
