import 'package:firebase_database/firebase_database.dart';
import 'package:logger/logger.dart';

import '../../domain/entities/apiary.dart';
import '../../domain/repositories/apiary_repository.dart';
import '../models/apiary_model.dart';

/// Implémentation Firebase du repository des ruchers
class FirebaseApiaryRepository implements ApiaryRepository {
  final FirebaseDatabase _database;
  final Logger _logger;

  FirebaseApiaryRepository(this._database, this._logger);

  /// Référence vers la collection des ruchers
  DatabaseReference get _apiariesRef => _database.ref('apiaries');

  /// Référence vers l'index utilisateur-ruchers
  DatabaseReference get _userApiariesRef => _database.ref('user_apiaries');

  @override
  Future<({List<Apiary>? result, Exception? error})> getUserApiaries(
      String userId) async {
    try {
      _logger.d('Récupération des ruchers pour l\'utilisateur: $userId');

      // Récupérer les IDs des ruchers de l'utilisateur depuis l'index
      final userApiariesSnapshot = await _userApiariesRef.child(userId).get();

      if (!userApiariesSnapshot.exists) {
        _logger.d('Aucun rucher trouvé pour l\'utilisateur: $userId');
        return (result: <Apiary>[], error: null);
      }

      final apiaryIds = <String>[];
      final userApiariesData =
          userApiariesSnapshot.value as Map<dynamic, dynamic>;

      for (final entry in userApiariesData.entries) {
        if (entry.value == true) {
          apiaryIds.add(entry.key.toString());
        }
      }

      if (apiaryIds.isEmpty) {
        return (result: <Apiary>[], error: null);
      }

      // Récupérer les données des ruchers
      final apiaries = <Apiary>[];
      for (final apiaryId in apiaryIds) {
        final apiarySnapshot = await _apiariesRef.child(apiaryId).get();
        if (apiarySnapshot.exists) {
          final apiaryData = apiarySnapshot.value as Map<dynamic, dynamic>;
          final apiary = ApiaryModel.fromMap(apiaryId, apiaryData);
          apiaries.add(apiary);
        }
      }

      _logger.d(
          '${apiaries.length} ruchers récupérés pour l\'utilisateur: $userId');
      return (result: apiaries, error: null);
    } catch (e, stackTrace) {
      _logger.e('Erreur lors de la récupération des ruchers',
          error: e, stackTrace: stackTrace);
      return (
        result: null,
        error: Exception('Erreur lors de la récupération des ruchers: $e')
      );
    }
  }

  @override
  Future<({Apiary? result, Exception? error})> getApiaryById(
      String apiaryId) async {
    try {
      _logger.d('Récupération du rucher: $apiaryId');

      final snapshot = await _apiariesRef.child(apiaryId).get();

      if (!snapshot.exists) {
        return (result: null, error: Exception('Rucher non trouvé'));
      }

      final apiaryData = snapshot.value as Map<dynamic, dynamic>;
      final apiary = ApiaryModel.fromMap(apiaryId, apiaryData);

      return (result: apiary, error: null);
    } catch (e, stackTrace) {
      _logger.e('Erreur lors de la récupération du rucher',
          error: e, stackTrace: stackTrace);
      return (
        result: null,
        error: Exception('Erreur lors de la récupération du rucher: $e')
      );
    }
  }

  @override
  Future<({Apiary? result, Exception? error})> createApiary(
      Apiary apiary) async {
    try {
      _logger.d('Création d\'un nouveau rucher: ${apiary.name}');

      // Générer un ID unique
      final newApiaryRef = _apiariesRef.push();
      final apiaryId = newApiaryRef.key!;

      // Créer le modèle avec l'ID généré
      final apiaryModel = ApiaryModel.fromEntity(apiary.copyWith(id: apiaryId));

      // Transaction pour créer le rucher et l'index utilisateur
      await _database.ref().update({
        'apiaries/$apiaryId': apiaryModel.toMap(),
        'user_apiaries/${apiary.ownerId}/$apiaryId': true,
      });

      _logger.d('Rucher créé avec succès: $apiaryId');
      return (result: apiaryModel, error: null);
    } catch (e, stackTrace) {
      _logger.e('Erreur lors de la création du rucher',
          error: e, stackTrace: stackTrace);
      return (
        result: null,
        error: Exception('Erreur lors de la création du rucher: $e')
      );
    }
  }

