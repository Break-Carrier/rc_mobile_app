import 'package:flutter/material.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/entities/beekeeper_details_entity.dart';
import '../../domain/entities/user_role_entity.dart';

/// Écran de profil utilisateur simplifié
///
/// Version fonctionnelle sans BLoC pour démonstration
/// de l'intégration du soft delete.
class ProfileScreenSimple extends StatefulWidget {
  const ProfileScreenSimple({super.key});

  @override
  State<ProfileScreenSimple> createState() => _ProfileScreenSimpleState();
}

class _ProfileScreenSimpleState extends State<ProfileScreenSimple> {
  UserProfileEntity? _currentProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
    });

    // Simulation du chargement avec données de test
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _currentProfile = _generateMockProfile();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
        actions: [
          if (_currentProfile?.canManageUsers == true)
            IconButton(
              onPressed: () => _navigateToAdminPanel(context),
              icon: const Icon(Icons.admin_panel_settings),
              tooltip: 'Panneau d\'administration',
            ),
          IconButton(
            onPressed: () => _navigateToEditProfile(context),
            icon: const Icon(Icons.edit),
            tooltip: 'Modifier le profil',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _currentProfile == null
              ? _buildErrorWidget()
              : _buildProfileContent(_currentProfile!),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Erreur lors du chargement du profil',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadProfile,
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent(UserProfileEntity profile) {
    return RefreshIndicator(
      onRefresh: _loadProfile,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec photo et infos de base
            _buildProfileHeader(profile),

            const SizedBox(height: 24),

            // Badge de rôle
            _buildRoleBadge(profile.role),

            const SizedBox(height: 24),

            // Informations personnelles
            _buildProfileInfoCard(
              title: 'Informations personnelles',
              items: [
                _buildInfoItem('Nom complet', profile.fullName, Icons.person),
                _buildInfoItem('Email', profile.email, Icons.email),
                _buildInfoItem('Téléphone',
                    profile.phoneNumber ?? 'Non renseigné', Icons.phone),
                _buildInfoItem(
                    'Adresse', profile.fullAddress, Icons.location_on),
              ],
            ),

            const SizedBox(height: 16),

            // Informations spécifiques apiculteur
            if (profile.beekeeperDetails != null) ...[
              _buildBeekeeperDetails(profile.beekeeperDetails!),
              const SizedBox(height: 16),
            ],

            // Actions disponibles selon le rôle
            _buildRoleBasedActions(context, profile),

            const SizedBox(height: 24),

            // Statut du compte
            _buildAccountStatus(profile),

            const SizedBox(height: 24),

            // Informations de soft delete si supprimé
            if (profile.isDeleted) _buildSoftDeleteInfo(profile),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(UserProfileEntity profile) {
    return Row(
      children: [
        // Photo de profil
        CircleAvatar(
          radius: 40,
          backgroundImage: profile.profileImageUrl != null
              ? NetworkImage(profile.profileImageUrl!)
              : null,
          child: profile.profileImageUrl == null
              ? Text(
                  profile.firstName.isNotEmpty
                      ? profile.firstName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                )
              : null,
        ),

        const SizedBox(width: 16),

        // Nom et email
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile.fullName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                profile.email,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRoleBadge(UserRoleEntity role) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).primaryColor),
      ),
      child: Text(
        role.roleType.displayName,
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildProfileInfoCard({
    required String title,
    required List<Widget> items,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            ...items,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBeekeeperDetails(BeekeeperDetailsEntity details) {
    return _buildProfileInfoCard(
      title: 'Informations apiculteur',
      items: [
        if (details.beekeeperId != null)
          _buildInfoItem('N° Apiculteur', details.beekeeperId!, Icons.badge),
        _buildInfoItem('Type d\'apiculture', details.beekeepingType.displayName,
            Icons.category),
        if (details.yearsOfExperience != null)
          _buildInfoItem('Années d\'expérience',
              '${details.yearsOfExperience} ans', Icons.timeline),
        _buildInfoItem(
            'Nombre de ruches', '${details.totalHives}', Icons.home_work),
        if (details.annualProduction != null)
          _buildInfoItem(
              'Production annuelle',
              '${details.annualProduction!.toStringAsFixed(1)} kg',
              Icons.production_quantity_limits),
      ],
    );
  }

  Widget _buildRoleBasedActions(
      BuildContext context, UserProfileEntity profile) {
    final actions = <Widget>[];

    if (profile.isAdmin) {
      actions.addAll([
        ListTile(
          leading: const Icon(Icons.group),
          title: const Text('Gérer les apiculteurs'),
          subtitle: const Text('Créer et valider les comptes apiculteurs'),
          onTap: () => _navigateToBeekeeperManagement(context),
        ),
        ListTile(
          leading: const Icon(Icons.pending),
          title: const Text('Validations en attente'),
          subtitle: const Text('Approuver ou rejeter les nouvelles demandes'),
          onTap: () => _navigateToPendingValidations(context),
        ),
        ListTile(
          leading: const Icon(Icons.delete_sweep),
          title: const Text('Profils supprimés'),
          subtitle: const Text('Gérer les profils supprimés logiquement'),
          onTap: () => _navigateToDeletedProfiles(context),
        ),
      ]);
    }

    if (profile.canAccessBeekeepingFeatures) {
      actions.addAll([
        ListTile(
          leading: const Icon(Icons.dashboard),
          title: const Text('Tableau de bord'),
          subtitle: const Text('Vue d\'ensemble de vos ruches'),
          onTap: () => _navigateToDashboard(context),
        ),
        ListTile(
          leading: const Icon(Icons.home_work),
          title: const Text('Mes ruchers'),
          subtitle: const Text('Gérer vos ruchers et ruches'),
          onTap: () => _navigateToApiaries(context),
        ),
      ]);
    }

    if (actions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Actions disponibles',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          ...actions,
        ],
      ),
    );
  }

  Widget _buildAccountStatus(UserProfileEntity profile) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statut du compte',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  profile.isActive ? Icons.check_circle : Icons.cancel,
                  color: profile.isActive ? Colors.green : Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(profile.isActive ? 'Compte actif' : 'Compte désactivé'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  profile.isEmailVerified ? Icons.verified : Icons.warning,
                  color: profile.isEmailVerified ? Colors.green : Colors.orange,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(profile.isEmailVerified
                    ? 'Email vérifié'
                    : 'Email non vérifié'),
              ],
            ),
            if (profile.isPendingValidation) ...[
              const SizedBox(height: 8),
              const Row(
                children: [
                  Icon(
                    Icons.hourglass_empty,
                    color: Colors.orange,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text('En attente de validation'),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSoftDeleteInfo(UserProfileEntity profile) {
    return Card(
      color: Colors.red.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.delete_outline, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  'Profil supprimé',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Supprimé le: ${_formatDate(profile.deletedAt!)}'),
            if (profile.deletedBy != null) Text('Par: ${profile.deletedBy}'),
            if (profile.deletionReason != null)
              Text('Raison: ${profile.deletionReason}'),
            const SizedBox(height: 12),
            if (profile.canBeRestored)
              ElevatedButton.icon(
                onPressed: () => _showRestoreRequest(profile),
                icon: const Icon(Icons.restore),
                label: const Text('Demander la restauration'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} à ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showRestoreRequest(UserProfileEntity profile) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Demande de restauration'),
        content: const Text(
            'Voulez-vous envoyer une demande de restauration de votre profil à l\'administration ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Demande de restauration envoyée'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );
  }

  // Méthodes de navigation
  void _navigateToEditProfile(BuildContext context) {
    Navigator.pushNamed(context, '/profile/edit');
  }

  void _navigateToAdminPanel(BuildContext context) {
    Navigator.pushNamed(context, '/admin');
  }

  void _navigateToBeekeeperManagement(BuildContext context) {
    Navigator.pushNamed(context, '/admin/beekeepers');
  }

  void _navigateToPendingValidations(BuildContext context) {
    Navigator.pushNamed(context, '/admin/pending');
  }

  void _navigateToDeletedProfiles(BuildContext context) {
    Navigator.pushNamed(context, '/admin/deleted-profiles');
  }

  void _navigateToDashboard(BuildContext context) {
    Navigator.pushNamed(context, '/dashboard');
  }

  void _navigateToApiaries(BuildContext context) {
    Navigator.pushNamed(context, '/apiaries');
  }

  // Génération de données de test
  UserProfileEntity _generateMockProfile() {
    return UserProfileEntity(
      userId: 'current_user_id',
      firstName: 'Jean',
      lastName: 'Dupont',
      email: 'jean.dupont@example.com',
      address: '123 Rue de la Paix',
      city: 'Paris',
      postalCode: '75001',
      country: 'France',
      role: UserRoleEntity(
        roleType: UserRoleType.admin,
        assignedAt: DateTime.now().subtract(const Duration(days: 365)),
        assignedBy: 'system',
        isActive: true,
      ),
      beekeeperDetails: BeekeeperDetailsEntity(
        beekeeperId: 'API123456',
        yearsOfExperience: 5,
        beekeepingType: BeekeepingType.professional,
        totalHives: 15,
        annualProduction: 250.5,
        validationStatus: BeekeeperValidationStatus.approved,
        validatedAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      createdAt: DateTime.now().subtract(const Duration(days: 400)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      isEmailVerified: true,
      phoneNumber: '+33 1 23 45 67 89',
      // Exemple d'un profil NON supprimé
      isDeleted: false,
    );
  }
}
