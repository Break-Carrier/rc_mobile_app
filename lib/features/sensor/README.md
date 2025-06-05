# Feature Sensor (Capteurs) - Entités IoT

Cette feature centralise toutes les **entités métier** liées au système IoT de monitoring des ruches. Elle constitue le cœur du domaine métier de l'application.

## 🎯 Rôle dans l'architecture

La feature `sensor` ne gère pas directement les capteurs physiques, mais définit les **entités de domaine** utilisées par toutes les autres features :

- **Ruchers** (Apiary) - Groupements géographiques de ruches
- **Ruches** (Hive) - Unités individuelles de monitoring
- **États actuels** (CurrentState) - Données temps réel des capteurs
- **Lectures capteurs** (SensorReading) - Historique des mesures
- **Événements seuils** (ThresholdEvent) - Alertes et dépassements
- **Filtres temporels** (TimeFilter) - Périodes d'analyse

## 🏗️ Structure Clean Architecture

```
sensor/
├── domain/                      # 🎯 Logique métier pure
│   ├── entities/                # Entités de domaine centrales
│   │   ├── apiary.dart          # ✅ Rucher (id, name, location, hiveIds)
│   │   ├── hive.dart            # ✅ Ruche (id, name, description, apiaryId)
│   │   ├── current_state.dart   # ✅ État actuel (temp, humidity, weight, timestamp)
│   │   ├── sensor_reading.dart  # ✅ Lecture historique (temp, humidity, weight)
│   │   ├── threshold_event.dart # ✅ Événement d'alerte (type, value, threshold)
│   │   └── time_filter.dart     # ✅ Filtre temporel (oneHour, oneDay, etc.)
│   └── repositories/            # Interfaces (contrats)
│       └── sensor_repository_interface.dart
├── data/                        # 📦 Accès aux données
│   └── repositories/
│       └── sensor_repository.dart # Implémentation Firebase
└── presentation/               # 🎨 Interface utilisateur
    └── pages/
        └── sensor_readings_screen.dart # Page des lectures capteurs
```

## ✅ Entités métier (Domain Layer)

### 1. Apiary (Rucher)

```dart
class Apiary {
  final String id;              // Identifiant unique
  final String name;            // Nom du rucher ("Rucher Principal")
  final String location;        // Localisation ("Forêt de Fontainebleau")
  final List<String> hiveIds;   // IDs des ruches contenues
  final String? description;    // Description optionnelle
}
```

**Usage** : Groupement géographique de ruches pour organisation et gestion.

### 2. Hive (Ruche)

```dart
class Hive {
  final String id;              // Identifiant unique
  final String name;            // Nom de la ruche ("Ruche Alpha")
  final String? description;    // Description optionnelle
  final String apiaryId;        // Rucher parent
}
```

**Usage** : Unité individuelle de monitoring avec capteurs intégrés.

### 3. CurrentState (État actuel)

```dart
class CurrentState {
  final double? temperature;    // Température actuelle (°C)
  final double? humidity;       // Humidité actuelle (%)
  final double? weight;         // Poids actuel (kg)
  final DateTime timestamp;     // Moment de la mesure
  final bool isOnline;         // Connectivité du capteur
}
```

**Usage** : Snapshot temps réel de l'état d'une ruche.

### 4. SensorReading (Lecture capteur)

```dart
class SensorReading {
  final double? temperature;    // Température mesurée (°C)
  final double? humidity;       // Humidité mesurée (%)
  final double? weight;         // Poids mesuré (kg)
  final DateTime timestamp;     // Moment de la lecture
}
```

**Usage** : Point de données historique pour analyses et tendances.

### 5. ThresholdEvent (Événement de seuil)

```dart
class ThresholdEvent {
  final String type;           // Type d'événement ("temperature", "humidity")
  final double value;          // Valeur déclenchante
  final double threshold;      // Seuil configuré
  final String severity;       // Sévérité ("low", "medium", "high")
  final DateTime timestamp;    // Moment de l'événement
  final bool isResolved;      // Événement résolu ou actif
}
```

**Usage** : Alerte automatique lors de dépassement de seuils configurés.

### 6. TimeFilter (Filtre temporel)

```dart
enum TimeFilter {
  oneHour,      // Dernière heure
  sixHours,     // 6 dernières heures
  oneDay,       // Dernier jour
  oneWeek,      // Dernière semaine
  oneMonth;     // Dernier mois

  String get displayName;  // Nom affiché à l'utilisateur
}
```

**Usage** : Filtrage des données historiques par période.

