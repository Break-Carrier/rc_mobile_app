import 'package:flutter/material.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/entities/beekeeper_details_entity.dart';
import '../../../../core/error/app_error.dart';

/// Écran de profil utilisateur
///
/// Affiche les informations du profil utilisateur avec des fonctionnalités
/// conditionnelles basées sur le rôle (administrateur/apiculteur).
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Chargement initial du profil
    _loadProfile();
  }

  void _loadProfile() {
    // Simulation du chargement - à remplacer par le vrai BLoC
    // context.read<UserProfileBloc>().add(LoadCurrentUserProfile());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
        actions: [
          BlocBuilder<UserProfileBloc, UserProfileState>(
            builder: (context, state) {
              if (state is UserProfileLoaded && state.profile.canManageUsers) {
                return IconButton(
                  onPressed: () => _navigateToAdminPanel(context),
                  icon: const Icon(Icons.admin_panel_settings),
                  tooltip: 'Panneau d\'administration',
                );
              }
              return const SizedBox.shrink();
            },
          ),
          IconButton(
            onPressed: () => _navigateToEditProfile(context),
            icon: const Icon(Icons.edit),
            tooltip: 'Modifier le profil',
          ),
        ],
      ),
      body: BlocBuilder<UserProfileBloc, UserProfileState>(
        builder: (context, state) {
          return switch (state) {
            UserProfileInitial() => const Center(
                child: Text('Initialisation du profil...'),
              ),
            UserProfileLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
            UserProfileLoaded(:final profile) =>
              _buildProfileContent(context, profile),
            UserProfileError(:final error) => _buildErrorWidget(context, error),
          };
        },
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, AppError error) {
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
          const SizedBox(height: 8),
          Text(
            error.message,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<UserProfileBloc>().add(
                  const LoadCurrentUserProfile(),
                ),
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, UserProfileEntity profile) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<UserProfileBloc>().add(const LoadCurrentUserProfile());
      },
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
            RoleBadge(role: profile.role),

            const SizedBox(height: 24),

            // Informations personnelles
            ProfileInfoCard(
              title: 'Informations personnelles',
              items: [
                ProfileInfoItem(
                  label: 'Nom complet',
                  value: profile.fullName,
                  icon: Icons.person,
                ),
                ProfileInfoItem(
                  label: 'Email',
                  value: profile.email,
                  icon: Icons.email,
                ),
                ProfileInfoItem(
                  label: 'Téléphone',
                  value: profile.phoneNumber ?? 'Non renseigné',
                  icon: Icons.phone,
                ),
                ProfileInfoItem(
                  label: 'Adresse',
                  value: profile.fullAddress,
                  icon: Icons.location_on,
                ),
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

  Widget _buildBeekeeperDetails(BeekeeperDetailsEntity details) {
    return ProfileInfoCard(
      title: 'Informations apiculteur',
      items: [
        if (details.beekeeperId != null)
          ProfileInfoItem(
            label: 'N° Apiculteur',
            value: details.beekeeperId!,
            icon: Icons.badge,
          ),
        ProfileInfoItem(
          label: 'Type d\'apiculture',
          value: details.beekeepingType.displayName,
          icon: Icons.category,
        ),
        if (details.yearsOfExperience != null)
          ProfileInfoItem(
            label: 'Années d\'expérience',
            value: '${details.yearsOfExperience} ans',
            icon: Icons.timeline,
          ),
        ProfileInfoItem(
          label: 'Nombre de ruches',
          value: '${details.totalHives}',
          icon: Icons.home_work,
        ),
        if (details.annualProduction != null)
          ProfileInfoItem(
            label: 'Production annuelle',
            value: '${details.annualProduction!.toStringAsFixed(1)} kg',
            icon: Icons.production_quantity_limits,
          ),
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

  void _navigateToDashboard(BuildContext context) {
    Navigator.pushNamed(context, '/dashboard');
  }

  void _navigateToApiaries(BuildContext context) {
    Navigator.pushNamed(context, '/apiaries');
  }
}

// Placeholder pour les classes manquantes
class UserProfileBloc {}

class UserProfileState {}

class UserProfileInitial extends UserProfileState {}

class UserProfileLoading extends UserProfileState {}

class UserProfileLoaded extends UserProfileState {
  final UserProfileEntity profile;
  UserProfileLoaded(this.profile);
}

class UserProfileError extends UserProfileState {
  final AppError error;
  UserProfileError(this.error);
}

class LoadCurrentUserProfile {}

class ProfileInfoCard extends StatelessWidget {
  final String title;
  final List<ProfileInfoItem> items;

  const ProfileInfoCard({
    super.key,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
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
            ...items
                .map((item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Icon(item.icon, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.label,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                Text(
                                  item.value,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }
}

class ProfileInfoItem {
  final String label;
  final String value;
  final IconData icon;

  const ProfileInfoItem({
    required this.label,
    required this.value,
    required this.icon,
  });
}

class RoleBadge extends StatelessWidget {
  final dynamic role;

  const RoleBadge({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
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
}
