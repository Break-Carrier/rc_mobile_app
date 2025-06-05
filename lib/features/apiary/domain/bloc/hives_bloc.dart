import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../sensor/domain/entities/apiary.dart';
import '../../../sensor/domain/entities/hive.dart';
import '../../data/repositories/apiary_repository.dart';
import '../repositories/apiary_repository_interface.dart';

// Événements
abstract class HivesEvent {}

class LoadHives extends HivesEvent {
  final String apiaryId;

  LoadHives({required this.apiaryId});
}

class RefreshHives extends HivesEvent {
  final String apiaryId;

  RefreshHives({required this.apiaryId});
}

class AddHive extends HivesEvent {
  final String apiaryId;
  final Hive hive;

  AddHive({
    required this.apiaryId,
    required this.hive,
  });
}

class DeleteHive extends HivesEvent {
  final String apiaryId;
  final String hiveId;

  DeleteHive({
    required this.apiaryId,
    required this.hiveId,
  });
}

// États
abstract class HivesState {}

class HivesInitial extends HivesState {}

class HivesLoading extends HivesState {}

class HivesLoaded extends HivesState {
  final String apiaryId;
  final Apiary? apiary;
  final List<Hive> hives;

  HivesLoaded({
    required this.apiaryId,
    this.apiary,
    required this.hives,
  });
}

class HiveOperationSuccess extends HivesState {
  final String message;

  HiveOperationSuccess({required this.message});
}

class HivesError extends HivesState {
  final String message;

  HivesError({required this.message});
}

// BLoC
class HivesBloc extends Bloc<HivesEvent, HivesState> {
  final IApiaryRepository _apiaryRepository;

  HivesBloc({
    IApiaryRepository? apiaryRepository,
  })  : _apiaryRepository = apiaryRepository ?? ApiaryRepository(),
        super(HivesInitial()) {
    on<LoadHives>(_onLoadHives);
    on<RefreshHives>(_onRefreshHives);
    on<AddHive>(_onAddHive);
    on<DeleteHive>(_onDeleteHive);
  }

  Future<void> _onLoadHives(LoadHives event, Emitter<HivesState> emit) async {
    try {
      emit(HivesLoading());

      // Charger le rucher
      final apiary = await _apiaryRepository.getApiaryById(event.apiaryId);

      // Charger les ruches de ce rucher
      final hives = await _apiaryRepository.getHivesForApiary(event.apiaryId);

      emit(HivesLoaded(
        apiaryId: event.apiaryId,
        apiary: apiary,
        hives: hives,
      ));
    } catch (e) {
      debugPrint('❌ Error loading hives: $e');
      emit(HivesError(message: 'Erreur lors du chargement des ruches: $e'));
    }
  }

  Future<void> _onRefreshHives(
      RefreshHives event, Emitter<HivesState> emit) async {
    add(LoadHives(apiaryId: event.apiaryId));
  }

  Future<void> _onAddHive(AddHive event, Emitter<HivesState> emit) async {
    try {
      emit(HivesLoading());

      final hiveId = await _apiaryRepository.addHiveToApiary(
        event.apiaryId,
        event.hive,
      );

      if (hiveId != null) {
        // Si l'ajout a réussi, recharger la liste
        add(LoadHives(apiaryId: event.apiaryId));
        emit(HiveOperationSuccess(
            message: 'Ruche "${event.hive.name}" ajoutée avec succès'));
      } else {
        emit(HivesError(message: 'Erreur lors de l\'ajout de la ruche'));
      }
    } catch (e) {
      debugPrint('❌ Error adding hive: $e');
      emit(HivesError(message: 'Erreur lors de l\'ajout de la ruche: $e'));
    }
  }

  Future<void> _onDeleteHive(DeleteHive event, Emitter<HivesState> emit) async {
    try {
      emit(HivesLoading());

      final success = await _apiaryRepository.deleteHiveFromApiary(
        event.apiaryId,
        event.hiveId,
      );

      if (success) {
        // Si la suppression a réussi, recharger la liste
        add(LoadHives(apiaryId: event.apiaryId));
        emit(HiveOperationSuccess(message: 'Ruche supprimée avec succès'));
      } else {
        emit(HivesError(message: 'Erreur lors de la suppression de la ruche'));
      }
    } catch (e) {
      debugPrint('❌ Error deleting hive: $e');
      emit(
          HivesError(message: 'Erreur lors de la suppression de la ruche: $e'));
    }
  }
}
