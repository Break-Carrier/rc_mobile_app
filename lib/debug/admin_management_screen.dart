import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/presentation/bloc/auth_state.dart';

/// Écran de gestion des administrateurs (Debug/DevOps)
///
/// Interface simple pour ajouter/supprimer des admins
/// Accessible uniquement en mode debug
class AdminManagementScreen extends StatefulWidget {
  const AdminManagementScreen({super.key});

  @override
  State<AdminManagementScreen> createState() => _AdminManagementScreenState();
}

class _AdminManagementScreenState extends State<AdminManagementScreen> {
  final _uidController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  List<AdminInfo> _admins = [];

  @override
  void initState() {
    super.initState();
    _loadAdmins();
  }

  @override
  void dispose() {
    _uidController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Admins'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCurrentUserCard(authState),
                const SizedBox(height: 24),
                _buildQuickActionsCard(authState),
                const SizedBox(height: 24),
                _buildAddAdminCard(),
                const SizedBox(height: 24),
                _buildAdminListCard(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCurrentUserCard(AuthState authState) {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '👤 Utilisateur Actuel',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
            ),
            const SizedBox(height: 12),
            if (authState is AuthAuthenticated) ...[
              Text('UID: ${authState.user.id}'),
              Text('Email: ${authState.user.email}'),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _makeCurrentUserAdmin(authState.user.id),
                  icon: const Icon(Icons.admin_panel_settings),
                  label: const Text('Me faire Admin'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ] else ...[
              const Text('Aucun utilisateur connecté'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsCard(AuthState authState) {
    return Card(
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '⚡ Actions Rapides',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade800,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _loadAdmins,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Actualiser'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _clearAllAdmins,
                    icon: const Icon(Icons.clear_all),
                    label: const Text('Tout effacer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddAdminCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '➕ Ajouter un Administrateur',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _uidController,
              decoration: const InputDecoration(
                labelText: 'UID Firebase',
                hintText: 'Collez l\'UID ici...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.fingerprint),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _addAdmin,
                icon: _isLoading
                    ? const CircularProgressIndicator(strokeWidth: 2)
                    : const Icon(Icons.person_add),
                label: Text(_isLoading ? 'Ajout...' : 'Ajouter comme Admin'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminListCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '👑 Administrateurs Actuels (${_admins.length})',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            if (_admins.isEmpty) ...[
              const Text(
                'Aucun administrateur configuré',
                style: TextStyle(color: Colors.grey),
              ),
            ] else ...[
              ..._admins.map((admin) => _buildAdminTile(admin)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAdminTile(AdminInfo admin) {
    return Card(
      color: Colors.green.shade50,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.admin_panel_settings, color: Colors.green),
        title: Text(
          admin.uid,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Méthode: ${admin.method}'),
            if (admin.addedAt != null)
              Text('Ajouté: ${admin.addedAt!.toLocal()}'),
          ],
        ),
        trailing: IconButton(
          onPressed: () => _removeAdmin(admin.uid),
          icon: const Icon(Icons.delete, color: Colors.red),
          tooltip: 'Supprimer',
        ),
      ),
    );
  }

  // === Actions ===

  Future<void> _makeCurrentUserAdmin(String uid) async {
    setState(() => _isLoading = true);

    try {
      await _firestore.collection('admin_config').doc(uid).set({
        'isAdmin': true,
        'addedAt': FieldValue.serverTimestamp(),
        'addedBy': 'self_service',
        'method': 'SELF_SERVICE',
      });

      _showSuccess('Vous êtes maintenant administrateur !');
      await _loadAdmins();
    } catch (e) {
      _showError('Erreur: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addAdmin() async {
    final uid = _uidController.text.trim();
    if (uid.isEmpty) {
      _showError('Veuillez saisir un UID');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _firestore.collection('admin_config').doc(uid).set({
        'isAdmin': true,
        'addedAt': FieldValue.serverTimestamp(),
        'addedBy': 'manual',
        'method': 'MANUAL_ADD',
      });

      _uidController.clear();
      _showSuccess('Administrateur ajouté avec succès !');
      await _loadAdmins();
    } catch (e) {
      _showError('Erreur: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _removeAdmin(String uid) async {
    try {
      await _firestore.collection('admin_config').doc(uid).delete();
      _showSuccess('Administrateur supprimé');
      await _loadAdmins();
    } catch (e) {
      _showError('Erreur: ${e.toString()}');
    }
  }

  Future<void> _clearAllAdmins() async {
    final confirmed = await _showConfirmDialog(
      'Supprimer tous les admins ?',
      'Cette action est irréversible !',
    );

    if (confirmed) {
      try {
        final snapshot = await _firestore.collection('admin_config').get();
        for (final doc in snapshot.docs) {
          await doc.reference.delete();
        }
        _showSuccess('Tous les admins ont été supprimés');
        await _loadAdmins();
      } catch (e) {
        _showError('Erreur: ${e.toString()}');
      }
    }
  }

  Future<void> _loadAdmins() async {
    try {
      final snapshot = await _firestore.collection('admin_config').get();

      setState(() {
        _admins = snapshot.docs.map((doc) {
          final data = doc.data();
          return AdminInfo(
            uid: doc.id,
            addedAt: (data['addedAt'] as Timestamp?)?.toDate(),
            addedBy: data['addedBy'] as String?,
            method: data['method'] as String? ?? 'UNKNOWN',
          );
        }).toList();
      });
    } catch (e) {
      _showError('Erreur de chargement: ${e.toString()}');
    }
  }

  // === Utilities ===

  Future<bool> _showConfirmDialog(String title, String content) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Confirmer'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// Informations d'un administrateur
class AdminInfo {
  final String uid;
  final DateTime? addedAt;
  final String? addedBy;
  final String method;

  const AdminInfo({
    required this.uid,
    this.addedAt,
    this.addedBy,
    required this.method,
  });
}
