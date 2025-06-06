import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/entities/user_role_entity.dart';
import '../../domain/entities/beekeeper_details_entity.dart';
import '../../../../core/error/app_error.dart';

/// Écran de profil utilisateur
///
/// Responsabilité unique : Afficher le profil utilisateur
/// Separation of Concerns : UI séparée de la logique métier
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    _loadCurrentUserProfile();
  }

  // === Actions (Single Responsibility) ===
  void _loadCurrentUserProfile() {
    // TODO: Remplacer par le vrai BLoC quand implémenté
    // context.read<UserProfileBloc>().add(const LoadCurrentUserProfile());
  }

  void _refreshProfile() {
    // TODO: Implémenter le refresh via BLoC
    _loadCurrentUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  // === Construction d'interface (Fonctions courtes) ===
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Mon Profil'),
      actions: [
        _buildAdminButton(),
        _buildEditButton(),
      ],
    );
  }

  Widget _buildAdminButton() {
    // TODO: Remplacer par BlocBuilder quand le BLoC sera implémenté
    return FutureBuilder<bool>(
      future: _checkIfUserIsAdmin(),
      builder: (context, snapshot) {
        if (snapshot.data == true) {
          return IconButton(
            onPressed: () => _navigateToAdminPanel(context),
            icon: const Icon(Icons.admin_panel_settings),
            tooltip: 'Panneau d\'administration',
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildEditButton() {
    return IconButton(
      onPressed: () => _navigateToEditProfile(context),
      icon: const Icon(Icons.edit),
      tooltip: 'Modifier le profil',
    );
  }

  Widget _buildBody() {
    // TODO: Remplacer par BlocBuilder quand le BLoC sera implémenté
    return FutureBuilder<UserProfileEntity?>(
      future: _loadMockProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _buildErrorWidget(
            context,
            ServiceError(
              message: 'Erreur de chargement: ${snapshot.error}',
              code: 'PROFILE_LOAD_ERROR',
            ),
          );
        }

        final profile = snapshot.data;
        if (profile == null) {
          return _buildErrorWidget(
            context,
            const DataNotFoundError(
              message: 'Profil utilisateur introuvable',
              code: 'PROFILE_NOT_FOUND',
            ),
          );
        }

        return _buildProfileContent(context, profile);
      },
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
            onPressed: _loadCurrentUserProfile,
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, UserProfileEntity profile) {
    return RefreshIndicator(
      onRefresh: () async => _refreshProfile(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(profile),
            const SizedBox(height: 24),
            RoleBadge(role: profile.role),
            const SizedBox(height: 24),
            _buildPersonalInfoCard(profile),
            const SizedBox(height: 16),
            if (profile.beekeeperDetails != null) ...[
              _buildBeekeeperDetails(profile.beekeeperDetails!),
              const SizedBox(height: 16),
            ],
            _buildRoleBasedActions(context, profile),
            const SizedBox(height: 24),
            _buildAccountStatus(profile),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(UserProfileEntity profile) {
    return Row(
      children: [
        _buildProfileAvatar(profile),
        const SizedBox(width: 16),
        _buildProfileInfo(profile),
      ],
    );
  }

  Widget _buildProfileAvatar(UserProfileEntity profile) {
    return CircleAvatar(
      radius: 40,
      backgroundImage: profile.profileImageUrl != null
          ? NetworkImage(profile.profileImageUrl!)
          : null,
      child: profile.profileImageUrl == null
          ? Text(
              _getInitials(profile.firstName),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            )
          : null,
    );
  }

  Widget _buildProfileInfo(UserProfileEntity profile) {
    return Expanded(
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
    );
  }

  Widget _buildPersonalInfoCard(UserProfileEntity profile) {
    return ProfileInfoCard(
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
    final actions = _getActionsForRole(profile);

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
            _buildStatusRow(
              icon: profile.isActive ? Icons.check_circle : Icons.cancel,
              color: profile.isActive ? Colors.green : Colors.red,
              text: profile.isActive ? 'Compte actif' : 'Compte désactivé',
            ),
            const SizedBox(height: 8),
            _buildStatusRow(
              icon: profile.isEmailVerified ? Icons.verified : Icons.warning,
              color: profile.isEmailVerified ? Colors.green : Colors.orange,
              text: profile.isEmailVerified
                  ? 'Email vérifié'
                  : 'Email non vérifié',
            ),
            if (profile.isPendingValidation) ...[
              const SizedBox(height: 8),
              _buildStatusRow(
                icon: Icons.hourglass_empty,
                color: Colors.orange,
                text: 'En attente de validation',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow({
    required IconData icon,
    required Color color,
    required String text,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(text),
      ],
    );
  }

  // === Logique métier (Fonctions pures) ===
  String _getInitials(String firstName) {
    return firstName.isNotEmpty ? firstName[0].toUpperCase() : '?';
  }

  List<Widget> _getActionsForRole(UserProfileEntity profile) {
    final actions = <Widget>[];

    if (profile.isAdmin) {
      actions.addAll(_getAdminActions());
    }

    if (profile.canAccessBeekeepingFeatures) {
      actions.addAll(_getBeekeeperActions());
    }

    return actions;
  }

  List<Widget> _getAdminActions() {
    return [
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
    ];
  }

  List<Widget> _getBeekeeperActions() {
    return [
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
    ];
  }

  // === Données de test (Temporaire) ===
  Future<bool> _checkIfUserIsAdmin() async {
    // TODO: Remplacer par la vraie logique
    return Future.value(true);
  }

  Future<UserProfileEntity?> _loadMockProfile() async {
    // TODO: Remplacer par le vrai chargement via repository
    await Future.delayed(const Duration(milliseconds: 500));

    // Données mock pour demo
    return UserProfileEntity(
      userId: 'user123',
      firstName: 'Jean',
      lastName: 'Dupont',
      email: 'jean.dupont@example.com',
      address: '123 Rue de la Ruche',
      city: 'Paris',
      postalCode: '75001',
      phoneNumber: '+33 6 12 34 56 78',
      role: UserRoleEntity(
        roleType: UserRoleType.admin,
        assignedAt: DateTime.now().subtract(const Duration(days: 30)),
        assignedBy: 'system',
      ),
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now(),
      version: 1,
    );
  }

  // === Navigation (Side Effects isolés) ===
  void _navigateToEditProfile(BuildContext context) {
    Navigator.pushNamed(context, '/profile/edit');
  }

  void _navigateToAdminPanel(BuildContext context) {
    context.push('/admin');
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

// === Widgets réutilisables (Single Responsibility) ===

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
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: _buildInfoRow(context, item),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, ProfileInfoItem item) {
    return Row(
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
}

// Pour les futures implémentations BLoC (actuellement en placeholder)
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

class LoadCurrentUserProfile {
  const LoadCurrentUserProfile();
}
