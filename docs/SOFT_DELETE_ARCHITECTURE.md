# 🗑️ Architecture Soft Delete

## Vue d'ensemble

Cette documentation décrit l'implémentation du système de soft delete (suppression logique) dans l'application RC Mobile App, conçu pour maintenir l'intégrité des données et permettre la récupération en cas de réclamations utilisateurs.

## 🏗️ Architecture

### 1. Entité de Base : `SoftDeletableEntity`

```dart
abstract class SoftDeletableEntity extends Equatable {
  // Champs de soft delete
  final bool isDeleted;
  final DateTime? deletedAt;
  final String? deletedBy;
  final String? deletionReason;

  // Audit et versioning
  final int version;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final String? updatedBy;
}
```

**Avantages :**

- ✅ Réutilisable pour toutes les entités
- ✅ Audit trail complet
- ✅ Versioning pour la concurrence optimiste
- ✅ Métadonnées de traçabilité

### 2. Classes d'Information

#### `DeletionInfo`

Encapsule les détails d'une suppression :

```dart
class DeletionInfo {
  final String deletedBy;
  final String reason;
  final DateTime? deletedAt;
  final Map<String, dynamic>? metadata;
}
```

#### `RestorationInfo`

Encapsule les détails d'une restauration :

```dart
class RestorationInfo {
  final String restoredBy;
  final String reason;
  final DateTime? restoredAt;
  final Map<String, dynamic>? metadata;
}
```

#### `DeletionReason` (Enum)

Raisons prédéfinies de suppression :

- `userRequest` - Demande de l'utilisateur
- `adminAction` - Action administrative
- `dataCleanup` - Nettoyage des données
- `securityBreach` - Problème de sécurité
- `regulatoryCompliance` - Conformité réglementaire

## 🔧 Implementation

### 1. Repository Pattern

Le `UserProfileRepository` inclut les méthodes soft delete :

```dart
abstract class UserProfileRepository {
  // Soft delete
  Future<UserProfileResult<UserProfileEntity>> softDeleteUserProfile(
    String userId,
    DeletionInfo deletionInfo
  );

  // Restauration
  Future<UserProfileResult<UserProfileEntity>> restoreUserProfile(
    String userId,
    RestorationInfo restorationInfo
  );

  // Consultation des supprimés
  Future<UserProfileResult<List<UserProfileEntity>>> getDeletedProfiles({
    bool includeExpired = false,
    Duration? maxAge,
  });

  // Suppression définitive (cas extrêmes)
  Future<UserProfileResult<void>> permanentDeleteUserProfile(
    String userId,
    String deletedBy,
    String reason,
  );
}
```

### 2. Use Cases

#### `SoftDeleteUserProfile`

```dart
class SoftDeleteUserProfile {
  Future<UserProfileResult<UserProfileEntity>> call({
    required String userId,
    required String deletedBy,
    required String reason,
    Map<String, dynamic>? metadata,
  });
}
```

**Validations incluses :**

- ✅ Paramètres d'entrée
- ✅ Permissions utilisateur
- ✅ État existant de l'entité
- ✅ Règles métier spécifiques

#### `RestoreUserProfile`

```dart
class RestoreUserProfile {
  Future<UserProfileResult<UserProfileEntity>> call({
    required String userId,
    required String restoredBy,
    required String reason,
    Map<String, dynamic>? metadata,
  });
}
```

**Vérifications incluses :**

- ✅ Période de grâce (90 jours par défaut)
- ✅ Permissions administrateur
- ✅ Éligibilité à la restauration

### 3. Service d'Audit

Le `AuditService` enregistre toutes les actions :

```dart
class AuditService {
  // Logging des actions
  Future<void> logSoftDeletion(...);
  Future<void> logRestoration(...);
  Future<void> logPermanentDeletion(...);

  // Rapports et historiques
  Future<AuditReport> generateAuditReport(...);
  Future<List<AuditEntry>> getEntityAuditHistory(...);
}
```

**Types d'audit :**

- 🔴 **Critical** : Suppressions définitives
- 🟡 **High** : Suppressions logiques d'admins
- 🟢 **Normal** : Suppressions logiques standards
- 🔵 **Low** : Modifications mineures

## 🔐 Sécurité et Permissions

### Matrice des Permissions

| Action                   | Utilisateur | Apiculteur | Admin | Super Admin |
| ------------------------ | ----------- | ---------- | ----- | ----------- |
| Voir ses données         | ✅          | ✅         | ✅    | ✅          |
| Modifier son profil      | ✅          | ✅         | ✅    | ✅          |
| Supprimer son profil     | ❌          | ❌         | ❌    | ❌          |
| Supprimer autres profils | ❌          | ❌         | ✅    | ✅          |
| Restaurer profils        | ❌          | ❌         | ✅    | ✅          |
| Suppression définitive   | ❌          | ❌         | ❌    | ✅          |
| Audit complet            | ❌          | ❌         | ✅    | ✅          |

