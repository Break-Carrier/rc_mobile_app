import 'package:flutter/material.dart';
import '../../../models/current_state.dart';
import '../../factories/service_factory.dart';
import '../../error/app_error.dart';
import '../../../core/config/app_config.dart';
import 'state_display_card.dart';

/// Widget optimisé qui gère les streams d'état d'une ruche
class StateStreamWidget extends StatefulWidget {
  final String hiveId;
  final VoidCallback? onRefresh;

  const StateStreamWidget({
    super.key,
    required this.hiveId,
    this.onRefresh,
  });

  @override
  State<StateStreamWidget> createState() => _StateStreamWidgetState();
}

class _StateStreamWidgetState extends State<StateStreamWidget> {
  late final coordinator = ServiceFactory.getHiveServiceCoordinator();

  @override
  void initState() {
    super.initState();
    _initializeHive();
  }

  @override
  void didUpdateWidget(StateStreamWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.hiveId != widget.hiveId) {
      _initializeHive();
    }
  }

  Future<void> _initializeHive() async {
    try {
      await coordinator.setActiveHive(widget.hiveId);
    } catch (e) {
      // L'erreur sera gérée par le StreamBuilder
      debugPrint('Error setting active hive: $e');
    }
  }

  Future<void> _handleRefresh() async {
    try {
      await coordinator.refreshAllData();
      if (widget.onRefresh != null) {
        widget.onRefresh!();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorHandler.getUserMessage(
              ErrorHandler.handleError(e),
            )),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<CurrentState?>(
      stream: coordinator.getCurrentStateStream(),
      builder: (context, snapshot) {
        return switch (snapshot.connectionState) {
          ConnectionState.none => const _LoadingState(),
          ConnectionState.waiting => const _LoadingState(),
          ConnectionState.active => _buildActiveState(snapshot),
          ConnectionState.done => _buildDoneState(snapshot),
        };
      },
    );
  }

  Widget _buildActiveState(AsyncSnapshot<CurrentState?> snapshot) {
    if (snapshot.hasError) {
      return _ErrorState(
        error: snapshot.error!,
        onRetry: _initializeHive,
      );
    }

    return StateDisplayCard(
      state: snapshot.data,
      onRefresh: _handleRefresh,
    );
  }

  Widget _buildDoneState(AsyncSnapshot<CurrentState?> snapshot) {
    if (snapshot.hasError) {
      return _ErrorState(
        error: snapshot.error!,
        onRetry: _initializeHive,
      );
    }

    return StateDisplayCard(
      state: snapshot.data,
      onRefresh: _handleRefresh,
    );
  }
}

/// Widget d'état de chargement
class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(AppConfig.defaultCardMargin),
      child: Padding(
        padding: EdgeInsets.all(AppConfig.defaultCardMargin * 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Chargement des données...',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget d'état d'erreur
class _ErrorState extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final appError = ErrorHandler.handleError(error);
    final userMessage = ErrorHandler.getUserMessage(appError);

    return Card(
      margin: EdgeInsets.all(AppConfig.defaultCardMargin),
      child: Padding(
        padding: EdgeInsets.all(AppConfig.defaultCardMargin),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Erreur de connexion',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              userMessage,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}
