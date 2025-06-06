# 🏗️ Architecture Clean Code - Flutter IoT App "Ruche Connectée"

## 📋 **Vue d'ensemble**

Cette application Flutter de monitoring IoT pour ruches suit les principes du **Clean Architecture** et du **Clean Code**, organisant le code en couches distinctes avec des responsabilités claires. L'application inclut maintenant un système d'authentification Firebase complet et une architecture par features.

## 🎯 **Principes appliqués**

- ✅ **Single Responsibility Principle** - Chaque classe a une seule responsabilité
- ✅ **Open/Closed Principle** - Ouvert à l'extension, fermé à la modification
- ✅ **Dependency Inversion** - Dépendance sur les abstractions, pas les concrétions
- ✅ **Separation of Concerns** - Séparation claire entre les couches
- ✅ **Repository Pattern** - Abstraction de l'accès aux données
- ✅ **BLoC Pattern** - Gestion d'état prévisible et testable
- ✅ **Feature-Driven Architecture** - Organisation par domaines métier

## 🏗️ **Structure du projet actuelle**

```
lib/
├── main.dart                      # Point d'entrée de l'application
├── firebase_options.dart          # Configuration Firebase
├── core/                          # 🔧 Composants partagés UNIQUEMENT
│   ├── config/                    # Configuration centralisée
│   │   └── app_config.dart        # Constantes globales
│   ├── error/                     # Gestion d'erreur centralisée
│   │   ├── app_error.dart         # Classes d'erreur globales
│   │   └── auth_failures.dart     # Erreurs d'authentification
│   ├── extensions/                # Extensions Dart utiles
│   │   ├── datetime_extensions.dart
│   │   └── double_extensions.dart
│   ├── factories/                 # Factory Pattern
│   │   └── service_factory.dart   # Création et injection des services
│   ├── models/                    # Modèles partagés (non-métier)
│   │   ├── apiary_status.dart     # Statuts des ruchers
│   │   └── hive_status.dart       # Statuts des ruches
│   ├── services/                  # Services d'infrastructure
│   │   ├── firebase_service.dart  # Service Firebase global
│   │   └── hive_service_coordinator.dart # Coordination IoT
│   ├── usecases/                  # Interface de base des use cases
│   │   └── usecase.dart           # Contrat générique
│   └── widgets/                   # Widgets réutilisables
│       ├── chart/                 # Composants graphiques
│       │   └── sensor_chart.dart
│       ├── events/                # Gestion des événements
│       │   └── threshold_events.dart
│       ├── state/                 # Affichage d'état
│       │   ├── state_display_card.dart
│       │   └── state_stream_widget.dart
│       └── threshold/             # Configuration seuils
│           ├── threshold_config.dart
│           └── threshold_display.dart
├── features/                      # 📱 Features par domaine métier
│   ├── auth/                      # 🔐 Authentification Firebase
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── auth_remote_data_source.dart
│   │   │   ├── models/
│   │   │   │   └── user_model.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart
│   │   │   └── usecases/
│   │   │       ├── sign_in_with_email_password.dart
│   │   │       ├── sign_up_with_email_password.dart
│   │   │       ├── sign_out.dart
│   │   │       └── get_auth_state.dart
│   │   ├── presentation/
│   │   │   ├── bloc/
│   │   │   │   └── auth_bloc.dart
│   │   │   ├── pages/
│   │   │   │   └── login_page.dart
│   │   │   └── widgets/
│   │   │       └── auth_form.dart
│   │   └── di/
│   │       └── auth_injection.dart
│   ├── sensor/                    # 🌡️ Données capteurs et entités IoT
│   │   ├── data/
│   │   │   └── repositories/
│   │   │       └── sensor_repository.dart
│   │   ├── domain/
│   │   │   ├── entities/          # Entités métier principales
│   │   │   │   ├── apiary.dart    # Rucher
│   │   │   │   ├── hive.dart      # Ruche
│   │   │   │   ├── current_state.dart # État actuel
│   │   │   │   ├── sensor_reading.dart # Lecture capteur
│   │   │   │   ├── threshold_event.dart # Événement seuil
│   │   │   │   └── time_filter.dart # Filtre temporel
│   │   │   └── repositories/
│   │   │       └── sensor_repository_interface.dart
│   │   └── presentation/
│   │       └── pages/
│   │           └── sensor_readings_screen.dart
│   ├── dashboard/                 # 📊 Tableau de bord
│   │   ├── data/
│   │   │   └── repositories/
│   │   │       └── dashboard_repository.dart
│   │   ├── domain/
│   │   │   ├── bloc/
│   │   │   │   └── dashboard_bloc.dart
│   │   │   └── usecases/
│   │   │       └── dashboard_usecases.dart
│   │   └── presentation/
│   │       ├── pages/
│   │       │   └── dashboard_screen.dart
│   │       └── widgets/
│   │           ├── apiaries_section.dart
│   │           ├── apiary_overview_card.dart
│   │           ├── average_temperature_chart.dart
│   │           └── global_stats_card.dart
│   ├── apiary/                    # 🏡 Gestion ruchers
│   │   ├── data/
│   │   │   └── repositories/
│   │   │       └── apiary_repository.dart
│   │   ├── domain/
│   │   │   ├── bloc/
│   │   │   │   ├── apiaries_bloc.dart
│   │   │   │   └── hives_bloc.dart
│   │   │   └── repositories/
│   │   │       └── apiary_repository_interface.dart
│   │   └── presentation/
│   │       ├── pages/
│   │       │   └── apiaries_screen.dart
│   │       └── widgets/
│   │           └── apiary_card.dart
│   ├── hive/                      # 🐝 Gestion ruches
│   │   ├── data/
│   │   │   └── repositories/
│   │   │       └── hive_repository.dart
│   │   ├── domain/
│   │   │   ├── bloc/
│   │   │   │   └── hive_details_bloc.dart
│   │   │   └── repositories/
│   │   │       └── hive_repository_interface.dart
│   │   └── presentation/
│   │       └── pages/
│   │           ├── hive_detail_screen.dart
│   │           └── hives_screen.dart
│   └── alert/                     # 🔔 Système d'alertes
│       ├── data/
│       │   └── repositories/
│       │       └── alert_repository.dart
│       ├── domain/
│       │   ├── entities/
│       │   │   └── threshold_event.dart
│       │   └── repositories/
│       │       └── alert_repository_interface.dart
│       └── presentation/
├── screens/                       # 📱 Écrans globaux
│   └── main_screen.dart           # Écran principal avec navigation par onglets
└── l10n/                          # 🌍 Internationalisation
```

