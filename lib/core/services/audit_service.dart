import 'package:equatable/equatable.dart';
import '../error/app_error.dart';

/// Service d'audit pour traquer les actions sensibles
///
/// Enregistre toutes les opérations de suppression, restauration
/// et modifications importantes pour assurer la traçabilité.
class AuditService {
  // Interface pour la persistance des logs d'audit
  final AuditRepository _auditRepository;

  const AuditService(this._auditRepository);

  /// Enregistre une action de suppression logique
  Future<AuditResult<void>> logSoftDeletion({
    required String entityType,
    required String entityId,
    required String performedBy,
    required String reason,
    Map<String, dynamic>? additionalData,
  }) async {
    final auditEntry = AuditEntry(
      action: AuditAction.softDelete,
      entityType: entityType,
      entityId: entityId,
      performedBy: performedBy,
      timestamp: DateTime.now(),
      details: AuditDetails(
        reason: reason,
        additionalData: additionalData,
      ),
    );

    return await _auditRepository.createAuditEntry(auditEntry);
  }

  /// Enregistre une action de restauration
  Future<AuditResult<void>> logRestoration({
    required String entityType,
    required String entityId,
    required String performedBy,
    required String reason,
    Map<String, dynamic>? additionalData,
  }) async {
    final auditEntry = AuditEntry(
      action: AuditAction.restore,
      entityType: entityType,
      entityId: entityId,
      performedBy: performedBy,
      timestamp: DateTime.now(),
      details: AuditDetails(
        reason: reason,
        additionalData: additionalData,
      ),
    );

    return await _auditRepository.createAuditEntry(auditEntry);
  }

  /// Enregistre une suppression définitive
  Future<AuditResult<void>> logPermanentDeletion({
    required String entityType,
    required String entityId,
    required String performedBy,
    required String reason,
    Map<String, dynamic>? additionalData,
  }) async {
    final auditEntry = AuditEntry(
      action: AuditAction.permanentDelete,
      entityType: entityType,
      entityId: entityId,
      performedBy: performedBy,
      timestamp: DateTime.now(),
      details: AuditDetails(
        reason: reason,
        additionalData: additionalData,
      ),
      severity: AuditSeverity.critical,
    );

    return await _auditRepository.createAuditEntry(auditEntry);
  }

  /// Récupère l'historique d'audit pour une entité
  Future<AuditResult<List<AuditEntry>>> getEntityAuditHistory({
    required String entityType,
    required String entityId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    return await _auditRepository.getEntityAuditHistory(
      entityType: entityType,
      entityId: entityId,
      fromDate: fromDate,
      toDate: toDate,
    );
  }

  /// Récupère l'historique d'audit par utilisateur
  Future<AuditResult<List<AuditEntry>>> getUserAuditHistory({
    required String userId,
    DateTime? fromDate,
    DateTime? toDate,
    List<AuditAction>? actionFilter,
  }) async {
    return await _auditRepository.getUserAuditHistory(
      userId: userId,
      fromDate: fromDate,
      toDate: toDate,
      actionFilter: actionFilter,
    );
  }

  /// Génère un rapport d'audit pour une période donnée
  Future<AuditResult<AuditReport>> generateAuditReport({
    required DateTime fromDate,
    required DateTime toDate,
    String? entityType,
    List<AuditAction>? actionFilter,
  }) async {
    final entriesResult = await _auditRepository.getAuditEntries(
      fromDate: fromDate,
      toDate: toDate,
      entityType: entityType,
      actionFilter: actionFilter,
    );

    if (entriesResult is AuditFailure<List<AuditEntry>>) {
      return AuditFailure(entriesResult.error);
    }

    final entries = (entriesResult as AuditSuccess<List<AuditEntry>>).data;

    final report = AuditReport(
      period: DateRange(fromDate, toDate),
      totalActions: entries.length,
      actionBreakdown: _calculateActionBreakdown(entries),
      userBreakdown: _calculateUserBreakdown(entries),
      entityBreakdown: _calculateEntityBreakdown(entries),
      criticalActions:
          entries.where((e) => e.severity == AuditSeverity.critical).toList(),
    );

    return AuditSuccess(report);
  }

  Map<AuditAction, int> _calculateActionBreakdown(List<AuditEntry> entries) {
    final breakdown = <AuditAction, int>{};
    for (final entry in entries) {
      breakdown[entry.action] = (breakdown[entry.action] ?? 0) + 1;
    }
    return breakdown;
  }

  Map<String, int> _calculateUserBreakdown(List<AuditEntry> entries) {
    final breakdown = <String, int>{};
    for (final entry in entries) {
      breakdown[entry.performedBy] = (breakdown[entry.performedBy] ?? 0) + 1;
    }
    return breakdown;
  }

  Map<String, int> _calculateEntityBreakdown(List<AuditEntry> entries) {
    final breakdown = <String, int>{};
    for (final entry in entries) {
      breakdown[entry.entityType] = (breakdown[entry.entityType] ?? 0) + 1;
    }
    return breakdown;
  }
}

/// Entrée d'audit représentant une action enregistrée
class AuditEntry extends Equatable {
  final String id;
  final AuditAction action;
  final String entityType;
  final String entityId;
  final String performedBy;
  final DateTime timestamp;
  final AuditDetails details;
  final AuditSeverity severity;

