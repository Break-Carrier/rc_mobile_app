import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../domain/bloc/apiaries_bloc.dart';
import '../../data/repositories/apiary_repository.dart';
import '../../../../services/sensor_service.dart';
import '../../../../models/apiary.dart';
import '../widgets/apiary_card.dart';

class ApiariesScreen extends StatelessWidget {
  const ApiariesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sensorService = Provider.of<SensorService>(context, listen: false);

    return BlocProvider(
      create: (context) => ApiariesBloc(
        apiaryRepository: ApiaryRepository(sensorService: sensorService),
      )..add(LoadApiaries()),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ApiariesBloc>().add(RefreshApiaries());
            },
          ),
        ],
      ),
      body: BlocBuilder<ApiariesBloc, ApiariesState>(
        builder: (context, state) {
          return _buildBody(context, state);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implémenter l'ajout d'un rucher
          _showAddApiaryDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ApiariesState state) {
    if (state is ApiariesInitial || state is ApiariesLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else if (state is ApiariesLoaded) {
      return _buildApiariesList(context, state.apiaries);
    } else if (state is ApiaryOperationSuccess) {
      // Afficher un message de succès temporaire
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.message),
            backgroundColor: Colors.green,
          ),
        );
      });

      return BlocBuilder<ApiariesBloc, ApiariesState>(
        builder: (context, state) {
          if (state is ApiariesLoaded) {
            return _buildApiariesList(context, state.apiaries);
          }
          return const Center(child: CircularProgressIndicator());
        },
      );
    } else if (state is ApiariesError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            Text(
              'Erreur',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(state.message),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.read<ApiariesBloc>().add(LoadApiaries());
              },
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    return const SizedBox();
  }

  Widget _buildApiariesList(BuildContext context, List<Apiary> apiaries) {
    if (apiaries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.storefront,
              size: 64,
              color: Colors.amber,
            ),
            const SizedBox(height: 16),
            const Text(
              'Aucun rucher disponible',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ajoutez un rucher pour commencer',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                _showAddApiaryDialog(context);
              },
              icon: const Icon(Icons.add),
              label: const Text('Ajouter un rucher'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<ApiariesBloc>().add(RefreshApiaries());
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: apiaries.length,
        itemBuilder: (context, index) {
          final apiary = apiaries[index];
          return ApiaryCard(
            apiary: apiary,
            onTap: () {
              context.go('/apiary/${apiary.id}');
            },
            onEdit: () {
              // TODO: Implémenter la modification d'un rucher
            },
            onDelete: () {
              _showDeleteApiaryDialog(context, apiary);
            },
          );
        },
      ),
    );
  }

  void _showAddApiaryDialog(BuildContext context) {
    // TODO: Implémenter l'ajout d'un rucher

    // Pour l'instant, afficher un message d'information
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Fonctionnalité en développement'),
        content:
            const Text('Cette fonctionnalité n\'est pas encore implémentée.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showDeleteApiaryDialog(BuildContext context, Apiary apiary) {
    // TODO: Implémenter la suppression d'un rucher

    // Pour l'instant, afficher un message d'information
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Fonctionnalité en développement'),
        content:
            const Text('Cette fonctionnalité n\'est pas encore implémentée.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