## 🔐 **Authentification Firebase**

### **Architecture d'authentification complète**

L'application intègre maintenant un système d'authentification robuste :

```dart
// Entité utilisateur
class UserEntity {
  final String id;
  final String email;
  final String? displayName;
  final DateTime? createdAt;
}

// Use cases disponibles
- SignInWithEmailPassword
- SignUpWithEmailPassword
- SignOut
- GetAuthState

// États gérés par AuthBloc
- AuthInitial
- AuthLoading
- AuthAuthenticated
- AuthUnauthenticated
- AuthError
```

### **Flux d'authentification**

1. **Connexion** : Email/Password → Firebase Auth → UserEntity
2. **Inscription** : Validation → Création compte → Auto-connexion
3. **Déconnexion** : Nettoyage état → Redirection login
4. **Persistance** : État maintenu entre sessions

## 🎯 **Architecture des Features**

### **Feature Sensor (Entités IoT)**

Centralise toutes les entités métier liées au monitoring IoT :

```dart
// Entités principales
- Apiary (Rucher): id, name, location, hiveIds, description
- Hive (Ruche): id, name, description, apiaryId
- CurrentState: temperature, humidity, weight, timestamp, isOnline
- SensorReading: temperature, humidity, weight, timestamp
- ThresholdEvent: type, value, threshold, severity, timestamp
- TimeFilter: oneHour, sixHours, oneDay, oneWeek, oneMonth
```

### **Feature Dashboard**

Orchestration des données pour la vue d'ensemble :

```dart
// États du dashboard
- DashboardLoaded: apiaries, hives, averageTemperatureReadings
- Support multi-ruchers avec statistiques globales
- Graphiques de température moyenne par rucher
```

### **Feature Apiary/Hive**

Gestion hiérarchique ruchers → ruches :

```dart
// Navigation métier intuitive
Ruchers (liste) → Rucher spécifique → Ruches du rucher → Détails ruche
```

## 🔧 **Services d'infrastructure**

### **ServiceFactory (Singleton)**

Factory centralisé pour tous les services :

