import 'package:equatable/equatable.dart';
import '../../domain/usecases/create_hive.dart';

/// Événements du BLoC Hive
abstract class HiveEvent extends Equatable {
  const HiveEvent();

  @override
  List<Object?> get props => [];
}

/// Charger les ruches d'un rucher
class LoadApiaryHives extends HiveEvent {
  final String apiaryId;

  const LoadApiaryHives(this.apiaryId);

  @override
  List<Object?> get props => [apiaryId];
}

/// Créer une nouvelle ruche
class CreateHiveRequested extends HiveEvent {
  final CreateHiveParams params;

  const CreateHiveRequested(this.params);

  @override
  List<Object?> get props => [params];
}

/// Supprimer une ruche
class DeleteHiveRequested extends HiveEvent {
  final String hiveId;

  const DeleteHiveRequested(this.hiveId);

  @override
  List<Object?> get props => [hiveId];
}

/// Actualiser les ruches
class RefreshHives extends HiveEvent {
  const RefreshHives();
}