  const AuditEntry({
    required this.action,
    required this.entityType,
    required this.entityId,
    required this.performedBy,
    required this.timestamp,
    required this.details,
    this.severity = AuditSeverity.normal,
    String? id,
  }) : id = id ?? '';

  @override
  List<Object?> get props => [
        id,
        action,
        entityType,
        entityId,
        performedBy,
        timestamp,
        details,
        severity,
      ];
}

/// Détails d'une action d'audit
class AuditDetails extends Equatable {
  final String reason;
  final Map<String, dynamic>? additionalData;
  final String? ipAddress;
  final String? userAgent;

  const AuditDetails({
    required this.reason,
    this.additionalData,
    this.ipAddress,
    this.userAgent,
  });

  @override
  List<Object?> get props => [reason, additionalData, ipAddress, userAgent];
}

/// Types d'actions auditées
enum AuditAction {
  softDelete('soft_delete', 'Suppression logique'),
  restore('restore', 'Restauration'),
  permanentDelete('permanent_delete', 'Suppression définitive'),
  create('create', 'Création'),
  update('update', 'Modification'),
  roleChange('role_change', 'Changement de rôle'),
  statusChange('status_change', 'Changement de statut'),
  login('login', 'Connexion'),
  logout('logout', 'Déconnexion'),
  passwordChange('password_change', 'Changement de mot de passe');

  const AuditAction(this.value, this.displayName);

  final String value;
  final String displayName;

  static AuditAction fromString(String value) {
    return AuditAction.values.firstWhere(
      (action) => action.value == value,
      orElse: () => AuditAction.update,
    );
  }
}

/// Niveaux de sévérité des actions d'audit
enum AuditSeverity {
  low('low', 'Faible'),
  normal('normal', 'Normal'),
  high('high', 'Élevé'),
  critical('critical', 'Critique');

  const AuditSeverity(this.value, this.displayName);

  final String value;
  final String displayName;

  static AuditSeverity fromString(String value) {
    return AuditSeverity.values.firstWhere(
      (severity) => severity.value == value,
      orElse: () => AuditSeverity.normal,
    );
  }
}

/// Rapport d'audit généré
class AuditReport extends Equatable {
  final DateRange period;
  final int totalActions;
  final Map<AuditAction, int> actionBreakdown;
  final Map<String, int> userBreakdown;
  final Map<String, int> entityBreakdown;
  final List<AuditEntry> criticalActions;

  const AuditReport({
    required this.period,
    required this.totalActions,
    required this.actionBreakdown,
    required this.userBreakdown,
    required this.entityBreakdown,
    required this.criticalActions,
  });

  @override
  List<Object> get props => [
        period,
        totalActions,
        actionBreakdown,
        userBreakdown,
        entityBreakdown,
        criticalActions,
      ];
}

/// Plage de dates pour les rapports
class DateRange extends Equatable {
  final DateTime start;
  final DateTime end;

  const DateRange(this.start, this.end);

  Duration get duration => end.difference(start);

  @override
  List<Object> get props => [start, end];
}

/// Résultat d'une opération d'audit
sealed class AuditResult<T> {
  const AuditResult();
}

class AuditSuccess<T> extends AuditResult<T> {
  final T data;
  const AuditSuccess(this.data);
}

class AuditFailure<T> extends AuditResult<T> {
  final AppError error;
  const AuditFailure(this.error);
}

/// Interface du repository d'audit
abstract class AuditRepository {
  Future<AuditResult<void>> createAuditEntry(AuditEntry entry);

  Future<AuditResult<List<AuditEntry>>> getEntityAuditHistory({
    required String entityType,
    required String entityId,
    DateTime? fromDate,
    DateTime? toDate,
  });

  Future<AuditResult<List<AuditEntry>>> getUserAuditHistory({
    required String userId,
    DateTime? fromDate,
    DateTime? toDate,
    List<AuditAction>? actionFilter,
  });

  Future<AuditResult<List<AuditEntry>>> getAuditEntries({
    DateTime? fromDate,
    DateTime? toDate,
    String? entityType,
    List<AuditAction>? actionFilter,
  });
}