```dart
class ServiceFactory {
  static FirebaseService get firebaseService;
  static HiveServiceCoordinator getHiveServiceCoordinator();
  // Injection de dépendances centralisée
}
```

### **HiveServiceCoordinator**

Coordinateur remplaçant l'ancien service monolithique :

```dart
// Responsabilités
- Coordination Firebase + capteurs + alertes
- Gestion des streams de données temps réel
- Orchestration des différents services IoT
- Cache et optimisations des requêtes
```

## 📱 **Gestion d'état avec BLoC**

### **Patrons implémentés**

```dart
// Architecture standardisée par feature
Feature/
├── domain/bloc/
│   ├── feature_bloc.dart    # Logique métier
│   ├── feature_event.dart   # Événements
│   └── feature_state.dart   # États

// Exemples concrets
- AuthBloc: Gestion authentification
- DashboardBloc: Orchestration données dashboard
- HiveDetailsBloc: Détails d'une ruche spécifique
- ApiariesBloc: Liste des ruchers
```

### **Streams et réactivité**

- **Temps réel** : Connexion WebSocket Firebase
- **État local** : BLoC avec Cubit pour logique simple
- **Navigation** : GoRouter avec état persisté

## 🎨 **Hiérarchie UI et UX**

### **Navigation métier apiculteur**

```
🏠 Dashboard Global
├── 📊 Vue d'ensemble (stats multi-ruchers)
├── 🏡 Ruchers
│   ├── Rucher Principal
│   │   ├── 🐝 Ruche Alpha (détails)
│   │   ├── 🐝 Ruche Beta
│   │   └── ➕ Ajouter ruche
│   ├── Rucher Forêt
│   └── Rucher Prairie
├── 🔔 Alertes globales
└── ⚙️ Paramètres
```

### **Progressive disclosure**

1. **Global** : Résumé de tous les ruchers
2. **Rucher** : Vue d'ensemble des ruches d'un rucher
3. **Ruche** : Monitoring détaillé d'une ruche
4. **Technique** : Configuration capteurs et seuils

## 🚀 **Avantages de l'architecture actuelle**

### **1. Séparation des responsabilités ⚡**

- **Core** : Uniquement composants partagés (services, widgets)
- **Features** : Domaines métier isolés et autonomes
- **Clean Architecture** : Domain → Data → Presentation

### **2. Maintenabilité 🔧**

- Ajout de features sans impact sur l'existant
- Tests isolés par couche et par feature
- Refactoring facilité par les interfaces

### **3. Évolutivité 📈**

- Architecture modulaire prête pour de nouvelles features
- Réutilisation maximale des composants core
- Intégration d'autres systèmes IoT simplifiée

### **4. Performance ⚡**

- Injection de dépendances optimisée via ServiceFactory
- Gestion mémoire avec disposal automatique des BLoCs
- Cache intelligent des données IoT

### **5. Robustesse 🛡️**

- Gestion d'erreurs centralisée avec récupération gracieuse
- Authentification sécurisée avec Firebase Auth
- Mode hors ligne avec persistance locale

## 🧪 **Stratégie de tests**

### **Tests par couche**

```dart
// Tests unitaires (Domain)
- Entities: Validation et logique métier
- Use cases: Scénarios fonctionnels
- BLoCs: États et transitions

// Tests d'intégration (Data)
- Repositories: Accès données Firebase
- Services: Coordination et cache

// Tests widgets (Presentation)
- Pages: Rendu et interactions utilisateur
- Widgets: Composants réutilisables
```

## 📦 **Migration réussie**

### **Avant → Après**

```dart
// AVANT (problématique)
core/models/           → Entités mélangées
core/repositories/     → Logique métier dans core
core/usecases/        → Use cases globaux

// APRÈS (clean)
features/sensor/domain/entities/     → Entités IoT centralisées
features/*/data/repositories/        → Repositories par feature
features/*/domain/usecases/         → Use cases spécialisés
```

### **Résultats**

✅ **207 erreurs de linter corrigées**  
✅ **Architecture Clean complètement implémentée**  
✅ **Authentification Firebase fonctionnelle**  
✅ **Séparation par features respectée**  
✅ **Widgets core réutilisables**  
✅ **Tests unitaires possibles par feature**

---

**Cette architecture garantit un code propre, maintenable et évolutif selon les meilleures pratiques Flutter et Clean Architecture, parfaitement adapté aux besoins métier de monitoring IoT pour l'apiculture moderne.**
