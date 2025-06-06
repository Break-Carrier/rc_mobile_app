import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/usecases/create_user_use_case.dart';
import '../../../user_profile/domain/entities/user_role_entity.dart';
import '../../../../core/error/app_error.dart';
import '../widgets/user_creation_form.dart';
import '../widgets/user_creation_header.dart';
import '../widgets/password_display_card.dart';

/// Écran de création d'utilisateur - Version Clean Code
///
/// Responsabilité unique : Orchestrer l'interface de création d'utilisateur
/// Separation of Concerns : Délègue la logique métier au Use Case
class CreateUserScreenClean extends StatefulWidget {
  const CreateUserScreenClean({super.key});

  @override
  State<CreateUserScreenClean> createState() => _CreateUserScreenCleanState();
}

class _CreateUserScreenCleanState extends State<CreateUserScreenClean> {
  // === État minimal (Single Responsibility) ===
  bool _isLoading = false;
  CreateUserResultData? _creationResult;

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
      title: const Text('👤 Créer un utilisateur'),
      backgroundColor: Colors.green.shade600,
      foregroundColor: Colors.white,
      elevation: 0,
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const UserCreationHeader(),
          const SizedBox(height: 24),
          UserCreationForm(
            isLoading: _isLoading,
            onSubmit: _handleFormSubmission,
          ),
          if (_creationResult != null) ...[
            const SizedBox(height: 24),
            PasswordDisplayCard(
              temporaryPassword: _creationResult!.temporaryPassword,
              userEmail: _creationResult!.email,
            ),
          ],
        ],
      ),
    );
  }

  // === Gestion des événements (Single Responsibility) ===
  Future<void> _handleFormSubmission(CreateUserFormData formData) async {
    if (!_validateFormData(formData)) return;

    await _executeUserCreation(formData);
  }

  // === Validation (Fail Fast) ===
  bool _validateFormData(CreateUserFormData formData) {
    if (formData.email.isEmpty) {
      _showErrorMessage('L\'email est requis');
      return false;
    }

    if (formData.fullName.isEmpty) {
      _showErrorMessage('Le nom complet est requis');
      return false;
    }

    return true;
  }

  // === Logique métier déléguée au Use Case ===
  Future<void> _executeUserCreation(CreateUserFormData formData) async {
    _setLoadingState(true);

    try {
      final useCase = context.read<CreateUserUseCase>();
      final params = _buildUseCaseParams(formData);

      final result = await useCase.call(params);

      _handleUseCaseResult(result);
    } catch (e) {
      _handleUnexpectedError(e);
    } finally {
      _setLoadingState(false);
    }
  }

  // === Construction de paramètres (Factory Method) ===
  CreateUserParams _buildUseCaseParams(CreateUserFormData formData) {
    return CreateUserParams(
      email: formData.email.trim(),
      fullName: formData.fullName.trim(),
      roleType: formData.selectedRole,
      createdByAdminId: _getCurrentAdminId(),
      phoneNumber: formData.phoneNumber?.trim(),
    );
  }

  // === Gestion des résultats ===
  void _handleUseCaseResult(CreateUserResult result) {
    switch (result) {
      case CreateUserSuccess(data: final data):
        _handleCreationSuccess(data);
      case CreateUserFailure(error: final error):
        _handleCreationError(error);
    }
  }

  void _handleCreationSuccess(CreateUserResultData data) {
    setState(() {
      _creationResult = data;
    });

    _showSuccessMessage(
      'Utilisateur ${data.email} créé avec succès !',
    );
  }

  void _handleCreationError(AppError error) {
    _showErrorMessage(error.message);
  }

  void _handleUnexpectedError(dynamic error) {
    _showErrorMessage('Erreur inattendue: ${error.toString()}');
  }

  // === État local (Fonctions pures) ===
  void _setLoadingState(bool isLoading) {
    if (mounted) {
      setState(() {
        _isLoading = isLoading;
      });
    }
  }

  // === Messages utilisateur (Side Effects isolés) ===
  void _showSuccessMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showErrorMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  // === Données contextuelles ===
  String _getCurrentAdminId() {
    // TODO: Récupérer l'ID de l'admin connecté depuis le contexte d'auth
    return 'current_admin_id'; // Placeholder
  }
}

/// Données du formulaire (Value Object)
class CreateUserFormData {
  final String email;
  final String fullName;
  final String? phoneNumber;
  final UserRoleType selectedRole;

  const CreateUserFormData({
    required this.email,
    required this.fullName,
    required this.selectedRole,
    this.phoneNumber,
  });
}
