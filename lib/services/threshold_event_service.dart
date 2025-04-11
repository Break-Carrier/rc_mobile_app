import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/threshold_event.dart';
import '../utils/map_converter.dart';
import 'firebase_service.dart';

/// Service pour gérer les événements de dépassement de seuil
class ThresholdEventService extends ChangeNotifier {
  final FirebaseService _firebaseService;

  /// ID de la ruche actuellement sélectionnée
  String? _currentHiveId;
  String? get currentHiveId => _currentHiveId;

  /// Liste des événements
  List<ThresholdEvent> _events = [];
  List<ThresholdEvent> get events => _events;

  /// Stream controller pour émettre les événements
  final _eventsStreamController =
      StreamController<List<ThresholdEvent>>.broadcast();
  Stream<List<ThresholdEvent>> get eventsStream =>
      _eventsStreamController.stream;

  /// Abonnement au stream Firebase
  StreamSubscription? _eventsSubscription;

  /// Constructeur
  ThresholdEventService(this._firebaseService);

  /// Définit la ruche active et configure l'écouteur
  void setCurrentHive(String hiveId) {
    _currentHiveId = hiveId;
    _cancelCurrentSubscription();
    _setupEventsListener();
    notifyListeners();
  }

  /// Annule l'abonnement actuel
  void _cancelCurrentSubscription() {
    _eventsSubscription?.cancel();
    _eventsSubscription = null;
  }

  /// Configure l'écouteur d'événements
  void _setupEventsListener() {
    if (_currentHiveId == null) {
      debugPrint('⚠️ No hive selected, cannot setup threshold events listener');
      return;
    }

    try {
      final path = 'hives/$_currentHiveId/threshold_events';

      _eventsSubscription =
          _firebaseService.getDataStream(path).listen((event) {
        if (event.snapshot.exists) {
          try {
            // Convertir les données de façon sécurisée
            if (event.snapshot.value is Map) {
              final rawData = event.snapshot.value as Map<Object?, Object?>;
              final Map<String, dynamic> data =
                  MapConverter.convertToStringDynamicMap(rawData);

              _processEventsData(data);
            } else {
              debugPrint('⚠️ Les données reçues ne sont pas au format Map');
              _events = [];
              _eventsStreamController.add(_events);
              notifyListeners();
            }
          } catch (e) {
            debugPrint('❌ Erreur de conversion des données: $e');
            _eventsStreamController.addError(e);
          }
        } else {
          debugPrint(
              '⚠️ No threshold events data available for hive $_currentHiveId');
          _events = [];
          _eventsStreamController.add(_events);
          notifyListeners();
        }
      }, onError: (error) {
        debugPrint('❌ Error listening to threshold events: $error');
        _eventsStreamController.addError(error);
      });
    } catch (e) {
      debugPrint('❌ Error setting up threshold events listener: $e');
    }
  }

  /// Traite les données d'événements reçues de Firebase
  void _processEventsData(Map<String, dynamic> data) {
    try {
      _events = [];

      // Convertir chaque entrée en objet ThresholdEvent
      data.forEach((key, value) {
        try {
          if (value is Map<String, dynamic>) {
            // Adapter le format des événements à la structure actuelle
            final event = _parseThresholdEvent(value, key);
            if (event != null) {
              _events.add(event);
            }
          }
        } catch (e) {
          debugPrint('⚠️ Error parsing threshold event: $e');
        }
      });

      // Trier par timestamp (plus récent en premier)
      _events.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      _eventsStreamController.add(_events);
      notifyListeners();

      debugPrint(
          '📊 ${_events.length} threshold events updated for hive $_currentHiveId');
    } catch (e) {
      debugPrint('❌ Error processing threshold events data: $e');
    }
  }

  /// Parse un événement de seuil depuis le format actuel de Firebase
  ThresholdEvent? _parseThresholdEvent(Map<String, dynamic> data, String id) {
    try {
      final timestamp = data['timestamp'] as int?;
      if (timestamp == null) return null;

      ThresholdEventType type;
      if (data['event'] == 'threshold_exceeded') {
        type = ThresholdEventType.exceeded;
      } else if (data['event'] == 'threshold_ended') {
        type = ThresholdEventType.normal;
      } else {
        return null; // Type d'événement non reconnu
      }

      return ThresholdEvent(
        id: id,
        timestamp: DateTime.fromMillisecondsSinceEpoch(timestamp),
        temperature: (data['temperature'] as num?)?.toDouble() ?? 0.0,
        humidity: (data['humidity'] as num?)?.toDouble() ?? 0.0,
        eventType: type,
        thresholdHigh: (data['threshold'] as num?)?.toDouble() ?? 28.0,
        thresholdLow: (data['threshold'] as num?)?.toDouble() ?? 15.0,
      );
    } catch (e) {
      debugPrint('❌ Error parsing threshold event: $e');
      return null;
    }
  }

  /// Récupère les événements une seule fois
  Future<List<ThresholdEvent>> getThresholdEvents() async {
    if (_currentHiveId == null) {
      debugPrint('⚠️ No hive selected, cannot get threshold events');
      return [];
    }

    try {
      final path = 'hives/$_currentHiveId/threshold_events';
      final data = await _firebaseService.getData(path);

      if (data != null) {
        _processEventsData(data);
        return _events;
      } else {
        debugPrint(
            '⚠️ No threshold events data available for hive $_currentHiveId');
        _events = [];
        _eventsStreamController.add(_events);
        notifyListeners();
        return [];
      }
    } catch (e) {
      debugPrint('❌ Error fetching threshold events: $e');
      rethrow;
    }
  }

  /// Crée un nouvel événement de dépassement de seuil
  Future<String?> createThresholdEvent({
    required double temperature,
    required double humidity,
    required ThresholdEventType eventType,
    required double thresholdHigh,
    required double thresholdLow,
  }) async {
    try {
      final event = ThresholdEvent(
        temperature: temperature,
        humidity: humidity,
        timestamp: DateTime.now(),
        eventType: eventType,
        thresholdHigh: thresholdHigh,
        thresholdLow: thresholdLow,
      );

      final eventData = event.toMap();
      final eventId = await _firebaseService.pushData(
          'hives/$_currentHiveId/threshold_events', eventData);

      debugPrint('✅ New threshold event created with ID: $eventId');

      // Actualiser la liste des événements
      await getThresholdEvents();

      return eventId;
    } catch (e) {
      debugPrint('❌ Error creating threshold event: $e');
      rethrow;
    }
  }

  @override
  void dispose() {
    _eventsSubscription?.cancel();
    _eventsStreamController.close();
    super.dispose();
  }
}
