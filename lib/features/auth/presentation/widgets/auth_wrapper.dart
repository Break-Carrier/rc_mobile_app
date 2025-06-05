import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../pages/login_page.dart';
import '../../../../screens/main_screen.dart';

/// Widget wrapper qui gère l'authentification obligatoire
///
/// Vérifie l'état d'authentification et redirige :
/// - Vers LoginPage si non authentifié
/// - Vers MainScreen avec navigation si authentifié
/// - Affiche un loading pendant la vérification
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return switch (state) {
          // État initial - Vérification en cours
          AuthInitial() => const _LoadingScreen(),

          // Chargement de l'authentification
          AuthLoading() => const _LoadingScreen(),

          // Utilisateur authentifié - Accès à l'application principale
          AuthAuthenticated() => const MainScreen(),

          // Utilisateur non authentifié - Redirection login
          AuthUnauthenticated() => const LoginPage(),

          // Erreur d'authentification - Retour au login avec message
          AuthError() => LoginPage(
              initialErrorMessage: state.failure.message,
            ),

          // Autres états - Retour au login
          _ => const LoginPage(),
        };
      },
    );
  }
}

/// Écran de chargement pendant la vérification d'authentification
class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo ou icon de l'application
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.hive,
                size: 60,
                color: Colors.amber,
              ),
            ),

            const SizedBox(height: 40),

            // Titre de l'application
            const Text(
              'Ruche Connectée',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Monitoring IoT pour apiculteurs',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),

            const SizedBox(height: 50),

            // Indicateur de chargement
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3,
            ),

            const SizedBox(height: 20),

            const Text(
              'Vérification de l\'authentification...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
