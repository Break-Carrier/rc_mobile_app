import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../screens/home_screen.dart';
import '../../screens/hive_details_screen.dart';
import '../../screens/settings_screen.dart';
import '../../screens/sensor_readings_screen.dart';
import '../../screens/alerts_screen.dart';
import '../../screens/apiaries_screen.dart';
import '../../screens/hives_screen.dart';

/// Configuration des routes de l'application
class AppRouter {
  /// Instance unique du routeur
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      // Route principale avec navigation imbriquée
      ShellRoute(
        builder: (context, state, child) {
          return ScaffoldWithBottomNavBar(child: child);
        },
        routes: [
          // Route de la page d'accueil
          GoRoute(
            path: '/',
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
          // Route des ruchers
          GoRoute(
            path: '/apiaries',
            name: 'apiaries',
            builder: (context, state) => const ApiariesScreen(),
          ),
          // Route des ruches d'un rucher
          GoRoute(
            path: '/apiary/:id',
            name: 'apiary_details',
            builder: (context, state) {
              final apiaryId = state.pathParameters['id']!;
              return HivesScreen(apiaryId: apiaryId);
            },
          ),
          // Route des détails d'une ruche
          GoRoute(
            path: '/hive/:id',
            name: 'hive_details',
            builder: (context, state) {
              final hiveId = state.pathParameters['id']!;
              return HiveDetailsScreen(hiveId: hiveId);
            },
            routes: [
              // Sous-route pour les lectures des capteurs
              GoRoute(
                path: 'readings',
                name: 'hive_readings',
                builder: (context, state) {
                  final hiveId = state.pathParameters['id']!;
                  return SensorReadingsScreen(hiveId: hiveId);
                },
              ),
              // Sous-route pour les alertes
              GoRoute(
                path: 'alerts',
                name: 'hive_alerts',
                builder: (context, state) {
                  final hiveId = state.pathParameters['id']!;
                  return AlertsScreen(hiveId: hiveId);
                },
              ),
            ],
          ),
          // Route des paramètres
          GoRoute(
            path: '/settings',
            name: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page non trouvée: ${state.error}'),
      ),
    ),
  );
}

/// Widget de base avec la barre de navigation
class ScaffoldWithBottomNavBar extends StatelessWidget {
  final Widget child;

  const ScaffoldWithBottomNavBar({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go('/');
              break;
            case 1:
              context.go('/apiaries');
              break;
            case 2:
              context.go('/alerts');
              break;
            case 3:
              context.go('/settings');
              break;
          }
        },
        selectedIndex: _calculateSelectedIndex(context),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Tableau de bord',
          ),
          NavigationDestination(
            icon: Icon(Icons.hive_outlined),
            selectedIcon: Icon(Icons.hive),
            label: 'Ruchers',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications),
            label: 'Alertes',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Paramètres',
          ),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/settings')) return 3;
    if (location.startsWith('/alerts')) return 2;
    if (location.startsWith('/apiaries') ||
        location.startsWith('/apiary') ||
        location.startsWith('/hive')) return 1;
    return 0;
  }
}
