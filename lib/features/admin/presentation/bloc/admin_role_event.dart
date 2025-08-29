import 'package:equatable/equatable.dart';
import '../../../auth/domain/entities/user_entity.dart';

/// Événements pour la gestion des rôles administrateur
abstract class AdminRoleEvent extends Equatable {
  const AdminRoleEvent();

  @override
  List<Object?> get props => [];
}

/// Vérifier si l'utilisateur actuel est administrateur
class CheckAdminStatus extends AdminRoleEvent {
  final String userId;

  const CheckAdminStatus({required this.userId});

  @override
  List<Object> get props => [userId];
}

/// Bootstrap du premier administrateur
class BootstrapFirstAdmin extends AdminRoleEvent {
  final UserEntity user;

  const BootstrapFirstAdmin({required this.user});

  @override
  List<Object> get props => [user];
}

/// Promouvoir un utilisateur en administrateur
class PromoteUserToAdmin extends AdminRoleEvent {
  final String targetUserId;
  final String adminUserId;
  final String? reason;

  const PromoteUserToAdmin({
    required this.targetUserId,
    required this.adminUserId,
    this.reason,
  });

  @override
  List<Object?> get props => [targetUserId, adminUserId, reason];
}

/// Rétrograder un administrateur
class DemoteUserFromAdmin extends AdminRoleEvent {
  final String targetUserId;
  final String adminUserId;
  final String? reason;

  const DemoteUserFromAdmin({
    required this.targetUserId,
    required this.adminUserId,
    this.reason,
  });

  @override
  List<Object?> get props => [targetUserId, adminUserId, reason];
}
