import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../sensor/domain/entities/hive.dart';
import '../../../../core/models/hive_status.dart';
import '../../../apiary/domain/bloc/hives_bloc.dart';

class HivesScreen extends StatelessWidget {
  final String apiaryId;

  const HivesScreen({super.key, required this.apiaryId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HivesBloc()..add(LoadHives(apiaryId: apiaryId)),
      child: HivesView(apiaryId: apiaryId),
    );
  }
}

class HivesView extends StatelessWidget {
  final String apiaryId;

  const HivesView({super.key, required this.apiaryId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🏡 Dashboard Rucher'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.blue),
          onPressed: () => context.go('/'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.blue),
            onPressed: () =>
                context.read<HivesBloc>().add(RefreshHives(apiaryId: apiaryId)),
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.green),
            onPressed: () => _showAddHiveDialog(context),
          ),
        ],
      ),
      body: BlocBuilder<HivesBloc, HivesState>(
        builder: (context, state) {
          return switch (state) {
            HivesInitial() => const _LoadingWidget(),
            HivesLoading() => const _LoadingWidget(),
            HivesError() => _ErrorWidget(message: state.message),
            HivesLoaded() => _LoadedContent(state: state),
            HiveOperationSuccess() => _LoadedContent(
                state: context.read<HivesBloc>().state as HivesLoaded,
                successMessage: state.message,
              ),
            _ => const _LoadingWidget(),
          };
        },
      ),
    );
  }

  void _showAddHiveDialog(BuildContext context) {
    // TODO: Implémenter l'ajout d'une ruche
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fonction à implémenter')),
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
          Text('Chargement du rucher...'),
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
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Erreur',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.red,
                ),
          ),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Retour'),
          ),
        ],
      ),
    );
  }
}

class _LoadedContent extends StatelessWidget {
  final HivesLoaded state;
  final String? successMessage;

  const _LoadedContent({
    required this.state,
    this.successMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (successMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(successMessage!)),
        );
      });
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<HivesBloc>().add(RefreshHives(apiaryId: state.apiaryId));
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // En-tête du rucher
            _buildApiaryHeader(context),

            const SizedBox(height: 20),

            // Grille des ruches
            _buildHiveGrid(context),

            const SizedBox(height: 20),

            // Graphique comparatif
            _buildComparisonChart(context),

            const SizedBox(height: 20),

            // Actions et filtres
            _buildActionsSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildApiaryHeader(BuildContext context) {
    final apiary = state.apiary;
    final hiveCount = state.hives.length;
    final avgTemp = _getAverageTemperature();
    final avgHumidity = _getAverageHumidity();
    final healthyCount = _getHealthyHivesCount();
    final warningCount = _getWarningHivesCount();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.green.shade50, Colors.white],
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
                const Icon(Icons.home_work, color: Colors.green, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        apiary?.name ?? 'Rucher',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade800,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            apiary?.location ?? 'Emplacement non défini',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            '• $hiveCount ruches',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Statistiques du rucher
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
                    '✅ $healthyCount',
                    'OK',
                    Colors.green.shade600,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    '⚠️ $warningCount',
                    'Attention',
                    Colors.orange.shade600,
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
      margin: const EdgeInsets.symmetric(horizontal: 4),
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
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color.withValues(alpha: 0.8),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHiveGrid(BuildContext context) {
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
                const Icon(Icons.grid_view, color: Colors.blue, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Grille des Ruches',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (state.hives.isEmpty)
              _buildEmptyHivesMessage(context)
            else
              _buildHivesGrid(context),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyHivesMessage(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.hive_outlined, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Aucune ruche dans ce rucher',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ajoutez votre première ruche pour commencer le monitoring',
            style: TextStyle(color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Implémenter l'ajout d'une ruche
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fonction à implémenter')),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Ajouter une ruche'),
          ),
        ],
      ),
    );
  }

  Widget _buildHivesGrid(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: state.hives.length,
      itemBuilder: (context, index) {
        final hive = state.hives[index];
        return _buildHiveCard(context, hive);
      },
    );
  }

  Widget _buildHiveCard(BuildContext context, Hive hive) {
    final status = _getHiveStatus(hive);
    final statusIcon = status.emoji;
    final statusColor = status.color;

    // Données simulées pour l'instant
    final temp = 24.0 + (hive.id.hashCode % 5) - 2; // Température simulée
    final humidity = 60.0 + (hive.id.hashCode % 10); // Humidité simulée

    return InkWell(
      onTap: () => context.go('/hive/${hive.id}'),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: statusColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: statusColor.withValues(alpha: 0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icône de la ruche et statut
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.hive, size: 32, color: Colors.amber),
                const SizedBox(width: 8),
                Text(statusIcon, style: const TextStyle(fontSize: 20)),
              ],
            ),

            const SizedBox(height: 8),

            // Nom de la ruche
            Text(
              hive.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 8),

            // Données de capteurs
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.thermostat,
                        size: 16, color: Colors.red.shade600),
                    const SizedBox(width: 4),
                    Text(
                      '${temp.toStringAsFixed(1)}°C',
                      style: TextStyle(
                        color: Colors.red.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.water_drop,
                        size: 16, color: Colors.blue.shade600),
                    const SizedBox(width: 4),
                    Text(
                      '${humidity.toStringAsFixed(0)}%',
                      style: TextStyle(
                        color: Colors.blue.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonChart(BuildContext context) {
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
                const Icon(Icons.analytics, color: Colors.purple, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Graphique Comparatif',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.purple.shade800,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.show_chart,
                        size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 8),
                    Text(
                      'Graphique comparatif des ${state.hives.length} ruches',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Température sur 24h (à implémenter)',
                      style:
                          TextStyle(color: Colors.grey.shade500, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsSection(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actions & Filtres',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    icon: Icons.add_circle,
                    label: 'Ajouter Ruche',
                    color: Colors.green,
                    onTap: () {
                      // TODO: Implémenter l'ajout d'une ruche
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Fonction à implémenter')),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.filter_list,
                    label: 'Filtrer',
                    color: Colors.blue,
                    onTap: () {
                      // TODO: Implémenter les filtres
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Filtres à implémenter')),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.settings,
                    label: 'Configurer',
                    color: Colors.orange,
                    onTap: () {
                      // TODO: Implémenter la configuration du rucher
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Configuration à implémenter')),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  double _getAverageTemperature() {
    // TODO: Calculer la température moyenne réelle
    return 24.2; // Simulé pour l'instant
  }

  double _getAverageHumidity() {
    // TODO: Calculer l'humidité moyenne réelle
    return 64.0; // Simulé pour l'instant
  }

  int _getHealthyHivesCount() {
    // TODO: Calculer le nombre de ruches en bonne santé
    return state.hives.length > 2 ? state.hives.length - 2 : state.hives.length;
  }

  int _getWarningHivesCount() {
    // TODO: Calculer le nombre de ruches avec des alertes
    return state.hives.length > 2 ? 2 : 0;
  }

  HiveStatus _getHiveStatus(Hive hive) {
    // TODO: Implémenter la logique de calcul du statut
    final hash = hive.id.hashCode % 10;
    if (hash < 6) return HiveStatus.normal;
    if (hash < 8) return HiveStatus.warning;
    return HiveStatus.critical;
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
              size: 24,
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
