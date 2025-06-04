import 'package:flutter/material.dart';
import '../../models/threshold_event.dart';
import '../../factories/service_factory.dart';
import 'event_states.dart';
import 'event_item.dart';
import 'event_pagination.dart';

class ThresholdEvents extends StatefulWidget {
  final int eventsPerPage;

  const ThresholdEvents({
    super.key,
    this.eventsPerPage = 5,
  });

  @override
  State<ThresholdEvents> createState() => _ThresholdEventsState();
}

class _ThresholdEventsState extends State<ThresholdEvents> {
  int _currentPage = 0;
  late final coordinator = ServiceFactory.getHiveServiceCoordinator();

  @override
  Widget build(BuildContext context) {
    // Si aucune ruche n'est sélectionnée, on n'affiche pas le widget
    if (coordinator.currentHiveId == null) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Événements de dépassement de seuil',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => setState(() {}),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildEventsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsList() {
    return StreamBuilder<List<ThresholdEvent>>(
      stream: coordinator.getThresholdEventsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const EventLoadingState();
        }

        if (snapshot.hasError) {
          return EventErrorState(error: snapshot.error.toString());
        }

        final events = snapshot.data ?? [];
        if (events.isEmpty) {
          return const EventEmptyState();
        }

        return _buildPaginatedEvents(events);
      },
    );
  }

  Widget _buildPaginatedEvents(List<ThresholdEvent> events) {
    // Calculer le nombre total de pages
    final int totalPages = (events.length / widget.eventsPerPage).ceil();

    // S'assurer que la page actuelle est valide
    if (_currentPage >= totalPages) {
      _currentPage = totalPages - 1;
    }
    if (_currentPage < 0) {
      _currentPage = 0;
    }

    // Calculer les indices de début et de fin pour la page actuelle
    final int startIndex = _currentPage * widget.eventsPerPage;
    final int endIndex =
        (startIndex + widget.eventsPerPage).clamp(0, events.length);

    // Obtenir les événements pour la page actuelle
    final List<ThresholdEvent> pageEvents =
        events.sublist(startIndex, endIndex);

    return Column(
      children: [
        // Liste des événements de la page actuelle
        ...pageEvents.map((event) => EventItem(event: event)),

        // Pagination si nécessaire
        if (totalPages > 1)
          EventPagination(
            currentPage: _currentPage,
            totalPages: totalPages,
            onPrevious: () {
              if (_currentPage > 0) setState(() => _currentPage--);
            },
            onNext: () {
              if (_currentPage < totalPages - 1) setState(() => _currentPage++);
            },
          ),
      ],
    );
  }
}
