import 'package:intl/intl.dart';

/// Extensions pour DateTime
extension DateTimeExtensions on DateTime {
  /// Formate la date au format français
  String toFrenchFormat() {
    return DateFormat('dd/MM/yyyy à HH:mm').format(this);
  }

  /// Formate seulement l'heure
  String toTimeFormat() {
    return DateFormat('HH:mm').format(this);
  }

  /// Formate seulement la date
  String toDateFormat() {
    return DateFormat('dd/MM/yyyy').format(this);
  }

  /// Retourne le temps écoulé depuis maintenant (ex: "il y a 5 minutes")
  String timeAgo() {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inDays > 0) {
      return 'il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'il y a ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'il y a ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'à l\'instant';
    }
  }

  /// Vérifie si la date est aujourd'hui
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Vérifie si la date est récente (moins d'une heure)
  bool get isRecent {
    return DateTime.now().difference(this).inHours < 1;
  }
}
