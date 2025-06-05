import 'package:flutter/material.dart';

/// Statut d'un rucher
enum ApiaryStatus {
  /// Rucher fonctionnant normalement
  normal,

  /// Rucher nécessitant une attention (alertes mineures)
  warning,

  /// Rucher en situation critique (alertes majeures)
  critical;

  /// Couleur associée au statut
  Color get color {
    switch (this) {
      case ApiaryStatus.normal:
        return Colors.green;
      case ApiaryStatus.warning:
        return Colors.orange;
      case ApiaryStatus.critical:
        return Colors.red;
    }
  }

  /// Icône associée au statut
  IconData get icon {
    switch (this) {
      case ApiaryStatus.normal:
        return Icons.check_circle;
      case ApiaryStatus.warning:
        return Icons.warning;
      case ApiaryStatus.critical:
        return Icons.error;
    }
  }

  /// Emoji représentant le statut
  String get emoji {
    switch (this) {
      case ApiaryStatus.normal:
        return '✅';
      case ApiaryStatus.warning:
        return '⚠️';
      case ApiaryStatus.critical:
        return '❌';
    }
  }

  /// Label lisible du statut
  String get label {
    switch (this) {
      case ApiaryStatus.normal:
        return 'Normal';
      case ApiaryStatus.warning:
        return 'Attention';
      case ApiaryStatus.critical:
        return 'Critique';
    }
  }
}
