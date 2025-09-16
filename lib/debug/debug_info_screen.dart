import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_database/firebase_database.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/presentation/bloc/auth_state.dart';
import '../features/alert/data/services/alert_test_service.dart';
import '../core/config/app_config.dart';

/// Écran de debug pour afficher les informations système
///
/// Utile pour récupérer l'UID Firebase et déboguer
class DebugInfoScreen extends StatelessWidget {
  const DebugInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Info'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAuthInfoCard(context, authState),
                const SizedBox(height: 16),
                _buildQuickActionsCard(context, authState),
                const SizedBox(height: 16),
                _buildAlertTestCard(context),
                const SizedBox(height: 16),
                _buildInstructionsCard(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAuthInfoCard(BuildContext context, AuthState authState) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🔐 Informations d\'Authentification',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            if (authState is AuthAuthenticated) ...[
              _buildInfoRow(
                context,
                'UID Firebase',
                authState.user.id,
                isCopiable: true,
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                context,
                'Email',
                authState.user.email,
                isCopiable: true,
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                context,
                'Nom d\'affichage',
                authState.user.displayName ?? 'Non défini',
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                context,
                'Date de création',
                authState.user.createdAt?.toString() ?? 'Non disponible',
              ),
            ] else if (authState is AuthUnauthenticated) ...[
              const Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange),
                  SizedBox(width: 8),
                  Text('Aucun utilisateur connecté'),
                ],
              ),
            ] else if (authState is AuthLoading) ...[
              const Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 16),
                  Text('Vérification de l\'authentification...'),
                ],
              ),
            ] else ...[
              const Row(
                children: [
                  Icon(Icons.error, color: Colors.red),
                  SizedBox(width: 8),
                  Text('État d\'authentification inconnu'),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsCard(BuildContext context, AuthState authState) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '⚡ Actions Rapides',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            if (authState is AuthAuthenticated) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () =>
                      _copyUidToClipboard(context, authState.user.id),
                  icon: const Icon(Icons.copy),
                  label: const Text('Copier UID Firebase'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () =>
                      _copyEmailToClipboard(context, authState.user.email),
                  icon: const Icon(Icons.email),
                  label: const Text('Copier Email'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/admin/management'),
                  icon: const Icon(Icons.admin_panel_settings),
                  label: const Text('Gestion Admins (Nouveau)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ] else ...[
              const Text(
                'Connectez-vous pour voir les actions disponibles',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionsCard(BuildContext context) {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📋 Instructions pour DevOps',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Pour devenir administrateur :',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.blue.shade800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '1. Cliquez sur "Gestion Admins" ci-dessous\n'
              '2. Cliquez sur "Me faire Admin"\n'
              '3. Votre UID sera automatiquement ajouté dans Firestore\n'
              '4. Retournez dans votre profil\n'
              '5. Le bouton admin apparaîtra automatiquement !',
              style: TextStyle(height: 1.4),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.green.shade600),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green.shade800),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      '✅ Aucun code à modifier ! Configuration stockée dans Firestore.',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertTestCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🧪 Test des Alertes',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Ajoutez des alertes de test pour vérifier le système d\'alertes :',
              style: TextStyle(height: 1.4),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _addTestAlerts(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Ajouter Alertes Test'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _clearTestAlerts(context),
                    icon: const Icon(Icons.clear),
                    label: const Text('Nettoyer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.blue.shade600),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue.shade800),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Les alertes de test seront ajoutées dans Firebase et visibles sur le dashboard.',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addTestAlerts(BuildContext context) async {
    try {
      final testService = AlertTestService(
        database: FirebaseDatabase.instance,
        basePath: AppConfig.firebaseBasePath,
      );

      await testService.addTestAlerts();

      if (context.mounted) {
        _showSnackBar(
          context,
          '✅ Alertes de test ajoutées ! Vérifiez le dashboard.',
          Colors.green,
        );
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(
          context,
          '❌ Erreur lors de l\'ajout des alertes de test: $e',
          Colors.red,
        );
      }
    }
  }

  Future<void> _clearTestAlerts(BuildContext context) async {
    try {
      final testService = AlertTestService(
        database: FirebaseDatabase.instance,
        basePath: AppConfig.firebaseBasePath,
      );

      await testService.clearTestAlerts();

      if (context.mounted) {
        _showSnackBar(
          context,
          '🧹 Alertes de test supprimées !',
          Colors.orange,
        );
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(
          context,
          '❌ Erreur lors de la suppression des alertes de test: $e',
          Colors.red,
        );
      }
    }
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value, {
    bool isCopiable = false,
  }) {
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
            onPressed: () => _copyToClipboard(context, value),
            icon: const Icon(Icons.copy, size: 16),
            tooltip: 'Copier',
          ),
        ],
      ],
    );
  }

  void _copyUidToClipboard(BuildContext context, String uid) {
    _copyToClipboard(context, uid);
    _showSnackBar(
      context,
      'UID copié ! Collez-le dans admin_verification_service.dart',
      Colors.green,
    );
  }

  void _copyEmailToClipboard(BuildContext context, String email) {
    _copyToClipboard(context, email);
    _showSnackBar(context, 'Email copié !', Colors.blue);
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
