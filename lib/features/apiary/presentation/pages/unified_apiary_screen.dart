import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../hive/data/injection/hive_injection.dart';
import '../../../hive/presentation/bloc/hive_bloc.dart';
import '../../../hive/presentation/bloc/hive_event.dart';
import '../../../hive/presentation/bloc/hive_state.dart';
import '../../../hive/presentation/widgets/hive_card.dart';
import '../../../hive/presentation/widgets/create_hive_dialog.dart';
import '../../../alert/di/alert_injection.dart';
import '../../../alert/presentation/bloc/alert_bloc.dart';
import '../../domain/entities/apiary.dart';
import '../../../../core/utils/text_utils.dart';
import '../../../../core/models/hive_status.dart';

/// Écran unifié d'un rucher : informations + statistiques + ruches
class UnifiedApiaryScreen extends StatelessWidget {
  final String apiaryId;
  final dynamic apiary;

  const UnifiedApiaryScreen({
    super.key,
    required this.apiaryId,
    this.apiary,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              HiveInjection.getHiveBloc()..add(LoadApiaryHives(apiaryId)),
        ),
        BlocProvider(
          create: (context) => AlertInjection.getAlertBloc(),
        ),
      ],
      child: _UnifiedApiaryView(apiaryId: apiaryId, apiary: apiary),
    );
  }
}

class _UnifiedApiaryView extends StatefulWidget {
  final String apiaryId;
  final dynamic apiary;

  const _UnifiedApiaryView({required this.apiaryId, this.apiary});

  @override
  State<_UnifiedApiaryView> createState() => _UnifiedApiaryViewState();
}

class _UnifiedApiaryViewState extends State<_UnifiedApiaryView> {
  dynamic _apiary;

  @override
  void initState() {
    super.initState();
    _loadApiary();
  }

