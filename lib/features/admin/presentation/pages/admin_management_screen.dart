import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/admin_role_bloc.dart';
import '../bloc/admin_role_event.dart';
import '../bloc/admin_role_state.dart';

/// Écran de gestion des administrateurs
///
/// Remplace l'écran de debug par une interface professionnelle
class AdminManagementScreen extends StatefulWidget {
  const AdminManagementScreen({super.key});

  @override
  State<AdminManagementScreen> createState() => _AdminManagementScreenState();
}

class _AdminManagementScreenState extends State<AdminManagementScreen> {
  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }

  void _checkAdminStatus() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<AdminRoleBloc>().add(
            CheckAdminStatus(userId: authState.user.id),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Administrateurs'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (authState is! AuthAuthenticated) {
            return _buildUnauthenticatedView();
          }

          return _buildAuthenticatedView(authState.user);
        },
      ),
    );
  }

  Widget _buildUnauthenticatedView() {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'Authentification requise',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              const Text(
                'Vous devez être connecté pour accéder à cette section.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuthenticatedView(dynamic user) {
    return BlocBuilder<AdminRoleBloc, AdminRoleState>(
      builder: (context, adminState) {
        return RefreshIndicator(
          onRefresh: () async => _checkAdminStatus(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildUserInfoCard(user),
                const SizedBox(height: 16),
                _buildAdminStatusCard(adminState, user),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserInfoCard(dynamic user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '👤 Utilisateur Connecté',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('UID Firebase', user.id, isCopiable: true),
            const SizedBox(height: 8),
            _buildInfoRow('Email', user.email, isCopiable: true),
            const SizedBox(height: 8),
            _buildInfoRow(
              'Nom d\'affichage',
              user.displayName ?? 'Non défini',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isCopiable = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontFamily: isCopiable ? 'monospace' : null,
              fontSize: isCopiable ? 12 : null,
            ),
          ),
        ),
        if (isCopiable) ...[
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => _copyToClipboard(value),
            icon: const Icon(Icons.copy, size: 16),
            tooltip: 'Copier',
          ),
        ],
      ],
    );
  }

  Widget _buildAdminStatusCard(AdminRoleState state, dynamic user) {
    if (state is AdminRoleLoading) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 16),
              const Text('Vérification du statut administrateur...'),
            ],
          ),
        ),
      );
    }

    if (state is AdminRoleError) {
      return Card(
        color: Colors.red.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.error, color: Colors.red.shade700),
                  const SizedBox(width: 8),
                  const Text('Erreur'),
                ],
              ),
              const SizedBox(height: 8),
              Text(state.message),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _checkAdminStatus,
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    if (state is AdminRoleLoaded) {
      return _buildStatusCard(state, user);
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Vérification du statut...'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _checkAdminStatus,
              child: const Text('Vérifier'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(AdminRoleLoaded state, dynamic user) {
    final isAdmin = state.isCurrentUserAdmin;
    final hasAdmins = state.hasAnyAdmins;

    return Card(
      color: isAdmin ? Colors.green.shade50 : Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  isAdmin ? Icons.admin_panel_settings : Icons.person,
                  color: isAdmin ? Colors.green : Colors.blue,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAdmin ? 'Administrateur' : 'Utilisateur Standard',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isAdmin ? Colors.green : Colors.blue,
                                ),
                      ),
                      Text(
                        isAdmin
                            ? 'Vous avez les privilèges administrateur'
                            : 'Vous êtes un utilisateur standard',
                        style: TextStyle(
                          color: isAdmin
                              ? Colors.green.shade700
                              : Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (!hasAdmins) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange.shade700),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Aucun administrateur dans le système',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            if (!isAdmin && !hasAdmins)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _bootstrapFirstAdmin(user),
                  icon: const Icon(Icons.admin_panel_settings),
                  label: const Text('Devenir le Premier Admin'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _checkAdminStatus,
                icon: const Icon(Icons.refresh),
                label: const Text('Actualiser le statut'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isAdmin ? Colors.green : Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _bootstrapFirstAdmin(dynamic user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Devenir Administrateur'),
        content: const Text(
          'Voulez-vous vraiment devenir le premier administrateur ?\n\n'
          'Cette action vous donnera tous les privilèges admin.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AdminRoleBloc>().add(
                    BootstrapFirstAdmin(user: user),
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(String text) {
    // TODO: Implémenter la copie dans le presse-papier
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$text copié !')),
    );
  }
}
