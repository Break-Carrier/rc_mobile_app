import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/services/admin_role_service.dart';
import 'admin_role_event.dart';
import 'admin_role_state.dart';

/// BLoC pour la gestion des rôles administrateur
///
/// Responsabilité unique : Orchestrer les opérations liées aux rôles admin
/// Sépare la logique UI de la logique métier
class AdminRoleBloc extends Bloc<AdminRoleEvent, AdminRoleState> {
  final AdminRoleService _adminRoleService;

  AdminRoleBloc({
    required AdminRoleService adminRoleService,
  })  : _adminRoleService = adminRoleService,
        super(const AdminRoleInitial()) {
    on<CheckAdminStatus>(_onCheckAdminStatus);
    on<BootstrapFirstAdmin>(_onBootstrapFirstAdmin);
    on<PromoteUserToAdmin>(_onPromoteUserToAdmin);
    on<DemoteUserFromAdmin>(_onDemoteUserFromAdmin);
  }

  /// Vérifier le statut administrateur de l'utilisateur
  Future<void> _onCheckAdminStatus(
    CheckAdminStatus event,
    Emitter<AdminRoleState> emit,
  ) async {
    emit(const AdminRoleLoading());

    try {
      // Vérification si l'utilisateur est admin
      final isAdminResult = await _adminRoleService.isUserAdmin(event.userId);

      if (isAdminResult is AdminRoleFailure) {
        emit(AdminRoleError(
          message: (isAdminResult as AdminRoleFailure).error.message,
        ));
        return;
      }

      final isCurrentUserAdmin = (isAdminResult as AdminRoleSuccess).data;

      // Pour l'instant, on considère qu'il y a des admins si l'utilisateur actuel l'est
      final hasAnyAdmins = isCurrentUserAdmin;

      emit(AdminRoleLoaded(
        isCurrentUserAdmin: isCurrentUserAdmin,
        hasAnyAdmins: hasAnyAdmins,
      ));
    } catch (error) {
      emit(AdminRoleError(
        message:
            'Erreur lors de la vérification du statut: ${error.toString()}',
      ));
    }
  }

  /// Bootstrap du premier administrateur
  Future<void> _onBootstrapFirstAdmin(
    BootstrapFirstAdmin event,
    Emitter<AdminRoleState> emit,
  ) async {
    emit(const AdminRoleLoading());

    try {
      final result = await _adminRoleService.bootstrapFirstAdmin(event.user);

      if (result is AdminRoleFailure) {
        emit(AdminRoleError(
          message: (result).error.message,
        ));
        return;
      }

      // Succès - actualiser le statut
      emit(const AdminRoleActionSuccess(
        message: 'Vous êtes maintenant administrateur !',
      ));

      // Recharger le statut
      add(CheckAdminStatus(userId: event.user.id));
    } catch (error) {
      emit(AdminRoleError(
        message: 'Erreur lors du bootstrap: ${error.toString()}',
      ));
    }
  }

  /// Promouvoir un utilisateur en administrateur
  Future<void> _onPromoteUserToAdmin(
    PromoteUserToAdmin event,
    Emitter<AdminRoleState> emit,
  ) async {
    emit(const AdminRoleLoading());

    try {
      final result = await _adminRoleService.promoteToAdmin(
        targetUserId: event.targetUserId,
        adminUserId: event.adminUserId,
        reason: event.reason,
      );

      if (result is AdminRoleFailure) {
        emit(AdminRoleError(
          message: (result).error.message,
        ));
        return;
      }

      emit(const AdminRoleActionSuccess(
        message: 'Utilisateur promu administrateur avec succès',
      ));

      // Recharger le statut
      add(CheckAdminStatus(userId: event.adminUserId));
    } catch (error) {
      emit(AdminRoleError(
        message: 'Erreur lors de la promotion: ${error.toString()}',
      ));
    }
  }

  /// Rétrograder un utilisateur administrateur
  Future<void> _onDemoteUserFromAdmin(
    DemoteUserFromAdmin event,
    Emitter<AdminRoleState> emit,
  ) async {
    emit(const AdminRoleLoading());

    try {
      final result = await _adminRoleService.demoteFromAdmin(
        targetUserId: event.targetUserId,
        adminUserId: event.adminUserId,
        reason: event.reason,
      );

      if (result is AdminRoleFailure) {
        emit(AdminRoleError(
          message: (result).error.message,
        ));
        return;
      }

      emit(const AdminRoleActionSuccess(
        message: 'Utilisateur rétrogradé avec succès',
      ));

      // Recharger le statut
      add(CheckAdminStatus(userId: event.adminUserId));
    } catch (error) {
      emit(AdminRoleError(
        message: 'Erreur lors de la rétrogradation: ${error.toString()}',
      ));
    }
  }
}
