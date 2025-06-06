import 'package:flutter/material.dart';
import '../../../user_profile/domain/entities/user_profile_entity.dart';
import '../../../user_profile/domain/entities/user_role_entity.dart';

/// Écran d'administration pour gérer les profils supprimés
///
/// Permet aux administrateurs de consulter, filtrer et restaurer
/// les profils utilisateur supprimés logiquement.
class DeletedProfilesScreen extends StatefulWidget {
  const DeletedProfilesScreen({super.key});

  @override
  State<DeletedProfilesScreen> createState() => _DeletedProfilesScreenState();
}

class _DeletedProfilesScreenState extends State<DeletedProfilesScreen> {
  bool _includeExpired = false;
  Duration? _maxAge = const Duration(days: 30);
  String?
      _searchQuery; // TODO: Implémenter la logique de filtrage par recherche

  @override
  void initState() {
    super.initState();
    _loadDeletedProfiles();
  }

  void _loadDeletedProfiles() {
    // context.read<AdminBloc>().add(LoadDeletedProfiles(
    //   includeExpired: _includeExpired,
    //   maxAge: _maxAge,
    // ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profils supprimés'),
        actions: [
          IconButton(
            onPressed: _showFilterDialog,
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filtrer',
          ),
          IconButton(
            onPressed: _loadDeletedProfiles,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche
          _buildSearchBar(),

          // Statistiques rapides
          _buildStatsBar(),

          // Liste des profils supprimés
          Expanded(
            child: _buildProfilesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        decoration: const InputDecoration(
          hintText: 'Rechercher par nom, email...',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value.isEmpty ? null : value;
          });
        },
      ),
    );
  }

  Widget _buildStatsBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.3),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          _buildStatChip(
            icon: Icons.delete_outline,
            label: 'Total supprimés',
            value: '24', // Placeholder
            color: Colors.orange,
          ),
          const SizedBox(width: 12),
          _buildStatChip(
            icon: Icons.restore,
            label: 'Restaurables',
            value: '18', // Placeholder
            color: Colors.green,
          ),
          const SizedBox(width: 12),
          _buildStatChip(
            icon: Icons.warning,
            label: 'Expirés',
            value: '6', // Placeholder
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            '$value $label',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfilesList() {
    // Placeholder - à remplacer par BlocBuilder
    return _buildPlaceholderList();
  }

  Widget _buildPlaceholderList() {
    // Données de test pour l'exemple
    final mockProfiles = _generateMockDeletedProfiles();

    if (mockProfiles.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async => _loadDeletedProfiles(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: mockProfiles.length,
        itemBuilder: (context, index) {
          final profile = mockProfiles[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: DeletedProfileCard(
              profile: profile,
              onRestore: () => _showRestoreDialog(profile),
              onViewDetails: () => _showProfileDetails(profile),
              onViewAuditLog: () => _showAuditLog(profile),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.delete_sweep_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun profil supprimé',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Tous les profils utilisateur sont actifs',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtres'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Inclure les suppressions expirées'),
              subtitle: const Text('Profils supprimés depuis plus de 30 jours'),
              value: _includeExpired,
              onChanged: (value) {
                setState(() {
                  _includeExpired = value;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Duration?>(
              decoration: const InputDecoration(
                labelText: 'Période maximale',
                border: OutlineInputBorder(),
              ),
              value: _maxAge,
              items: const [
                DropdownMenuItem(
                  value: Duration(days: 7),
                  child: Text('7 derniers jours'),
                ),
                DropdownMenuItem(
                  value: Duration(days: 30),
                  child: Text('30 derniers jours'),
                ),
                DropdownMenuItem(
                  value: Duration(days: 90),
                  child: Text('90 derniers jours'),
                ),
                DropdownMenuItem(
                  value: null,
                  child: Text('Toutes les périodes'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _maxAge = value;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _loadDeletedProfiles();
            },
            child: const Text('Appliquer'),
          ),
        ],
      ),
    );
  }

  void _showRestoreDialog(UserProfileEntity profile) {
    showDialog(
      context: context,
      builder: (context) => RestoreConfirmationDialog(
        profile: profile,
        onConfirm: (reason) => _restoreProfile(profile, reason),
      ),
    );
  }

  void _showProfileDetails(UserProfileEntity profile) {
    Navigator.pushNamed(
      context,
      '/admin/profile-details',
      arguments: profile,
    );
  }

  void _showAuditLog(UserProfileEntity profile) {
    Navigator.pushNamed(
      context,
      '/admin/audit-log',
      arguments: {
        'entityType': 'UserProfile',
        'entityId': profile.userId,
      },
    );
  }

  void _restoreProfile(UserProfileEntity profile, String reason) {
    // context.read<AdminBloc>().add(RestoreUserProfile(
    //   userId: profile.userId,
    //   reason: reason,
    // ));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Restauration de ${profile.fullName} en cours...'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Génération de données de test
  List<UserProfileEntity> _generateMockDeletedProfiles() {
    return [
      // Exemples de profils supprimés pour la démonstration
      UserProfileEntity(
        userId: 'user1',
        firstName: 'Jean',
        lastName: 'Dupont',
        email: 'jean.dupont@example.com',
        address: '123 Rue de la Paix',
        role: UserRoleEntity(
          roleType: UserRoleType.beekeeper,
          assignedAt: DateTime.now().subtract(const Duration(days: 30)),
        ),
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
        isDeleted: true,
        deletedAt: DateTime.now().subtract(const Duration(days: 5)),
        deletedBy: 'admin1',
        deletionReason: 'Demande de suppression de compte utilisateur',
      ),
      UserProfileEntity(
        userId: 'user2',
        firstName: 'Marie',
        lastName: 'Martin',
        email: 'marie.martin@example.com',
        address: '456 Avenue des Fleurs',
        role: UserRoleEntity(
          roleType: UserRoleType.pendingBeekeeper,
          assignedAt: DateTime.now().subtract(const Duration(days: 15)),
        ),
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
        updatedAt: DateTime.now().subtract(const Duration(days: 10)),
        isDeleted: true,
        deletedAt: DateTime.now().subtract(const Duration(days: 10)),
        deletedBy: 'admin1',
        deletionReason: 'Profil incomplet abandonné depuis plus de 30 jours',
      ),
    ];
  }
}

// Widgets placeholder
class DeletedProfileCard extends StatelessWidget {
  final UserProfileEntity profile;
  final VoidCallback onRestore;
  final VoidCallback onViewDetails;
  final VoidCallback onViewAuditLog;

  const DeletedProfileCard({
    super.key,
    required this.profile,
    required this.onRestore,
    required this.onViewDetails,
    required this.onViewAuditLog,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  child: Text(profile.firstName[0]),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.fullName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(profile.email),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Supprimé: ${_formatDate(profile.deletedAt!)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              'Raison: ${profile.deletionReason}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: onRestore,
                  icon: const Icon(Icons.restore),
                  label: const Text('Restaurer'),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: onViewDetails,
                  child: const Text('Détails'),
                ),
                TextButton(
                  onPressed: onViewAuditLog,
                  child: const Text('Historique'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class RestoreConfirmationDialog extends StatelessWidget {
  final UserProfileEntity profile;
  final Function(String reason) onConfirm;

  const RestoreConfirmationDialog({
    super.key,
    required this.profile,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final reasonController = TextEditingController();

    return AlertDialog(
      title: const Text('Confirmer la restauration'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Restaurer le profil de ${profile.fullName} ?'),
          const SizedBox(height: 16),
          TextField(
            controller: reasonController,
            decoration: const InputDecoration(
              labelText: 'Raison de la restauration',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () {
            if (reasonController.text.trim().isNotEmpty) {
              Navigator.pop(context);
              onConfirm(reasonController.text.trim());
            }
          },
          child: const Text('Restaurer'),
        ),
      ],
    );
  }
}