### Règles de Sécurité

1. **Auto-protection** : Un utilisateur ne peut pas se supprimer lui-même
2. **Validation obligatoire** : Raison minimum 10 caractères
3. **Période de grâce** : 90 jours pour restauration
4. **Audit trail** : Toutes les actions sont tracées
5. **Permissions graduelles** : Accès basé sur le rôle

## 📱 Interface Utilisateur

### 1. Écran Profil Utilisateur

**Fonctionnalités par rôle :**

- **Utilisateur standard** : Consultation, modification
- **Apiculteur** : + Accès fonctionnalités métier
- **Administrateur** : + Gestion utilisateurs, restauration

**Indicateurs visuels :**

- 🟢 Badge vert : Compte actif
- 🟡 Badge orange : En attente de validation
- 🔴 Badge rouge : Compte supprimé (avec option restauration)

### 2. Interface Administrateur

**Écran des profils supprimés :**

- 📋 Liste filtrée par période/statut
- 🔍 Recherche par nom/email
- 📊 Statistiques rapides
- ⚡ Restauration en un clic
- 📖 Consultation audit trail

**Filtres disponibles :**

- Période de suppression
- Type d'utilisateur
- Raison de suppression
- Éligibilité à la restauration

## 🗄️ Structure de Données

### Firebase Realtime Database

```json
{
  "user_profiles": {
    "userId": {
      "basicInfo": { ... },
      "role": { ... },
      "beekeeperDetails": { ... },
      "softDelete": {
        "isDeleted": false,
        "deletedAt": null,
        "deletedBy": null,
        "deletionReason": null
      },
      "audit": {
        "version": 1,
        "createdAt": "timestamp",
        "updatedAt": "timestamp",
        "createdBy": "userId",
        "updatedBy": "userId"
      }
    }
  },
  "audit_logs": {
    "entryId": {
      "action": "soft_delete",
      "entityType": "UserProfile",
      "entityId": "userId",
      "performedBy": "adminId",
      "timestamp": "timestamp",
      "details": {
        "reason": "...",
        "metadata": { ... }
      },
      "severity": "normal"
    }
  }
}
```

## ⚡ Performances

### Optimisations

1. **Index spécialisés** pour les requêtes soft delete
2. **Pagination** pour les listes de profils supprimés
3. **Cache intelligent** pour les données fréquemment consultées
4. **Requêtes composées** Firebase pour filtres multiples

### Métriques

- 📈 Temps de suppression logique : < 500ms
- 📈 Temps de restauration : < 1s
- 📈 Chargement liste supprimés : < 2s
- 📈 Génération rapport audit : < 5s

## 🧪 Tests

### Stratégie de Test

1. **Tests unitaires** : Use cases et validations
2. **Tests d'intégration** : Repository et Firebase
3. **Tests UI** : Écrans administrateur
4. **Tests de performance** : Gestion de charge

### Scénarios Critiques

- ✅ Suppression avec permissions insuffisantes
- ✅ Restauration après expiration
- ✅ Tentative d'auto-suppression
- ✅ Concurrence sur même entité
- ✅ Intégrité audit trail

## 🚀 Déploiement

### Checklist Pré-Déploiement

- [ ] Tests passants à 100%
- [ ] Configuration Firebase sécurisée
- [ ] Index Firestore optimisés
- [ ] Permissions IAM configurées
- [ ] Monitoring et alertes activés

### Migration

1. **Phase 1** : Ajout champs soft delete (compatible descendants)
2. **Phase 2** : Mise à jour logique applicative
3. **Phase 3** : Formation équipes support
4. **Phase 4** : Activation fonctionnalités admin

## 📊 Monitoring

### Métriques Clés

- Nombre de suppressions par jour/semaine
- Taux de restauration
- Temps moyen de résolution réclamations
- Utilisation interface admin

### Alertes Configurées

- 🚨 Pic de suppressions anormal
- 🚨 Tentatives d'accès non autorisées
- 🚨 Erreurs répétées restauration
- 🚨 Temps de réponse dégradés

## 🔄 Évolutions Futures

### Roadmap

- **v1.1** : Soft delete pour toutes les entités métier
- **v1.2** : Workflow validation à plusieurs niveaux
- **v1.3** : Export/Import pour conformité RGPD
- **v1.4** : Intelligence artificielle détection patterns suspects

### Extensibilité

L'architecture `SoftDeletableEntity` peut être étendue à :

- 🏠 Ruchers et ruches
- 📊 Données de capteurs
- 📝 Rapports et notifications
- 👥 Équipes et organisations

---

**Documentation maintenue par l'équipe de développement RC Mobile App**
_Dernière mise à jour : Décembre 2024_
