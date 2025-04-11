# Feature Sensor (Capteurs)

Cette fonctionnalité gère l'affichage et la gestion des données liées aux capteurs et aux lectures des capteurs.

## Structure

L'architecture suit le pattern Clean Architecture avec trois couches principales:

```
sensor/
├── data/                        # Couche de données
│   ├── models/                  # Modèles de données
│   │   └── sensor_reading_model.dart  # Modèle pour les lectures de capteurs
│   └── repositories/
│       └── sensor_repository.dart # Implémentation du repository
├── domain/                      # Couche métier
│   ├── bloc/                    # Gestion d'état
│   │   ├── readings_bloc.dart   # BLoC pour les lectures de capteurs
│   │   ├── readings_event.dart  # Événements du BLoC
│   │   └── readings_state.dart  # États du BLoC
│   ├── entities/                # Entités métier
│   │   └── sensor_reading.dart  # Entité pour les lectures de capteurs
│   └── repositories/            # Interfaces (contrats)
│       └── sensor_repository_interface.dart
├── presentation/               # Couche de présentation
│   ├── screens/                # Écrans complets
│   │   └── sensor_readings_screen.dart
│   └── widgets/                # Composants UI réutilisables
│       └── sensor_reading_chart.dart
└── README.md                   # Documentation de la fonctionnalité
```

## Fonctionnalités

### Principales fonctionnalités

- Affichage des lectures de capteurs (température, humidité, poids, etc.)
- Visualisation des données historiques
- Filtrage des données par période
- Rafraîchissement des données en temps réel

### À venir

- Configuration des capteurs
- Export des données
- Visualisation avancée et analyses

## Architecture technique

### 1. Couche domain

Contient les définitions abstraites et la logique métier:

- `ISensorRepository`: Interface définissant les contrats pour l'accès aux données des capteurs
- `ReadingsBloc`: Gère l'état et les événements liés aux lectures de capteurs

### 2. Couche data

Implémente l'accès aux données:

- `SensorRepository`: Implémente `ISensorRepository` en utilisant directement le service Firebase

### 3. Couche presentation

Gère l'interface utilisateur:

- `SensorReadingsScreen`: Écran principal pour afficher les lectures de capteurs
- Widgets spécifiques pour l'affichage des données des capteurs

## Flux de données

1. L'utilisateur navigue vers la page des lectures de capteurs
2. Le `ReadingsBloc` charge les données via le `SensorRepository`
3. L'interface utilisateur réagit aux changements d'état du BLoC
4. Pour les données en temps réel, le BLoC s'abonne aux streams fournis par le repository

## Tests

- Tests unitaires pour la logique métier du BLoC et du repository
- Tests de widget pour les composants UI
- Tests d'intégration pour le flux complet

## Migration

Cette feature est en cours de migration depuis l'architecture précédente. Les étapes sont:

1. Migration de la structure du modèle et des services ✓
2. Mise en place du repository et des BLOCs ✓
3. Migration de l'interface utilisateur ✓
4. Tests et optimisations