  Future<void> _loadApiary() async {
    // Utiliser les données du rucher passées en paramètre si disponibles
    if (widget.apiary != null) {
      print('🐛 Données du rucher reçues: ${widget.apiary.name}');
      setState(() {
        _apiary = widget.apiary;
      });
    } else {
      print('🐛 Aucune donnée du rucher reçue, utilisation du fallback');
      // Fallback si les données ne sont pas disponibles
      setState(() {
        _apiary = Apiary(
          id: widget.apiaryId,
          name: 'Rucher ${widget.apiaryId.substring(0, 8)}',
          location: 'Emplacement non défini',
          description: 'Description du rucher',
          ownerId: 'temp_owner',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_apiary == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar avec image d'en-tête
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                _apiary!.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 3,
                      color: Colors.black54,
                    ),
                  ],
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.green.shade600,
                      Colors.green.shade400,
                    ],
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.hive,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: () {
                  context
                      .read<HiveBloc>()
                      .add(LoadApiaryHives(widget.apiaryId));
                  context.read<AlertBloc>().add(const LoadAlerts(limit: 20));
                },
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onSelected: (value) => _handleMenuAction(context, value),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 8),
                        Text('Modifier'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Supprimer', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Contenu principal
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Informations du rucher
                  _buildApiaryInfoCard(),
                  const SizedBox(height: 16),

                  // Statistiques du rucher
                  _buildApiaryStatsCard(),
                  const SizedBox(height: 16),

                  // Section des ruches
                  _buildHivesSection(),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateHiveDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle Ruche'),
      ),
    );
  }

  Widget _buildApiaryInfoCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Informations',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.location_on, 'Localisation', _apiary!.location),
            const SizedBox(height: 8),
            _buildInfoRow(
                Icons.description, 'Description', _apiary!.description),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.calendar_today,
              'Créé le',
              _apiary!.createdAt.toString().split(' ')[0],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApiaryStatsCard() {
    return BlocBuilder<HiveBloc, HiveState>(
      builder: (context, hiveState) {
        int hiveCount = 0;
        double avgTemp = 0;
        double avgHumidity = 0;
        int healthyHives = 0;

        if (hiveState is HiveLoaded) {
          hiveCount = hiveState.hives.length;
          if (hiveCount > 0) {
            // TODO: Récupérer les vraies données de capteurs depuis Firebase
            avgTemp = 24.5; // Simulé pour l'instant
            avgHumidity = 65.0; // Simulé pour l'instant
            healthyHives = hiveState.hives
                .where((h) => h.isActive && !h.needsInspection)
                .length;
          }
        }

        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.dashboard, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      'Statistiques',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _StatItem(
                        icon: Icons.hive,
                        label: 'Ruches',
                        value: hiveCount.toString(),
                        color: Colors.amber.shade700,
                      ),
                    ),
                    Expanded(
                      child: _StatItem(
                        icon: Icons.thermostat,
                        label: 'Temp. moy.',
                        value: '${avgTemp.toStringAsFixed(1)}°C',
                        color: Colors.red.shade600,
                      ),
                    ),
                    Expanded(
                      child: _StatItem(
                        icon: Icons.water_drop,
                        label: 'Humid. moy.',
                        value: '${avgHumidity.toStringAsFixed(0)}%',
                        color: Colors.blue.shade600,
                      ),
                    ),
                    Expanded(
                      child: _StatItem(
                        icon: Icons.check_circle,
                        label: 'OK',
                        value: healthyHives.toString(),
                        color: Colors.green.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHivesSection() {
    return BlocBuilder<HiveBloc, HiveState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.grid_view, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Grille des Ruches',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _showCreateHiveDialog(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            switch (state) {
              HiveInitial() => const LoadingWidget(message: 'Chargement...'),
              HiveLoading() => const LoadingWidget(message: 'Chargement...'),
              HiveError() => AppErrorWidget(
                  message: state.message,
                  onRetry: () => context
                      .read<HiveBloc>()
                      .add(LoadApiaryHives(widget.apiaryId)),
                ),
              HiveLoaded() => state.hives.isEmpty
                  ? _buildEmptyHivesState()
                  : _buildHivesGrid(state.hives),
              _ => const LoadingWidget(message: 'Chargement...'),
            },
          ],
        );
      },
    );
  }

  Widget _buildHivesGrid(List<dynamic> hives) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: hives.length,
      itemBuilder: (context, index) {
        final hive = hives[index];
        return HiveCard(
          hive: hive,
          onTap: () => _navigateToHiveDetail(context, hive),
          onEdit: () => _showEditHiveDialog(context, hive),
          onDelete: () => _showDeleteHiveConfirmation(context, hive),
        );
      },
    );
  }

  Widget _buildEmptyHivesState() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.hive_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune ruche',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ajoutez votre première ruche pour commencer',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _showCreateHiveDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Ajouter une ruche'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ),
      ],
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'edit':
        // TODO: Implémenter la modification du rucher
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Modification à implémenter')),
        );
        break;
      case 'delete':
        _showDeleteApiaryConfirmation(context);
        break;
    }
  }

  void _showCreateHiveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<HiveBloc>(),
        child: CreateHiveDialog(apiaryId: widget.apiaryId),
      ),
    );
  }

  void _showEditHiveDialog(BuildContext context, dynamic hive) {
    // TODO: Implémenter la modification d'une ruche
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Modification à implémenter')),
    );
  }

  void _showDeleteHiveConfirmation(BuildContext context, dynamic hive) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la ruche'),
        content: Text('Êtes-vous sûr de vouloir supprimer ${hive.name} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implémenter la suppression
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Suppression à implémenter')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _showDeleteApiaryConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le rucher'),
        content: Text('Êtes-vous sûr de vouloir supprimer ${_apiary!.name} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implémenter la suppression
              Navigator.of(context).pop();
              context.go('/apiaries');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Suppression à implémenter')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _navigateToHiveDetail(BuildContext context, dynamic hive) {
    context.go('/hive/${hive.id}/detail');
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
