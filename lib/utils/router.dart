import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:keywarden/providers/auth_provider.dart';
import 'package:keywarden/screens/add_screen.dart';
import 'package:keywarden/screens/create_master_key.dart';
import 'package:keywarden/screens/home/home.dart';
import 'package:keywarden/screens/login.dart';
import 'package:keywarden/screens/settings.dart';
import 'package:keywarden/utils/encryption.dart';
import 'package:provider/provider.dart';

final router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => const CupertinoPage(child: Homescreen()),
      routes: [
        GoRoute(
          path: 'settings',
          pageBuilder: (context, state) => const CupertinoPage(
            child: SettingsScreen(),
          ),
        ),
        GoRoute(
            path: 'addScreen',
            pageBuilder: (context, state) {
              Map? extra = state.extra as Map?;
              return MaterialPage(
                child: AddScreen(
                  edit: extra?['edit'] ?? false,
                  id: extra?['id'] ?? false,
                ),
              );
            })
      ],
    ),
    GoRoute(
      path: '/createkey',
      pageBuilder: (context, state) =>
          const CupertinoPage(child: CreateMasterKey()),
    ),
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) => const CupertinoPage(child: Login()),
    ),
  ],
  redirect: (context, state) async {
    bool logged = context.read<AuthProvider>().logged;
    bool registered = await Preferences.getItem('masterKey') != null;

    if (!registered && state.path != '/createkey') {
      return '/createkey';
    }

    if (!logged && state.path != '/login') {
      return '/login';
    }

    return null;
  },
);
