import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/alert_bloc.dart';
import '../widgets/alert_card.dart';
import '../widgets/alert_filter_chip.dart';

/// Écran principal pour afficher et gérer les alertes
class AlertsScreen extends StatefulWidget {
  final String? hiveId;
  final String? apiaryId;

  const AlertsScreen({
    super.key,
    this.hiveId,
    this.apiaryId,
  });

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  String _currentFilter = 'all';
  final List<String> _filters = ['all', 'unread', 'critical'];

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  void _loadAlerts() {
    final bloc = context.read<AlertBloc>();

    switch (_currentFilter) {
      case 'all':
        if (widget.hiveId != null) {
          bloc.add(LoadHiveAlerts(hiveId: widget.hiveId!));
        } else if (widget.apiaryId != null) {
          bloc.add(LoadApiaryAlerts(apiaryId: widget.apiaryId!));
        } else {
          bloc.add(const LoadAlerts());
        }
        break;
      case 'unread':
        bloc.add(const LoadUnreadAlerts());
        break;
      case 'critical':
        bloc.add(const LoadCriticalAlerts());
        break;
    }
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _currentFilter = filter;
    });
    _loadAlerts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAlerts,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'mark_all_read':
                  _markAllAsRead();
                  break;
                case 'delete_read':
                  _deleteReadAlerts();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'mark_all_read',
                child: Row(
                  children: [
                    Icon(Icons.mark_email_read),
                    SizedBox(width: 8),
                    Text('Marquer tout comme lu'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete_read',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep),
                    SizedBox(width: 8),
                    Text('Supprimer les lues'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtres
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: _filters.map((filter) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: AlertFilterChip(
                    label: _getFilterLabel(filter),
                    isSelected: _currentFilter == filter,
                    onTap: () => _onFilterChanged(filter),
                  ),
                );
              }).toList(),
            ),
          ),

          // Liste des alertes
          Expanded(
            child: BlocConsumer<AlertBloc, AlertState>(
              listener: (context, state) {
                if (state is AlertActionSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else if (state is AlertActionFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is AlertLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (state is AlertError) {
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
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.message,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadAlerts,
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  );
                } else if (state is AlertLoaded) {
                  if (state.alerts.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.notifications_none,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Aucune alerte',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _getEmptyMessage(),
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.grey,
                                ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      _loadAlerts();
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.alerts.length,
                      itemBuilder: (context, index) {
                        final alert = state.alerts[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: AlertCard(
                            alert: alert,
                            onMarkAsRead: () {
                              context.read<AlertBloc>().add(
                                    MarkAlertAsRead(alertId: alert.id!),
                                  );
                            },
                            onDelete: () {
                              _showDeleteConfirmation(alert);
                            },
                          ),
                        );
                      },
                    ),
                  );
                }

                return const Center(
                  child: Text('Aucune donnée'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getTitle() {
    if (widget.hiveId != null) {
      return 'Alertes de la ruche';
    } else if (widget.apiaryId != null) {
      return 'Alertes du rucher';
    }
    return 'Alertes';
  }

  String _getFilterLabel(String filter) {
    switch (filter) {
      case 'all':
        return 'Toutes';
      case 'unread':
        return 'Non lues';
      case 'critical':
        return 'Critiques';
      default:
        return filter;
    }
  }

  String _getEmptyMessage() {
    switch (_currentFilter) {
      case 'all':
        return 'Aucune alerte pour le moment.\nTout va bien !';
      case 'unread':
        return 'Aucune alerte non lue.\nVous êtes à jour !';
      case 'critical':
        return 'Aucune alerte critique.\nVos ruches sont en bonne santé !';
      default:
        return 'Aucune alerte trouvée.';
    }
  }

  void _markAllAsRead() {
    if (widget.hiveId != null) {
      context.read<AlertBloc>().add(
            MarkAllHiveAlertsAsRead(hiveId: widget.hiveId!),
          );
    } else {
      // Pour les alertes générales, marquer toutes comme lues
      final state = context.read<AlertBloc>().state;
      if (state is AlertLoaded) {
        for (final alert in state.alerts) {
          if (alert.id != null && !alert.isRead) {
            context.read<AlertBloc>().add(
                  MarkAlertAsRead(alertId: alert.id!),
                );
          }
        }
      }
    }
  }

  void _deleteReadAlerts() {
    if (widget.hiveId != null) {
      // Implémenter la suppression des alertes lues pour une ruche
      // Cette fonctionnalité nécessiterait un use case supplémentaire
    }
  }

  void _showDeleteConfirmation(alert) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer l\'alerte'),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer cette alerte ? '
          'Cette action ne peut pas être annulée.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<AlertBloc>().add(
                    DeleteAlert(alertId: alert.id!),
                  );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
