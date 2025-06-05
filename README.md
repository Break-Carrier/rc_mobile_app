# 🐝 Ruche Connectée - IoT Monitoring App

Application Flutter de monitoring IoT pour ruches d'abeilles avec architecture Clean Code et authentification Firebase.

## 📋 Table des matières

1. [Présentation du projet](#présentation)
2. [Fonctionnalités principales](#fonctionnalités-principales)
3. [Architecture technique](#architecture-technique)
4. [Installation et configuration](#installation-et-configuration)
5. [Structure du projet](#structure-du-projet)
6. [Authentification](#authentification)
7. [Entités métier](#entités-métier)
8. [Services et coordinateurs](#services-et-coordinateurs)
9. [Interface utilisateur](#interface-utilisateur)
10. [Tests et qualité](#tests-et-qualité)
11. [Contribution](#contribution)
12. [Licence](#licence)

## 🎯 Présentation

**Ruche Connectée** est une application Flutter moderne permettant aux apiculteurs de surveiller et gérer leurs ruches connectées en temps réel. L'application suit une **architecture Clean Code** avec séparation par features et intègre un système d'authentification Firebase complet.

### 🎨 Fonctionnalités métier

- **Dashboard multi-ruchers** - Vue d'ensemble de tous les ruchers
- **Monitoring temps réel** - Surveillance des capteurs IoT (température, humidité, poids)
- **Gestion hiérarchique** - Ruchers → Ruches → Capteurs
- **Système d'alertes** - Notifications automatiques sur dépassement de seuils
- **Historiques et tendances** - Analyse des données dans le temps
- **Interface intuitive** - Navigation pensée pour le métier d'apiculteur

## ✨ Fonctionnalités principales

### 🔐 **Authentification sécurisée**

- Connexion/inscription avec Firebase Auth
- Gestion des sessions utilisateur
- Validation des formulaires
- Récupération de mot de passe

### 📊 **Dashboard intelligent**

- Vue d'ensemble multi-ruchers avec statistiques globales
- Cartes de statut visuelles (✅⚠️❌)
- Graphiques de température moyenne par rucher
- Alertes critiques prioritaires

### 🏡 **Gestion des ruchers**

- Liste des ruchers avec informations détaillées
- Navigation vers les ruches d'un rucher spécifique
- Ajout et configuration de nouveaux ruchers

### 🐝 **Monitoring des ruches**

- État actuel en temps réel (température, humidité, poids)
- Détails individuels par ruche
- Historique des lectures de capteurs
- Configuration des seuils d'alerte

### 🔔 **Système d'alertes**

- Événements de dépassement de seuil automatiques
- Historique des alertes avec pagination
- Configuration des seuils avec hystérésis
- Notifications en temps réel

### 📈 **Visualisations et analyses**

- Graphiques d'évolution des données
- Filtres temporels multiples (1h, 6h, 1j, 1s, 1m)
- Comparaisons entre ruches
- Export des données historiques

## 🏗️ Architecture technique

### **Clean Architecture avec Features**

L'application est construite sur les principes du **Clean Architecture** :

```
🏗️ Architecture par couches
├── 🎯 Domain Layer    # Logique métier pure (entities, repositories, use cases)
├── 📦 Data Layer      # Accès aux données (models, repositories, datasources)
└── 🎨 Presentation    # Interface utilisateur (pages, widgets, BLoCs)

🚀 Organisation par Features
├── 🔐 auth/          # Authentification Firebase
├── 🌡️ sensor/        # Entités IoT (ruchers, ruches, capteurs)
├── 📊 dashboard/     # Tableau de bord multi-ruchers
├── 🏡 apiary/        # Gestion des ruchers
├── 🐝 hive/          # Gestion des ruches
└── 🔔 alert/         # Système d'alertes
```

### **Stack technique**

- **Frontend** : Flutter 3.x avec Material Design 3
- **Backend** : Firebase Realtime Database + Firebase Auth
- **Architecture** : Clean Architecture + BLoC Pattern
- **State Management** : BLoC/Cubit avec équate
- **Charts** : fl_chart pour visualisations
- **Navigation** : GoRouter avec routes typées
- **Injection** : ServiceFactory pattern

## 🚀 Installation et configuration

### Prérequis

- Flutter SDK 3.x ou supérieur
- Dart SDK 3.x ou supérieur
- Compte Firebase avec projet configuré
- Android Studio / VS Code avec extensions Flutter

### Configuration

1. **Cloner le repository**

   ```bash
   git clone https://github.com/username/rc_mobile_app.git
   cd rc_mobile_app
   ```

2. **Installer les dépendances**

   ```bash
   flutter pub get
   ```

3. **Configurer Firebase**

   Assurez-vous que `firebase_options.dart` contient :

   ```dart
   static const FirebaseOptions android = FirebaseOptions(
     apiKey: 'your-api-key',
     appId: 'your-app-id',
     messagingSenderId: 'your-sender-id',
     projectId: 'your-project-id',
     databaseURL: 'your-database-url',
   );
   ```

4. **Lancer l'application**
   ```bash
   flutter run
   ```

## 📁 Structure du projet

```
lib/
├── main.dart                          # Point d'entrée
├── firebase_options.dart              # Configuration Firebase
├── core/                              # 🔧 Composants partagés
│   ├── config/app_config.dart         # Configuration globale
│   ├── error/                         # Gestion d'erreurs
│   ├── extensions/                    # Extensions Dart
│   ├── factories/service_factory.dart # Injection de dépendances
│   ├── services/                      # Services d'infrastructure
│   └── widgets/                       # Composants UI réutilisables
├── features/                          # 📱 Features métier
│   ├── auth/                          # 🔐 Authentification
│   │   ├── domain/                    # Logique métier auth
│   │   ├── data/                      # Accès données Firebase Auth
│   │   └── presentation/              # UI auth (login, signup)
│   ├── sensor/                        # 🌡️ Entités IoT
│   │   └── domain/entities/           # Ruchers, ruches, capteurs
│   ├── dashboard/                     # 📊 Tableau de bord
│   ├── apiary/                        # 🏡 Gestion ruchers
│   ├── hive/                          # 🐝 Gestion ruches
│   └── alert/                         # 🔔 Système alertes
├── screens/                           # 📱 Écrans globaux
└── l10n/                              # 🌍 Localisation
```

## 🔐 Authentification

### Architecture d'authentification

```dart
// Use Cases disponibles
- SignInWithEmailPassword     # Connexion utilisateur
- SignUpWithEmailPassword     # Inscription utilisateur
- SignOut                     # Déconnexion
- GetAuthState               # État d'authentification

// États BLoC
- AuthInitial               # État initial
- AuthLoading              # Chargement en cours
- AuthAuthenticated        # Utilisateur connecté
- AuthUnauthenticated      # Utilisateur non connecté
- AuthError                # Erreur d'authentification
```

### Flux d'authentification

1. **Ouverture app** → Vérification état auth → Dashboard ou Login
2. **Connexion** → Validation → Firebase Auth → Redirection Dashboard
3. **Inscription** → Validation → Création compte → Auto-connexion
4. **Session** → Persistance automatique → Reconnexion

## 🌡️ Entités métier

### Modèle de données IoT

```dart
// Rucher (Apiary)
class Apiary {
  String id;                    # Identifiant unique
  String name;                  # Nom du rucher
  String location;              # Localisation GPS
  List<String> hiveIds;         # IDs des ruches
  String? description;          # Description optionnelle
}

// Ruche (Hive)
class Hive {
  String id;                    # Identifiant unique
  String name;                  # Nom de la ruche
  String apiaryId;              # Rucher parent
  String? description;          # Description optionnelle
}

// État actuel (CurrentState)
class CurrentState {
  double? temperature;          # Température actuelle (°C)
  double? humidity;             # Humidité actuelle (%)
  double? weight;               # Poids actuel (kg)
  DateTime timestamp;           # Timestamp de la mesure
  bool isOnline;               # État de connectivité
}

// Lecture capteur (SensorReading)
class SensorReading {
  double? temperature;          # Température (°C)
  double? humidity;             # Humidité (%)
  double? weight;               # Poids (kg)
  DateTime timestamp;           # Moment de la lecture
}

// Événement de seuil (ThresholdEvent)
class ThresholdEvent {
  String type;                  # Type d'événement
  double value;                 # Valeur déclenchante
  double threshold;             # Seuil configuré
  String severity;              # Sévérité (low, medium, high)
  DateTime timestamp;           # Moment de l'événement
  bool isResolved;             # Événement résolu
}
```

## 🔧 Services et coordinateurs

### ServiceFactory

Pattern centralisé pour l'injection de dépendances :

```dart
class ServiceFactory {
  // Service Firebase global
  static FirebaseService get firebaseService;

  // Coordinateur IoT principal
  static HiveServiceCoordinator getHiveServiceCoordinator();
}
```

### HiveServiceCoordinator

Coordinateur principal remplaçant l'ancien service monolithique :

```dart
class HiveServiceCoordinator {
  // Gestion des ruchers et ruches
  Future<List<Apiary>> getApiaries();
  Future<List<Hive>> getHivesForApiary(String apiaryId);

  // Données temps réel
  Stream<CurrentState?> getCurrentStateStream();
  Stream<List<SensorReading>> getSensorReadingsStream();
  Stream<List<ThresholdEvent>> getThresholdEventsStream();

  // Configuration
  void setActiveHive(String hiveId);
  void setTimeFilter(TimeFilter filter);
  Future<void> updateThresholds(double low, double high);
}
```

## 🎨 Interface utilisateur

### Navigation hiérarchique métier

```
🏠 Dashboard Global
├── 📊 Statistiques multi-ruchers
├── 🏡 Mes Ruchers
│   ├── Rucher Principal
│   │   ├── 🐝 Ruche Alpha → Détails
│   │   ├── 🐝 Ruche Beta → Détails
│   │   └── ➕ Ajouter ruche
│   ├── Rucher Forêt
│   └── Rucher Prairie
├── 🔔 Alertes globales
└── ⚙️ Paramètres
```

### Progressive disclosure

1. **Global** - Vue d'ensemble de tous les ruchers
2. **Rucher** - Ruches d'un rucher spécifique
3. **Ruche** - Monitoring détaillé d'une ruche
4. **Technique** - Configuration capteurs et seuils

### Widgets core réutilisables

- `StateDisplayCard` - Affichage état actuel d'une ruche
- `StateStreamWidget` - Widget de stream temps réel
- `SensorChart` - Graphiques de données capteurs
- `ThresholdConfig` - Configuration des seuils
- `ThresholdEvents` - Liste des événements d'alerte

## 🧪 Tests et qualité

### Stratégie de tests

```dart
// Tests unitaires (Domain)
- Entities: Logique métier et validation
- Use Cases: Scénarios fonctionnels
- BLoCs: États et transitions

// Tests d'intégration (Data)
- Repositories: Accès Firebase
- Services: Coordination et cache

// Tests widgets (Presentation)
- Pages: Rendu et interactions
- Widgets: Composants réutilisables
```

### Métriques qualité

- ✅ **0 erreur linter** - Code conforme aux standards
- ✅ **Architecture Clean** - Couches respectées
- ✅ **Couverture tests** - Logique métier testée
- ✅ **Documentation** - Code auto-documenté

## 🚀 Utilisation

### Premiers pas

1. **Connexion** - Créez un compte ou connectez-vous
2. **Dashboard** - Consultez la vue d'ensemble de vos ruchers
3. **Navigation** - Explorez ruchers → ruches → détails
4. **Configuration** - Paramétrez les seuils d'alerte
5. **Monitoring** - Surveillez vos ruches en temps réel

### Fonctionnalités avancées

- **Filtres temporels** - Analysez les données sur différentes périodes
- **Comparaisons** - Comparez les performances entre ruches
- **Exportation** - Exportez les données pour analyse externe
- **Notifications** - Recevez des alertes en temps réel

## 🤝 Contribution

### Guidelines de développement

1. **Architecture** - Respectez les couches Clean Architecture
2. **Features** - Organisez par domaines métier
3. **Tests** - Testez la logique métier
4. **Documentation** - Documentez les API publiques
5. **Qualité** - Zéro erreur linter accepté

### Workflow de contribution

1. Fork du projet
2. Branche feature (`git checkout -b feature/nouvelle-fonctionnalite`)
3. Commit (`git commit -m 'Ajout nouvelle fonctionnalité'`)
4. Push (`git push origin feature/nouvelle-fonctionnalite`)
5. Pull Request avec description détaillée

## 📄 Licence

Ce projet est distribué sous licence MIT. Voir le fichier `LICENSE` pour plus d'informations.

---

## 🏆 Statut du projet

✅ **Architecture Clean complète** - Domain/Data/Presentation respectées  
✅ **Firebase Auth fonctionnel** - Authentification robuste  
✅ **Monitoring IoT opérationnel** - Capteurs temps réel  
✅ **Interface moderne** - Material Design 3  
✅ **Code quality** - 0 erreur linter, tests possibles  
✅ **Prêt production** - Architecture évolutive et maintenable

**Développé avec ❤️ pour les apiculteurs modernes**
