import 'package:equatable/equatable.dart';

/// Entité de base pour tous les objets supportant le soft delete
///
/// Cette classe abstraite fournit les propriétés et méthodes communes
/// pour gérer la suppression logique des données.
abstract class SoftDeletableEntity extends Equatable {
  /// Indique si l'entité est supprimée (soft delete)
  final bool isDeleted;

  /// Date de suppression (null si pas supprimé)
  final DateTime? deletedAt;

  /// ID de l'utilisateur qui a effectué la suppression
  final String? deletedBy;

  /// Raison de la suppression (optionnelle)
  final String? deletionReason;

  /// Version de l'entité pour le contrôle de concurrence optimiste
  final int version;

  /// Date de création de l'entité
  final DateTime createdAt;

  /// Date de dernière modification
  final DateTime updatedAt;

  /// ID de l'utilisateur qui a créé l'entité
  final String? createdBy;

  /// ID de l'utilisateur qui a effectué la dernière modification
  final String? updatedBy;

  const SoftDeletableEntity({
    this.isDeleted = false,
    this.deletedAt,
    this.deletedBy,
    this.deletionReason,
    this.version = 1,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  /// Vérifie si l'entité est active (non supprimée)
  bool get isActive => !isDeleted;

  /// Vérifie si l'entité peut être restaurée
  bool get canBeRestored => isDeleted && deletedAt != null;

  /// Retourne la durée depuis la suppression
  Duration? get timeSinceDeletion {
    if (deletedAt == null) return null;
    return DateTime.now().difference(deletedAt!);
  }

  /// Vérifie si la suppression est récente (moins de 30 jours par défaut)
  bool isRecentlyDeleted([Duration threshold = const Duration(days: 30)]) {
    final duration = timeSinceDeletion;
    return duration != null && duration <= threshold;
  }

  @override
  List<Object?> get props => [
        isDeleted,
        deletedAt,
        deletedBy,
        deletionReason,
        version,
        createdAt,
        updatedAt,
        createdBy,
        updatedBy,
      ];
}

/// Informations de suppression pour le soft delete
class DeletionInfo extends Equatable {
  /// ID de l'utilisateur effectuant la suppression
  final String deletedBy;

  /// Raison de la suppression
  final String reason;

  /// Date de suppression (auto-générée si null)
  final DateTime? deletedAt;

  /// Métadonnées additionnelles
  final Map<String, dynamic>? metadata;

  const DeletionInfo({
    required this.deletedBy,
    required this.reason,
    this.deletedAt,
    this.metadata,
  });

  /// Date effective de suppression
  DateTime get effectiveDeletionDate => deletedAt ?? DateTime.now();

  DeletionInfo copyWith({
    String? deletedBy,
    String? reason,
    DateTime? deletedAt,
    Map<String, dynamic>? metadata,
  }) {
    return DeletionInfo(
      deletedBy: deletedBy ?? this.deletedBy,
      reason: reason ?? this.reason,
      deletedAt: deletedAt ?? this.deletedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [deletedBy, reason, deletedAt, metadata];
}

/// Informations de restauration
class RestorationInfo extends Equatable {
  /// ID de l'utilisateur effectuant la restauration
  final String restoredBy;

  /// Raison de la restauration
  final String reason;

  /// Date de restauration (auto-générée si null)
  final DateTime? restoredAt;

  /// Métadonnées additionnelles
  final Map<String, dynamic>? metadata;

  const RestorationInfo({
    required this.restoredBy,
    required this.reason,
    this.restoredAt,
    this.metadata,
  });

  /// Date effective de restauration
  DateTime get effectiveRestorationDate => restoredAt ?? DateTime.now();

  RestorationInfo copyWith({
    String? restoredBy,
    String? reason,
    DateTime? restoredAt,
    Map<String, dynamic>? metadata,
  }) {
    return RestorationInfo(
      restoredBy: restoredBy ?? this.restoredBy,
      reason: reason ?? this.reason,
      restoredAt: restoredAt ?? this.restoredAt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [restoredBy, reason, restoredAt, metadata];
}

/// Énumération des raisons de suppression communes
enum DeletionReason {
  userRequest('user_request', 'Demande de l\'utilisateur'),
  adminAction('admin_action', 'Action administrative'),
  dataCleanup('data_cleanup', 'Nettoyage des données'),
  securityBreach('security_breach', 'Problème de sécurité'),
  duplicateData('duplicate_data', 'Données dupliquées'),
  invalidData('invalid_data', 'Données invalides'),
  regulatoryCompliance('regulatory_compliance', 'Conformité réglementaire'),
  systemMigration('system_migration', 'Migration système'),
  other('other', 'Autre');

  const DeletionReason(this.value, this.displayName);

  final String value;
  final String displayName;

  static DeletionReason fromString(String value) {
    return DeletionReason.values.firstWhere(
      (reason) => reason.value == value,
      orElse: () => DeletionReason.other,
    );
  }
}
