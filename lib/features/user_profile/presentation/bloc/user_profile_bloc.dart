import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/usecases/get_user_profile.dart';
import '../../domain/usecases/soft_delete_user_profile.dart';
import '../../domain/usecases/restore_user_profile.dart';
import '../../../../core/error/app_error.dart';
import '../../../../core/entities/soft_deletable_entity.dart';

// Events
abstract class UserProfileEvent extends Equatable {
  const UserProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadCurrentUserProfile extends UserProfileEvent {
  const LoadCurrentUserProfile();
}

class LoadUserProfile extends UserProfileEvent {
  final String userId;

  const LoadUserProfile(this.userId);

  @override
  List<Object> get props => [userId];
}

class RefreshUserProfile extends UserProfileEvent {
  const RefreshUserProfile();
}

class RequestSoftDelete extends UserProfileEvent {
  final String userId;
  final String reason;
  final Map<String, dynamic>? metadata;

  const RequestSoftDelete({
    required this.userId,
    required this.reason,
    this.metadata,
  });

  @override
  List<Object?> get props => [userId, reason, metadata];
}

class RequestRestore extends UserProfileEvent {
  final String userId;
  final String reason;
  final Map<String, dynamic>? metadata;

  const RequestRestore({
    required this.userId,
    required this.reason,
    this.metadata,
  });

  @override
  List<Object?> get props => [userId, reason, metadata];
}

// States
abstract class UserProfileState extends Equatable {
  const UserProfileState();

  @override
  List<Object?> get props => [];
}

class UserProfileInitial extends UserProfileState {
  const UserProfileInitial();
}

class UserProfileLoading extends UserProfileState {
  const UserProfileLoading();
}

class UserProfileLoaded extends UserProfileState {
  final UserProfileEntity profile;

  const UserProfileLoaded(this.profile);

  @override
  List<Object> get props => [profile];
}

class UserProfileError extends UserProfileState {
  final AppError error;

  const UserProfileError(this.error);

  @override
  List<Object> get props => [error];
}

class UserProfileDeleting extends UserProfileState {
  final UserProfileEntity profile;

  const UserProfileDeleting(this.profile);

  @override
  List<Object> get props => [profile];
}

class UserProfileDeleted extends UserProfileState {
  final UserProfileEntity deletedProfile;

  const UserProfileDeleted(this.deletedProfile);

  @override
  List<Object> get props => [deletedProfile];
}

class UserProfileRestoring extends UserProfileState {
  final UserProfileEntity profile;

  const UserProfileRestoring(this.profile);

  @override
  List<Object> get props => [profile];
}

class UserProfileRestored extends UserProfileState {
  final UserProfileEntity restoredProfile;

  const UserProfileRestored(this.restoredProfile);

  @override
  List<Object> get props => [restoredProfile];
}

// BLoC
class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> {
  final GetUserProfile _getUserProfile;
  final SoftDeleteUserProfile _softDeleteUserProfile;
  final RestoreUserProfile _restoreUserProfile;

  String? _currentUserId;
  UserProfileEntity? _currentProfile;

  UserProfileBloc({
    required GetUserProfile getUserProfile,
    required SoftDeleteUserProfile softDeleteUserProfile,
    required RestoreUserProfile restoreUserProfile,
  })  : _getUserProfile = getUserProfile,
        _softDeleteUserProfile = softDeleteUserProfile,
        _restoreUserProfile = restoreUserProfile,
        super(const UserProfileInitial()) {
    on<LoadCurrentUserProfile>(_onLoadCurrentUserProfile);
    on<LoadUserProfile>(_onLoadUserProfile);
    on<RefreshUserProfile>(_onRefreshUserProfile);
    on<RequestSoftDelete>(_onRequestSoftDelete);
    on<RequestRestore>(_onRequestRestore);
  }

  // Getters utiles
  UserProfileEntity? get currentProfile => _currentProfile;
  bool get isCurrentUserAdmin => _currentProfile?.isAdmin ?? false;
  bool get canCurrentUserManageUsers =>
      _currentProfile?.canManageUsers ?? false;
  bool get canCurrentUserAccessBeekeeping =>
      _currentProfile?.canAccessBeekeepingFeatures ?? false;

  Future<void> _onLoadCurrentUserProfile(
    LoadCurrentUserProfile event,
    Emitter<UserProfileState> emit,
  ) async {
    emit(const UserProfileLoading());

    try {
      // TODO: Récupérer l'ID de l'utilisateur connecté depuis le service d'auth
      // const currentUserId = await _authService.getCurrentUserId();
      const currentUserId = 'current_user_id'; // Placeholder

      await _loadUserProfile(currentUserId, emit);
    } catch (error) {
      final appError = ErrorHandler.handleError(error);
      emit(UserProfileError(appError));
    }
  }

  Future<void> _onLoadUserProfile(
    LoadUserProfile event,
    Emitter<UserProfileState> emit,
  ) async {
    emit(const UserProfileLoading());
    await _loadUserProfile(event.userId, emit);
  }

