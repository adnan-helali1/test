import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:e_smart/app/router.dart';
import 'package:e_smart/core/storage/locale_preference.dart';
import 'package:e_smart/core/storage/token_store.dart';
import 'package:e_smart/core/theme/app_theme.dart';
import 'package:e_smart/core/widgets/custom_toast.dart';
import 'package:e_smart/core/widgets/splash_gate.dart';

class DarNasriApp extends ConsumerStatefulWidget {
  const DarNasriApp({super.key});

  @override
  ConsumerState<DarNasriApp> createState() => _DarNasriAppState();
}

class _DarNasriAppState extends ConsumerState<DarNasriApp> {
  var _ready = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _restore());
  }

  Future<void> _restore() async {
    await ref.read(localeProvider.notifier).restore();
    await ref.read(tokenProvider.notifier).restore();
    if (mounted) {
      setState(() => _ready = true);
      FlutterNativeSplash.remove();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const SplashGate();
    }
    final locale = ref.watch(localeProvider);
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      locale: locale,
      supportedLocales: const [Locale('ar'), Locale('en'), Locale('tr')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
      builder: (context, child) => ToastHost(child: child ?? const SizedBox.shrink()),
    );
  }
}
