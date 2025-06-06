import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../apiary/domain/entities/apiary.dart';
import '../../../hive/domain/entities/hive.dart';
import '../../../apiary/domain/usecases/get_user_apiaries.dart';
import '../../../hive/domain/usecases/get_apiary_hives.dart';
import 'package:get_it/get_it.dart';

// Events
abstract class DashboardEvent {}

class LoadDashboardData extends DashboardEvent {}

class RefreshDashboardData extends DashboardEvent {}

// States
abstract class DashboardState {}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final List<Apiary> apiaries;
  final List<Hive> allHives;
  final Map<String, List<Hive>> hivesByApiary;

  DashboardLoaded({
    required this.apiaries,
    required this.allHives,
    required this.hivesByApiary,
  });

  DashboardLoaded copyWith({
    List<Apiary>? apiaries,
    List<Hive>? allHives,
    Map<String, List<Hive>>? hivesByApiary,
  }) {
    return DashboardLoaded(
      apiaries: apiaries ?? this.apiaries,
      allHives: allHives ?? this.allHives,
      hivesByApiary: hivesByApiary ?? this.hivesByApiary,
    );
  }
}

class DashboardError extends DashboardState {
  final String message;

  DashboardError({required this.message});
}

// BLoC
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetUserApiaries _getUserApiaries;

  DashboardBloc({
    GetUserApiaries? getUserApiaries,
  })  : _getUserApiaries = getUserApiaries ?? GetIt.instance<GetUserApiaries>(),
        super(DashboardInitial()) {
    on<LoadDashboardData>(_onLoadDashboardData);
    on<RefreshDashboardData>(_onRefreshDashboardData);
  }

  Future<void> _onLoadDashboardData(
      LoadDashboardData event, Emitter<DashboardState> emit) async {
    try {
      debugPrint('🐛 Chargement des données du dashboard');
      emit(DashboardLoading());

      // Récupérer les ruchers de l'utilisateur
      final apiariesResult = await _getUserApiaries();

      if (apiariesResult.error != null) {
        emit(DashboardError(
            message:
                'Erreur lors du chargement des ruchers: ${apiariesResult.error}'));
        return;
      }

      final apiaries = apiariesResult.result ?? [];
      debugPrint('🐛 ${apiaries.length} ruchers chargés');

      // Récupérer toutes les ruches via les ruchers pour éviter les problèmes d'index Firebase
      final allHives = <Hive>[];
      for (final apiary in apiaries) {
        final apiaryHivesResult =
            await GetIt.instance<GetApiaryHives>()(apiary.id);
        if (apiaryHivesResult.error == null &&
            apiaryHivesResult.result != null) {
          allHives.addAll(apiaryHivesResult.result!);
        }
      }
      debugPrint('🐛 ${allHives.length} ruches chargées via les ruchers');

      // Organiser les ruches par rucher
      final hivesByApiary = <String, List<Hive>>{};
      for (final apiary in apiaries) {
        hivesByApiary[apiary.id] =
            allHives.where((hive) => hive.apiaryId == apiary.id).toList();
      }

      emit(DashboardLoaded(
        apiaries: apiaries,
        allHives: allHives,
        hivesByApiary: hivesByApiary,
      ));
    } catch (e) {
      debugPrint('❌ Erreur lors du chargement du dashboard: $e');
      emit(
          DashboardError(message: 'Erreur lors du chargement des données: $e'));
    }
  }

  Future<void> _onRefreshDashboardData(
      RefreshDashboardData event, Emitter<DashboardState> emit) async {
    debugPrint('🐛 Rafraîchissement des données du dashboard');
    add(LoadDashboardData());
  }
}