  Future<void> _onRefreshUserProfile(
    RefreshUserProfile event,
    Emitter<UserProfileState> emit,
  ) async {
    if (_currentUserId != null) {
      await _loadUserProfile(_currentUserId!, emit, showLoading: false);
    }
  }

  Future<void> _loadUserProfile(
    String userId,
    Emitter<UserProfileState> emit, {
    bool showLoading = true,
  }) async {
    if (showLoading) {
      emit(const UserProfileLoading());
    }

    try {
      final result = await _getUserProfile.call(userId);

      switch (result) {
        case UserProfileSuccess(data: final profile):
          _currentUserId = userId;
          _currentProfile = profile;
          emit(UserProfileLoaded(profile));

        case UserProfileFailure(error: final error):
          emit(UserProfileError(error));
      }
    } catch (error) {
      final appError = ErrorHandler.handleError(error);
      emit(UserProfileError(appError));
    }
  }

  Future<void> _onRequestSoftDelete(
    RequestSoftDelete event,
    Emitter<UserProfileState> emit,
  ) async {
    // Vérification des permissions
    if (!canCurrentUserManageUsers) {
      emit(UserProfileError(
        const ValidationError(
          message: 'Permissions insuffisantes pour supprimer des profils',
          code: 'INSUFFICIENT_PERMISSIONS',
        ),
      ));
      return;
    }

    // État actuel pour l'interface
    if (state is UserProfileLoaded) {
      final currentProfile = (state as UserProfileLoaded).profile;
      emit(UserProfileDeleting(currentProfile));
    }

    try {
      final result = await _softDeleteUserProfile.call(
        userId: event.userId,
        deletedBy: _currentProfile!.userId,
        reason: event.reason,
        metadata: event.metadata,
      );

      switch (result) {
        case UserProfileSuccess(data: final deletedProfile):
          emit(UserProfileDeleted(deletedProfile));

          // Rechargement automatique si c'est le profil courant
          if (event.userId == _currentUserId) {
            _currentProfile = deletedProfile;
            emit(UserProfileLoaded(deletedProfile));
          }

        case UserProfileFailure(error: final error):
          // Retour à l'état précédent en cas d'erreur
          if (_currentProfile != null) {
            emit(UserProfileLoaded(_currentProfile!));
          }
          emit(UserProfileError(error));
      }
    } catch (error) {
      final appError = ErrorHandler.handleError(error);
      if (_currentProfile != null) {
        emit(UserProfileLoaded(_currentProfile!));
      }
      emit(UserProfileError(appError));
    }
  }

  Future<void> _onRequestRestore(
    RequestRestore event,
    Emitter<UserProfileState> emit,
  ) async {
    // Vérification des permissions
    if (!canCurrentUserManageUsers) {
      emit(UserProfileError(
        const ValidationError(
          message: 'Permissions insuffisantes pour restaurer des profils',
          code: 'INSUFFICIENT_PERMISSIONS',
        ),
      ));
      return;
    }

    // État actuel pour l'interface
    if (state is UserProfileLoaded) {
      final currentProfile = (state as UserProfileLoaded).profile;
      emit(UserProfileRestoring(currentProfile));
    }

    try {
      final result = await _restoreUserProfile.call(
        userId: event.userId,
        restoredBy: _currentProfile!.userId,
        reason: event.reason,
        metadata: event.metadata,
      );

      switch (result) {
        case UserProfileSuccess(data: final restoredProfile):
          emit(UserProfileRestored(restoredProfile));

          // Rechargement automatique si c'est le profil courant
          if (event.userId == _currentUserId) {
            _currentProfile = restoredProfile;
            emit(UserProfileLoaded(restoredProfile));
          }

        case UserProfileFailure(error: final error):
          // Retour à l'état précédent en cas d'erreur
          if (_currentProfile != null) {
            emit(UserProfileLoaded(_currentProfile!));
          }
          emit(UserProfileError(error));
      }
    } catch (error) {
      final appError = ErrorHandler.handleError(error);
      if (_currentProfile != null) {
        emit(UserProfileLoaded(_currentProfile!));
      }
      emit(UserProfileError(appError));
    }
  }

  // Méthodes utilitaires
  bool canDeleteUser(String targetUserId) {
    if (!canCurrentUserManageUsers) return false;
    if (_currentProfile?.userId == targetUserId)
      return false; // Pas d'auto-suppression
    return true;
  }

  bool canRestoreUser(UserProfileEntity targetProfile) {
    if (!canCurrentUserManageUsers) return false;
    if (!targetProfile.isDeleted) return false;
    if (!targetProfile.canBeRestored) return false;
    return true;
  }

  // Méthodes pour les actions rapides
  void deleteCurrentUser(String reason) {
    if (_currentUserId != null) {
      add(RequestSoftDelete(
        userId: _currentUserId!,
        reason: reason,
      ));
    }
  }

  void restoreCurrentUser(String reason) {
    if (_currentUserId != null) {
      add(RequestRestore(
        userId: _currentUserId!,
        reason: reason,
      ));
    }
  }

  void refreshCurrentProfile() {
    add(const RefreshUserProfile());
  }
}
