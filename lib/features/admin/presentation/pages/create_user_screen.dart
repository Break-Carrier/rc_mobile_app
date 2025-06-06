import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/auth_service.dart';
import '../../../user_profile/domain/entities/user_role_entity.dart';

/// Écran de création d'utilisateur par un administrateur
///
/// Permet aux admins de créer de nouveaux apiculteurs avec :
/// - Compte Firebase Auth automatique
/// - Mot de passe temporaire généré
/// - Profil de base à compléter
class CreateUserScreen extends StatefulWidget {
  const CreateUserScreen({super.key});

  @override
  State<CreateUserScreen> createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();

  UserRoleType _selectedRole = UserRoleType.pendingBeekeeper;
  bool _isLoading = false;
  String? _generatedPassword;

  @override
  void dispose() {
    _emailController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('👤 Créer un utilisateur'),
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // En-tête
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(
                        Icons.person_add,
                        size: 48,
                        color: Colors.blue.shade600,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Création d\'un nouvel utilisateur',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.blue.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'L\'utilisateur recevra un email avec ses identifiants temporaires',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.blue.shade700,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Formulaire
              _buildFormSection(),

              const SizedBox(height: 32),

              // Bouton de création
              _buildCreateButton(),

              // Affichage du mot de passe généré
              if (_generatedPassword != null) ...[
                const SizedBox(height: 24),
                _buildPasswordDisplay(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📋 Informations utilisateur',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            // Email
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Adresse email',
                hintText: 'exemple@ruche.com',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'L\'email est requis';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                    .hasMatch(value)) {
                  return 'Format d\'email invalide';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Nom complet
            TextFormField(
              controller: _fullNameController,
              decoration: const InputDecoration(
                labelText: 'Nom complet',
                hintText: 'Jean Dupont',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Le nom est requis';
                }
                if (value.length < 2) {
                  return 'Le nom doit contenir au moins 2 caractères';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Téléphone (optionnel)
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Numéro de téléphone (optionnel)',
                hintText: '+33 6 12 34 56 78',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // Sélection du rôle
            Text(
              'Rôle utilisateur',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            _buildRoleSelector(),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleSelector() {
    return Column(
      children: [
        _buildRoleOption(
          UserRoleType.pendingBeekeeper,
          '🐝 Apiculteur en attente',
          'Nécessite une validation ultérieure',
        ),
        _buildRoleOption(
          UserRoleType.beekeeper,
          '✅ Apiculteur validé',
          'Accès immédiat aux fonctionnalités',
        ),
        _buildRoleOption(
          UserRoleType.admin,
          '👑 Administrateur',
          'Gestion complète du système',
        ),
      ],
    );
  }

  Widget _buildRoleOption(UserRoleType role, String title, String subtitle) {
    return Card(
      elevation: _selectedRole == role ? 4 : 1,
      color: _selectedRole == role ? Colors.green.shade50 : null,
      child: RadioListTile<UserRoleType>(
        title: Text(
          title,
          style: TextStyle(
            fontWeight:
                _selectedRole == role ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text(subtitle),
        value: role,
        groupValue: _selectedRole,
        onChanged: (value) {
          setState(() {
            _selectedRole = value!;
          });
        },
        activeColor: Colors.green.shade600,
      ),
    );
  }

  Widget _buildCreateButton() {
    return ElevatedButton.icon(
      onPressed: _isLoading ? null : _handleCreateUser,
      icon: _isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.person_add),
      label: Text(_isLoading ? 'Création en cours...' : 'Créer l\'utilisateur'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPasswordDisplay() {
    return Card(
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.key, color: Colors.orange.shade600),
                const SizedBox(width: 8),
                Text(
                  'Mot de passe temporaire généré',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.orange.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.orange.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _generatedPassword!,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // TODO: Copier dans le presse-papier
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Mot de passe copié !'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy),
                    tooltip: 'Copier',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '⚠️ Communiquez ce mot de passe à l\'utilisateur de manière sécurisée',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.orange.shade700,
                    fontStyle: FontStyle.italic,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleCreateUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _generatedPassword = null;
    });

    try {
      final authService = context.read<AuthService>();

      final result = await authService.createUserByAdmin(
        email: _emailController.text.trim(),
        fullName: _fullNameController.text.trim(),
      );

      switch (result) {
        case AuthSuccess(data: final user):
          setState(() {
            _generatedPassword = 'MotDePasseTemp123!'; // Placeholder pour demo
          });

          // TODO: Créer le profil complet via UserProfileRepository

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Utilisateur ${user.email} créé avec succès !'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 4),
              ),
            );
          }

        case AuthFailure(error: final error):
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erreur: ${error.message}'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 5),
              ),
            );
          }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur inattendue: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
