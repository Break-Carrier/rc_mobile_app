import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Écran principal d'administration
///
/// Responsabilité unique : Interface de gestion administrative
/// Accessible uniquement aux administrateurs
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administration'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // En-tête admin
          _buildAdminHeader(context),
          const SizedBox(height: 24),

          // Section Gestion des Utilisateurs
          _buildSection(
            context,
            '👥 Gestion des Utilisateurs',
            [
              _buildActionCard(
                context,
                icon: Icons.person_add,
                title: 'Créer un Apiculteur',
                subtitle: 'Ajouter un nouveau compte apiculteur',
                color: Colors.green,
                onTap: () => _navigateToCreateBeekeeper(context),
              ),
              const SizedBox(height: 12),
              _buildActionCard(
                context,
                icon: Icons.people,
                title: 'Gérer les Apiculteurs',
                subtitle: 'Voir et modifier les comptes existants',
                color: Colors.blue,
                onTap: () => _navigateToManageBeekeepers(context),
              ),
              const SizedBox(height: 12),
              _buildActionCard(
                context,
                icon: Icons.pending_actions,
                title: 'Validations en Attente',
                subtitle: 'Approuver ou rejeter les demandes',
                color: Colors.orange,
                onTap: () => _navigateToPendingValidations(context),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Section Système
          _buildSection(
            context,
            '⚙️ Système',
            [
              _buildActionCard(
                context,
                icon: Icons.delete_sweep,
                title: 'Profils Supprimés',
                subtitle: 'Gérer les comptes supprimés',
                color: Colors.red,
                onTap: () => _navigateToDeletedProfiles(context),
              ),
              const SizedBox(height: 12),
              _buildActionCard(
                context,
                icon: Icons.analytics,
                title: 'Statistiques',
                subtitle: 'Voir les métriques d\'utilisation',
                color: Colors.purple,
                onTap: () => _navigateToAnalytics(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdminHeader(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.admin_panel_settings,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              'Panneau d\'Administration',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Gérez les utilisateurs et le système de la ruche connectée',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // === Navigation ===
  void _navigateToCreateBeekeeper(BuildContext context) {
    context.push('/admin/create-beekeeper');
  }

  void _navigateToManageBeekeepers(BuildContext context) {
    context.push('/admin/beekeepers');
  }

  void _navigateToPendingValidations(BuildContext context) {
    context.push('/admin/pending-validations');
  }

  void _navigateToDeletedProfiles(BuildContext context) {
    context.push('/admin/deleted-profiles');
  }

  void _navigateToAnalytics(BuildContext context) {
    context.push('/admin/analytics');
  }
}
