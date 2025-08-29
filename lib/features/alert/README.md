# 🚨 Système d'Alertes - Ruche Connectée

## Vue d'ensemble

Le système d'alertes permet de surveiller en temps réel les conditions des ruches et de générer des alertes automatiques lorsque les seuils de température et d'humidité sont dépassés.

## 🏗️ Architecture

### Structure des données Firebase

```
beehive_monitoring/
├── alerts/                    # Alertes générées
│   ├── {hiveId}/             # Alertes par ruche
│   │   ├── {timestamp}/      # Alerte individuelle
│   │   │   ├── temperature
│   │   │   ├── humidity
│   │   │   ├── timestamp
│   │   │   ├── event
│   │   │   ├── threshold_high
│   │   │   ├── threshold_low
│   │   │   ├── hive_id
│   │   │   ├── apiary_id
│   │   │   └── is_read
│   │   └── ...
│   └── ...
├── alert_settings/           # Paramètres d'alertes
│   ├── hives/               # Paramètres par ruche
│   │   ├── {hiveId}/
│   │   │   ├── temperature_high_threshold
│   │   │   ├── temperature_low_threshold
│   │   │   ├── humidity_high_threshold
│   │   │   ├── humidity_low_threshold
│   │   │   ├── is_enabled
│   │   │   ├── email_notifications
│   │   │   ├── push_notifications
│   │   │   ├── sms_notifications
│   │   │   ├── created_at
│   │   │   └── updated_at
│   │   └── ...
│   └── apiaries/            # Paramètres par rucher
│       ├── {apiaryId}/
│       └── ...
└── hives/                   # Données des capteurs
    ├── {hiveId}/
    │   └── sensor/
    │       ├── temperature
    │       └── humidity
    └── ...
```

## 🔧 Composants

### 1. Entités (Domain)

- **`ThresholdEvent`** : Représente un événement de dépassement de seuil
- **`AlertSettings`** : Paramètres de configuration des alertes

### 2. Modèles (Data)

- **`ThresholdEventModel`** : Modèle de données avec conversion Firebase
- **`AlertSettingsModel`** : Modèle des paramètres d'alertes

### 3. Services (Data)

- **`AlertDetectionService`** : Service de détection d'alertes en temps réel
  - Surveillance des capteurs
  - Détection des dépassements de seuil
  - Génération automatique d'alertes

### 4. Repository (Data)

- **`AlertRepository`** : Implémentation Firebase du repository
  - Récupération des alertes
  - Gestion des paramètres
  - Streams en temps réel

### 5. Use Cases (Domain)

- **`GetAlertsUseCase`** : Récupération d'alertes avec filtres
- **`ManageAlertUseCase`** : Gestion des alertes (marquer comme lue, supprimer)

### 6. BLoC (Presentation)

- **`AlertBloc`** : Gestion de l'état des alertes
  - Événements : LoadAlerts, MarkAlertAsRead, DeleteAlert, etc.
  - États : AlertLoading, AlertLoaded, AlertError, etc.

### 7. Widgets (Presentation)

- **`AlertsScreen`** : Écran principal des alertes
- **`AlertCard`** : Carte d'affichage d'une alerte
- **`AlertFilterChip`** : Filtre d'alertes

## 🚀 Utilisation

### 1. Configuration des dépendances

```dart
// Dans main.dart ou lors de l'initialisation
AlertInjection.setupAlertDependencies();
```

### 2. Utilisation du BLoC

```dart
// Fournir le BLoC
BlocProvider<AlertBloc>(
  create: (context) => AlertInjection.getAlertBloc(),
  child: AlertsScreen(),
)

// Utiliser le BLoC
context.read<AlertBloc>().add(const LoadAlerts());
```

### 3. Surveillance d'une ruche

```dart
// Démarrer la surveillance
context.read<AlertBloc>().add(
  StartMonitoringHive(hiveId: 'hive_123', apiaryId: 'apiary_456'),
);

// Arrêter la surveillance
context.read<AlertBloc>().add(
  StopMonitoringHive(hiveId: 'hive_123'),
);
```

