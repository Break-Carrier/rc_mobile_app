import 'package:firebase_database/firebase_database.dart';
import 'package:logger/logger.dart';

import '../../domain/entities/hive.dart';
import '../../domain/repositories/hive_repository.dart';
import '../models/hive_model.dart';

/// Implémentation Firebase du repository des ruches
class FirebaseHiveRepository implements HiveRepository {
  final FirebaseDatabase _database;
  final Logger _logger;

  FirebaseHiveRepository(this._database, this._logger);

  /// Référence vers la collection des ruches
  DatabaseReference get _hivesRef => _database.ref('hives');

  /// Référence vers l'index rucher-ruches
  DatabaseReference get _apiaryHivesRef => _database.ref('apiary_hives');

  @override
  Future<({List<Hive>? result, Exception? error})> getApiaryHives(
      String apiaryId) async {
    try {
      _logger.d('Récupération des ruches pour le rucher: $apiaryId');

      // Récupérer les IDs des ruches du rucher depuis l'index
      final apiaryHivesSnapshot = await _apiaryHivesRef.child(apiaryId).get();

      if (!apiaryHivesSnapshot.exists) {
        _logger.d('Aucune ruche trouvée pour le rucher: $apiaryId');
        return (result: <Hive>[], error: null);
      }

      final hiveIds = <String>[];
      final apiaryHivesData =
          apiaryHivesSnapshot.value as Map<dynamic, dynamic>;

      for (final entry in apiaryHivesData.entries) {
        if (entry.value == true) {
          hiveIds.add(entry.key.toString());
        }
      }

      if (hiveIds.isEmpty) {
        return (result: <Hive>[], error: null);
      }

      // Récupérer les données des ruches
      final hives = <Hive>[];
      for (final hiveId in hiveIds) {
        final hiveSnapshot = await _hivesRef.child(hiveId).get();
        if (hiveSnapshot.exists) {
          final hiveData = hiveSnapshot.value as Map<dynamic, dynamic>;
          final hive = HiveModel.fromMap(hiveId, hiveData);
          hives.add(hive);
        }
      }

      _logger.d('${hives.length} ruches récupérées pour le rucher: $apiaryId');
      return (result: hives, error: null);
    } catch (e, stackTrace) {
      _logger.e('Erreur lors de la récupération des ruches',
          error: e, stackTrace: stackTrace);
      return (
        result: null,
        error: Exception('Erreur lors de la récupération des ruches: $e')
      );
    }
  }

  @override
  Future<({List<Hive>? result, Exception? error})> getUserHives(
      String userId) async {
    try {
      _logger
          .d('Récupération de toutes les ruches pour l\'utilisateur: $userId');

      final hivesSnapshot =
          await _hivesRef.orderByChild('ownerId').equalTo(userId).get();

      if (!hivesSnapshot.exists) {
        _logger.d('Aucune ruche trouvée pour l\'utilisateur: $userId');
        return (result: <Hive>[], error: null);
      }

      final hives = <Hive>[];
      final hivesData = hivesSnapshot.value as Map<dynamic, dynamic>;

      hivesData.forEach((key, value) {
        final hiveData = Map<dynamic, dynamic>.from(value as Map);
        final hive = HiveModel.fromMap(key.toString(), hiveData);
        hives.add(hive);
      });

      _logger
          .d('${hives.length} ruches récupérées pour l\'utilisateur: $userId');
      return (result: hives, error: null);
    } catch (e, stackTrace) {
      _logger.e('Erreur lors de la récupération des ruches utilisateur',
          error: e, stackTrace: stackTrace);
      return (
        result: null,
        error: Exception('Erreur lors de la récupération des ruches: $e')
      );
    }
  }

  @override
  Future<({Hive? result, Exception? error})> getHiveById(String hiveId) async {
    try {
      _logger.d('Récupération de la ruche: $hiveId');

      final snapshot = await _hivesRef.child(hiveId).get();

      if (!snapshot.exists) {
        return (result: null, error: Exception('Ruche non trouvée'));
      }

      final hiveData = snapshot.value as Map<dynamic, dynamic>;
      final hive = HiveModel.fromMap(hiveId, hiveData);

      return (result: hive, error: null);
    } catch (e, stackTrace) {
      _logger.e('Erreur lors de la récupération de la ruche',
          error: e, stackTrace: stackTrace);
      return (
        result: null,
        error: Exception('Erreur lors de la récupération de la ruche: $e')
      );
    }
  }

  @override
  Future<({Hive? result, Exception? error})> createHive(Hive hive) async {
    try {
      _logger.d('Création d\'une nouvelle ruche: ${hive.name}');

      // Générer un ID unique
      final newHiveRef = _hivesRef.push();
      final hiveId = newHiveRef.key!;

      // Créer le modèle avec l'ID généré
      final hiveModel = HiveModel.fromEntity(hive.copyWith(id: hiveId));

      // Transaction pour créer la ruche et l'index rucher
      await _database.ref().update({
        'hives/$hiveId': hiveModel.toMap(),
        'apiary_hives/${hive.apiaryId}/$hiveId': true,
      });

      _logger.d('Ruche créée avec succès: $hiveId');
      return (result: hiveModel, error: null);
    } catch (e, stackTrace) {
      _logger.e('Erreur lors de la création de la ruche',
          error: e, stackTrace: stackTrace);
      return (
        result: null,
        error: Exception('Erreur lors de la création de la ruche: $e')
      );
    }
  }

