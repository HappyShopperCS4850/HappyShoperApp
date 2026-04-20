import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'routes.dart';
import 'screens/create_account_screen.dart';
import 'screens/list_detail_screen.dart';
import 'screens/lists_screen.dart';
import 'screens/profile_screen.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

class HappyShopperApp extends StatefulWidget {
  const HappyShopperApp({super.key});

  @override
  State<HappyShopperApp> createState() => _HappyShopperAppState();
}

class _HappyShopperAppState extends State<HappyShopperApp> {
  final AppState _appState = AppState();

  @override
  void initState() {
    super.initState();

    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      _appState.loadAllData();
    }

    Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
      final session = data.session;

      if (session != null) {
        await _appState.loadAllData();
      } else {
        _appState.clearLocalState();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppThemeData>(
      valueListenable: AppTheme.notifier,
      builder: (context, theme, _) {
        final baseTheme = ThemeData(
          useMaterial3: true,
          fontFamily: 'Roboto',
          scaffoldBackgroundColor: Colors.transparent,
        );

        return MaterialApp(
          title: 'HappyShopper',
          debugShowCheckedModeBanner: false,
          theme: baseTheme.copyWith(
            textTheme: baseTheme.textTheme.apply(
              bodyColor: theme.secondary,
              displayColor: theme.secondary,
            ),
            iconTheme: baseTheme.iconTheme.copyWith(color: Colors.white),
          ),
          initialRoute: Routes.createAccount,
          routes: {
            Routes.createAccount: (_) =>
                CreateAccountScreen(appState: _appState),
            Routes.lists: (_) => ListsScreen(appState: _appState),
            Routes.profile: (_) => ProfileScreen(appState: _appState),
            Routes.listDetail: (_) =>
                ListDetailScreen(appState: _appState, listId: ''),
          },
        );
      },
    );
  }
}
