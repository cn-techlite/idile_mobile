import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idile_mobile_app/app/router/routers.dart' as router;
import 'package:idile_mobile_app/app/router/route.dart';
import 'package:idile_mobile_app/core/services/globals.dart';
import 'package:idile_mobile_app/core/services/session_events.dart';
import 'package:idile_mobile_app/core/theme/app_theme.dart';
import 'package:idile_mobile_app/core/utils/size_config.dart';
import 'package:idile_mobile_app/shared/providers/connectivity_state.dart';
import 'package:idile_mobile_app/shared/providers/theme_state.dart';
import 'package:idile_mobile_app/shared/widgets/offline_banner.dart';
import 'package:upgrader/upgrader.dart';

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

class IdileApp extends ConsumerStatefulWidget {
  const IdileApp({required this.navigatorKey, super.key, this.initialRoute});

  final String? initialRoute;
  final GlobalKey<NavigatorState> navigatorKey;

  @override
  ConsumerState<IdileApp> createState() => _IdileAppState();
}

class _IdileAppState extends ConsumerState<IdileApp> {
  StreamSubscription<void>? _deviceRevokedSubscription;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(themeNotifierProvider.notifier).loadTheme(),
    );
    _deviceRevokedSubscription = SessionEvents.deviceRevoked.listen((_) async {
      await globals.init();
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.navigatorKey.currentState?.pushNamedAndRemoveUntil(
          RootRoutes.login,
          (_) => false,
        );
      });
    });
  }

  @override
  void dispose() {
    _deviceRevokedSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeNotifierProvider);
    ref.watch(connectivityStatusProviders);

    return LayoutBuilder(
      builder: (context, constraints) => OrientationBuilder(
        builder: (context, orientation) {
          SizeConfig.init(context);
          return MaterialApp(
            title: 'Ìdílé',
            debugShowCheckedModeBanner: false,
            navigatorKey: widget.navigatorKey,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: themeMode,
            navigatorObservers: [routeObserver],
            onGenerateRoute: router.generateRoute,
            initialRoute: widget.initialRoute,
            builder: (context, child) {
              final theme = Theme.of(context);
              final isDark = theme.brightness == Brightness.dark;
              final overlayStyle = isDark
                  ? SystemUiOverlayStyle.light
                  : SystemUiOverlayStyle.dark;

              return AnnotatedRegion<SystemUiOverlayStyle>(
                value: overlayStyle.copyWith(
                  statusBarColor: Colors.transparent,
                  statusBarBrightness: isDark
                      ? Brightness.dark
                      : Brightness.light,
                  statusBarIconBrightness: isDark
                      ? Brightness.light
                      : Brightness.dark,
                  systemNavigationBarColor: theme.scaffoldBackgroundColor,
                  systemNavigationBarDividerColor:
                      theme.scaffoldBackgroundColor,
                  systemNavigationBarIconBrightness: isDark
                      ? Brightness.light
                      : Brightness.dark,
                ),
                child: Stack(
                  children: [
                    UpgradeAlert(
                      showReleaseNotes: false,
                      dialogStyle: UpgradeDialogStyle.cupertino,
                      upgrader: Upgrader(),
                      child: child ?? const SizedBox.shrink(),
                    ),
                    const OfflineBanner(),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
