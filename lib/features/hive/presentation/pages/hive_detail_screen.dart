import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/hive.dart';
import '../../data/injection/hive_injection.dart';
import '../bloc/hive_bloc.dart';
import '../bloc/hive_event.dart';
import '../widgets/create_hive_dialog.dart';

/// Écran de détail d'une ruche
class HiveDetailScreen extends StatelessWidget {
  final Hive hive;

  const HiveDetailScreen({
    super.key,
    required this.hive,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HiveInjection.getHiveBloc(),
      child: _HiveDetailView(hive: hive),
    );
  }
}

class _HiveDetailView extends StatelessWidget {
  final Hive hive;

  const _HiveDetailView({required this.hive});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(hive.name),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _showEditHiveDialog(context),
            tooltip: 'Modifier',
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(context, value),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'toggle_status',
                child: Row(
                  children: [
                    Icon(hive.isActive ? Icons.pause : Icons.play_arrow),
                    const SizedBox(width: 8),
                    Text(hive.isActive ? 'Désactiver' : 'Activer'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'inspection',
                child: Row(
                  children: [
                    Icon(Icons.search),
                    SizedBox(width: 8),
                    Text('Marquer inspection'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Supprimer', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _HiveStatusCard(hive: hive),
            const SizedBox(height: 16),
            _HiveInfoCard(hive: hive),
            const SizedBox(height: 16),
            _HiveSpecsCard(hive: hive),
            if (hive.description?.isNotEmpty ?? false) ...[
              const SizedBox(height: 16),
              _HiveDescriptionCard(hive: hive),
            ],
            const SizedBox(height: 16),
            _HiveActionsCard(
              hive: hive,
              onInspection: () => _markInspection(context),
              onEdit: () => _showEditHiveDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditHiveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<HiveBloc>(),
        child: CreateHiveDialog(
          apiaryId: hive.apiaryId,
          hive: hive,
        ),
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'toggle_status':
        _toggleHiveStatus(context);
        break;
      case 'inspection':
        _markInspection(context);
        break;
      case 'delete':
        _confirmDelete(context);
        break;
    }
  }

  void _toggleHiveStatus(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(hive.isActive ? 'Ruche désactivée' : 'Ruche activée'),
      ),
    );
  }

  void _markInspection(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Inspection marquée')),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Supprimer la ruche'),
        content: Text('Êtes-vous sûr de vouloir supprimer "${hive.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<HiveBloc>().add(DeleteHiveRequested(hive.id));
              Navigator.of(context).pop();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}

/// Widget de carte de statut de la ruche
class _HiveStatusCard extends StatelessWidget {
  final Hive hive;

  const _HiveStatusCard({required this.hive});

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(context);
    final needsAttention = hive.needsInspection || !hive.isActive;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: needsAttention
              ? Theme.of(context).colorScheme.error.withOpacity(0.3)
              : Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(_getStatusIcon(), color: statusColor, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Statut actuel',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  Text(
                    hive.status,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
            if (!hive.isActive)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Inactive',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(BuildContext context) {
    if (!hive.isActive) return Theme.of(context).colorScheme.error;
    if (hive.needsInspection) return Theme.of(context).colorScheme.error;

    final daysSinceInspection = hive.lastInspection != null
        ? DateTime.now().difference(hive.lastInspection!).inDays
        : 999;

    if (daysSinceInspection > 14) {
      return Theme.of(context).colorScheme.tertiary;
    }
    return Theme.of(context).colorScheme.primary;
  }

  IconData _getStatusIcon() {
    if (!hive.isActive) return Icons.pause_circle_outline;
    if (hive.needsInspection) return Icons.warning_outlined;
    return Icons.check_circle_outline;
  }
}

/// Widget de carte d'informations de la ruche
class _HiveInfoCard extends StatelessWidget {
  final Hive hive;

  const _HiveInfoCard({required this.hive});

  @override
  Widget build(BuildContext context) {
    return Card(
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
            Text(
              'Informations',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            _InfoRow(
              icon: Icons.tag,
              label: 'Identifiant',
              value: hive.id,
            ),
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.calendar_today,
              label: 'Créée le',
              value: _formatDate(hive.createdAt),
            ),
            if (hive.updatedAt != null) ...[
              const SizedBox(height: 12),
              _InfoRow(
                icon: Icons.update,
                label: 'Modifiée le',
                value: _formatDate(hive.updatedAt!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

/// Widget de carte de spécifications de la ruche
class _HiveSpecsCard extends StatelessWidget {
  final Hive hive;

  const _HiveSpecsCard({required this.hive});

  @override
  Widget build(BuildContext context) {
    return Card(
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
            Text(
              'Spécifications',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            if (hive.hiveType != null)
              _SpecRow(
                icon: Icons.home_work,
                label: 'Type',
                value: hive.hiveType!,
              ),
            if (hive.material != null) ...[
              const SizedBox(height: 12),
              _SpecRow(
                icon: Icons.construction,
                label: 'Matériau',
                value: hive.material!,
              ),
            ],
            if (hive.frameCount != null) ...[
              const SizedBox(height: 12),
              _SpecRow(
                icon: Icons.grid_view,
                label: 'Nombre de cadres',
                value: '${hive.frameCount}',
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Widget de carte de description de la ruche
class _HiveDescriptionCard extends StatelessWidget {
  final Hive hive;

  const _HiveDescriptionCard({required this.hive});

  @override
  Widget build(BuildContext context) {
    return Card(
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
            Text(
              'Description',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              hive.description!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget de carte d'actions de la ruche
class _HiveActionsCard extends StatelessWidget {
  final Hive hive;
  final VoidCallback onInspection;
  final VoidCallback onEdit;

  const _HiveActionsCard({
    required this.hive,
    required this.onInspection,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
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
            Text(
              'Actions rapides',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onInspection,
                    icon: const Icon(Icons.search),
                    label: const Text('Marquer inspection'),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.tonal(
                  onPressed: onEdit,
                  child: const Icon(Icons.edit),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget réutilisable pour afficher une ligne d'information
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Widget réutilisable pour afficher une ligne de spécification
class _SpecRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SpecRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
