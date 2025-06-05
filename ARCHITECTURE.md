# 🏗️ Architecture Clean Code - Flutter IoT App

## 📋 **Vue d'ensemble**

Cette application Flutter suit les principes du **Clean Architecture** et du **Clean Code**, organisant le code en couches distinctes avec des responsabilités claires.

## 🎯 **Principes appliqués**

- ✅ **Single Responsibility Principle** - Chaque classe a une seule responsabilité
- ✅ **Open/Closed Principle** - Ouvert à l'extension, fermé à la modification
- ✅ **Dependency Inversion** - Dépendance sur les abstractions, pas les concrétions
- ✅ **Separation of Concerns** - Séparation claire entre les couches
- ✅ **Repository Pattern** - Abstraction de l'accès aux données
- ✅ **BLoC Pattern** - Gestion d'état prévisible et testable

## 🏗️ **Structure du projet**

```
lib/
├── main.dart                      # Point d'entrée de l'application
├── firebase_options.dart          # Configuration Firebase
├── core/                          # 🔧 Composants partagés
│   ├── core.dart                  # Index des exports
│   ├── config/                    # Configuration centralisée
│   │   └── app_config.dart        # Constantes globales
│   ├── error/                     # Gestion d'erreur centralisée
│   │   └── app_error.dart         # Classes d'erreur personnalisées
│   ├── extensions/                # Extensions Dart utiles
│   │   ├── datetime_extensions.dart
│   │   └── double_extensions.dart
│   ├── factories/                 # Factory Pattern
│   │   └── service_factory.dart   # Création et injection des services
│   ├── models/                    # Modèles de données partagés
│   │   └── current_state.dart     # Modèle état capteur
│   ├── repositories/              # Couche d'accès aux données
│   │   ├── sensor_repository.dart      # Interface repository
│   │   └── sensor_repository_impl.dart # Implémentation repository
│   ├── services/                  # Services métier
│   │   └── hive_service_coordinator.dart # Coordination services
│   ├── usecases/                  # Logique métier
│   │   └── dashboard_usecases.dart # Use cases dashboard
│   └── widgets/                   # Widgets réutilisables
│       └── state/                 # Widgets d'état
│           ├── state_display_card.dart    # Affichage état ruche
│           └── state_stream_widget.dart   # Gestion stream état
├── features/                      # 📱 Features par domaine métier
│   ├── features.dart              # Index des exports
│   ├── dashboard/                 # Feature tableau de bord
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   └── dashboard_bloc.dart    # BLoC dashboard
│   │       └── pages/
│   │           └── dashboard_screen.dart  # Écran dashboard
│   ├── hive/                      # Feature gestion ruches
│   │   └── presentation/
│   │       └── pages/
│   │           ├── hives_screen.dart      # Liste ruches
│   │           └── hive_details_screen.dart # Détails ruche
│   ├── apiary/                    # Feature gestion ruchers
│   │   └── presentation/
│   │       └── pages/
│   │           └── apiaries_screen.dart   # Écran ruchers
│   ├── alert/                     # Feature alertes
│   │   └── presentation/
│   │       └── pages/
│   │           └── alerts_screen.dart     # Écran alertes
│   ├── sensor/                    # Feature capteurs
│   │   └── presentation/
│   │       └── pages/
│   │           └── sensor_readings_screen.dart # Lectures capteurs
│   ├── settings/                  # Feature paramètres
│   │   └── presentation/
│   │       └── pages/
│   │           └── settings_screen.dart   # Écran paramètres
│   └── auth/                      # Feature authentification
├── screens/                       # 📱 Écrans globaux
│   └── home_screen.dart           # Écran d'accueil principal
└── l10n/                          # 🌍 Internationalisation
```

## 🎯 **Architecture Dashboard & Navigation**

### **Hiérarchie de Navigation Métier**

L'application suit une hiérarchie naturelle pour l'apiculteur :

```
Dashboard Global (Vue d'ensemble)
├── 📊 Résumé Multi-Ruchers
│   ├── Statistiques globales (ruchers, ruches, alertes)
│   ├── État de santé général
│   └── Alertes prioritaires
├── 🏡 Ruchers
│   ├── Rucher Principal
│   │   ├── Vue grille des ruches
│   │   ├── Comparaisons température/humidité
│   │   └── Ruche Alpha (détails)
│   ├── Rucher Forêt
│   └── Rucher Prairie
└── 🔔 Alertes Globales
```

### **Niveaux de Dashboard**

#### **1. Dashboard Principal (Accueil)**

- **Objectif** : Vue d'ensemble complète pour l'apiculteur
- **Contenu** :
  - Résumé statistiques (X ruchers, Y ruches, Z alertes)
  - Cards des ruchers avec statut visuel (✅⚠️❌)
  - Alertes les plus critiques
  - Graphique température moyenne par rucher
- **Navigation** : Vers ruchers spécifiques