### 4. Gestion des alertes

```dart
// Marquer comme lue
context.read<AlertBloc>().add(
  MarkAlertAsRead(alertId: 'alert_123'),
);

// Supprimer une alerte
context.read<AlertBloc>().add(
  DeleteAlert(alertId: 'alert_123'),
);
```

## ⚙️ Configuration des seuils

### Seuils par défaut

- **Température haute** : 30°C
- **Température basse** : 15°C
- **Humidité haute** : 80%
- **Humidité basse** : 40%

### Personnalisation

```dart
final settings = AlertSettingsModel.defaultForHive('hive_123').copyWith(
  temperatureHighThreshold: 35.0,
  temperatureLowThreshold: 10.0,
  humidityHighThreshold: 85.0,
  humidityLowThreshold: 35.0,
);

context.read<AlertBloc>().add(
  UpdateAlertSettings(hiveId: 'hive_123', settings: settings),
);
```

## 🔄 Flux de données

1. **Surveillance** : Le `AlertDetectionService` surveille les données des capteurs
2. **Détection** : Comparaison avec les seuils configurés
3. **Génération** : Création automatique d'alertes en cas de dépassement
4. **Stockage** : Sauvegarde dans Firebase Realtime Database
5. **Notification** : Émission via streams pour l'interface utilisateur
6. **Affichage** : Mise à jour de l'interface en temps réel

## 🎯 Fonctionnalités

### ✅ Implémentées

- [x] Détection automatique d'alertes
- [x] Surveillance en temps réel
- [x] Paramètres configurables par ruche/rucher
- [x] Interface utilisateur moderne
- [x] Filtres d'alertes (toutes, non lues, critiques)
- [x] Gestion des alertes (marquer comme lue, supprimer)
- [x] Streams en temps réel
- [x] Architecture Clean Architecture
- [x] Injection de dépendances

### 🔄 En cours

- [ ] Notifications push
- [ ] Notifications email
- [ ] Notifications SMS
- [ ] Historique des alertes
- [ ] Export des alertes
- [ ] Alertes personnalisées

### 📋 À venir

- [ ] Alertes de poids
- [ ] Alertes de batterie
- [ ] Alertes de maintenance
- [ ] Alertes météo
- [ ] Alertes de santé des abeilles
- [ ] Système de priorités
- [ ] Alertes groupées

## 🧪 Tests

### Tests unitaires

```bash
# Tests des use cases
flutter test test/features/alert/domain/usecases/

# Tests du repository
flutter test test/features/alert/data/repositories/

# Tests du BLoC
flutter test test/features/alert/presentation/bloc/
```

### Tests d'intégration

```bash
# Tests d'intégration Firebase
flutter test test/features/alert/integration/
```

## 🔒 Sécurité

- Authentification requise pour accéder aux alertes
- Vérification des permissions par ruche/rucher
- Validation des données d'entrée
- Protection contre les injections

## 📊 Performance

- Surveillance optimisée avec streams
- Pagination des alertes
- Mise en cache des paramètres
- Nettoyage automatique des anciennes alertes

## 🐛 Dépannage

### Problèmes courants

1. **Alertes non générées** : Vérifier les paramètres de seuil
2. **Données non mises à jour** : Vérifier la connexion Firebase
3. **Interface non réactive** : Vérifier les streams BLoC

### Logs

Les logs détaillés sont disponibles avec le Logger :

```dart
Logger().d('Surveillance démarrée pour la ruche: $hiveId');
Logger().i('🚨 Alerte détectée: $alertType');
Logger().e('❌ Erreur de connexion: $error');
```

## 📚 Ressources

- [Documentation Firebase Realtime Database](https://firebase.google.com/docs/database)
- [Guide Flutter BLoC](https://bloclibrary.dev/)
- [Architecture Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
