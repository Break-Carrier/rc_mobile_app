import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/threshold_event.dart';
import '../../../services/sensor_service.dart';
import 'event_states.dart';
import 'event_item.dart';
import 'event_pagination.dart';

class ThresholdEvents extends StatefulWidget {
  const ThresholdEvents({super.key});

  @override
  State<ThresholdEvents> createState() => _ThresholdEventsState();
}

class _ThresholdEventsState extends State<ThresholdEvents> {
  static const int _eventsPerPage = 5;
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final sensorService = Provider.of<SensorService>(context);

    // Si aucune ruche n'est sélectionnée, on n'affiche pas le widget
    if (sensorService.currentHiveId == null) {
      return const SizedBox();
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Événements de dépassement',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildEventsList(sensorService),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsList(SensorService sensorService) {
    return StreamBuilder<List<ThresholdEvent>>(
      stream: sensorService.getThresholdEvents(),
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
    final int totalPages = (events.length / _eventsPerPage).ceil();

    // S'assurer que la page actuelle est valide
    if (_currentPage >= totalPages) {
      _currentPage = totalPages - 1;
    }

    // Calculer les indices de début et fin pour la page actuelle
    final int startIndex = _currentPage * _eventsPerPage;
    final int endIndex = (startIndex + _eventsPerPage < events.length)
        ? startIndex + _eventsPerPage
        : events.length;

    // Obtenir les événements pour la page actuelle
    final List<ThresholdEvent> pageEvents =
        events.sublist(startIndex, endIndex);

    return Column(
      children: [
        // Liste des événements
        ...pageEvents.map((event) => EventItem(event: event)),

        // Pagination
        EventPagination(
          currentPage: _currentPage,
          totalPages: totalPages,
          onPrevious: () => setState(() => _currentPage--),
          onNext: () => setState(() => _currentPage++),
        ),
      ],
    );
  }
}
