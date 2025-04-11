# Feature Hive (Ruche)

Cette fonctionnalité gère l'affichage et la gestion des données liées aux ruches individuelles.

## Structure

L'architecture suit le pattern Clean Architecture avec trois couches principales:

```
hive/
├── data/                        # Couche de données
│   └── repositories/
│       └── hive_repository.dart # Implémentation du repository
├── domain/                      # Couche métier
│   ├── bloc/                    # Gestion d'état
│   │   └── hive_details_bloc.dart  # BLoC pour les détails de ruche
│   └── repositories/            # Interfaces (contrats)
│       └── hive_repository_interface.dart
├── presentation/               # Couche de présentation
│   ├── screens/                # Écrans complets
│   │   └── hive_details_screen.dart
│   └── widgets/                # Composants UI réutilisables
│       └── (à venir: widgets spécifiques aux ruches)
└── README.md                   # Documentation de la fonctionnalité
```

## Fonctionnalités

### Principales fonctionnalités

- Affichage des détails d'une ruche (nom, description)
- Affichage de l'état actuel (température, humidité)
- Navigation vers les lectures de capteurs, alertes, etc.
- Rafraîchissement des données

### À venir

- Configuration des seuils de notification
- Gestion des notes liées aux ruches
- Historique des événements
- Visualisation avancée des données

## Architecture technique

### 1. Couche domain

Contient les définitions abstraites et la logique métier:

- `IHiveRepository`: Interface définissant les contrats pour l'accès aux données
- `HiveDetailsBloc`: Gère l'état et les événements liés à l'écran de détails

### 2. Couche data

Implémente l'accès aux données:

- `HiveRepository`: Implémente `IHiveRepository` en utilisant le `SensorService` existant

### 3. Couche presentation

Gère l'interface utilisateur:

- `HiveDetailsScreen`: Écran principal pour afficher les détails d'une ruche
- Widgets spécifiques pour l'affichage des données de ruche

## Flux de données

1. L'utilisateur navigue vers la page de détails d'une ruche
2. Le `HiveDetailsBloc` charge les données via le `HiveRepository`
3. L'interface utilisateur réagit aux changements d'état du BLoC
4. Pour les données en temps réel, le BLoC s'abonne aux streams fournis par le repository

## Tests

- Tests unitaires pour la logique métier du BLoC et du repository
- Tests de widget pour les composants UI
- Tests d'intégration pour le flux complet

## Migration

Cette feature est en cours de migration depuis l'architecture précédente. Les étapes sont:

1. Migration des fonctionnalités essentielles (affichage des détails) ✓
2. Ajout des fonctionnalités manquantes et amélioration de l'UI
3. Migration des écrans liés (lectures, alertes)
4. Tests et optimisations
