import 'package:flutter/material.dart';
import '../../../features/sensor/domain/entities/time_filter.dart';

/// En-tête du graphique avec sélecteur de filtre temporel
class ChartHeader extends StatelessWidget {
  final TimeFilter selectedFilter;
  final ValueChanged<TimeFilter> onFilterChanged;

  const ChartHeader({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Données des capteurs',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Row(
            children: [
              Text(
                'Période: ',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              DropdownButton<TimeFilter>(
                value: selectedFilter,
                onChanged: (TimeFilter? newValue) {
                  if (newValue != null) {
                    onFilterChanged(newValue);
                  }
                },
                items: TimeFilter.values
                    .map<DropdownMenuItem<TimeFilter>>((TimeFilter value) {
                  return DropdownMenuItem<TimeFilter>(
                    value: value,
                    child: Text(value.displayName),
                  );
                }).toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
