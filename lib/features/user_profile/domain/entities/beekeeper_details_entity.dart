import 'package:equatable/equatable.dart';

/// Entité représentant les détails spécifiques d'un apiculteur
///
/// Cette entité contient toutes les informations métier spécifiques
/// au profil d'apiculteur, séparées du profil utilisateur de base.
class BeekeeperDetailsEntity extends Equatable {
  /// Numéro d'identification apiculteur (NAPI ou équivalent)
  final String? beekeeperId;

  /// Nombre d'années d'expérience en apiculture
  final int? yearsOfExperience;

  /// Type d'apiculture pratiquée
  final BeekeepingType beekeepingType;

  /// Certifications obtenues
  final List<String> certifications;

  /// Nombre total de ruches possédées
  final int totalHives;

  /// Production annuelle moyenne (en kg)
  final double? annualProduction;

  /// Préférences de notification
  final BeekeeperNotificationPreferences notificationPreferences;

  /// Informations d'assurance
  final String? insuranceCompany;
  final String? insurancePolicyNumber;
  final DateTime? insuranceExpiryDate;

  /// Statut de validation par l'administration
  final BeekeeperValidationStatus validationStatus;

  /// Date de validation (si validé)
  final DateTime? validatedAt;

  /// Commentaires de l'administrateur lors de la validation
  final String? adminComments;

  /// Informations supplémentaires
  final String? notes;

  const BeekeeperDetailsEntity({
    this.beekeeperId,
    this.yearsOfExperience,
    this.beekeepingType = BeekeepingType.hobbyist,
    this.certifications = const [],
    this.totalHives = 0,
    this.annualProduction,
    this.notificationPreferences = const BeekeeperNotificationPreferences(),
    this.insuranceCompany,
    this.insurancePolicyNumber,
    this.insuranceExpiryDate,
    this.validationStatus = BeekeeperValidationStatus.pending,
    this.validatedAt,
    this.adminComments,
    this.notes,
  });

  /// Vérifie si l'apiculteur est professionnel
  bool get isProfessional =>
      beekeepingType == BeekeepingType.professional ||
      beekeepingType == BeekeepingType.commercial;

  /// Vérifie si l'assurance est valide
  bool get hasValidInsurance {
    if (insuranceExpiryDate == null) return false;
    return insuranceExpiryDate!.isAfter(DateTime.now());
  }

  /// Vérifie si le profil apiculteur est complet
  bool get isComplete {
    return beekeeperId != null &&
        yearsOfExperience != null &&
        (isProfessional ? hasValidInsurance : true);
  }

  BeekeeperDetailsEntity copyWith({
    String? beekeeperId,
    int? yearsOfExperience,
    BeekeepingType? beekeepingType,
    List<String>? certifications,
    int? totalHives,
    double? annualProduction,
    BeekeeperNotificationPreferences? notificationPreferences,
    String? insuranceCompany,
    String? insurancePolicyNumber,
    DateTime? insuranceExpiryDate,
    BeekeeperValidationStatus? validationStatus,
    DateTime? validatedAt,
    String? adminComments,
    String? notes,
  }) {
    return BeekeeperDetailsEntity(
      beekeeperId: beekeeperId ?? this.beekeeperId,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      beekeepingType: beekeepingType ?? this.beekeepingType,
      certifications: certifications ?? this.certifications,
      totalHives: totalHives ?? this.totalHives,
      annualProduction: annualProduction ?? this.annualProduction,
      notificationPreferences:
          notificationPreferences ?? this.notificationPreferences,
      insuranceCompany: insuranceCompany ?? this.insuranceCompany,
      insurancePolicyNumber:
          insurancePolicyNumber ?? this.insurancePolicyNumber,
      insuranceExpiryDate: insuranceExpiryDate ?? this.insuranceExpiryDate,
      validationStatus: validationStatus ?? this.validationStatus,
      validatedAt: validatedAt ?? this.validatedAt,
      adminComments: adminComments ?? this.adminComments,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
        beekeeperId,
        yearsOfExperience,
        beekeepingType,
        certifications,
        totalHives,
        annualProduction,
        notificationPreferences,
        insuranceCompany,
        insurancePolicyNumber,
        insuranceExpiryDate,
        validationStatus,
        validatedAt,
        adminComments,
        notes,
      ];
}

/// Types d'apiculture pratiquée
enum BeekeepingType {
  hobbyist('hobbyist', 'Amateur'),
  semiProfessional('semi_professional', 'Semi-professionnel'),
  professional('professional', 'Professionnel'),
  commercial('commercial', 'Commercial');

  const BeekeepingType(this.value, this.displayName);

  final String value;
  final String displayName;

  static BeekeepingType fromString(String value) {
    return BeekeepingType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => BeekeepingType.hobbyist,
    );
  }
}

/// Statut de validation d'un apiculteur
enum BeekeeperValidationStatus {
  pending('pending', 'En attente'),
  approved('approved', 'Approuvé'),
  rejected('rejected', 'Rejeté'),
  suspended('suspended', 'Suspendu');

  const BeekeeperValidationStatus(this.value, this.displayName);

  final String value;
  final String displayName;

  static BeekeeperValidationStatus fromString(String value) {
    return BeekeeperValidationStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => BeekeeperValidationStatus.pending,
    );
  }
}

/// Préférences de notification pour les apiculteurs
class BeekeeperNotificationPreferences extends Equatable {
  /// Notifications pour les alertes de ruche
  final bool hiveAlerts;

  /// Notifications pour les conditions météo
  final bool weatherAlerts;

  /// Notifications pour les tâches d'entretien
  final bool maintenanceReminders;

  /// Notifications pour les mises à jour administratives
  final bool adminUpdates;

  /// Notifications par email
  final bool emailNotifications;

  /// Notifications push
  final bool pushNotifications;

  const BeekeeperNotificationPreferences({
    this.hiveAlerts = true,
    this.weatherAlerts = true,
    this.maintenanceReminders = true,
    this.adminUpdates = true,
    this.emailNotifications = true,
    this.pushNotifications = true,
  });

  BeekeeperNotificationPreferences copyWith({
    bool? hiveAlerts,
    bool? weatherAlerts,
    bool? maintenanceReminders,
    bool? adminUpdates,
    bool? emailNotifications,
    bool? pushNotifications,
  }) {
    return BeekeeperNotificationPreferences(
      hiveAlerts: hiveAlerts ?? this.hiveAlerts,
      weatherAlerts: weatherAlerts ?? this.weatherAlerts,
      maintenanceReminders: maintenanceReminders ?? this.maintenanceReminders,
      adminUpdates: adminUpdates ?? this.adminUpdates,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
    );
  }

  @override
  List<Object?> get props => [
        hiveAlerts,
        weatherAlerts,
        maintenanceReminders,
        adminUpdates,
        emailNotifications,
        pushNotifications,
      ];
}
