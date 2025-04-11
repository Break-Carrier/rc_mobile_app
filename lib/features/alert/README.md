# Feature Alert (Alertes)

Cette fonctionnalité gère l'affichage et la gestion des alertes générées à partir des données des capteurs.

## Structure

L'architecture suit le pattern Clean Architecture avec trois couches principales:

```
alert/
├── data/                        # Couche de données
│   ├── models/                  # Modèles de données
│   │   └── threshold_event_model.dart  # Modèle pour les alertes
│   └── repositories/
│       └── alert_repository.dart # Implémentation du repository
├── domain/                      # Couche métier
│   ├── bloc/                    # Gestion d'état
│   │   ├── alert_bloc.dart      # BLoC pour les alertes
│   │   ├── alert_event.dart     # Événements du BLoC
│   │   └── alert_state.dart     # États du BLoC
│   ├── entities/                # Entités métier
│   │   └── threshold_event.dart # Entité pour les alertes
│   └── repositories/            # Interfaces (contrats)
│       └── alert_repository_interface.dart
├── presentation/               # Couche de présentation
│   ├── screens/                # Écrans complets
│   │   └── alerts_screen.dart
│   └── widgets/                # Composants UI réutilisables
│       └── alert_card.dart
└── README.md                   # Documentation de la fonctionnalité
```

## Fonctionnalités

### Principales fonctionnalités

- Affichage des alertes (température, humidité, poids, etc.)
- Filtrage des alertes par type, ruche, et période
- Marquage des alertes comme lues/traitées
- Notification des nouvelles alertes

### À venir

- Configuration des seuils d'alerte personnalisés
- Export des données d'alertes
- Statistiques sur les alertes

## Architecture technique

### 1. Couche domain

Contient les définitions abstraites et la logique métier:

- `IAlertRepository`: Interface définissant les contrats pour l'accès aux données des alertes
- `AlertBloc`: Gère l'état et les événements liés aux alertes

### 2. Couche data

Implémente l'accès aux données:

- `AlertRepository`: Implémente `IAlertRepository` en utilisant directement le service Firebase

### 3. Couche presentation

Gère l'interface utilisateur:

- `AlertsScreen`: Écran principal pour afficher les alertes
- Widgets spécifiques pour l'affichage des alertes

## Flux de données

1. L'utilisateur navigue vers la page des alertes
2. Le `AlertBloc` charge les données via le `AlertRepository`
3. L'interface utilisateur réagit aux changements d'état du BLoC
4. Pour les données en temps réel, le BLoC s'abonne aux streams fournis par le repository

## Tests

- Tests unitaires pour la logique métier du BLoC et du repository
- Tests de widget pour les composants UI
- Tests d'intégration pour le flux complet

## Migration

Cette feature est en cours de migration depuis l'architecture précédente. Les étapes sont:

1. Migration de la structure du modèle et des services
2. Mise en place du repository et des BLOCs
3. Migration de l'interface utilisateur
4. Tests et optimisations
