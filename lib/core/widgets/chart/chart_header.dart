import 'package:flutter/material.dart';
import '../../../models/time_filter.dart';

class ChartHeader extends StatelessWidget {
  final String title;
  final TimeFilter currentFilter;
  final Function(TimeFilter) onFilterChanged;

  const ChartHeader({
    super.key,
    required this.title,
    required this.currentFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withAlpha(30),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Theme.of(context).primaryColor.withAlpha(50),
              width: 1,
            ),
          ),
          child: DropdownButton<TimeFilter>(
            value: currentFilter,
            onChanged: (TimeFilter? newValue) {
              if (newValue != null) {
                onFilterChanged(newValue);
              }
            },
            icon: Icon(
              Icons.arrow_drop_down,
              color: Theme.of(context).primaryColor,
            ),
            underline: const SizedBox(),
            borderRadius: BorderRadius.circular(10),
            items: TimeFilter.values.map((TimeFilter filter) {
              return DropdownMenuItem<TimeFilter>(
                value: filter,
                child: Text(
                  filter.displayName,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