  @override
  Future<({Apiary? result, Exception? error})> updateApiary(
      Apiary apiary) async {
    try {
      _logger.d('Mise à jour du rucher: ${apiary.id}');

      final apiaryModel = ApiaryModel.fromEntity(apiary);
      await _apiariesRef.child(apiary.id).update(apiaryModel.toMap());

      _logger.d('Rucher mis à jour avec succès: ${apiary.id}');
      return (result: apiaryModel, error: null);
    } catch (e, stackTrace) {
      _logger.e('Erreur lors de la mise à jour du rucher',
          error: e, stackTrace: stackTrace);
      return (
        result: null,
        error: Exception('Erreur lors de la mise à jour du rucher: $e')
      );
    }
  }

  @override
  Future<({bool? result, Exception? error})> deleteApiary(
      String apiaryId) async {
    try {
      _logger.d('Suppression du rucher: $apiaryId');

      // Récupérer le rucher pour obtenir l'ownerId
      final apiaryResult = await getApiaryById(apiaryId);
      if (apiaryResult.error != null) {
        return (result: null, error: apiaryResult.error);
      }

      final apiary = apiaryResult.result!;

      // Transaction pour supprimer le rucher et l'index utilisateur
      await _database.ref().update({
        'apiaries/$apiaryId': null,
        'user_apiaries/${apiary.ownerId}/$apiaryId': null,
      });

      _logger.d('Rucher supprimé avec succès: $apiaryId');
      return (result: true, error: null);
    } catch (e, stackTrace) {
      _logger.e('Erreur lors de la suppression du rucher',
          error: e, stackTrace: stackTrace);
      return (
        result: null,
        error: Exception('Erreur lors de la suppression du rucher: $e')
      );
    }
  }

  @override
  Future<({bool? result, Exception? error})> incrementHiveCount(
      String apiaryId) async {
    try {
      await _apiariesRef
          .child(apiaryId)
          .child('hiveCount')
          .runTransaction((currentValue) {
        return Transaction.success((currentValue as int? ?? 0) + 1);
      });
      return (result: true, error: null);
    } catch (e, stackTrace) {
      _logger.e('Erreur lors de l\'incrémentation du nombre ruches',
          error: e, stackTrace: stackTrace);
      return (
        result: null,
        error: Exception('Erreur lors de la mise à jour: $e')
      );
    }
  }

  @override
  Future<({bool? result, Exception? error})> decrementHiveCount(
      String apiaryId) async {
    try {
      await _apiariesRef
          .child(apiaryId)
          .child('hiveCount')
          .runTransaction((currentValue) {
        final current = currentValue as int? ?? 0;
        return Transaction.success(current > 0 ? current - 1 : 0);
      });
      return (result: true, error: null);
    } catch (e, stackTrace) {
      _logger.e('Erreur lors de la décrémentation du nombre ruches',
          error: e, stackTrace: stackTrace);
      return (
        result: null,
        error: Exception('Erreur lors de la mise à jour: $e')
      );
    }
  }

  @override
  Stream<List<Apiary>> watchUserApiaries(String userId) {
    _logger.d('Écoute des ruchers pour l\'utilisateur: $userId');

    return _userApiariesRef.child(userId).onValue.asyncMap((event) async {
      if (!event.snapshot.exists) {
        return <Apiary>[];
      }

      final userApiariesData = event.snapshot.value as Map<dynamic, dynamic>;
      final apiaryIds = <String>[];

      for (final entry in userApiariesData.entries) {
        if (entry.value == true) {
          apiaryIds.add(entry.key.toString());
        }
      }

      if (apiaryIds.isEmpty) {
        return <Apiary>[];
      }

      // Récupérer les données des ruchers
      final apiaries = <Apiary>[];
      for (final apiaryId in apiaryIds) {
        try {
          final apiarySnapshot = await _apiariesRef.child(apiaryId).get();
          if (apiarySnapshot.exists) {
            final apiaryData = apiarySnapshot.value as Map<dynamic, dynamic>;
            final apiary = ApiaryModel.fromMap(apiaryId, apiaryData);
            apiaries.add(apiary);
          }
        } catch (e) {
          _logger.w('Erreur lors de la récupération du rucher $apiaryId: $e');
        }
      }

      return apiaries;
    });
  }
}
