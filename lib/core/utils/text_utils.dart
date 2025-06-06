/// Utilitaires pour le formatage et la gestion de texte
class TextUtils {
  /// Retourne le texte avec le bon pluriel pour le nombre de ruches
  static String getHiveCountText(int count) {
    if (count == 0) return 'Aucune ruche';
    if (count == 1) return '1 ruche';
    return '$count ruches';
  }

  /// Retourne le texte avec le bon pluriel pour le nombre de ruchers
  static String getApiaryCountText(int count) {
    if (count == 0) return 'Aucun rucher';
    if (count == 1) return '1 rucher';
    return '$count ruchers';
  }

  /// Retourne le texte avec le bon pluriel pour le nombre d'alertes
  static String getAlertCountText(int count) {
    if (count == 0) return 'Aucune alerte';
    if (count == 1) return '1 alerte';
    return '$count alertes';
  }

  /// Formatage générique pour le pluriel
  static String formatCount(int count, String singular, String plural,
      {String? zero}) {
    if (count == 0 && zero != null) return zero;
    if (count <= 1) return '$count $singular';
    return '$count $plural';
  }

  /// Capitalise la première lettre d'une chaîne
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  /// Tronque un texte à une longueur donnée avec des points de suspension
  static String truncate(String text, int maxLength, {String suffix = '...'}) {
    if (text.length <= maxLength) return text;
    return text.substring(0, maxLength - suffix.length) + suffix;
  }
}
