import 'package:flutter/material.dart';
import '../../../../core/models/apiary.dart';
import '../../../../core/factories/service_factory.dart';
import 'package:go_router/go_router.dart';

class ApiariesScreen extends StatelessWidget {
  const ApiariesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final coordinator = ServiceFactory.getHiveServiceCoordinator();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Ruchers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Implémenter l'ajout d'un rucher
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Apiary>>(
        future: coordinator.getApiaries(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Erreur: ${snapshot.error}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            );
          }

          final apiaries = snapshot.data;
          if (apiaries == null || apiaries.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.hive_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Aucun rucher disponible',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Implémenter l'ajout d'un rucher
                    },
                    child: const Text('Ajouter un rucher'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: apiaries.length,
            itemBuilder: (context, index) {
              final apiary = apiaries[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: InkWell(
                  onTap: () {
                    context.go('/apiary/${apiary.id}');
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.hive),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                apiary.name,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            Text(
                              '${apiary.hiveIds.length} ruches',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        if (apiary.description != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            apiary.description!,
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              apiary.location,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implémenter l'ajout d'un rucher
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
