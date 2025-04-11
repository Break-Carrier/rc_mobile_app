import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/current_state.dart';
import '../utils/map_converter.dart';
import 'firebase_service.dart';

/// Service pour gérer l'état actuel des capteurs
class CurrentStateService extends ChangeNotifier {
  final FirebaseService _firebaseService;

  /// ID de la ruche actuellement sélectionnée
  String? _currentHiveId;
  String? get currentHiveId => _currentHiveId;

  /// État actuel des capteurs
  CurrentState? _currentState;
  CurrentState? get currentState => _currentState;

  /// Stream controller pour émettre l'état actuel
  final _stateStreamController = StreamController<CurrentState?>.broadcast();
  Stream<CurrentState?> get stateStream => _stateStreamController.stream;

  /// Abonnement au stream Firebase
  StreamSubscription? _stateSubscription;

  /// Constructeur
  CurrentStateService(this._firebaseService);

  /// Définit la ruche active et configure l'écouteur
  void setCurrentHive(String hiveId) {
    _currentHiveId = hiveId;
    _cancelCurrentSubscription();
    _setupStateListener();
    notifyListeners();
  }

  /// Annule l'abonnement actuel
  void _cancelCurrentSubscription() {
    _stateSubscription?.cancel();
    _stateSubscription = null;
  }

  /// Configure l'écouteur d'état
  void _setupStateListener() {
    if (_currentHiveId == null) {
      debugPrint('⚠️ No hive selected, cannot setup state listener');
      return;
    }

    try {
      final path = 'hives/$_currentHiveId/current_state';
      _stateSubscription = _firebaseService.getDataStream(path).listen((event) {
        if (event.snapshot.exists) {
          try {
            // Convertir les données de façon sécurisée
            if (event.snapshot.value is Map) {
              final rawData = event.snapshot.value as Map<Object?, Object?>;
              final Map<String, dynamic> data =
                  MapConverter.convertToStringDynamicMap(rawData);

              // Adaptation pour le format actuel
              _processCurrentStateData(data);
            } else {
              debugPrint('⚠️ Les données reçues ne sont pas au format Map');
              _stateStreamController.add(null);
            }
          } catch (e) {
            debugPrint('❌ Erreur de conversion des données: $e');
            _stateStreamController.addError(e);
          }
        } else {
          debugPrint('⚠️ No current state data available');
          _stateStreamController.add(null);
        }
      }, onError: (error) {
        debugPrint('❌ Error listening to current state: $error');
        _stateStreamController.addError(error);
      });
    } catch (e) {
      debugPrint('❌ Error setting up current state listener: $e');
    }
  }

  /// Traite les données de l'état actuel
  void _processCurrentStateData(Map<String, dynamic> data) {
    try {
      final temperature = (data['temperature'] as num?)?.toDouble() ?? 0.0;
      final humidity = (data['humidity'] as num?)?.toDouble() ?? 0.0;
      final timestamp = data['lastUpdate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['lastUpdate'] as int)
          : DateTime.now();

      // Récupérer les informations d'hystérésis
      double thresholdHigh = 28.0; // Valeurs par défaut
      double thresholdLow = 15.0;

      if (data.containsKey('hysteresis') &&
          data['hysteresis'] is Map &&
          data['hysteresis']['temperature'] is Map) {
        final tempHysteresis =
            data['hysteresis']['temperature'] as Map<String, dynamic>;
        final threshold =
            (tempHysteresis['threshold'] as num?)?.toDouble() ?? 28.0;
        final upperOffset =
            (tempHysteresis['upper_offset'] as num?)?.toDouble() ?? 0.5;
        final lowerOffset =
            (tempHysteresis['lower_offset'] as num?)?.toDouble() ?? 0.5;

        thresholdHigh = threshold;
        thresholdLow = threshold - (lowerOffset * 2 + upperOffset * 2);
      }

      final isOverThreshold = data['isThresholdExceeded'] as bool? ?? false;

      _currentState = CurrentState(
        temperature: temperature,
        humidity: humidity,
        timestamp: timestamp,
        thresholdHigh: thresholdHigh,
        thresholdLow: thresholdLow,
        isOverThreshold: isOverThreshold,
        metadata: data['connectivity'] as Map<String, dynamic>?,
      );

      _stateStreamController.add(_currentState);
      notifyListeners();

      debugPrint(
          '📊 Current state updated for hive $_currentHiveId: $temperature°C, $humidity%');
    } catch (e) {
      debugPrint('❌ Error processing current state data: $e');
    }
  }

  /// Récupère l'état actuel une seule fois
  Future<CurrentState?> getCurrentState() async {
    if (_currentHiveId == null) {
      debugPrint('⚠️ No hive selected, cannot get current state');
      return null;
    }

    try {
      final path = 'hives/$_currentHiveId/current_state';
      final data = await _firebaseService.getData(path);

      if (data != null) {
        _processCurrentStateData(data);
        return _currentState;
      } else {
        debugPrint(
            '⚠️ No current state data available for hive $_currentHiveId');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Error fetching current state: $e');
      rethrow;
    }
  }

  /// Vérifie si la température actuelle dépasse les seuils
  bool isTemperatureOverThreshold() {
    if (_currentState == null) return false;
    return _currentState!.isLowTemperature || _currentState!.isHighTemperature;
  }

  @override
  void dispose() {
    _stateSubscription?.cancel();
    _stateStreamController.close();
    super.dispose();
  }
}
