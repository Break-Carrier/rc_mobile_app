import 'package:equatable/equatable.dart';

/// Profil utilisateur étendu stocké dans Realtime Database
///
/// Cette entité contient les données métier spécifiques à l'apiculteur
/// et est liée à l'utilisateur Firebase Authentication par l'UID.
///
/// Stockage: /users/{firebase_uid}/profile
class UserProfile extends Equatable {
  /// UID Firebase de l'utilisateur (clé de liaison)
  final String uid;

  /// Nom complet de l'apiculteur
  final String? fullName;

  /// Rôle de l'utilisateur dans l'application
  final UserRole role;

  /// IDs des ruchers appartenant à cet utilisateur
  final List<String> apiaryIds;

  /// Préférences utilisateur
  final UserPreferences preferences;

  /// Informations de contact
  final ContactInfo? contactInfo;

  /// Date de création du profil
  final DateTime createdAt;

  /// Dernière mise à jour du profil
  final DateTime updatedAt;

  const UserProfile({
    required this.uid,
    this.fullName,
    this.role = UserRole.apiculteur,
    this.apiaryIds = const [],
    this.preferences = const UserPreferences(),
    this.contactInfo,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Copie le profil avec de nouvelles valeurs
  UserProfile copyWith({
    String? uid,
    String? fullName,
    UserRole? role,
    List<String>? apiaryIds,
    UserPreferences? preferences,
    ContactInfo? contactInfo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      apiaryIds: apiaryIds ?? this.apiaryIds,
      preferences: preferences ?? this.preferences,
      contactInfo: contactInfo ?? this.contactInfo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Ajoute un rucher au profil
  UserProfile addApiary(String apiaryId) {
    if (apiaryIds.contains(apiaryId)) return this;

    return copyWith(
      apiaryIds: [...apiaryIds, apiaryId],
      updatedAt: DateTime.now(),
    );
  }

  /// Supprime un rucher du profil
  UserProfile removeApiary(String apiaryId) {
    return copyWith(
      apiaryIds: apiaryIds.where((id) => id != apiaryId).toList(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        uid,
        fullName,
        role,
        apiaryIds,
        preferences,
        contactInfo,
        createdAt,
        updatedAt,
      ];
}

/// Rôles utilisateur dans l'application
enum UserRole {
  apiculteur('Apiculteur'),
  technicien('Technicien'),
  administrateur('Administrateur');

  const UserRole(this.displayName);
  final String displayName;
}

/// Préférences utilisateur
class UserPreferences extends Equatable {
  /// Langue de l'interface
  final String language;

  /// Notifications push activées
  final bool notificationsEnabled;

  /// Notifications par email activées
  final bool emailNotificationsEnabled;

  /// Seuils d'alerte par défaut
  final double defaultTempThresholdHigh;
  final double defaultTempThresholdLow;
  final double defaultHumidityThresholdHigh;
  final double defaultHumidityThresholdLow;

  const UserPreferences({
    this.language = 'fr',
    this.notificationsEnabled = true,
    this.emailNotificationsEnabled = true,
    this.defaultTempThresholdHigh = 35.0,
    this.defaultTempThresholdLow = 10.0,
    this.defaultHumidityThresholdHigh = 80.0,
    this.defaultHumidityThresholdLow = 30.0,
  });

  UserPreferences copyWith({
    String? language,
    bool? notificationsEnabled,
    bool? emailNotificationsEnabled,
    double? defaultTempThresholdHigh,
    double? defaultTempThresholdLow,
    double? defaultHumidityThresholdHigh,
    double? defaultHumidityThresholdLow,
  }) {
    return UserPreferences(
      language: language ?? this.language,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      emailNotificationsEnabled:
          emailNotificationsEnabled ?? this.emailNotificationsEnabled,
      defaultTempThresholdHigh:
          defaultTempThresholdHigh ?? this.defaultTempThresholdHigh,
      defaultTempThresholdLow:
          defaultTempThresholdLow ?? this.defaultTempThresholdLow,
      defaultHumidityThresholdHigh:
          defaultHumidityThresholdHigh ?? this.defaultHumidityThresholdHigh,
      defaultHumidityThresholdLow:
          defaultHumidityThresholdLow ?? this.defaultHumidityThresholdLow,
    );
  }

  @override
  List<Object?> get props => [
        language,
        notificationsEnabled,
        emailNotificationsEnabled,
        defaultTempThresholdHigh,
        defaultTempThresholdLow,
        defaultHumidityThresholdHigh,
        defaultHumidityThresholdLow,
      ];
}

/// Informations de contact de l'utilisateur
class ContactInfo extends Equatable {
  /// Numéro de téléphone
  final String? phoneNumber;

  /// Adresse postale
  final String? address;

  /// Ville
  final String? city;

  /// Code postal
  final String? zipCode;

  /// Pays
  final String? country;

  const ContactInfo({
    this.phoneNumber,
    this.address,
    this.city,
    this.zipCode,
    this.country,
  });

  ContactInfo copyWith({
    String? phoneNumber,
    String? address,
    String? city,
    String? zipCode,
    String? country,
  }) {
    return ContactInfo(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      city: city ?? this.city,
      zipCode: zipCode ?? this.zipCode,
      country: country ?? this.country,
    );
  }

  @override
  List<Object?> get props => [
        phoneNumber,
        address,
        city,
        zipCode,
        country,
      ];
}
