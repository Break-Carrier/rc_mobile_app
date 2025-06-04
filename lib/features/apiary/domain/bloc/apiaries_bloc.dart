import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/models/apiary.dart';
import '../../data/repositories/apiary_repository.dart';
import '../repositories/apiary_repository_interface.dart';

// Événements
abstract class ApiariesEvent {}

class LoadApiaries extends ApiariesEvent {}

class RefreshApiaries extends ApiariesEvent {}

class AddApiary extends ApiariesEvent {
  final Apiary apiary;

  AddApiary({required this.apiary});
}

class UpdateApiary extends ApiariesEvent {
  final String id;
  final Apiary apiary;

  UpdateApiary({
    required this.id,
    required this.apiary,
  });
}

class DeleteApiary extends ApiariesEvent {
  final String id;

  DeleteApiary({required this.id});
}

// États
abstract class ApiariesState {}

class ApiariesInitial extends ApiariesState {}

class ApiariesLoading extends ApiariesState {}

class ApiariesLoaded extends ApiariesState {
  final List<Apiary> apiaries;

  ApiariesLoaded({required this.apiaries});
}

class ApiaryOperationSuccess extends ApiariesState {
  final String message;

  ApiaryOperationSuccess({required this.message});
}

class ApiariesError extends ApiariesState {
  final String message;

  ApiariesError({required this.message});
}

// BLoC
class ApiariesBloc extends Bloc<ApiariesEvent, ApiariesState> {
  final IApiaryRepository _apiaryRepository;

  ApiariesBloc({
    IApiaryRepository? apiaryRepository,
  })  : _apiaryRepository = apiaryRepository ?? ApiaryRepository(),
        super(ApiariesInitial()) {
    on<LoadApiaries>(_onLoadApiaries);
    on<RefreshApiaries>(_onRefreshApiaries);
    on<AddApiary>(_onAddApiary);
    on<UpdateApiary>(_onUpdateApiary);
    on<DeleteApiary>(_onDeleteApiary);
  }

  Future<void> _onLoadApiaries(
      LoadApiaries event, Emitter<ApiariesState> emit) async {
    try {
      emit(ApiariesLoading());

      final apiaries = await _apiaryRepository.getApiaries();

      emit(ApiariesLoaded(apiaries: apiaries));
    } catch (e) {
      debugPrint('❌ Error loading apiaries: $e');
      emit(ApiariesError(message: 'Erreur lors du chargement des ruchers: $e'));
    }
  }

  Future<void> _onRefreshApiaries(
      RefreshApiaries event, Emitter<ApiariesState> emit) async {
    add(LoadApiaries());
  }

  Future<void> _onAddApiary(
      AddApiary event, Emitter<ApiariesState> emit) async {
    try {
      emit(ApiariesLoading());

      final apiaryId = await _apiaryRepository.addApiary(event.apiary);

      if (apiaryId != null) {
        // Si l'ajout a réussi, recharger la liste
        add(LoadApiaries());
        emit(ApiaryOperationSuccess(
            message: 'Rucher "${event.apiary.name}" ajouté avec succès'));
      } else {
        emit(ApiariesError(message: 'Erreur lors de l\'ajout du rucher'));
      }
    } catch (e) {
      debugPrint('❌ Error adding apiary: $e');
      emit(ApiariesError(message: 'Erreur lors de l\'ajout du rucher: $e'));
    }
  }

  Future<void> _onUpdateApiary(
      UpdateApiary event, Emitter<ApiariesState> emit) async {
    try {
      emit(ApiariesLoading());

      final success =
          await _apiaryRepository.updateApiary(event.id, event.apiary);

      if (success) {
        // Si la mise à jour a réussi, recharger la liste
        add(LoadApiaries());
        emit(ApiaryOperationSuccess(
            message: 'Rucher "${event.apiary.name}" mis à jour avec succès'));
      } else {
        emit(ApiariesError(message: 'Erreur lors de la mise à jour du rucher'));
      }
    } catch (e) {
      debugPrint('❌ Error updating apiary: $e');
      emit(ApiariesError(
          message: 'Erreur lors de la mise à jour du rucher: $e'));
    }
  }

  Future<void> _onDeleteApiary(
      DeleteApiary event, Emitter<ApiariesState> emit) async {
    try {
      emit(ApiariesLoading());

      final success = await _apiaryRepository.deleteApiary(event.id);

      if (success) {
        // Si la suppression a réussi, recharger la liste
        add(LoadApiaries());
        emit(ApiaryOperationSuccess(message: 'Rucher supprimé avec succès'));
      } else {
        emit(ApiariesError(message: 'Erreur lors de la suppression du rucher'));
      }
    } catch (e) {
      debugPrint('❌ Error deleting apiary: $e');
      emit(ApiariesError(
          message: 'Erreur lors de la suppression du rucher: $e'));
    }
  }
}
