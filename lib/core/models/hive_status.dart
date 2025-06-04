import 'package:flutter/material.dart';

/// Statut d'une ruche
enum HiveStatus {
  /// Ruche fonctionnant normalement
  normal,

  /// Ruche nécessitant une attention (alertes mineures)
  warning,

  /// Ruche en situation critique (alertes majeures)
  critical;

  /// Couleur associée au statut
  Color get color {
    switch (this) {
      case HiveStatus.normal:
        return Colors.green;
      case HiveStatus.warning:
        return Colors.orange;
      case HiveStatus.critical:
        return Colors.red;
    }
  }

  /// Icône associée au statut
  IconData get icon {
    switch (this) {
      case HiveStatus.normal:
        return Icons.check_circle;
      case HiveStatus.warning:
        return Icons.warning;
      case HiveStatus.critical:
        return Icons.error;
    }
  }

  /// Emoji représentant le statut
  String get emoji {
    switch (this) {
      case HiveStatus.normal:
        return '✅';
      case HiveStatus.warning:
        return '⚠️';
      case HiveStatus.critical:
        return '❌';
    }
  }

  /// Label lisible du statut
  String get label {
    switch (this) {
      case HiveStatus.normal:
        return 'Normal';
      case HiveStatus.warning:
        return 'Attention';
      case HiveStatus.critical:
        return 'Critique';
    }
  }
}