  @override
  Future<({Hive? result, Exception? error})> updateHive(Hive hive) async {
    try {
      _logger.d('Mise à jour de la ruche: ${hive.id}');

      final hiveModel = HiveModel.fromEntity(hive);
      await _hivesRef.child(hive.id).update(hiveModel.toMap());

      _logger.d('Ruche mise à jour avec succès: ${hive.id}');
      return (result: hiveModel, error: null);
    } catch (e, stackTrace) {
      _logger.e('Erreur lors de la mise à jour de la ruche',
          error: e, stackTrace: stackTrace);
      return (
        result: null,
        error: Exception('Erreur lors de la mise à jour de la ruche: $e')
      );
    }
  }

  @override
  Future<({bool? result, Exception? error})> deleteHive(String hiveId) async {
    try {
      _logger.d('Suppression de la ruche: $hiveId');

      // Récupérer la ruche pour obtenir l'apiaryId
      final hiveResult = await getHiveById(hiveId);
      if (hiveResult.error != null) {
        return (result: null, error: hiveResult.error);
      }

      final hive = hiveResult.result!;

      // Transaction pour supprimer la ruche et l'index rucher
      await _database.ref().update({
        'hives/$hiveId': null,
        'apiary_hives/${hive.apiaryId}/$hiveId': null,
      });

      _logger.d('Ruche supprimée avec succès: $hiveId');
      return (result: true, error: null);
    } catch (e, stackTrace) {
      _logger.e('Erreur lors de la suppression de la ruche',
          error: e, stackTrace: stackTrace);
      return (
        result: null,
        error: Exception('Erreur lors de la suppression de la ruche: $e')
      );
    }
  }

  @override
  Future<({bool? result, Exception? error})> updateLastInspection(
      String hiveId, DateTime inspectionDate) async {
    try {
      await _hivesRef.child(hiveId).update({
        'lastInspection': inspectionDate.millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
      return (result: true, error: null);
    } catch (e, stackTrace) {
      _logger.e('Erreur lors de la mise à jour de l\'inspection',
          error: e, stackTrace: stackTrace);
      return (
        result: null,
        error: Exception('Erreur lors de la mise à jour: $e')
      );
    }
  }

  @override
  Future<({bool? result, Exception? error})> toggleHiveStatus(
      String hiveId, bool isActive) async {
    try {
      await _hivesRef.child(hiveId).update({
        'isActive': isActive,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
      return (result: true, error: null);
    } catch (e, stackTrace) {
      _logger.e('Erreur lors du changement de statut',
          error: e, stackTrace: stackTrace);
      return (
        result: null,
        error: Exception('Erreur lors de la mise à jour: $e')
      );
    }
  }

  @override
  Stream<List<Hive>> watchApiaryHives(String apiaryId) {
    _logger.d('Écoute des ruches pour le rucher: $apiaryId');

    return _apiaryHivesRef.child(apiaryId).onValue.asyncMap((event) async {
      if (!event.snapshot.exists) {
        return <Hive>[];
      }

      final apiaryHivesData = event.snapshot.value as Map<dynamic, dynamic>;
      final hiveIds = <String>[];

      for (final entry in apiaryHivesData.entries) {
        if (entry.value == true) {
          hiveIds.add(entry.key.toString());
        }
      }

      if (hiveIds.isEmpty) {
        return <Hive>[];
      }

      // Récupérer les données des ruches
      final hives = <Hive>[];
      for (final hiveId in hiveIds) {
        try {
          final hiveSnapshot = await _hivesRef.child(hiveId).get();
          if (hiveSnapshot.exists) {
            final hiveData = hiveSnapshot.value as Map<dynamic, dynamic>;
            final hive = HiveModel.fromMap(hiveId, hiveData);
            hives.add(hive);
          }
        } catch (e) {
          _logger.w('Erreur lors de la récupération de la ruche $hiveId: $e');
        }
      }

      return hives;
    });
  }

  @override
  Stream<List<Hive>> watchUserHives(String userId) {
    _logger.d('Écoute de toutes les ruches pour l\'utilisateur: $userId');

    return _hivesRef
        .orderByChild('ownerId')
        .equalTo(userId)
        .onValue
        .map((event) {
      if (!event.snapshot.exists) {
        return <Hive>[];
      }

      final hives = <Hive>[];
      final hivesData = event.snapshot.value as Map<dynamic, dynamic>;

      hivesData.forEach((key, value) {
        try {
          final hiveData = Map<dynamic, dynamic>.from(value as Map);
          final hive = HiveModel.fromMap(key.toString(), hiveData);
          hives.add(hive);
        } catch (e) {
          _logger.w('Erreur lors de la récupération de la ruche $key: $e');
        }
      });

      return hives;
    });
  }
}
