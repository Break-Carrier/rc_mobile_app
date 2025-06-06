import 'package:equatable/equatable.dart';

/// États pour la gestion des rôles administrateur
abstract class AdminRoleState extends Equatable {
  const AdminRoleState();

  @override
  List<Object?> get props => [];
}

/// État initial
class AdminRoleInitial extends AdminRoleState {
  const AdminRoleInitial();
}

/// Chargement en cours
class AdminRoleLoading extends AdminRoleState {
  const AdminRoleLoading();
}

/// État avec informations sur les rôles admin
class AdminRoleLoaded extends AdminRoleState {
  final bool isCurrentUserAdmin;
  final bool hasAnyAdmins;

  const AdminRoleLoaded({
    required this.isCurrentUserAdmin,
    required this.hasAnyAdmins,
  });

  @override
  List<Object> get props => [isCurrentUserAdmin, hasAnyAdmins];
}

/// Erreur
class AdminRoleError extends AdminRoleState {
  final String message;

  const AdminRoleError({required this.message});

  @override
  List<Object> get props => [message];
}

/// Succès d'une action admin
class AdminRoleActionSuccess extends AdminRoleState {
  final String message;

  const AdminRoleActionSuccess({required this.message});

  @override
  List<Object> get props => [message];
}
