import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';

/// Écran des paramètres de l'application
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('⚙️ Paramètres'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Section Authentification
          _buildSection('🔐 Authentification', [
            _buildTile(
              icon: Icons.logout,
              title: 'Déconnexion',
              subtitle: 'Se déconnecter de l\'application',
              textColor: Colors.red,
              onTap: () {
                _showLogoutDialog(context);
              },
            ),
          ]),

          const SizedBox(height: 20),

          // Section Notifications
          _buildSection('🔔 Notifications', [
            _buildTile(
              icon: Icons.notifications_active,
              title: 'Notifications push',
              subtitle: 'Recevoir des alertes en temps réel',
              trailing: Switch(
                value: true, // TODO: Connecter à l'état réel
                activeColor: Colors.green,
                onChanged: (value) {
                  // TODO: Implémenter la logique
                },
              ),
              onTap: () {},
            ),
            _buildTile(
              icon: Icons.email,
              title: 'Notifications email',
              subtitle: 'Recevoir un résumé quotidien',
              trailing: Switch(
                value: false, // TODO: Connecter à l'état réel
                onChanged: (value) {
                  // TODO: Implémenter la logique
                },
              ),
              onTap: () {},
            ),
          ]),

          const SizedBox(height: 20),

          // Section Application
          _buildSection('📱 Application', [
            _buildTile(
              icon: Icons.palette,
              title: 'Thème',
              subtitle: 'Clair / Sombre',
              onTap: () {
                // TODO: Implémenter le sélecteur de thème
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fonction à implémenter')),
                );
              },
            ),
            _buildTile(
              icon: Icons.language,
              title: 'Langue',
              subtitle: 'Français',
              onTap: () {
                // TODO: Implémenter le sélecteur de langue
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fonction à implémenter')),
                );
              },
            ),
            _buildTile(
              icon: Icons.info,
              title: 'À propos',
              subtitle: 'Version 1.0.0 - Ruche Connectée',
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'Ruche Connectée',
                  applicationVersion: '1.0.0',
                  applicationIcon:
                      const Icon(Icons.hive, size: 48, color: Colors.amber),
                  children: const [
                    Text('Application de monitoring IoT pour apiculteurs'),
                    SizedBox(height: 10),
                    Text('Développée avec Flutter et Firebase'),
                  ],
                );
              },
            ),
          ]),
        ],
      ),
    );
  }

  /// Affiche le dialogue de confirmation de déconnexion
  void _showLogoutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.logout, color: Colors.red),
              SizedBox(width: 8),
              Text('Déconnexion'),
            ],
          ),
          content: const Text(
            'Êtes-vous sûr de vouloir vous déconnecter de l\'application ?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();

                // Masquer d'abord toute SnackBar existante pour éviter qu'elle reste
                ScaffoldMessenger.of(context).hideCurrentSnackBar();

                // Déconnexion via AuthBloc (sera instantanée)
                context.read<AuthBloc>().add(const SignOutRequested());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Se déconnecter'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? textColor,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor),
      title: Text(
        title,
        style: TextStyle(color: textColor),
      ),
      subtitle: Text(subtitle),
      onTap: onTap,
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
    );
  }
}