#### **2. Dashboard Rucher**

- **Objectif** : Gestion d'un rucher spécifique
- **Contenu** :
  - En-tête rucher (nom, localisation, nombre ruches)
  - Grille visuelle des ruches avec statuts
  - Graphiques comparatifs multi-ruches
  - Actions : ajouter ruche, configurer rucher
- **Navigation** : Vers ruches individuelles

#### **3. Dashboard Ruche**

- **Objectif** : Monitoring détaillé d'une ruche
- **Contenu** :
  - Métriques temps réel (température, humidité)
  - Historiques détaillés et tendances
  - Configuration seuils et alertes
  - Gestion capteurs
- **Navigation** : Retour rucher ou vers autre ruche

### **Flux de Données Dashboard**

```dart
DashboardBloc
├── GlobalDashboardState
│   ├── List<Apiary> apiaries
│   ├── GlobalStats stats
│   └── List<Alert> criticalAlerts
├── ApiaryDashboardState
│   ├── Apiary selectedApiary
│   ├── List<Hive> hives
│   └── ComparisonData charts
└── HiveDashboardState
    ├── Hive selectedHive
    ├── CurrentState realTimeData
    └── HistoricalData trends
```

## 🔧 **Composants Core**

### **ServiceFactory**

- **Rôle** : Factory centralisant la création et injection des services
- **Pattern** : Singleton + Factory
- **Responsabilité** : Initialiser tous les services au démarrage

### **HiveServiceCoordinator**

- **Rôle** : Coordonnateur remplaçant l'ancien SensorService monolithique
- **Pattern** : Coordinator
- **Responsabilité** : Orchestrer les services Firebase, capteurs, alertes

### **SensorRepository**

- **Rôle** : Abstraction de l'accès aux données des capteurs
- **Pattern** : Repository
- **Responsabilité** : Interface standardisée pour les données

### **DashboardUseCases**

- **Rôle** : Logique métier du tableau de bord
- **Pattern** : Use Cases
- **Responsabilité** : Orchestrer la récupération et traitement des données

## 📱 **Architecture UI**

### **BLoC Pattern**

- Gestion d'état prévisible et testable
- Séparation claire entre logique métier et UI
- Réactivité avec des streams

### **Widget Composition**

- Widgets modulaires et réutilisables
- Séparation des responsabilités UI
- Configuration centralisée des styles

### **Navigation Hiérarchique**

- **Contexte métier** : Respecte le workflow naturel de l'apiculteur
- **Drill-down progressif** : Du général (tous ruchers) au spécifique (ruche)
- **Breadcrumbs** : Navigation claire avec contexte
- **Actions contextuelles** : Boutons adaptés au niveau (ajouter rucher/ruche)

## 🎨 **UX Principles**

### **Information Hierarchy**

1. **Global** : Vue d'ensemble pour prise de décision rapide
2. **Contextuel** : Données pertinentes selon le niveau
3. **Détaillé** : Informations techniques pour maintenance

### **Visual Design**

- **Status Colors** : ✅ Normal, ⚠️ Attention, ❌ Critique
- **Progressive Disclosure** : Information par niveaux
- **Responsive Layout** : Adaptation mobile/tablet

### **User Flow**

```
Ouverture App → Dashboard Global → Sélection Rucher →
Gestion Ruches → Détails Ruche → Actions/Configuration
```

## 🚀 **Avantages de cette architecture**

1. **Maintenabilité** ⚡

   - Code organisé et facile à comprendre
   - Responsabilités claires et séparées
   - Facilité d'ajout de nouvelles features

2. **Testabilité** 🧪

   - Chaque couche peut être testée isolément
   - Mocking facilité par les interfaces
   - Tests unitaires, widgets et intégration

3. **Évolutivité** 📈

   - Ajout de nouvelles features sans impact
   - Modification des services sans casser l'UI
   - Réutilisation maximale des composants

4. **Performance** ⚡

   - Injection de dépendances optimisée
   - Gestion de mémoire améliorée
   - Rebuild minimal des widgets

5. **UX Métier** 👨‍🌾
   - Navigation intuitive pour l'apiculteur
   - Workflow respectant les besoins réels
   - Information contextuelle et actionnable

## 📦 **Utilisation des exports**

```dart
// Import simple des composants core
import 'package:your_app/core/core.dart';

// Import simple des features
import 'package:your_app/features/features.dart';

// Utilisation directe
final coordinator = ServiceFactory.hiveServiceCoordinator;
final repository = ServiceFactory.sensorRepository;
```

## 🛡️ **Gestion d'erreur**

- Centralisation dans `AppError`
- Messages utilisateur localisés
- Logging des erreurs techniques
- Récupération gracieuse des erreurs

---

**Cette architecture garantit un code propre, maintenable et évolutif selon les meilleures pratiques Flutter et Clean Architecture, tout en respectant les besoins métier réels de l'apiculteur.**
