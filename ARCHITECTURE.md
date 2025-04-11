# Architecture du Projet Ruche Connectée

Ce document décrit l'architecture du projet d'application mobile Ruche Connectée.

## Architecture globale

Le projet suit une architecture inspirée de Clean Architecture avec une organisation par fonctionnalités (features). Cette approche offre plusieurs avantages:

- **Séparation des préoccupations**: Chaque composant a une responsabilité unique
- **Facilité de maintenance**: Les modifications sont isolées à des modules spécifiques
- **Testabilité**: Chaque couche peut être testée indépendamment
- **Scalabilité**: De nouvelles fonctionnalités peuvent être ajoutées facilement

## Structure de dossiers

```
lib/
  ├── core/                # Fonctionnalités communes à toute l'application
  │    ├── constants/     # Constantes globales
  │    ├── routes/        # Configuration des routes
  │    ├── theme/         # Thème de l'application
  │    └── utils/         # Utilitaires communs
  │
  ├── features/           # Fonctionnalités organisées par domaine métier
  │    ├── dashboard/     # Fonctionnalité tableau de bord
  │    │    ├── data/           # Couche données
  │    │    │    └── repositories/  # Implémentations des repositories
  │    │    ├── domain/         # Couche domaine (logique métier)
  │    │    │    └── bloc/      # État et logique de la fonctionnalité
  │    │    └── presentation/   # Couche présentation
  │    │         ├── screens/   # Écrans complets
  │    │         └── widgets/   # Composants UI réutilisables
  │    │
  │    ├── apiary/        # Fonctionnalité rucher
  │    ├── hive/          # Fonctionnalité ruche
  │    ├── auth/          # Fonctionnalité authentification
  │    └── settings/      # Fonctionnalité paramètres
  │
  ├── models/             # Modèles de données partagés
  ├── services/           # Services d'accès aux données
  ├── widgets/            # Widgets UI partagés
  ├── screens/            # Écrans (ancienne structure, à migrer progressivement)
  └── main.dart           # Point d'entrée de l'application
```

## Responsabilités des couches

### 1. Couche données (data)

Responsable de l'accès aux données, que ce soit via API, base de données locale ou Firebase:

- **Repositories**: Implémentent les interfaces définies dans la couche domaine
- **Sources de données**: Gèrent l'accès aux différentes sources (API, local, etc.)
- **Mappers**: Convertissent entre différents formats de données

### 2. Couche domaine (domain)

Contient la logique métier indépendante de l'interface utilisateur:

- **Entités**: Objets métier avec leurs règles et comportements
- **Repositories (interfaces)**: Définissent les contrats pour l'accès aux données
- **Blocs**: Gèrent l'état et la logique métier des fonctionnalités

### 3. Couche présentation (presentation)

Responsable de l'affichage et des interactions utilisateur:

- **Écrans**: Composants UI complets représentant un écran de l'application
- **Widgets**: Composants UI réutilisables
- **ViewModels/Blocs**: Préparent les données pour l'affichage

## Gestion d'état

L'application utilise deux approches complémentaires pour la gestion d'état:

1. **BLoC (Business Logic Component)**: Pour la logique métier complexe, les états multiples et les écrans à forte interaction utilisateur.
2. **Provider/ChangeNotifier**: Pour des états plus simples et lorsqu'une approche réactive est suffisante.

## Dépendances entre couches

Le principe fondamental est que les dépendances ne vont que dans une direction:

- La couche présentation dépend de la couche domaine
- La couche domaine ne dépend d'aucune autre couche
- La couche données dépend de la couche domaine (pour les interfaces de repository)

Cela garantit que notre logique métier reste propre et indépendante des détails d'implémentation.

## Approche de refactoring

La transition vers cette architecture se fait progressivement:

1. Création de nouvelles fonctionnalités avec la nouvelle architecture
2. Refactoring progressif des fonctionnalités existantes
3. Respect des principes SOLID lors des modifications

## Convention de nommage

- **Classes BLoC**: Suffixe `Bloc` (ex: `DashboardBloc`)
- **États BLoC**: Suffixe `State` (ex: `DashboardState`)
- **Événements BLoC**: Suffixe `Event` (ex: `DashboardEvent`)
- **Repositories**: Suffixe `Repository` (ex: `DashboardRepository`)
- **Classes d'interfaces**: Préfixe `I` (ex: `IApiaryRepository`)

## Tests

Chaque couche doit être testable indépendamment:

- **Tests unitaires**: Pour la logique métier et les modèles
- **Tests de widget**: Pour les composants UI
- **Tests d'intégration**: Pour les flux complets à travers plusieurs couches
