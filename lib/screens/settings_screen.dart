import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
      ),
      body: ListView(
        children: [
          _buildSection(
            context,
            'Notifications',
            [
              _buildSwitchTile(
                context,
                'Alertes de température',
                'Recevoir des alertes quand la température dépasse les seuils',
                true,
                (value) {
                  // TODO: Implémenter la gestion des notifications
                },
              ),
              _buildSwitchTile(
                context,
                'Alertes d\'humidité',
                'Recevoir des alertes quand l\'humidité dépasse les seuils',
                true,
                (value) {
                  // TODO: Implémenter la gestion des notifications
                },
              ),
            ],
          ),
          _buildSection(
            context,
            'Affichage',
            [
              _buildSwitchTile(
                context,
                'Mode sombre',
                'Activer le thème sombre',
                false,
                (value) {
                  // TODO: Implémenter le changement de thème
                },
              ),
            ],
          ),
          _buildSection(
            context,
            'À propos',
            [
              ListTile(
                title: const Text('Version'),
                subtitle: const Text('1.0.0'),
                trailing: const Icon(Icons.info_outline),
              ),
              ListTile(
                title: const Text('Licence'),
                subtitle: const Text('MIT'),
                trailing: const Icon(Icons.description_outlined),
              ),
            ],
          ),
        ],
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
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ),
        ...children,
        const Divider(),
      ],
    );
  }

  Widget _buildSwitchTile(
    BuildContext context,
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }
}
