import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../data/injection/apiary_injection.dart';
import '../bloc/apiary_bloc.dart';
import '../bloc/apiary_event.dart';
import '../bloc/apiary_state.dart';
import '../widgets/apiary_card.dart';
import '../widgets/create_apiary_dialog.dart';
import 'apiary_detail_screen.dart';

/// Écran principal de gestion des ruchers
class ApiariesScreen extends StatelessWidget {
  const ApiariesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ApiaryInjection.getApiaryBloc()..add(const StartWatchingApiaries()),
      child: const _ApiariesView(),
    );
  }
}

class _ApiariesView extends StatelessWidget {
  const _ApiariesView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Ruchers'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: () {
              context.read<ApiaryBloc>().add(const RefreshApiaries());
            },
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: BlocBuilder<ApiaryBloc, ApiaryState>(
        builder: (context, state) {
          return switch (state) {
            ApiaryInitial() => const Center(child: CircularProgressIndicator()),
            ApiaryLoading() =>
              const LoadingWidget(message: 'Chargement des ruchers...'),
            ApiaryLoadingWithData(apiaries: final apiaries) =>
              _BuildApiariesList(
                apiaries: apiaries,
                isLoading: true,
              ),
            ApiaryLoaded(
              apiaries: final apiaries,
              isWatching: final isWatching
            ) =>
              _BuildApiariesList(
                apiaries: apiaries,
                isRealTime: isWatching,
              ),
            ApiaryEmpty() => _BuildEmptyState(),
            ApiaryError(message: final message, apiaries: final apiaries) =>
              apiaries != null
                  ? _BuildApiariesList(apiaries: apiaries, error: message)
                  : AppErrorWidget(
                      message: message,
                      onRetry: () => context
                          .read<ApiaryBloc>()
                          .add(const LoadUserApiaries()),
                    ),
            _ => const SizedBox.shrink(),
          };
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateApiaryDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Nouveau Rucher'),
      ),
    );
  }

  void _showCreateApiaryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<ApiaryBloc>(),
        child: const CreateApiaryDialog(),
      ),
    );
  }
}

class _BuildApiariesList extends StatelessWidget {
  final List<dynamic> apiaries;
  final bool isLoading;
  final bool isRealTime;
  final String? error;

  const _BuildApiariesList({
    required this.apiaries,
    this.isLoading = false,
    this.isRealTime = false,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Indicateur de statut
        if (isRealTime)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Row(
              children: [
                Icon(
                  Icons.wifi,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Synchronisation temps réel active',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),

        // Message d'erreur
        if (error != null)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_outlined,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Liste des ruchers
        Expanded(
          child: apiaries.isEmpty
              ? _BuildEmptyState()
              : RefreshIndicator(
                  onRefresh: () async {
                    context.read<ApiaryBloc>().add(const RefreshApiaries());
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: apiaries.length,
                    itemBuilder: (context, index) {
                      final apiary = apiaries[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ApiaryCard(
                          apiary: apiary,
                          onTap: () => _navigateToApiaryDetail(context, apiary),
                          onEdit: () => _showEditApiaryDialog(context, apiary),
                          onDelete: () =>
                              _showDeleteConfirmation(context, apiary),
                        ),
                      );
                    },
                  ),
                ),
        ),

        // Indicateur de chargement superposé
        if (isLoading)
          Container(
            height: 4,
            child: const LinearProgressIndicator(),
          ),
      ],
    );
  }

  void _navigateToApiaryDetail(BuildContext context, dynamic apiary) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ApiaryDetailScreen(apiary: apiary),
      ),
    );
  }

  void _showEditApiaryDialog(BuildContext context, dynamic apiary) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<ApiaryBloc>(),
        child: CreateApiaryDialog(apiary: apiary),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, dynamic apiary) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le rucher'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer "${apiary.name}" ?\n\n'
          'Cette action est irréversible et supprimera également toutes les ruches associées.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<ApiaryBloc>().add(DeleteApiaryRequested(apiary.id));
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
}

class _BuildEmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.hive_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun rucher',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Créez votre premier rucher pour commencer à gérer vos ruches.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _showCreateApiaryDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Créer un rucher'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateApiaryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<ApiaryBloc>(),
        child: const CreateApiaryDialog(),
      ),
    );
  }
}
