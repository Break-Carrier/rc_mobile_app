import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../hive/data/injection/hive_injection.dart';
import '../../../hive/presentation/bloc/hive_bloc.dart';
import '../../../hive/presentation/bloc/hive_event.dart';
import '../../../hive/presentation/bloc/hive_state.dart';
import '../../../hive/presentation/widgets/hive_card.dart';
import '../../../hive/presentation/widgets/create_hive_dialog.dart';
import '../../domain/entities/apiary.dart';

/// Écran de détail d'un rucher avec ses ruches
class ApiaryDetailScreen extends StatelessWidget {
  final Apiary apiary;

  const ApiaryDetailScreen({
    super.key,
    required this.apiary,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          HiveInjection.getHiveBloc()..add(LoadApiaryHives(apiary.id)),
      child: _ApiaryDetailView(apiary: apiary),
    );
  }
}

class _ApiaryDetailView extends StatelessWidget {
  final Apiary apiary;

  const _ApiaryDetailView({required this.apiary});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar avec image d'en-tête
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                apiary.name,
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
                      Theme.of(context).colorScheme.primary.withOpacity(0.8),
                      Theme.of(context).colorScheme.primaryContainer,
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
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      // TODO: Naviguer vers l'édition
                      break;
                    case 'delete':
                      _showDeleteConfirmation(context);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined),
                        SizedBox(width: 8),
                        Text('Modifier'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outlined, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Supprimer', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Informations du rucher
          SliverToBoxAdapter(
            child: _buildApiaryInfo(context),
          ),

          // Liste des ruches
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text(
                    'Ruches',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: () => _showCreateHiveDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Ajouter'),
                  ),
                ],
              ),
            ),
          ),

          // Contenu des ruches
          BlocBuilder<HiveBloc, HiveState>(
            builder: (context, state) {
              return switch (state) {
                HiveInitial() => const SliverToBoxAdapter(
                    child: LoadingWidget(message: 'Chargement des ruches...'),
                  ),
                HiveLoading() => const SliverToBoxAdapter(
                    child: LoadingWidget(message: 'Chargement des ruches...'),
                  ),
                HiveLoaded(hives: final hives) => hives.isEmpty
                    ? SliverToBoxAdapter(child: _buildEmptyHives(context))
                    : SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final hive = hives[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: HiveCard(
                                  hive: hive,
                                  onTap: () =>
                                      _navigateToHiveDetail(context, hive),
                                  onEdit: () =>
                                      _showEditHiveDialog(context, hive),
                                  onDelete: () => _showDeleteHiveConfirmation(
                                      context, hive),
                                ),
                              );
                            },
                            childCount: hives.length,
                          ),
                        ),
                      ),
                HiveError(message: final message) => SliverToBoxAdapter(
                    child: AppErrorWidget(
                      message: message,
                      onRetry: () => context.read<HiveBloc>().add(
                            LoadApiaryHives(apiary.id),
                          ),
                    ),
                  ),
                _ => const SliverToBoxAdapter(
                    child: SizedBox.shrink(),
                  ),
              };
            },
          ),

          // Espacement en bas
          const SliverToBoxAdapter(
            child: SizedBox(height: 80),
          ),
        ],
      ),
    );
  }

  Widget _buildApiaryInfo(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Informations',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Localisation
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 20,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      apiary.location,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),

              if (apiary.description.isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.description_outlined,
                      size: 20,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        apiary.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 12),

              // Statistiques
              Row(
                children: [
                  _StatItem(
                    icon: Icons.widgets_outlined,
                    label: 'Ruches',
                    value: '${apiary.hiveCount}',
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  const SizedBox(width: 16),
                  _StatItem(
                    icon: Icons.calendar_today_outlined,
                    label: 'Créé le',
                    value: _formatDate(apiary.createdAt),
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                ],
              ),

              if (apiary.hasCoordinates) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.gps_fixed,
                      size: 20,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'GPS: ${apiary.latitude?.toStringAsFixed(4) ?? '0.0000'}, ${apiary.longitude?.toStringAsFixed(4) ?? '0.0000'}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyHives(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.widgets_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune ruche',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ajoutez votre première ruche à ce rucher.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => _showCreateHiveDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Ajouter une ruche'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  void _showCreateHiveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<HiveBloc>(),
        child: CreateHiveDialog(apiaryId: apiary.id),
      ),
    );
  }

  void _showEditHiveDialog(BuildContext context, dynamic hive) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<HiveBloc>(),
        child: CreateHiveDialog(apiaryId: apiary.id, hive: hive),
      ),
    );
  }

  void _showDeleteHiveConfirmation(BuildContext context, dynamic hive) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la ruche'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer "${hive.name}" ?\n\n'
          'Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<HiveBloc>().add(DeleteHiveRequested(hive.id));
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le rucher'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer "${apiary.name}" ?\n\n'
          'Cette action supprimera également toutes les ruches associées.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Retour à la liste
              // TODO: Déclencher suppression rucher
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _navigateToHiveDetail(BuildContext context, dynamic hive) {
    // TODO: Naviguer vers détail ruche
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Détail de ${hive.name} - À implémenter')),
    );
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
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