## 🔄 Migration réussie

### Avant la migration (❌ Problématique)

```
core/models/                 # Entités mélangées dans core
├── apiary.dart             # Violation de Clean Architecture
├── hive.dart               # Logique métier dans core
├── current_state.dart      # Responsabilités mélangées
├── sensor_reading.dart
├── threshold_event.dart
└── time_filter.dart
```

### Après la migration (✅ Clean Architecture)

```
features/sensor/domain/entities/  # Entités centralisées par domaine
├── apiary.dart                  # Pure entité métier
├── hive.dart                    # Clean Domain Layer
├── current_state.dart           # Single Responsibility
├── sensor_reading.dart          # Separation of Concerns
├── threshold_event.dart
└── time_filter.dart
```

## 🔗 Utilisation par les autres features

### Dashboard Feature

```dart
import '../../../sensor/domain/entities/apiary.dart';
import '../../../sensor/domain/entities/hive.dart';

// Utilise les entités pour afficher statistiques globales
class DashboardBloc {
  final List<Apiary> apiaries;
  final List<Hive> hives;
}
```

### Apiary Feature

```dart
import '../../../sensor/domain/entities/apiary.dart';

// Gère la liste et navigation des ruchers
class ApiariesBloc {
  Future<List<Apiary>> loadApiaries();
}
```

### Hive Feature

```dart
import '../../../sensor/domain/entities/hive.dart';
import '../../../sensor/domain/entities/current_state.dart';

// Monitoring détaillé d'une ruche
class HiveDetailsBloc {
  Stream<CurrentState?> getCurrentState(String hiveId);
}
```

### Alert Feature

```dart
import '../../../sensor/domain/entities/threshold_event.dart';

// Gestion des événements d'alerte
class AlertRepository {
  Stream<List<ThresholdEvent>> getThresholdEvents();
}
```

## 🎨 Repository Pattern

### Interface (Domain)

```dart
abstract class ISensorRepository {
  Future<List<SensorReading>> getSensorReadings(String hiveId, TimeFilter filter);
  Stream<CurrentState?> getCurrentState(String hiveId);
  Stream<List<ThresholdEvent>> getThresholdEvents(String hiveId);
}
```

### Implémentation (Data)

```dart
class SensorRepository implements ISensorRepository {
  // Utilise HiveServiceCoordinator pour accès Firebase
  final coordinator = ServiceFactory.getHiveServiceCoordinator();

  @override
  Future<List<SensorReading>> getSensorReadings(String hiveId, TimeFilter filter) {
    // Implémentation avec Firebase Realtime Database
  }
}
```

## ✅ État actuel

### Résultats de la migration

- ✅ **Architecture Clean respectée** - Domain/Data/Presentation séparées
- ✅ **Entités centralisées** - Single source of truth pour le domaine IoT
- ✅ **Imports corrigés** - Toutes les features utilisent les bonnes entités
- ✅ **Null safety** - Propriétés optionnelles gérées correctement
- ✅ **Tests possibles** - Entités pures testables unitairement

### Validation linter

```bash
flutter analyze lib/features/sensor/ ✅ "No issues found!"
```

### Fonctionnalités opérationnelles

- ✅ **Lecture données capteurs** - Température, humidité, poids
- ✅ **Filtrage temporel** - Historiques sur différentes périodes
- ✅ **États temps réel** - CurrentState avec WebSocket Firebase
- ✅ **Événements d'alerte** - ThresholdEvent avec sévérité
- ✅ **Navigation hiérarchique** - Ruchers → Ruches → Détails

## 🚀 Évolutivité

### Facilité d'extension

```dart
// Ajouter une nouvelle entité
class BeehiveInspection {
  final String id;
  final String hiveId;
  final DateTime inspectionDate;
  final String findings;
  // Ajout sans impact sur l'existant
}

// Étendre une entité existante
class Hive {
  // Propriétés existantes...
  final List<String>? sensorIds;  // Nouveaux capteurs
  final GeoLocation? coordinates; // Géolocalisation précise
}
```

### Intégration nouveaux capteurs

La structure modulaire permet d'ajouter facilement :

- Capteurs de CO2, pH, vibrations
- Caméras de surveillance
- Capteurs météorologiques
- Balances connectées

---

## 🎯 Résumé

La feature **sensor** constitue le **cœur du domaine métier** de l'application IoT. Elle centralise toutes les entités liées au monitoring des ruches dans une architecture Clean respectant les principes SOLID.

**Elle est maintenant prête pour la production avec une architecture évolutive et maintenable.**
