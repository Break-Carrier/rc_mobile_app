import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_form.dart';

/// Page de connexion et d'inscription
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Authentification'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.failure.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is AuthAuthenticated) {
            // Navigation vers la page principale sera gérée par le routeur
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Connexion réussie !'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        child: const SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: AuthForm(),
          ),
        ),
      ),
    );
  }
}
