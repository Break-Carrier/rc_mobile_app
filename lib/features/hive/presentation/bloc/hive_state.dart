import 'package:equatable/equatable.dart';
import '../../domain/entities/hive.dart';

/// États du BLoC Hive
abstract class HiveState extends Equatable {
  const HiveState();

  @override
  List<Object?> get props => [];
}

/// État initial
class HiveInitial extends HiveState {}

/// État de chargement
class HiveLoading extends HiveState {}

/// État avec ruches chargées
class HiveLoaded extends HiveState {
  final List<Hive> hives;

  const HiveLoaded(this.hives);

  @override
  List<Object?> get props => [hives];
}

/// État d'erreur
class HiveError extends HiveState {
  final String message;

  const HiveError(this.message);

  @override
  List<Object?> get props => [message];
}
