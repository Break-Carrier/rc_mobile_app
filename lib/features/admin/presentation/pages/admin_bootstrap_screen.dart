import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/bootstrap/admin_bootstrap.dart';
import '../../../../core/services/auth_service.dart';
import '../../../user_profile/domain/repositories/user_profile_repository.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

/// Écran de bootstrap pour créer le premier administrateur
///
/// Affiché uniquement quand aucun admin n'existe dans le système
class AdminBootstrapScreen extends StatefulWidget {
  const AdminBootstrapScreen({super.key});

  @override
  State<AdminBootstrapScreen> createState() => _AdminBootstrapScreenState();
}

class _AdminBootstrapScreenState extends State<AdminBootstrapScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isLoading = false;
  late AdminBootstrap _adminBootstrap;

  @override
  void initState() {
    super.initState();
    _adminBootstrap = AdminBootstrap(
      GetIt.instance<AuthService>(),
      GetIt.instance<UserProfileRepository>(),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuration Initiale'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false, // Pas de retour en arrière
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is! AuthAuthenticated) {
            return _buildNotAuthenticatedWidget();
          }

          return _buildBootstrapForm(authState);
        },
      ),
    );
  }

  Widget _buildNotAuthenticatedWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, size: 64, color: Colors.red),
          SizedBox(height: 16),
          Text(
            'Aucun utilisateur connecté',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('Veuillez vous connecter pour configurer votre profil admin.'),
        ],
      ),
    );
  }

  Widget _buildBootstrapForm(AuthAuthenticated authState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(authState),
            const SizedBox(height: 24),
            _buildFormFields(),
            const SizedBox(height: 24),
            _buildActionButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(AuthAuthenticated authState) {
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
            const SizedBox(height: 16),
            Text(
              'Bienvenue, ${authState.user.email}!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Configurez votre profil administrateur pour commencer à utiliser l\'application de gestion des ruches.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: Theme.of(context).colorScheme.primary),
              ),
              child: Text(
                '👑 Administrateur',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: 'Prénom *',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => _validateRequired(value, 'Prénom'),
                textCapitalization: TextCapitalization.words,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Nom *',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => _validateRequired(value, 'Nom'),
                textCapitalization: TextCapitalization.words,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _addressController,
          decoration: const InputDecoration(
            labelText: 'Adresse (optionnelle)',
            prefixIcon: Icon(Icons.location_on),
            border: OutlineInputBorder(),
            hintText: '123 Rue de la Ruche, 75001 Paris',
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _phoneController,
          decoration: const InputDecoration(
            labelText: 'Téléphone (optionnel)',
            prefixIcon: Icon(Icons.phone),
            border: OutlineInputBorder(),
            hintText: '+33 6 12 34 56 78',
          ),
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }

  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _createAdminProfile,
        icon: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.admin_panel_settings),
        label: Text(
            _isLoading ? 'Création en cours...' : 'Créer mon profil admin'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  // === Validation ===
  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName est requis';
    }
    return null;
  }

  // === Actions ===
  Future<void> _createAdminProfile() async {
    if (!_formKey.currentState!.validate()) {
      _showError('Veuillez remplir tous les champs requis');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _adminBootstrap.createCurrentUserAsAdmin(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        address: _addressController.text.trim().isNotEmpty
            ? _addressController.text.trim()
            : null,
        phoneNumber: _phoneController.text.trim().isNotEmpty
            ? _phoneController.text.trim()
            : null,
      );

      if (result is BootstrapSuccess) {
        _showSuccess(
          'Profil administrateur créé avec succès !\n'
          'Vous pouvez maintenant accéder à toutes les fonctionnalités.',
        );

        // Navigation vers l'accueil ou redémarrage de l'app
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/');
        }
      } else if (result is BootstrapFailure) {
        _showError(result.message);
      }
    } catch (e) {
      _showError('Erreur inattendue: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // === Notifications ===
  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
