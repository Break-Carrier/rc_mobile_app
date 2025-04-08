import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HiveDetailsScreen extends StatelessWidget {
  final String hiveId;

  const HiveDetailsScreen({
    super.key,
    required this.hiveId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ruche $hiveId'),
      ),
      body: Column(
        children: [
          // En-tête avec les informations principales
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 40,
                  child: Icon(Icons.hive, size: 40),
                ),
                const SizedBox(height: 16),
                Text(
                  'Ruche $hiveId',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                const Text('Dernière mise à jour: il y a 5 minutes'),
              ],
            ),
          ),
          // Navigation vers les sous-pages
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.all(16),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildNavigationCard(
                  context,
                  'Lectures des capteurs',
                  Icons.sensors,
                  () => context.go('/hive/$hiveId/readings'),
                ),
                _buildNavigationCard(
                  context,
                  'Alertes',
                  Icons.notifications,
                  () => context.go('/hive/$hiveId/alerts'),
                ),
                _buildNavigationCard(
                  context,
                  'Configuration',
                  Icons.settings,
                  () {
                    // TODO: Implémenter la navigation vers la configuration
                  },
                ),
                _buildNavigationCard(
                  context,
                  'Historique',
                  Icons.history,
                  () {
                    // TODO: Implémenter la navigation vers l'historique
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationCard(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
