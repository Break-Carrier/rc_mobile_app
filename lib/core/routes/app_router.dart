import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/settings/presentation/pages/settings_screen.dart';
import '../../features/apiary/presentation/pages/apiaries_screen.dart';
import '../../features/apiary/presentation/pages/apiary_detail_screen.dart';
import '../../features/apiary/data/injection/apiary_injection.dart';
import '../../features/apiary/presentation/bloc/apiary_bloc.dart';
import '../../features/apiary/presentation/bloc/apiary_event.dart';
import '../../features/apiary/presentation/bloc/apiary_state.dart';
import '../../features/hive/presentation/pages/hives_screen.dart';
import '../../features/hive/presentation/pages/hive_detail_screen.dart';
import '../../features/hive/data/injection/hive_injection.dart';
import '../../features/hive/domain/usecases/get_hive_by_id.dart';
import '../../features/dashboard/presentation/pages/dashboard_screen.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/di/auth_injection.dart';

/// Configuration des routes de l'application
class AppRouter {
  /// Instance unique du routeur
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      // Vérifier l'état d'authentification
      final authBloc = AuthInjection.getAuthBloc();
      final authState = authBloc.state;

      final isOnLoginPage = state.uri.path == '/login';

      if (authState is AuthUnauthenticated || authState is AuthError) {
        return isOnLoginPage ? null : '/login';
      }

      if (authState is AuthAuthenticated && isOnLoginPage) {
        return '/';
      }

      return null; // Pas de redirection
    },
    routes: [
      // Route de connexion
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),

      // Route principale avec navigation imbriquée
      ShellRoute(
        builder: (context, state, child) {
          return ScaffoldWithBottomNavBar(child: child);
        },
        routes: [
          // Route de la page d'accueil (tableau de bord)
          GoRoute(
            path: '/',
            name: 'home',
            builder: (context, state) => const DashboardScreen(),
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
          // Route du détail d'un rucher
          GoRoute(
            path: '/apiary/:id/detail',
            name: 'apiary_detail',
            builder: (context, state) {
              final apiaryId = state.pathParameters['id']!;
              return _ApiaryDetailWrapper(apiaryId: apiaryId);
            },
          ),
          // Route du détail d'une ruche
          GoRoute(
            path: '/hive/:id/detail',
            name: 'hive_detail',
            builder: (context, state) {
              final hiveId = state.pathParameters['id']!;
              return _HiveDetailWrapper(hiveId: hiveId);
            },
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
        location.startsWith('/hive')) {
      return 1;
    }
    return 0;
  }
}

/// Wrapper pour récupérer l'Apiary par ID et afficher l'écran de détail
class _ApiaryDetailWrapper extends StatefulWidget {
  final String apiaryId;

  const _ApiaryDetailWrapper({required this.apiaryId});

  @override
  State<_ApiaryDetailWrapper> createState() => _ApiaryDetailWrapperState();
}

class _ApiaryDetailWrapperState extends State<_ApiaryDetailWrapper> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ApiaryInjection.getApiaryBloc()..add(LoadUserApiaries()),
      child: BlocBuilder<ApiaryBloc, ApiaryState>(
        builder: (context, state) {
          return switch (state) {
            ApiaryLoaded(apiaries: final apiaries) => () {
                final apiary =
                    apiaries.where((a) => a.id == widget.apiaryId).firstOrNull;

                if (apiary != null) {
                  return ApiaryDetailScreen(apiary: apiary);
                }

                return Scaffold(
                  appBar: AppBar(title: const Text('Rucher')),
                  body: const Center(
                    child: Text('Rucher non trouvé'),
                  ),
                );
              }(),
            ApiaryError(message: final message) => Scaffold(
                appBar: AppBar(title: const Text('Erreur')),
                body: Center(child: Text('Erreur: $message')),
              ),
            _ => Scaffold(
                appBar: AppBar(title: const Text('Rucher')),
                body: const Center(child: CircularProgressIndicator()),
              ),
          };
        },
      ),
    );
  }
}

/// Wrapper pour récupérer la Hive par ID et afficher l'écran de détail
class _HiveDetailWrapper extends StatefulWidget {
  final String hiveId;

  const _HiveDetailWrapper({required this.hiveId});

  @override
  State<_HiveDetailWrapper> createState() => _HiveDetailWrapperState();
}

class _HiveDetailWrapperState extends State<_HiveDetailWrapper> {
  late final GetHiveById _getHiveByIdUseCase;
  bool _isLoading = true;
  dynamic _hive;
  String? _error;

  @override
  void initState() {
    super.initState();
    _getHiveByIdUseCase = HiveInjection.getHiveByIdUseCase();
    _loadHive();
  }

  Future<void> _loadHive() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await _getHiveByIdUseCase(widget.hiveId);

    setState(() {
      _isLoading = false;
      if (result.error != null) {
        _error = result.error!.toString();
      } else {
        _hive = result.result;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Détails de la ruche')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Erreur')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Erreur: $_error'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _loadHive,
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    if (_hive == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Ruche non trouvée')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('Ruche non trouvée'),
            ],
          ),
        ),
      );
    }

    return HiveDetailScreen(hive: _hive);
  }
}
