import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../domain/bloc/dashboard_bloc.dart';
import '../../../../core/models/apiary.dart';
import '../../../../core/models/apiary_status.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DashboardBloc()..add(LoadDashboardData()),
      child: const DashboardView(),
    );
  }
}

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🏡 Ruche Connectée'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.blue),
            onPressed: () =>
                context.read<DashboardBloc>().add(RefreshDashboardData()),
          ),
        ],
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          return switch (state) {
            DashboardInitial() => const _LoadingWidget(),
            DashboardLoading() => const _LoadingWidget(),
            DashboardError() => _ErrorWidget(message: state.message),
            DashboardLoaded() => _LoadedContent(state: state),
            _ => const _LoadingWidget(),
          };
        },
      ),
    );
  }
}

class _LoadingWidget extends StatelessWidget {
  const _LoadingWidget();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Chargement du tableau de bord...'),
        ],
      ),
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  final String message;

  const _ErrorWidget({required this.message});

  @override
  Widget build(BuildContext context) {
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
            'Erreur',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.red,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () =>
                context.read<DashboardBloc>().add(LoadDashboardData()),
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }
}

class _LoadedContent extends StatelessWidget {
  final DashboardLoaded state;

  const _LoadedContent({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.apiaries.isEmpty) {
      return const _NoApiariesWidget();
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<DashboardBloc>().add(RefreshDashboardData());
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Résumé Global
            _buildGlobalSummary(context),

            const SizedBox(height: 20),

            // Mes Ruchers
            _buildApiariesSection(context),

            const SizedBox(height: 20),

            // Alertes Récentes
            _buildRecentAlertsSection(context),

            const SizedBox(height: 20),

            // Actions rapides
            _buildQuickActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildGlobalSummary(BuildContext context) {
    final totalHives = _getTotalHiveCount(state.apiaries);
    final alertCount = _getCriticalAlertCount();
    final avgTemp = _getGlobalAverageTemperature();
    final avgHumidity = _getGlobalAverageHumidity();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.dashboard, color: Colors.blue, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Résumé Global',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Première ligne de statistiques
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    '📊 ${state.apiaries.length}',
                    'Ruchers',
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    '🏠 $totalHives',
                    'Ruches',
                    Colors.amber.shade700,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    '⚠️ $alertCount',
                    'Alertes',
                    alertCount > 0 ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Deuxième ligne de statistiques
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    '🌡️ ${avgTemp.toStringAsFixed(1)}°C',
                    'Temp. moy.',
                    Colors.red.shade600,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    '💧 ${avgHumidity.toStringAsFixed(0)}%',
                    'Humid. moy.',
                    Colors.blue.shade600,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    '✅ ${_getHealthyHivesCount()}',
                    'OK',
                    Colors.green.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color.withValues(alpha: 0.8),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildApiariesSection(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.home_work, color: Colors.green, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Mes Ruchers',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Liste compacte des ruchers
            ...state.apiaries
                .map((apiary) => _buildCompactApiaryCard(context, apiary)),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactApiaryCard(BuildContext context, Apiary apiary) {
    final status = _getApiaryStatus(apiary);
    final statusIcon = status.emoji;
    final statusColor = status.color;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _navigateToApiary(context, apiary),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: statusColor.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Text(
                '🏡',
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      apiary.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${apiary.hiveIds.length} ruches • ${apiary.location}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                statusIcon,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentAlertsSection(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.notification_important,
                    color: Colors.red, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Alertes Récentes',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade800,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Liste d'alertes récentes (simulées pour l'instant)
            _buildRecentAlertItem(
              '⚠️',
              'Ruche Alpha - Température élevée',
              '28.5°C détectée il y a 15 min',
              Colors.orange,
            ),
            const SizedBox(height: 8),
            _buildRecentAlertItem(
              '❌',
              'Ruche Forest-2 - Capteur déconnecté',
              'Aucune donnée depuis 2h',
              Colors.red,
            ),
            const SizedBox(height: 12),

            // Bouton voir toutes les alertes
            Center(
              child: TextButton.icon(
                onPressed: () => context.go('/alerts'),
                icon: const Icon(Icons.list_alt),
                label: const Text('Voir toutes les alertes'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentAlertItem(
      String icon, String title, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actions rapides',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    icon: Icons.add_home_work,
                    label: 'Ajouter Rucher',
                    color: Colors.green,
                    onTap: () {
                      // TODO: Navigation vers ajout rucher
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Fonction à implémenter')),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.analytics,
                    label: 'Statistiques',
                    color: Colors.blue,
                    onTap: () {
                      // TODO: Navigation vers statistiques
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Fonction à implémenter')),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.settings,
                    label: 'Paramètres',
                    color: Colors.grey,
                    onTap: () => context.go('/settings'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  int _getTotalHiveCount(List<Apiary> apiaries) {
    return apiaries.fold(0, (total, apiary) => total + apiary.hiveIds.length);
  }

  int _getCriticalAlertCount() {
    // TODO: Implémenter le compte des alertes critiques
    return 2; // Simulé pour l'instant
  }

  double _getGlobalAverageTemperature() {
    // TODO: Calculer la température moyenne réelle
    return 24.5; // Simulé pour l'instant
  }

  double _getGlobalAverageHumidity() {
    // TODO: Calculer l'humidité moyenne réelle
    return 65.0; // Simulé pour l'instant
  }

  int _getHealthyHivesCount() {
    // TODO: Calculer le nombre de ruches en bonne santé
    return _getTotalHiveCount(state.apiaries) - 2; // Simulé pour l'instant
  }

  ApiaryStatus _getApiaryStatus(Apiary apiary) {
    // TODO: Implémenter la logique de calcul du statut
    if (apiary.hiveIds.isEmpty) return ApiaryStatus.critical;
    if (apiary.name.contains('Forêt')) return ApiaryStatus.warning;
    if (apiary.name.contains('Prairie')) return ApiaryStatus.critical;
    return ApiaryStatus.normal;
  }

  void _navigateToApiary(BuildContext context, Apiary apiary) {
    context.go('/apiary/${apiary.id}/hives');
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _NoApiariesWidget extends StatelessWidget {
  const _NoApiariesWidget();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.home_work_outlined,
                size: 64,
                color: Colors.amber,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Bienvenue !',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Aucun rucher configuré',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            const Text(
              'Commencez par ajouter votre premier rucher pour gérer vos ruches',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Navigation vers ajout rucher
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fonction à implémenter')),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Ajouter un rucher'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
